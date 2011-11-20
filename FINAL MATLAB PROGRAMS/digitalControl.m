function chan = digitalControl
%Creates the necessary Digital control Objects

dio = digitalio('nidaq', 'Dev1');
chan = addline(dio, 0:2, 0, 'out');

