function turnGunTo(point,gunPos,chan)
% 2 means left, 3 means right
% 100 pixels = 0.5 sec

done = false;
turn = abs(point - gunPos);
time = .005*sqrt(45*turn);
if (point < gunPos)
    signal = 3;
else
    signal = 2;
end

tic;
control(chan,signal,1);
while done == false
    num = toc;
    if num >= time
        done = true;
        control(chan,signal,0);
    end
end

            
    