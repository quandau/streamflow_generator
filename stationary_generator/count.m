delay = 1;  % In seconds
for k = 1:2
   tic
   % You computations here
  disp(datestr(now));
     pause(delay - toc);
end