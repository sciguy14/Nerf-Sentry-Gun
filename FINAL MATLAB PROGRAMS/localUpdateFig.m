function localUpdateFig(vid, figData, frame, background)
% Update the figure display with the latest data.

% If the figure has been destroyed on us, stop the acquisition.
if ~ishandle(figData.hFigure),
    stop(vid);
    return;
end

% Plot the results.
I = imabsdiff(frame, background);
set(figData.hImage, 'CData', I);

% Update the patch to the new level value.
graylevel = graythresh(I);
level = max(0, floor(100*graylevel));
xpatch = [0 level level 0];
set(figData.hPatch, 'XData', xpatch)
drawnow;