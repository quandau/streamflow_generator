for i=1:length(sites)
    M{i} = load([datadir  sites{i}]);
end
leaps = 60:365*3+366:365*(2008-1900+1)+ceil(2008-1900)/4;
all = 1:1:365*(2008-1900+1)+ceil(2008-1900)/4+1;
non_leaps = setdiff(all,leaps);
Qfinal = zeros(length(non_leaps),length(sites));
for i=1:length(sites)
    Q = M{i};
    Qfinal(:,i) = Q(non_leaps);
end
dlmwrite('./../data/Qdaily.txt', Qfinal, ' ');
Qfinal_monthly = convert_data_to_monthly(Qfinal);
mkdir('./../validation/historical');
for i=1:length(sites)
   q_nx365 = reshape(Qfinal(:,i),365, [])';
   dlmwrite(['./../validation/historical/' sites{i}(1:(length(sites{i})-4)) '-daily.csv'], q_nx365);
   dlmwrite(['./../validation/historical/' sites{i}(1:(length(sites{i})-4)) '-monthly.csv'], Qfinal_monthly{i}); 
end
