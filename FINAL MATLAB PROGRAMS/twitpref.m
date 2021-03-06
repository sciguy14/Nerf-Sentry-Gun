function [Outusername, Outpassword] = twitpref(opt) %#ok<INUSD>
%TWITPREF Set twitter username and password
%   Opens a GUI for entering twitter username and password. Note that the
%   password is not masked. It stores the username and password in
%   the preferences. This is queried by the twit function when that
%   function is not supplied with username and password.
%
%   This function stores the password in plain text and is not secure. Use
%   this at your own risk.
%
%   See also twit.

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

groupName = 'TwitterAuthentication';
prefName = 'Credentials';

if nargin == 0
  FigureHandle = figure( ...
                    'Visible','off', ...
                    'Menubar','none', ...
                    'Toolbar','none', ...
                    'Position', [360,500,320,120], ...
                    'IntegerHandle', 'off', ...
                    'Color',    get(0, 'defaultuicontrolbackgroundcolor'), ...
                    'NumberTitle', 'off', ...
                    'Name', 'Twitter username and password');
  movegui(FigureHandle, 'center');
  set(FigureHandle,'Visible','on');
  uicontrol('Parent', FigureHandle, 'Style', 'Text', ...
            'String', 'Username', ...
            'Units', 'Normalized', 'Position', [0 0.65 0.4 0.2], ...
            'FontSize', 12);
  hUN = uicontrol('Parent', FigureHandle, 'Style', 'edit', ...
              'Units', 'Normalized', 'Position', [0.4 0.65 0.5 0.2], ...
              'FontSize', 12, 'BackgroundColor', 'white',...
              'HorizontalAlignment', 'left');
  uicontrol('Parent', FigureHandle, 'Style', 'Text', ...
              'String', 'Password', ...
              'Units', 'Normalized', 'Position', [0 0.4 0.4 0.2], ...
              'FontSize', 12);
  hPW = uicontrol('Parent', FigureHandle, 'Style', 'edit', ...
            'Units', 'Normalized', 'Position', [0.4 0.4 .5 0.2], ...
            'FontSize', 12, 'BackgroundColor', 'white', ...
            'HorizontalAlignment', 'left');
  uicontrol('Parent', FigureHandle, 'Style', 'pushbutton', ...
            'String', 'Submit', 'Units', 'Normalized', ...
            'Position', [0.1 0 .4 0.2], 'FontSize', 12, ...
            'Callback', @submitCallback);
  uicontrol('Parent', FigureHandle, 'Style', 'pushbutton', ...
            'String', 'Cancel', 'Units', 'Normalized', ...
            'Position', [0.5 0 .4 0.2], 'FontSize', 12, ...
            'Callback', @cancelCallback);
  set(FigureHandle', 'CloseRequestFcn', @cancelCallback);
  uiwait(FigureHandle);
else
  if ispref(groupName, prefName)
    Credentials = getpref(groupName, prefName);
    Outusername = Credentials.Username;
    Outpassword = Credentials.Password;
  else
    Outusername = '';
    Outpassword = '';
  end
end

    function submitCallback(h, evd) %#ok<INUSD,INUSD>
        username = get(hUN, 'String');
        password = get(hPW, 'String');
        setpref(groupName, prefName, struct('Username', username, ...
                                    'Password', password));
        delete(FigureHandle);
    end
    function cancelCallback(h, evd) %#ok<INUSD,INUSD>
        delete(FigureHandle);
    end
end
