function motionPauser

pause = dlmread('data/pause.txt');
if pause == 0
    dlmwrite('data/pause.txt',1);
else
    dlmwrite('data/pause.txt',0);
end