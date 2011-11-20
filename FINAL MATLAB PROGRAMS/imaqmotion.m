function imaqmotion(obj)

chan = digitalControl;

% Unique name for the UI.
appTitle = 'Image Acquisition Motion Detector';

% Initially start in active mode.
dlmwrite('log.txt',1);
dlmwrite('framepos.txt',0);
dlmwrite('gunpos.txt',0);
dlmwrite('turn.txt',0);

try
    % Make sure we've stopped so we can set up the acquisition.
    stop(obj);
    
    % Configure the video input object to continuously acquire data.
    triggerconfig(obj, 'manual');
    set(obj, 'Tag', appTitle, 'FramesAcquiredFcnCount', 1, ...
        'TimerFcn', {@localFrameCallback, chan}, 'TimerPeriod', 0.1);
    
    % Check to see if this object already has an associated figure.
    % Otherwise create a new one.
    ud = get(obj, 'UserData');
    if ~isempty(ud) && isstruct(ud) && isfield(ud, 'figureHandles') ...
            && ishandle(ud.figureHandles.hFigure)
        appdata.figureHandles = ud.figureHandles;
        figure(appdata.figureHandles.hFigure)
    else
        appdata.figureHandles = localCreateFigure(obj, appTitle);
    end

    % Store the application data the video input object needs.
    appdata.background = [];
    obj.UserData = appdata;

    % Start the acquisition.
    start(obj);

    % Avoid peekdata warnings in case it takes too long to return a frame.
    warning off imaq:peekdata:tooManyFramesRequested
catch
    % Error gracefully.
    error('MATLAB:imaqmotion:error', ...
    sprintf('Random error.\n%s', lasterr))
end

%-------------------------------------
function localFrameCallback(vid, event, chan)
% Executed by the videoinput object callback to update the image display.

% If the object has been deleted on us, or we're no longer running, do nothing.
if ~isvalid(vid) || ~isrunning(vid)
    return;
end

% Access our application data.
appdata = get(vid, 'UserData');
background = appdata.background;

% Peekdata to access current frame
frame = peekdata(vid, 1);
if isempty(frame),
    return;
end
flushdata(vid);

% First time through, a background image will be needed.
if isempty(background),
    background = getsnapshot(vid);
end

