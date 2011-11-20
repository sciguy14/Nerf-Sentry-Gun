function manualchanger(source, eventdata)

state = dlmread('data/manual.txt');

if state == 0
    dlmwrite('data/manual.txt',1);
else
    dlmwrite('data/manual.txt',0);
end
