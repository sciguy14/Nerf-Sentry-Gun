function dataConnectionMode = dataMode(h)
% dataMode Change to active mode
%   dataMode(FTP) returns the current connection status.
%   Possible return strings are:
%       'ACTIVE_LOCAL_DATA_CONNECTION_MODE'
%       'ACTIVE_REMOTE_DATA_CONNECTION_MODE'
%       'PASSIVE_LOCAL_DATA_CONNECTION_MODE'
%       'PASSIVE_REMOTE_DATA_CONNECTION_MODE'

% Idin Motedayen-Aval
% December 2004

% Make sure we're still connected.
try
    h.jobject.getStatus;
    error('Not connected.')
end

if (nargin ~= 1)
    error('Incorrect number of arguments.')
end

modeNumber = h.jobject.getDataConnectionMode;

switch modeNumber
    case 0
        dataConnectionMode = 'ACTIVE_LOCAL_DATA_CONNECTION_MODE';
    case 1
        dataConnectionMode = 'ACTIVE_REMOTE_DATA_CONNECTION_MODE';
    case 2
        dataConnectionMode = 'PASSIVE_LOCAL_DATA_CONNECTION_MODE';
    case 3
        dataConnectionMode = 'PASSIVE_REMOTE_DATA_CONNECTION_MODE';
    otherwise
        error ('Invalid data connection mode returned.');
end
