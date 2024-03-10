
Qdaily = load('./../data/Qdaily.txt');
num_realizations = [100, realisation];
num_years = [100, years];
Nyears = size(Qdaily,1)/365;
Nsites = size(Qdaily,2);
dimensions = {'-100x100','-1000x1'};
mkdir('./../validation/synthetic');
for k=1:length(num_realizations)
    Qd_cg = combined_generator(Qdaily, num_realizations(k), num_years(k) );
    % write simulated data to file
    for i=1:Nsites
        q_ = [];
        for j=1:num_realizations(k)
            qi = nan(365*num_years(k),1);
            qi(1:size(Qd_cg,2)) = Qd_cg(j,:,i)';
            q_ = [q_ reshape(qi,365,num_years(k))];
        end
        Qd2(:,i) = reshape(q_(:),[],1);
        saveQ = reshape(Qd2(:,i), num_years(k)*365, num_realizations(k))';
        dlmwrite(['./../validation/synthetic/' sites{i}(1:(length(sites{i})-4)) dimensions{k} '-daily.mat'], saveQ);
    end
    synMonthlyQ = convert_data_to_monthly(Qd2);
    for i=1:Nsites
        saveMonthlyQ = reshape(synMonthlyQ{i}',12*num_years(k),num_realizations(k))';
        dlmwrite(['./../validation/synthetic/' sites{i}(1:(length(sites{i})-4)) dimensions{k} '-monthly.csv'], saveMonthlyQ);
    end
    dlmwrite(['./../validation/synthetic/Qdaily' dimensions{k} '.csv'], Qd2);
    clear Qd2;
end
