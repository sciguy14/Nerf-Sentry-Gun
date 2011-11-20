function colormapchanger(source,eventdata)

disp(source);
disp([eventdata.EventName,'  ',... 
     get(eventdata.OldValue,'String'),'  ', ...
     get(eventdata.NewValue,'String')]);
disp(get(get(source,'SelectedObject'),'String'));
if strcmp((get(eventdata.NewValue,'String')), 'Jet')
    colormap(jet);
elseif strcmp((get(eventdata.NewValue,'String')), 'HSV')
    colormap(hsv);
elseif strcmp((get(eventdata.NewValue,'String')), 'Heatmap')
    colormap(hot);
elseif strcmp((get(eventdata.NewValue,'String')), 'Grayscale')
    colormap(gray);
end