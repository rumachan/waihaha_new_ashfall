#!/bin/csh -f
#ashfall_plot.csh

#plot shade plots for ashfall data
#plots 1 mm area

set BOX    = -R173/179/-42/-35
set SCALE  = -Jm2.5
set program_directory = /home/volcano/programs/new_ashfall
set place_directory = /home/volcano/programs/new_ashfall/place_files
set cpt_directory = /home/volcano/programs/new_ashfall/cpt_files
set wheregmt = `which psxy`
set GMT = `echo $wheregmt:h`

$GMT/gmtset BASEMAP_TYPE PLAIN
$GMT/gmtset ANOT_FONT_SIZE 10
$GMT/gmtset PAPER_MEDIA A4
$GMT/gmtset MEASURE_UNIT cm

if( $#argv != 4 ) then
	echo "ashfall_plot.csh: syntax error"
	echo "correct syntax ashfall_plot.csh input_file_vol input_file_thk input_file_win plot_file"
	exit
else
	set input_file_vol = $argv[1]
	set input_file_thk = $argv[2]
	set input_file_win = $argv[3]
	set plot_file = $argv[4]
endif

#extract eruption parameters for plot display
set me = `awk 'NR==3{print $2}' $input_file_vol`
set mn = `awk 'NR==3{print $3}' $input_file_vol`
set height = `awk 'NR==3{print $4/1000}' $input_file_vol`
set volume = `awk 'NR==3{print $5}' $input_file_vol`

set volcano_name = `echo $input_file_thk:t | awk 'BEGIN{FS="_"} {print $3}'`
set day = `echo $input_file_thk:t | awk 'BEGIN{FS="_"} {print $1}'`
set tim = `echo $input_file_thk:t | awk 'BEGIN{FS="_"} {print $2}'`
set model_date = `/bin/date -d$day "+%A %d %B %Y"`

#set volcano parameters
switch ( $volcano_name )
	case ruapehu:
		set volcano = Ruapehu
		set lonlat = "175.564 -39.281"
		breaksw
	case taranaki:
		set volcano = Taranaki
		set lonlat = "174.064 -39.297"
		breaksw
	case white:
		set volcano = (White Is)
		set lonlat = "177.183 -37.521"
		breaksw
	case ngauruhoe:
		set volcano = (Ngauruhoe)
		set lonlat = "175.632 -39.157"
		breaksw
	case auckland:
		set volcano = (Auckland)
		set lonlat = "174.735 -36.890"
		breaksw
	case mayor:
		set volcano = (Mayor Is)
		set lonlat = "176.256 -37.287"
		breaksw
	case tongariro:
		set volcano = (Tongariro)
		set lonlat = "175.673 -39.108"
		breaksw
	case tarawera:
		set volcano = (Tarawera)
		set lonlat = "176.506 -38.227"
		breaksw
	case haroharo:
		set volcano = (Haroharo)
		set lonlat = "176.466 -38.147"
		breaksw
	case taupo:
		set volcano = (Taupo)
		set lonlat = "175.978 -38.809"
		breaksw
endsw

#calculate data for wind plot
#echo calculating wind vectors
#$program_directory/win2plt $input_file_win >! winplt_file
$program_directory/win2plt.pl $input_file_win 173.5 -38.5 >! winplt_file
set winscale = ( 173.25 -38.4 90 0.75 )
set winkey = ( 173.4 -38.5 8 0 0 CM 25 m\/s )

#map
$GMT/psbasemap -Ba2f1NSEW $BOX $SCALE -L178/-41.5/-41.5/100 -X3 -Y3 -K -P >! $plot_file
$GMT/pscoast $BOX $SCALE -Dh -W -O -K >>$plot_file
awk '{print $2, $1*-1, $3}' $input_file_thk | $GMT/surface -Ggridfile.grd -I0.01 $BOX
awk '{print $2, $1*-1}' $input_file_thk | $GMT/grdmask -Gmask.grd -I0.01 -S10k $BOX
grdmath gridfile.grd mask.grd MUL = plot.grd
#cpt file depends on eruption volume
#very small < 0.05 km3
set vol_test = `echo "$volume < 0.05" | bc`
if ($vol_test == 1) then
	grdimage -C$program_directory/cpt_files/range_vsml.cpt plot.grd $BOX $SCALE -O -K >> $plot_file
	psscale -D12/19/5/0.5h -C$program_directory/cpt_files/range_vsml.cpt -Ba0.5f0.1:"thickness (mm)": -O -K >> $plot_file
endif
#small 0.05 - 0.5 km3
set vol_test = `echo "$volume >= 0.05 && $volume < 0.5" | bc`
if ($vol_test == 1) then
	grdimage -C$program_directory/cpt_files/range_sml.cpt plot.grd $BOX $SCALE -O -K >> $plot_file
	psscale -D12/19/5/0.5h -C$program_directory/cpt_files/range_sml.cpt -Ba1f0.5:"thickness (mm)": -O -K >> $plot_file
endif
#medium 0.5 - 5 km3
set vol_test = `echo "$volume >= 0.5 && $volume < 5" | bc`
if ($vol_test == 1) then
	grdimage -C$program_directory/cpt_files/range_med.cpt plot.grd $BOX $SCALE -O -K >> $plot_file
	psscale -D12/19/5/0.5h -C$program_directory/cpt_files/range_med.cpt -Ba10f5:"thickness (mm)": -O -K >> $plot_file
endif
#large > 5
set vol_test = `echo "$volume >= 5" | bc`
if ($vol_test == 1) then
	grdimage -C$program_directory/cpt_files/range_lrg.cpt plot.grd $BOX $SCALE -O -K >> $plot_file
	psscale -D12/19/5/0.5h -C$program_directory/cpt_files/range_lrg.cpt -Ba200f100:"thickness (mm)": -O -K >> $plot_file
endif
$GMT/psbasemap -Ba2f1NSEW $BOX $SCALE -L178/-41.5/-41.5/100 -O -K >> $plot_file
$GMT/pscoast $BOX $SCALE -Dh -W -O -K >>$plot_file

#places
awk '{print $1, $2}' $place_directory/places.dat_1 | $GMT/psxy $BOX $SCALE -Ss0.2 -Gred -O -K >>$plot_file
awk '{print $1, $2}' $place_directory/extra_places.dat | $GMT/psxy $BOX $SCALE -Ss0.2 -Gred -O -K >>$plot_file
#$GMT/psxy $place_directory/roads1m.geo $BOX $SCALE -: -Wthin,black -m -O -K >>$plot_file
$GMT/pstext $place_directory/places.txt_1 $BOX $SCALE -Gred -O -K >>$plot_file
$GMT/pstext $place_directory/extra_places.txt $BOX $SCALE -Gred -O -K >>$plot_file

#volcano
echo $lonlat | $GMT/psxy $BOX $SCALE -O -K -St0.3 -Wthin,white -Gblack >>$plot_file

#wind, plot only if height <= 12 km
awk '$5<=12' winplt_file | $GMT/psxy $BOX $SCALE -O -K -SV0.025c/0.15c/0.1c -Gblack >>$plot_file
awk '$5<=12{print $1-0.01, $2, 8, 0, 0, "RM", $5}' winplt_file | $GMT/pstext $BOX $SCALE -O -K >>$plot_file
echo $winscale | $GMT/psxy $BOX $SCALE -O -K -SV0.025c/0.15c/0.1c -Gblack >>$plot_file
echo $winkey | $GMT/pstext $BOX $SCALE -O -K >>$plot_file

#is it hi or lo wind profile?
set hilo = `echo $input_file_win:t | awk 'BEGIN{FS="_"}{print $4}' | awk 'BEGIN{FS="."}{print $1}'`
if ($hilo == "hi") then
	echo "173.5 -36.5 12 0 1 CB Wind" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
	$GMT/psxy $BOX $SCALE -O -K << end >>$plot_file
173 -36.3
173.9 -36.3
173.9 -38.7
173 -38.7
end
else
	echo "173.5 -37.2 12 0 1 CB Wind" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
	$GMT/psxy $BOX $SCALE -O -K << end >>$plot_file
173 -37.0
173.9 -37.0
173.9 -38.7
173 -38.7
end
endif

#model
$GMT/psxy $BOX $SCALE -O -K << end >>$plot_file
177 -35
177 -35.8
179 -35.8
end
echo "178 -35.2 12 0 1 CB Eruption Model" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
echo "177.1 -35.4 12 0 0 LB volume: $volume km@+3@+" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
echo "177.1 -35.6 12 0 0 LB height: $height km" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file

#text label
echo "176 -34.2 16 0 1 CB PREDICTED ASHFALL AREA" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
echo "176 -34.5 16 0 1 CB For a $volcano eruption at $tim $model_date" | $GMT/pstext $BOX $SCALE -N -O >>$plot_file
#echo "173 -42.5 8 0 0 LB This ashfall model relies on models of both the eruption and the wind flow. While every care is taken" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
#echo "173 -42.625 8 0 0 LB to ensure the accuracy of the ashfall model, should the actual eruption or wind be significantly" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
#echo "173 -42.75 8 0 0 LB different from their modelled values then the ashfall model may not accurately delineate the" | $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
#echo "173 -42.875 8 0 0 LB ash distribution. GNS accepts no liability for any loss or damage, direct or indirect, resulting from" |  $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
#echo "173 -43.0 8 0 0 LB the use of this information. GNS does not make any representation in respect of the" |  $GMT/pstext $BOX $SCALE -N -O -K >>$plot_file
#echo "173 -43.125 8 0 0 LB information's accuracy, completeness or fitness for any particular purpose." |  $GMT/pstext $BOX $SCALE -N -O >>$plot_file

