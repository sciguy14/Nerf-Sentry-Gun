function soundchanger(source,eventdata)

disp(source);
disp([eventdata.EventName,'  ',... 
     get(eventdata.OldValue,'String'),'  ', ...
     get(eventdata.NewValue,'String')]);
disp(get(get(source,'SelectedObject'),'String'));
if strcmp((get(eventdata.NewValue,'String')), 'Off')
    dlmwrite('data/sounds.txt',0);
else
    dlmwrite('data/sounds.txt',1);
end