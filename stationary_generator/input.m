function varargout = input(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @input_OpeningFcn, ...
    'gui_OutputFcn',  @input_OutputFcn, ...
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
function input_OpeningFcn(hObject, ~, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
function varargout = input_OutputFcn(~, ~, handles)
varargout{1} = handles.output;
movegui(gcf,'center');
function gen_Callback(~, ~, ~)
function gen_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function year_Callback(~, ~, ~)
function year_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function simulate_Callback(~, ~, handles)
datadir = './../data/';
name = dir('../data/');
filename = {name.name};
sites = filename(3:end);
realisation =  str2num(get(handles.gen,'string'));
years = str2num(get(handles.year,'string'));
clean_data; clc;
save('para.mat','realisation','sites','years')
try
    user_response = modaldlg('Reset','Confirm Close');
    switch user_response
        case 'No'
        case 'Yes'
            delete(gcf);
            h = msgbox({'Seat back !! Simulation is starting ... '; 'Result will automatically appear when simulation completed'});
            th = findall(h, 'Type', 'Text');
            th.FontSize = 10;
            deltaWidth = sum(th.Extent([1,3]))-h.Position(3) + th.Extent(1);
            deltaHeight = sum(th.Extent([2,4]))-h.Position(4) + 10;
            h.Position([3,4]) = h.Position([3,4]) + [deltaWidth, deltaHeight];
            h.Resize = 'off';
            script;clc;
            delete(gcf);
            vali;
    end
catch
    f = msgbox('Something goes wrong !!');
end
function cancel_Callback(~, ~, ~)
delete(gcf);
function result_Callback(~, ~, ~)
delete(gcf);
vali;
function import_Callback(~, ~, ~)
delete(gcf);
browser;
