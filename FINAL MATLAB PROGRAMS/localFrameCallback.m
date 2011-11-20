function localFrameCallback(vid, event)
% Executed by the videoinput object callback 
% to update the image display.

% If the object has been deleted on us, 
% or we're no longer running, do nothing.
if ~isvalid(vid) || ~isrunning(vid)
    return;
end

% Access our application data.
appdata = get(vid, 'UserData');
background = appdata.background;

% Peek into the video stream. Since we are only interested
% in processing the current frame, not every single image
% frame provided by the device, we can flush any frames in
% the buffer.
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
localUpdateFig(vid, appdata.figureHandles, frame, background);
appdata.background = frame;
set(vid, 'UserData', appdata);