% Update the figure and our application data.
localUpdateFig(vid, appdata.figureHandles, frame, background, chan);
appdata.background = frame;
set(vid, 'UserData', appdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localUpdateFig(vid, figData, frame, background, chan)
% Update the figure display with the latest data.

% If the figure has been destroyed on us, stop the acquisition.
if ~ishandle(figData.hFigure),
    stop(vid);
    return;
end

% Plot the results.
I = abs(double(rgb2gray(frame)) - double(rgb2gray(background)));
[nrows, ncols] = size(I);
It = zeros(nrows, ncols);
totalrows = 1;
totalcols = 1;
trows = 1;
tcols = 1;
for i = 1:nrows
    for j = 1:ncols
        if I(i,j) > 80
            It(i,j) = 1;
            totalrows = totalrows + i;
            totalcols = totalcols + j;
            trows = trows + 1;
            tcols = tcols + 1;
        end
    end
end

x = round(totalrows/trows);
y = round(totalcols/tcols);
log = dlmread('log.txt');
if (trows < 35) || ((x == 1) && (y == 1))
    control(chan,1,0);
else
    if log == 0
        control(chan,1,1);
    end
end

framepos = dlmread('framepos.txt');
if (x > 1) && (y > 1) && (log == 1) && (framepos > 100) && (dlmread('auth.txt') == 1)
    fprintf('Display badge or be terminated. \n');
    control(chan,1,0);
    prompt = wavread('prompt.wav');
    wavplay(prompt, 22000);
    dlmwrite('log.txt',0);
    badge = imread('badge.jpg');
    security_picture = getsnapshot(vid);
    det = detect_object(rgb2gray(badge), rgb2gray(security_picture));
    if det == true
        auth = wavread('auth.wav');
        fprintf('Authorized.\n');
        wavplay(auth, 22000);
    else
        fprintf('You will be terminated.\n');
        term = wavread('term.wav');
        wavplay(term, 22000);
        control(chan,1,1);
    end
    ftp_upload(security_picture, det);
else
    dlmwrite('framepos.txt',framepos + 1);
end

numTurns = dlmread('turn.txt');
gunPos = dlmread('gunpos.txt');
if numTurns == 2
    if (x > 1)
        turnGunTo(x,gunPos,chan);
        dlmwrite('gunpos.txt',x);
    end
    dlmwrite('turn.txt',0);
else
    dlmwrite('turn.txt',numTurns+1);
end

for i = (x):(x+3)
    for j = (y):(y+3)
        I(i,j) = 255;
    end
end

for j = 1:10
    I(j,gunPos+1) = 200;
end

set(figData.hImage, 'CData', I);

% % Update the patch to the new level value.
% graylevel = graythresh(I);
% level = max(0, floor(100*graylevel));
% xpatch = [0 level level 0];
% set(figData.hPatch, 'XData', xpatch)
% drawnow;

%-------------------------------------
function localDeleteFig(fig, event)

% Reset peekdata warnings.
warning on imaq:peekdata:tooManyFramesRequested

%----------------------------------------
function figData = localCreateFigure(vid, figTitle)
% Creates and initializes the figure.

% Create the figure and axes to plot into.
fig = figure('NumberTitle', 'off', 'MenuBar', 'none', ...
    'Name', figTitle, 'DeleteFcn', @localDeleteFig);

set(fig, 'Pointer', 'fullcrosshair');

uicontrol(fig, 'String', 'Close', 'Callback', 'close(gcf)', 'Position', [100 10 50 30]);
h = uibuttongroup('visible','off','Position',[0 0 .2 1]);
u0 = uicontrol(fig,'Style','Radio','String','Authentication Mode',...
    'pos',[175 20 150 15],'parent',h,'HandleVisibility','off');
u1 = uicontrol(fig,'Style','Radio','String','Freefire Mode',...
    'pos',[175 5 150 15],'parent',h,'HandleVisibility','off');
set(h,'SelectionChangeFcn',@modechanger);
set(h,'SelectedObject',u0);  % No selection
dlmwrite('auth.txt',1);
set(h,'Visible','on');


% Create a spot for the image object display.
nbands = get(vid, 'NumberOfBands');
res = get(vid, 'ROIPosition');
himage = imagesc(rand(res(4), res(3), nbands));

% Clean up the axes.
ax = get(himage, 'Parent');
set(ax, 'XTick', [], 'XTickLabel', [], 'YTick', [], 'YTickLabel', []);

% Create the motion detection bar before hiding the figure.
% [hPatch, hLine] = localCreateBar(ax);
% set(fig, 'HandleVisibility', 'off');

% Store the figure data.
figData.hFigure = fig;
figData.hImage = himage;
% figData.hPatch = hPatch;
% figData.hLine = hLine;

%------------------------------------------
function [hPatch, hLine] = localCreateBar(imAxes)
% Creates and initializes the bar display.

% Configure the bar axes.
barAxes = axes('XLim',[0 100], 'YLim',[0 1], 'Box','on', ...
    'Units','Points', 'XTickMode','manual', 'YTickMode','manual', ...
    'XTick',[], 'YTick',[], 'XTickLabelMode', 'manual', ...
    'XTickLabel', [], 'YTickLabelMode', 'manual', 'YTickLabel', []);

% Align the bar axes with the image axes.
oldImUnits = get(imAxes, 'Units');
set(imAxes, 'Units', 'points')
imPos = get(imAxes, 'Position');
set(imAxes, 'Units', oldImUnits)

oldRootUnits = get(0,'Units');
set(0, 'Units', 'points');
screenSize = get(0, 'ScreenSize');
set(0, 'Units', oldRootUnits);

pointsPerPixel = 72/get(0, 'ScreenPixelsPerInch');
width = 360 * pointsPerPixel;
height = 75 * pointsPerPixel;
pos = [screenSize(3)/2-width/2 screenSize(4)/2-height/2 width height];
axPos = [1 .3 .9 .2] .* [imPos(1), pos(4), pos(3:4)];
set(barAxes, 'Position', axPos)

% Create the default patch/line used to mark the level.
xpatch = [0 0 0 0];
ypatch = [0 0 1 1];
hPatch = patch(xpatch, ypatch, 'r', 'EdgeColor', 'r', 'EraseMode', 'none');

xline = [100 0 0 100 100];
yline = [0 0 1 1 0];
hLine = line(xline, yline, 'EraseMode', 'none');
set(hLine, 'Color', get(gca, 'XColor'));