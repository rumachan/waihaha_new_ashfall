#!/usr/bin/perl
#ashcontour2kml.pl

#plot a single ashfall contour file as google earth kml

#input file
#contour_1_0_i.xyz
#columns are tab separated, except for first line which is eruption details
#20120105_0600_ruapehu_hi_sml.thk 10000. 0.01
#175.949272599	-39.1429901196	1
#175.949678	-39.1428313994	1
#175.951324816	-39.1419460686	1

#file directory
$local_dir = "/home/volcano/programs/new_ashfall";
#colour for distribution
$colour = "80ffffff";   #white lower opacity

$usage = "ashcontour2kml.pl contour_file contour_colour (white, yellow, orange, red) \n";
if ($#ARGV != 1) { die "$usage";}
$infile = $ARGV[0];
$col = $ARGV[1];
open(INFILE, "< $infile")
	or die "Couldn't open $infile for reading: $!\n";

#colour (all semi-transparent)
if ($col eq "white") {
	$colour = "80ffffff"}
elsif ($col eq "yellow") {
	$colour = "80ffff00"}
elsif ($col eq "orange") {
	$colour = "80ff9933"}
elsif ($col eq "red") {
	$colour = "80000099"}
else {
	$colour = "7fff0000"};

#details of contour file
#filename
($dum, $contour, $num, $dum) = split("_", $infile);
$cont = sprintf("%0.1f", $contour);
#header line
#20120105_0600_ruapehu_hi_sml.thk 10000. 0.01
$line = <INFILE>;
($file, $height, $vol) = split (" +", $line);
($date, $time, $volcano, $dum, $dum) = split("_", $file);
$len = length($file);
$len -=4;
$fbase = substr($file, 0, $len);

$kmlfile = join ("_", $fbase, $cont, $num) . ".kml";
open(KMLFILE, "> $local_dir/$kmlfile")
	or die "Couldn't open $kmlfile for writing: $!\n";

#kml header
kml_head_1 ();
kml_head_2 ();
kml_head_3 ();

#contour data
while ($line = <INFILE>) {
	($lon, $lat, $cont) = split("\t", $line); 
	printf KMLFILE "%s,%s,0\n", $lon, $lat;
}

kml_tail_1();
kml_tail_2();

sub kml_head_1{
	#write kml header data, part for all placemarks
	printf KMLFILE "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	printf KMLFILE "<kml xmlns=\"http://earth.google.com/kml/2.1\">\n";
	printf KMLFILE "\n";

	printf KMLFILE "<Document>\n";
	printf KMLFILE "<name>ashfall distribution</name>\n";
	printf KMLFILE "\n";
}

sub kml_head_2{
	#write kml header data, part for specific placemarks
	printf KMLFILE "<Style id=\"track\">\n";
	printf KMLFILE "<PolyStyle>\n";
	printf KMLFILE "<color>$colour</color>\n";
	printf KMLFILE "</PolyStyle>\n";
	printf KMLFILE "</Style>\n";
	printf KMLFILE "\n";

}
sub kml_head_3{
	#write kml header data, part for specific placemarks
	printf KMLFILE "<Placemark>\n";
	printf KMLFILE "<name>$volcano - $date $time</name>\n";
	printf KMLFILE "<styleUrl>#track</styleUrl>\n";
	printf KMLFILE "<description><![CDATA[Column height: %d m<br>Eruption volume: %.2f km<sup>3</sup><br>Contour: %.1f mm]]></description>\n", $height, $vol, $contour;
	printf KMLFILE "<Polygon>\n";
	printf KMLFILE "<tessellate>1</tessellate>\n";
	printf KMLFILE "<outerBoundaryIs>\n";
	printf KMLFILE "<LinearRing>\n";
	printf KMLFILE "<coordinates>\n";
}

sub kml_tail_1{
	#write kml footer data to specified file
	#part for specific placemarks
	printf KMLFILE "</coordinates>\n";
	printf KMLFILE "</LinearRing>\n";
	printf KMLFILE "</outerBoundaryIs>\n";
	printf KMLFILE "</Polygon>\n";
	printf KMLFILE "</Placemark>\n";
	printf KMLFILE "\n";
}

sub kml_tail_2{
	#write kml footer data to specified file
	#end of file
	printf KMLFILE "</Document>\n";
	printf KMLFILE "\n";
	printf KMLFILE "</kml>\n";
}
