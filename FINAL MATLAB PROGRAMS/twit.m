function [status, result] = twit(msg, username, password)
%TWIT   Update your status at twitter.com
%   result = twit(message, username, password) updates the status with
%   message for username. It also returns status which is true if there was
%   no error and result which is the XML response from twitter.com.
%
%   [status, result] = twit(message) updates the status with message for
%   the username which was set using the twitpref function. twitpref
%   function opens a small GUI to ask for username and password and stores
%   them as persistent variables. twit function gets the username and
%   password from twitpref. This avoids the username and password showing
%   up in the console and in command history.
%
%   An example use for this function would be to update the status
%   periodically from a long time consuming computation and follow its
%   status from anywhere.
%
%   This function and its connection may not be secure. So use it at your
%   own risk.
%
%   See also twitpref.

%   Copyright 2008 The MathWorks, Inc.
%   Author: Navan Ruthramoorthy

if nargin == 1
    [username, password] = twitpref(1);
    if isempty(username)
      error('twit:usernamenotset', ...
        ['username is not set. Use twitpref function to set ' ...
        'username and password.']);
    end
end

if length(msg) > 140
    warning('twit:msgtruncation', ...
        'Message length is longer than 140 characters and is truncated.');
    msg = msg(1:140);
end

import java.io.*;
import java.net.*;
import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

msg = ['status=' msg];
url = URL('http://twitter.com/statuses/update.xml');
httpConn = url.openConnection();
httpConn.setDoOutput(true);
httpConn.setUseCaches (false);
httpConn.setRequestProperty('Content-Type', 'application/x-www-form-urlencoded');
httpConn.setRequestProperty('CONTENT_LENGTH', num2str(length(msg)));
encoder = sun.misc.BASE64Encoder();
authStr = java.lang.String([username ':' password]);
credentials = encoder.encode(authStr.getBytes());
basicStr = java.lang.String('Basic ');
combined = java.lang.String([basicStr.toCharArray()' ...
                             credentials.toCharArray()' ]);
httpConn.setRequestProperty('Authorization', combined);

outputStream = httpConn.getOutputStream;
msgStr = java.lang.String(msg);
outputStream.write(msgStr.getBytes());
outputStream.close;

try
  inputStream = httpConn.getInputStream;
catch ME
  throwError(ME.message);
end
byteArrayOutputStream = java.io.ByteArrayOutputStream;
% This StreamCopier is unsupported and may change at any time.
isc = InterruptibleStreamCopier.getInterruptibleStreamCopier;
isc.copyStream(inputStream,byteArrayOutputStream);
inputStream.close;
byteArrayOutputStream.close;

result = byteArrayOutputStream.toString('UTF-8');
status = isempty(strfind(result, '</error>'));

end

function throwError(msg)
  if strfind(msg, '401')
    error('twit:NotAuthorized', 'Authentication details were not correct.');
  elseif strfind(msg, '400')
    error('twit:BadRequest', 'You might have possibly exceeded rate limit.');
  else
    error('twit:ConnectionError', ...
      [msg 10 ...
      'Check '
      'http://groups.google.com/group/twitter-development-talk/web/api-documentation'
      ' for the error code.'])
  end
end