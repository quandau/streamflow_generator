
function [ mean_output] = readoutput(time, sites)
filename{time} = sites{time}(1:(length(sites{time})-4));
mean_output = mean(load(['./../validation/synthetic/' char(filename{time}) '-1000x1-daily.mat'], '-ascii'),1);
end

