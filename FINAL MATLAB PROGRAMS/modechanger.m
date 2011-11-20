function modechanger(source,eventdata,chan)

disp(source);
disp([eventdata.EventName,'  ',... 
     get(eventdata.OldValue,'String'),'  ', ...
     get(eventdata.NewValue,'String')]);
disp(get(get(source,'SelectedObject'),'String'));
if strcmp((get(eventdata.NewValue,'String')), 'Authentication Mode')
    dlmwrite('data/auth.txt',1);
    dlmwrite('data/manual.txt',0);
    dlmwrite('data/log.txt',1);
elseif strcmp((get(eventdata.NewValue,'String')), 'Freefire Mode')
    dlmwrite('data/auth.txt',0);
    dlmwrite('data/manual.txt',0);
    dlmwrite('data/log.txt',0);
end

if strcmp((get(eventdata.NewValue,'String')), 'Panic Mode')
    % Panic here
    siren = wavread('sounds/siren.wav');
    wavplay(siren, 22000);
    control(chan,1,1);
    turnGunTo(-200,0,chan);
    turnGunTo(400,0,chan);
    turnGunTo(-600,0,chan);
    turnGunTo(400,0,chan);
    turnGunTo(-500,0,chan);
    turnGunTo(600,0,chan);
    turnGunTo(-300,0,chan);
    turnGunTo(400,0,chan);
    turnGunTo(-500,0,chan);
    turnGunTo(300,0,chan);
    turnGunTo(-400,0,chan);
    control(chan,1,0);
    dlmwrite('data/auth.txt',0);
    dlmwrite('data/manual.txt',0);
end

if strcmp((get(eventdata.NewValue,'String')), 'Manual Mode')
    dlmwrite('data/manual.txt',1);
    dlmwrite('data/auth.txt',0);
end