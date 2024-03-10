function [synthetic, station, outcome] = csvexport(sites)
for n = 1:size(sites,2)
    station{n} = sites{n}(1:(length(sites{n})-4));
end
for t = 1:size(sites,2)
    synthetic{t}= readoutput(t, sites)';
end
synthetic = cell2mat(synthetic);
outcome = array2table(synthetic);
outcome.Properties.VariableNames = station;
writetable(outcome,'./../validation/synthetic/synth_gen_daily_1000ys.csv');

end