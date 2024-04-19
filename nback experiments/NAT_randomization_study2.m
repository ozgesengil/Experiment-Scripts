% run this code to randomly pic neverTs and alwaysTs once for a participant
% the output should be written on relevant places in experimental programs, (both practice and
% main), and metacognition block.

rand('seed', sum(100 * clock));
a=1;
while a==1
    piclist=1:22;
    alwaysTs=randsample(piclist,2,false);
    neverTs=randsample(piclist,2,false);

    combinedTs=[alwaysTs,neverTs];
    if length(unique(combinedTs))~=4
        a=1;
    elseif length(unique(combinedTs))==4
        a=2;
    end

end
piclist=setxor(piclist,combinedTs);
