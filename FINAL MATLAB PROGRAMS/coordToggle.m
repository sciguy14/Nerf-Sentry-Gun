function coordToggle

state = dlmread('data/coords.txt');

if state == 1
    dlmwrite('data/coords.txt',0);
else
    dlmwrite('data/coords.txt',1);
end