function active(h)
% ACTIVE Change to active mode
%   ACTIVE(FTP) changes the communication mode of FTP to active mode.

% Idin Motedayen-Aval

% Make sure we're still connected.
connect(h)

if (nargin ~= 1)
    error('Incorrect number of arguments.')
end

h.jobject.enterLocalActiveMode;

h.passiveMode = 0;