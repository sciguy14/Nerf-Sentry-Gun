function control(chan,line,state)
%Controls a Digital Output
%chan:  Digital I/O channels Vector
%Line:  The Digital Line you want to control
% 1 - Trigger
% 2 - Rotate Left
% 3 - Rotate Right
%State: Sets the State of the Line to be controled (0 for off, 1 for on)

putvalue(chan(line), state);