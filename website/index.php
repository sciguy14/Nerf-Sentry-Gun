<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>CS1114 Final Project - Nerf Sentry Gun Entrance Log</title>

<script type="text/javascript" src="lightbox/js/prototype.js"></script>
<script type="text/javascript" src="lightbox/js/scriptaculous.js?load=effects,builder"></script>
<script type="text/javascript" src="lightbox/js/lightbox.js"></script>
<link rel="stylesheet" href="lightbox/css/lightbox.css" type="text/css" media="screen" />


</head>

<body>
<font size="+1" style="font-family:Verdana, Geneva, sans-serif">

<img src="nerf_logo.png" /><br/>
<strong>Nerf Sentry Gun Entrance Log</strong><br/><br/>

<table><tr><td>

<table>

<?php
//page_width should be evenly divisible by thumbnail_size...
$page_width = 800; 
$thumbnail_size = 200;

//This loops through all files in the current directory and prints them to the screen
if ($handle = opendir('.')) {
	$count = 0;
    while (false !== ($file = readdir($handle))) {
		
		
        if ($file != "." && $file != ".." && $file !="index.php"  && $file != "lightbox" && $file !="nerf_logo.png") {
						
			//setup tables
			if ($count%($page_width/$thumbnail_size) == 0):
				echo "<tr><td>\n";
			else:
				echo "<td>\n";
			endif;
			
			//Get Date and Time Info based on file info
			$stuff = explode(".", "$file");
			$info  = explode(" " , $stuff[0]);
			$date = str_replace('-','/',$info[0]);
			$time = str_replace('_',':',$info[1]);
			$status = $info[2];
			$title = $date . "&nbsp;&nbsp;&nbsp;||&nbsp;&nbsp;&nbsp;" . $time . "&nbsp;&nbsp;&nbsp;||&nbsp;&nbsp;&nbsp; Access " . $status; 
			
			//print the actual picture
			echo "<a href='$file' title='$title' rel='lightbox[1]'><img src='" . $file . "' width = '$thumbnail_size px'/></a><br />\n";
			
			//Print Information
			echo $date . "<br/>\n";
			echo $time . "<br/>\n";
			if (strcmp($status , "granted") == 0) {
				echo "<font color='#00FF00'>\n";
				echo $status . "<br />\n";
				echo "</font><br /><br />\n";
			}
			
			else {
				echo "<font color='#FF0000'>\n";
				echo "<blink>\n";
				echo $status . "<br />\n";
				echo "</blink>\n";
				echo "</font><br /><br />\n";
			}
			
			//setup tables
			$count++;
			if ($count%($page_width/$thumbnail_size) == 0):
				echo "</td></tr>\n";
			else: 
				echo "</td>\n";
			endif;
			
			
        }
		
		
		
    }
    closedir($handle);
}

//Get the Approximate Height (assumes 4x3 ratio)
$thumbnail_height = $thumbnail_size*(3/4);
$num_rows = ceil($count / ($page_width/$thumbnail_size));
$total_height = $num_rows*210;

?>
</table>

</td><td valign="top">

<!--TWITTER-->
<!--Insert your twitter feed here.-->


</td></tr></table>

</font>

</body>
</html>