function access(chan,line)
%Gets the Value from a digital input
%chan:  Digital I/O channels Vector
%Line:  The Digital Line you want to access
% 4 - Right Sensor (viewed from rear)
% 5 - Left Sensor (viewed from rear)

getvalue(chan(line));