#!/bin/csh
#web_post.csh

#post latest data to web page

#define directories
#set web_dir = /var/www/html/volcano/new_ashfall
set web_dir = /var/www/html/new_ashfall
set data_dir = /home/volcano/output/new_ashfall
set html_file = $web_dir/new_ashfall.html

set ncol = 3
#set volcano_list = (ruapehu white ngauruhoe tongariro taranaki auckland haroharo mayor taupo)
set volcano_list = (ruapehu white ngauruhoe tongariro taranaki)

#do this in ashfall.csh
#remove all files from web_dir
#\rm $web_dir/*

#html header
echo "<html>" >!  $html_file
echo "<head>" >>  $html_file
echo "<title>Ashfall Plots</title>" >>  $html_file
echo "<style>body {background:silver}</style>" >>  $html_file
echo "</head>" >>  $html_file

#html body
echo "<body>" >>  $html_file
echo -n '<h2><font color="#ffffff">' >>  $html_file
echo "Ashfall plots<br></h2>" >>  $html_file
echo "This page last updated at:" >> $html_file
echo -n `date` >> $html_file
echo "<hr>" >>  $html_file
echo "Postscript, GIF, and KML (GoogleEarth) files are produced for various eruption models every 6 hours. New wind models are received at 0630 and 1830 each day. For the 0630 forecast ashfall models are produced for 0600, 1200, and 1800, and for the 1830 forecast ashfall models are produced for 1800, 0000, and 0630. When new models are available they replace the old ones on this page.<br>" >> $html_file
echo "Models for each volcano are based on several eruption volumes and column heights. These are labelled sml, med, lrg (for volumes) and hi, lo (for column heights). Actual values used are documented elsewhere, and represent 'best estimates' given available information." >> $html_file
echo "<hr>" >>  $html_file
echo "<table border=1 bordercolor=#FFFFFF cellpadding=10>" >>  $html_file
echo "<tbody>" >>  $html_file
echo "<tr>" >>  $html_file

#loop through each file and write html
foreach volcano ($volcano_list)
	set ftest = `find $data_dir -name "*$volcano*" -print | wc -l`
	if ($ftest > 0) then
		switch ( $volcano )
        		case ruapehu:
                		set volclab = "Ruapehu"
                		breaksw
        		case taranaki:
                		set volclab = "Taranaki"
                		breaksw
        		case white:
                		set volclab = "White Is"
                		breaksw
        		case ngauruhoe:
                		set volclab = "Ngauruhoe"
                		breaksw
        		case auckland:
                		set volclab = "Auckland"
                		breaksw
        		case mayor:
                		set volclab = "Mayor Is"
                		breaksw
        		case tongariro:
                		set volclab = "Tongariro"
                		breaksw
        		case tarawera:
                		set volclab = "Tarawera"
                		breaksw
        		case haroharo:
                		set volclab = "Haroharo"
                		breaksw
        		case taupo:
                		set volclab = "Taupo"
                		breaksw
		endsw

		set filelist = `ls $data_dir/*$volcano*`
		#volcano header row
		echo '<a name='"$volcano"'></a>'  >> $html_file
        	echo '<td align=middle valign=bottom><FONT color=#ffffff size=+1>'"volcano: $volclab"'</td>' >>  $html_file
                echo "<tr>" >>  $html_file
		#end volcano header row
		@ n = 0
		foreach file ($filelist)
			#echo $file
			\cp $file $web_dir
        		if (($n % $ncol) == 0) then
                		echo "<tr>" >>  $html_file
        		endif
        		echo -n '<td align=middle valign=bottom><FONT color=#ffffff size=+1 face='"courier"'><a href='"$file:t"'>' >>  $html_file
        		echo "$file:t</td>" >>  $html_file
		@ n++
		end
	endif
        echo "<tr>" >>  $html_file
end

#html tail
echo "</tbody>" >>  $html_file
echo "</table>" >>  $html_file
echo "<p></p>" >> $html_file
echo '<font color="#ffffff"><p><i>&copy;Rumasoft</i>' >>  $html_file
echo "<br><i>January 2012</i></p>" >>  $html_file
echo "</body>" >>  $html_file
echo "</html>" >>  $html_file
