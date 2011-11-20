function figData = localCreateFigure(vid, figTitle)
% Creates and initializes the figure.

% Create the figure and axes to plot into.
fig = figure('NumberTitle', 'off', 'MenuBar', 'none', ...
    'Name', figTitle, 'DeleteFcn', @localDeleteFig);

% Create a spot for the image object display.
nbands = get(vid, 'NumberOfBands');
res = get(vid, 'ROIPosition');
himage = imagesc(rand(res(4), res(3), nbands));

% Clean up the axes.
ax = get(himage, 'Parent');
set(ax, 'XTick', [], 'XTickLabel', [], 'YTick', [], 'YTickLabel', []);

set(fig, 'HandleVisibility', 'off');

% Store the figure data.
figData.hFigure = fig;
figData.hImage = himage;
% figData.hPatch = hPatch;
% figData.hLine = hLine;