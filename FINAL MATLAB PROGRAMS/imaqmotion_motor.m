function imaqmotion_motor(obj)

% Unique name for the UI.
appTitle = 'Image Acquisition Motion Detector';

% Initially start in active mode.
dlmwrite('data/log.txt',1);
dlmwrite('data/auth.txt',0);
dlmwrite('data/framepos.txt',0);
dlmwrite('data/gunpos.txt',160);
dlmwrite('data/turn.txt',0);
dlmwrite('data/x1.txt',160);
dlmwrite('data/x2.txt',160);
dlmwrite('data/x3.txt',160);
dlmwrite('data/x4.txt',160);
dlmwrite('data/pause.txt',0);
dlmwrite('data/coords.txt',1);
dlmwrite('data/sounds.txt',0);
dlmwrite('data/soundTurn.txt',0);
dlmwrite('data/manual.txt',0);

try
    chan = digitalControl;
    keypress(chan);
catch
    fprintf('No gun attached, static mode');
end

try
    % Make sure we've stopped so we can set up the acquisition.
    stop(obj);
    
    % Configure the video input object to continuously acquire data.
    triggerconfig(obj, 'manual');
    set(obj, 'Tag', appTitle, 'FramesAcquiredFcnCount', 1, ...
        'TimerFcn', {@localFrameCallbackStatic, chan}, 'TimerPeriod', 0.1);
    
    % Check to see if this object already has an associated figure.
    % Otherwise create a new one.
    ud = get(obj, 'UserData');
    if ~isempty(ud) && isstruct(ud) && isfield(ud, 'figureHandles') ...
            && ishandle(ud.figureHandles.hFigure)
        appdata.figureHandles = ud.figureHandles;
        figure(appdata.figureHandles.hFigure)
    else
        appdata.figureHandles = localCreateFigureStatic(obj, appTitle);
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
function localFrameCallbackStatic(vid, event, chan)
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
localUpdateFigStatic(vid, appdata.figureHandles, frame, background, chan);
appdata.background = frame;
set(vid, 'UserData', appdata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localUpdateFigStatic(vid, figData, frame, background, chan)
% Update the figure display with the latest data.

% If the figure has been destroyed on us, stop the acquisition.
if ~ishandle(figData.hFigure),
    stop(vid);
    return;
end

% Check if paused.
pause = dlmread('data/pause.txt');
coords = dlmread('data/coords.txt');
if pause == 0

% Plot the results.
I = abs(double(rgb2gray(frame)) - double(rgb2gray(background)));
totalrows = 1;
trows = 1;
for i = 1:240
    for j = 1:320
        if I(i,j) > 70
            totalrows = totalrows + j;
            trows = trows + 1;
        end
    end
end
x1 = dlmread('data/x1.txt');
x2 = dlmread('data/x2.txt');
x3 = dlmread('data/x3.txt');
x4 = dlmread('data/x4.txt');
recent = (x1+x2+x3+x4)/4;
if (trows < 15)
    x = round(recent);
else
    x = round(totalrows/trows);
end
dlmwrite('data/x1.txt',x2);
dlmwrite('data/x2.txt',x3);
dlmwrite('data/x3.txt',x4);
dlmwrite('data/x4.txt',x);
if abs(x-round(recent)) > 40
    x = round(recent);
end
log = dlmread('data/log.txt');

framepos = dlmread('data/framepos.txt');

if trows < 35
    control(chan,1,0);
elseif trows >= 35 && log == 0
    control(chan,1,1);
end
if (x > 1) && (log == 1) && (framepos > 100) && (dlmread('data/auth.txt') == 1) && (trows > 35)
    control(chan,1,0);
    fprintf('Display badge or be terminated. \n');
    prompt = wavread('sounds/prompt.wav');
    wavplay(prompt, 22000);
    dlmwrite('data/log.txt',0);
    badge = imread('images/badge.jpg');
    security_picture = getsnapshot(vid);
    det = detect_object(rgb2gray(badge), rgb2gray(security_picture));
    if det == true
        auth = wavread('sounds/auth.wav');
        fprintf('Authorized.\n');
        wavplay(auth, 22000);
    else
        fprintf('You will be terminated.\n');
        term = wavread('sounds/term.wav');
        wavplay(term, 22000);
        control(chan,1,1);
    end
    ftp_upload(security_picture, det);
else
    dlmwrite('data/framepos.txt',framepos + 1);
end

numTurns = dlmread('data/turn.txt');
gunPos = dlmread('data/gunpos.txt');
if numTurns == 4
    if (x > 1)
        dlmwrite('data/gunpos.txt',x);
        if abs(x-gunPos) > 15
            turnGunTo(x,gunPos,chan);
        end
    end
    dlmwrite('data/turn.txt',0);
else
    dlmwrite('data/turn.txt',numTurns+1);
end

soundTurn = dlmread('data/soundTurn.txt');
if (dlmread('data/sounds.txt') == 1) && (trows > 700) && (soundTurn > 4)
    num = round(rand(1)*10);
    if num > 8 || num == 0
        num = 1;
    end
    file = ['sounds/ltsaberswing0',int2str(num),'.wav'];
    saber = wavread(file);
    wavplay(saber, 22000);
    dlmwrite('data/soundTurn.txt',0);
else
    dlmwrite('data/soundTurn.txt', soundTurn + 1);
end

if coords == 1
    for j = 1:10
        I(j,x) = 255;
    end

    for j = 1:10
        I(j,gunPos+1) = 200;
    end
end

set(figData.hImage, 'CData', I);

end

% % Update the patch to the new level value.
% graylevel = graythresh(I);
% level = max(0, floor(100*graylevel));
% xpatch = [0 level level 0];
% set(figData.hPatch, 'XData', xpatch)
% drawnow;

%-------------------------------------
function localDeleteFigStatic(fig, event)

% Reset peekdata warnings.
warning on imaq:peekdata:tooManyFramesRequested

%----------------------------------------
function figData = localCreateFigureStatic(vid, figTitle)
% Creates and initializes the figure.

% Create the figure and axes to plot into.
fig = figure('NumberTitle', 'off', 'MenuBar', 'none', ...
    'Name', figTitle, 'DeleteFcn', @localDeleteFigStatic);

% set(fig, 'Pointer', 'fullcrosshair');

uicontrol(fig, 'String', 'Close', 'Callback', 'close(gcf)', 'Position', [10 10 50 30]);
h = uibuttongroup('visible','off','Position',[0 0 1 1]);
ul = uicontrol(fig,'Style','Text','String','Mode Select','pos',[85 75 150 15]);
u0 = uicontrol(fig,'Style','Radio','String','Authentication Mode',...
    'pos',[85 50 150 15],'parent',h,'HandleVisibility','off');
u1 = uicontrol(fig,'Style','Radio','String','Freefire Mode',...
    'pos',[85 35 150 15],'parent',h,'HandleVisibility','off');
u2 = uicontrol(fig,'Style','Radio','String','Panic Mode',...
    'pos',[85 20 150 15],'parent',h,'HandleVisibility','off');
u3 = uicontrol(fig,'Style','Radio','String','Manual Mode',...
    'pos',[85 5 150 15],'parent',h,'HandleVisibility','off');
set(h,'SelectionChangeFcn',@modechanger);
set(h,'SelectedObject',u1);  % No selection
dlmwrite('auth.txt',1);
set(h,'Visible','on');

m = uibuttongroup('visible','off','Position',[0 0 1 1]);
ml = uicontrol(fig,'Style','Text','String','Colormap Select','pos',[235 75 150 15]);
m0 = uicontrol(fig,'Style','Radio','String','Jet','pos',[235 50 150 15],'parent',m,'HandleVisibility','off');
m1 = uicontrol(fig,'Style','Radio','String','HSV','pos',[235 35 150 15],'parent',m,'HandleVisibility','off');
m2 = uicontrol(fig,'Style','Radio','String','Heatmap','pos',[235 20 150 15],'parent',m,'HandleVisibility','off');
m3 = uicontrol(fig,'Style','Radio','String','Grayscale','pos',[235 5 150 15],'parent',m,'HandleVisibility','off');
set(m,'SelectionChangeFcn',@colormapchanger);
set(m,'SelectedObject',m0);
set(m,'Visible','on');

uicontrol(fig, 'String', 'Pause', 'Callback', 'motionPauser', 'Position', [410 40 80 30]);
uicontrol(fig, 'String', 'Toggle Coords', 'Callback', 'coordToggle', 'Position', [410 10 80 30]);

s = uibuttongroup('visible','off','Position',[0 0 1 1]);
sl = uicontrol(fig,'Style','Text','String','Sounds','pos',[500 55 75 15]);
s0 = uicontrol(fig,'Style','Radio','String','Off','pos',[500 35 75 15],'parent',s,'HandleVisibility','off');
s1 = uicontrol(fig,'Style','Radio','String','On','pos',[500 20 75 15],'parent',s,'HandleVisibility','off');
set(s,'SelectionChangeFcn',@soundchanger);
set(s,'SelectedObject',s0);
set(s,'Visible','on');

t_left = uicontrol(fig,'Style','Text','String','Left: Off','pos',[600 55 50 15]);
t_right = uicontrol(fig,'Style','Text','String','Right: Off','pos',[600 35 50 15]);
t_fire = uicontrol(fig,'Style','Text','String','Firing: Off','pos',[600 20 50 15]);

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