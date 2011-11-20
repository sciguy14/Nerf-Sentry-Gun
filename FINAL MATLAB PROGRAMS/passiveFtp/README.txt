Installation instructions for passive mode FTP files in MATLAB.
Written by Idin Motedayen-Aval.

(See references at the end for more information)


Quick Install notes (for more detailed instructions, see blow):
1. Locate and rename your @ftp/ftp.m and @ftp/private/connect.m files.
2. Copy the provided connect.m into your @ftp/private folder.
3. Copy the rest of the files to your @ftp folder
    (ftp.m, pasv.m, active.m, dataMode.m)
4. Restart MATLAB and rehash your toolbox cache by typing:
    rehash toolboxcache
5. You can now use passive mode FTP by typing 'pasv(myFTP)' after
    constructing an FTP object called myFTP.


Detailed instructions:
1. Unzip all the files to a local directory on your machine.  Verify that
   you have these files in the zip file:
 ftp.m
 connect.m
 active.m
 pasv.m
 dataMode.m

2. Find the path to the MATLAB FTP class.
    a. At the MATLAB prompt, type
        which ftp
    b. This should return a string that looks like this:
        D:\Applications\MATLAB701\toolbox\matlab\iofun\@ftp\ftp.m  % ftp constructor
    c. Note this path (or copy it).

3. Save a back up copy of the files that will be modified (in case you need
    to change things back to the way they were):
    a. Rename these files as follows:
        ftp.m               to  ftp.m.old
        private/connect.m   to  private/connect.m.old
        (Note that the connect.m file is in the 'private' subfolder of
            your @ftp folder).

4. Copy the connect.m file to the '@ftp/private' folder (where the old one
    was).  Once done, the @ftp/private folder should contain these two
    files:
        connect.m   connect.m.old

5. Copy the remaining files to the @ftp folder.  Once the files are copied,
    you should have the following files in this folder in addition to
    ftp.m.old

        active.m    close.m     disp.m      mget.m      rename.m
        ascii.m     dataMode.m  display.m   mkdir.m     rmdir.m
        binary.m    delete.m    ftp.m       mput.m      saveobj.m
        cd.m        dir.m       loadobj.m   pasv.m

6. Resart MATLAB and rehash your MATLAB Toolbox Cache by issuing this
    command at the MATLAB prompt:
        rehash toolboxcache

7. You can now enter 'passive mode' FTP as follows:
    myFTP = ftp('ftp.mathworks.com')
    pasv(myFTP)
    dataMode(myFTP)  % this command simply shows the current mode

    you can return to normal/active mode by issuing the command
    active(myFTP)


REFERENCES:
For a description of passive mode FTP:
http://slacksite.com/other/ftp.html

For details on the FTPClient Java class used in MATLAB:
http://jakarta.apache.org/
The specifics for the class are at:
http://jakarta.apache.org/commons/net/apidocs/org/apache/commons/net/ftp/FTPClient.html
