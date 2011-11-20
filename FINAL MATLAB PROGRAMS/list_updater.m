function [list] = list_updater(list, x, y)

old_x = list(1,2);
old_y = list(2,2);

list = [ old_x x ; old_y y ];