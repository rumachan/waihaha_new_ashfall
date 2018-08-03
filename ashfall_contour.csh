#!/bin/csh -f
#ashfall_contour.csh

#produce contour file for ashfall data

#input file
#name is like 20120105_0600_ruapehu_hi_sml.thk
#  39.410395 176.077337      0.107
#  39.408820 176.135364      0.112
#  39.407216 176.193387      0.113

#output files
#multiple files possible for a given contour interval
#contour_0.5_0_i.xyz is 0.5 mm contour file 0
#contour_0.5_1_i.xyz is 0.5 mm contour file 1
#contour_1_0_i.xyz is 1 mm contour file 0

#add input file name (for date-time) and volume info from volume file as first line of any contour files

set BOX    = -R173/179/-42/-35
set SCALE  = -Jm2.0
set cpt_dir = /home/volcano/programs/new_ashfall/cpt_files
set vol_dir = /home/volcano/programs/new_ashfall/volume_files
set wheregmt = `which psxy`
set GMT = `echo $wheregmt:h`

if( $#argv != 1 ) then
	echo ashfall_contour.csh: syntax error
	echo "correct syntax ashfall_contour.csh input_file_thk"
	exit
else
	set input_file_thk = $argv[1]
endif

#produce contour files
#0.2 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_0.2.cpt $SCALE $BOX -W -D >& /dev/null

#0.5 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_0.5.cpt $SCALE $BOX -W -D >& /dev/null

#1 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_1.cpt $SCALE $BOX -W -D >& /dev/null

#5 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_5.cpt $SCALE $BOX -W -D >& /dev/null

#10 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_10.cpt $SCALE $BOX -W -D >& /dev/null

#50 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_50.cpt $SCALE $BOX -W -D >& /dev/null

#100 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_100.cpt $SCALE $BOX -W -D >& /dev/null

#500 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_500.cpt $SCALE $BOX -W -D >& /dev/null

#1000 mm contour
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/pscontour -C$cpt_dir/ash_1000.cpt $SCALE $BOX -W -D >& /dev/null

#add input filename and volume details as first line in contour files
set vol_file = `echo $input_file_thk:t | awk 'BEGIN{FS="_"} {printf ("%s_%s_%s\n", $3, $4, $5)}' | awk 'BEGIN{FS="."} {printf("%s.vol\n", $1)}'`
set height = `awk 'NR==3{print $4}' $vol_dir/$vol_file`
set vol = `awk 'NR==3{print $5}' $vol_dir/$vol_file`
echo vol_file is $vol_file, height $height, volume $vol
echo $input_file_thk $height $vol >! infile
foreach contfile (`ls contour*.xyz`)
	echo $contfile
	\mv $contfile tempcontfile	
	cat infile tempcontfile > $contfile
	\rm tempcontfile
end 
\rm infile
