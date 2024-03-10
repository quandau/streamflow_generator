function varargout = vali(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @vali_OpeningFcn, ...
                   'gui_OutputFcn',  @vali_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function vali_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
set(handles.monthly,'visible','off');
set(handles.quantile,'visible','off');
set(handles.axes3,'visible','off');
set(handles.axes4,'visible','off');


function varargout = vali_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;
movegui(gcf,'center');
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
function popupmenu1_Callback(hObject, ~, handles)
try
    load('para.mat');
    for t = 1:size(sites,2)
        [synthetic{t} historical{t}] = readoutput(t, sites);
    end    
    synth = cell2mat(synthetic);
    gen = str2num(get(handles.gen,'string'));
    
    contents = get(hObject,'Value');
    switch contents
        case 1
        case 2
            for i = 1
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen)));
                    set(handles.s_mean,'String',mean(synth(:,gen)));
                    set(handles.s_stdv,'String',std(synth(:,gen)));
                    set(handles.s_min,'String',min(synth(:,gen)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
                
            end
        case 3
            for i = 2
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 4
            for i = 3
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*2);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*2)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*2)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*2)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*2)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 5
            for i = 4
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*3);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*3)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*3)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*3)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*3)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 6
            for i = 5
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*4);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*4)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*4)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*4)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*4)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 7
            for i = 6
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*5);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*5)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*5)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*5)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*5)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 8
            for i = 7
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*6);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*6)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*6)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*6)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*6)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 9
            for i = 8
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*7);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*7)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*7)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*7)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*7)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 10
            for i = 9
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*8);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*8)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*8)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*8)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*8)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 11
            for i = 10
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*9);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*9)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*9)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*9)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*9)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 12
            for i = 11
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*10);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*10)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*10)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*10)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*10)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 13
            for i = 12
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*11);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*11)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*11)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*11)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*11)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 14
            for i = 13
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*12);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*12)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*12)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*12)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*12)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 15
            for i = 14
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*13);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*13)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*13)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*13)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*13)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 16
            for i = 15
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*14);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*14)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*14)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*14)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*14)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 17
            for i = 16
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*15);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*15)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*15)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*15)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*15)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
            
        case 18
            for i = 17
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*16);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*16)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*16)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*16)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*16)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 19
            for i = 18
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*17);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*17)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*17)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*17)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*17)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 20
            for i = 19
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*18);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*18)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*18)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*18)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*18)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 21
            for i = 20
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*19);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*19)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*19)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*19)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*19)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 22
            for i = 21
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*20);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*20)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*20)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*20)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*20)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 23
            for i = 22
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*21);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*21)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*21)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*21)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*21)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 24
            for i = 23
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*22);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*22)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*22)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*22)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*22)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 25
            for i = 24
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*23);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*23)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*23)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*23)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*23)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        case 26
            for i = 25
                if gen <= realisation
                    name_station = sites{i}(1:(length(sites{i})-4));
                    set(handles.station,'String',name_station);
                    his = cell2mat(historical(i));
                    his_month = convert_data_to_monthly(his);
                    his_month_mat = mean(cell2mat(his_month),1);
                    sim = synth(:,gen+realisation*24);
                    sim_month = convert_data_to_monthly(sim);
                    sim_month_mat = mean(cell2mat(sim_month));
                    set(handles.s_max,'String',max(synth(:,gen+realisation*24)));
                    set(handles.s_mean,'String',mean(synth(:,gen+realisation*24)));
                    set(handles.s_stdv,'String',std(synth(:,gen+realisation*24)));
                    set(handles.s_min,'String',min(synth(:,gen+realisation*24)));
                    set(handles.h_max,'String',max(cell2mat(historical(i))));
                    set(handles.h_mean,'String',mean(cell2mat(historical(i))));
                    set(handles.h_stdv,'String',std(cell2mat(historical(i))));
                    set(handles.h_min,'String',min(cell2mat(historical(i))));
                    lm = fitlm(his_month_mat,sim_month_mat);
                    [h_month p_month] = ttest2(his_month_mat,sim_month_mat);
                    if h_month ==1;
                        null_hypo_month = 'Significance';
                    else h_month == 0;
                        null_hypo_month = 'Insignificance';
                    end
                    if length(his)>length(sim);
                        [h_day p_day] = ttest2(his(1:length(sim),1), sim);
                        if h_day ==1
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    else
                        [h_day p_day] = ttest2(his, sim(1:length(his)));
                        if h_day ==1;
                            null_hypo_day = 'Significance';
                        else h_day == 0;
                            null_hypo_day = 'Insignificance';
                        end
                    end
                    set(handles.p_m,'String',p_month);
                    set(handles.p_d,'String',p_day);
                    set(handles.m_null,'String',null_hypo_month);
                    set(handles.d_null,'String',null_hypo_day);
                    set(handles.r2,'String',lm.Rsquared.Ordinary);
                    axes(handles.monthly);
                    boxplot(cell2mat(his_month)), hold on;
                    boxplot(cell2mat(sim_month)), hold off;
                    title('Monthly comparison'); ylabel('Total monthly streamflow(m^3/s)'); xlabel('Month');hold off;
                    axes(handles.quantile);
                    if length(his)>length(sim);
                        qqplot(his(1:length(sim),1), sim) ;
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    else
                        qqplot(his, sim(1:length(his)));
                        lm_daily = fitlm(his(1:length(sim),1), sim);
                        set(handles.r2_daily,'String',lm_daily.Rsquared.Ordinary);
                    end
                    title('Quantile-Quantile Plot for daily streamflow'); xlabel('Synthetic'); ylabel('Historical');
                    axes(handles.axes3);
                    if length(his)>length(sim);
                        probplot('lognormal',[his(1:length(sim),1) sim]) ;
                    else
                        probplot('lognormal',[his sim(1:length(his),1)]) ;
                    end
                    legend('Historical', 'Synthetic', 'Location','northwest'); h = zoom; h.Motion = 'horizontal'; h.Enable = 'on';
                    axes(handles.axes4);
                    stdv_his = std(his);
                    cfu_his = 2/sqrt(length(his));
                    cfl_his = -2/sqrt(length(his));
                    [normalizedACF_sim, lags] = autocorr(sim,35);
                    stem(lags,normalizedACF_sim); hold on;
                    [normalizedACF_his, lags] = autocorr(his,35);
                    stem(lags,normalizedACF_his);
                    plot(cfl_his+normalizedACF_his, 'r', 'LineWidth', 1);
                    plot(cfu_his+normalizedACF_his,'r','LineWidth', 1.4);
                    legend('Synthetic','Historical','Lower 95% conf','Lower 95% conf');
                    title('Autocorrelation'); xlabel('Lag (days)'); hold off;
                    r2_d = str2num(get(handles.r2_daily,'string'));
                    if r2_d > 0.15;
                        conclude = 'This prediction is VERY GOOD';
                        suggest = 'Highly recommended this prediction';
                    elseif r2_d < 0.15 && r2_d > 0.09;
                        conclude = 'This prediction is Acceptable';
                        suggest = 'Possible to use this prediction';
                    else r2_d < 0.09;
                        conclude = 'This prediction is BAD';
                        suggest = 'Please selects other Gen number & try again';
                    end
                    set(handles.remark,'String', conclude);
                    set(handles.subremark,'String', suggest);
                else
                    f = msgbox('Your selected Gen number excced number of realisation', 'Error','error');
                end
                 csvwrite('../validation/synthetic/selected_synthetic.csv', sim);
            end
        otherwise
    end
catch
    f = msgbox({'Error to read data on this station','Have you completed with the simulation yet?','You may check at both Input & Output data'}, 'Error','error');
end
function popupmenu1_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function gen_Callback(~, ~, ~)
function quantile_CreateFcn(~, ~, ~)
function gen_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r2_CreateFcn(~, ~, ~)
function r2_daily_CreateFcn(~, ~, ~)
function remark_CreateFcn(~, ~, ~)
function resimulate_Callback(~, ~, ~)
function pushbutton2_Callback(~, ~, ~)
delete(gcf);
input;
function export_Callback(~, ~, ~)
try
 winopen('../validation/synthetic/selected_synthetic.csv');
catch
 msgbox({'Something goes wrong with the data','Make sure you have selected at least 1 station'} ,'Error','error');  
end