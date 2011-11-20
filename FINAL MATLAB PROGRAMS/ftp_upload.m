function ftp_upload(A,access_granted)
%Given an jpeg file name, ftp_upload will get the date_stamp, upload the
%image to appropriate location, and note whether or not the user was
%allowed access
%image_file - file name (eg. picture1.jpg)
%access_granted - boolean, 1 for granted, 0 for denied

%Make the ftp object
f = ftp('server:port','username','password');
pasv(f);

%Generate the timestamp and status for this image
d = datestr(now,31);
d = regexprep(d, ':', '_'); %Windows Doesn't like colons in the filename
if access_granted == true
    d = strcat(d , ' granted.jpg');
else
    d = strcat(d , ' denied.jpg');
end

%If the image is larger than 600 pixels wide, then size it down
 [num_rows, num_cols, levels] = size(A);
 new_rows = num_rows/(num_cols/600);
 if num_cols > 600
     A = imresize(A, [new_rows 600]);
 end

%Write the Image back to the hard drive with its new name (and size if
%applicable)
imwrite(A,d,'jpg');

%Upload the image
mput(f,d);

%close the FTP connection
close(ftp);