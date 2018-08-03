#!/usr/bin/perl
#ashcontour_all2kml.pl

#plot all ashfall contour files as google earth kml
#one file for each eruption
#each file likely to contain several contours

#input file
#contour_1_0_i.xyz
#columns are tab separated, except for first line which is eruption details
#20120105_0600_ruapehu_hi_sml.thk 10000. 0.01
#175.949272599	-39.1429901196	1
#175.949678	-39.1428313994	1
#175.951324816	-39.1419460686	1

#file directory
$prog_dir = "/home/volcano/programs/new_ashfall";
$data_dir = "/home/volcano/data/new_ashfall";
$out_dir = "/home/volcano/output/new_ashfall";

$usage = "ashcontour_all2kml.pl forecast_date_time(yyyymmdd_hhmm) eruption_date_time(yyyymmdd_hhmm) volcano \n";
if ($#ARGV != 2) { die "$usage";}
$forecast = $ARGV[0];
$eruption = $ARGV[1];
$volcano = $ARGV[2];

($date, $time) = split("_", $eruption);

#get eruption list - thk files
$dir = join("/", $data_dir, $forecast);
$filespec = join("_", $eruption, $volcano);
opendir(DIR, $dir) or die "can't opendir $dir: $!";
@eruptions = grep {/$filespec/ && /thk/} readdir(DIR);
close(DIR);

#loop for eruption files
#each eruption is a different elevation and/or volume, but all at the same time
foreach $eruption (@eruptions) {
	#kml file
	$len = length($eruption);
	$len -=4;	
	$fbase = substr($eruption, 0, $len);
	$kmlfile = $fbase. ".kml";
	open(KMLFILE, "> $out_dir/$kmlfile")
		or die "Couldn't open $out_dir/$kmlfile for writing: $!\n";

	kml_head_1 ();
	
	#create contour files
	#print "$eruption\n";
	`$prog_dir/ashfall_contour.csh $dir/$eruption`;
	
	#list of contour files
	opendir(DIR, $prog_dir) or die "can't opendir $prog_dir: $!";
	@contours = grep {/contour/ && /xyz/} readdir(DIR);
	close(DIR);
	
	#sort contour files by ascending contour value
	$nc = 0;
	foreach $contour (@contours){
		#print "contour $contour\n";
		($dum, $val, $dum) = split ("_", $contour);
        	$temparray[$nc][0] = $val;
        	$temparray[$nc][1] = $contour;
        	$nc++;
	}
	#print "sorted\n";
	@contsort = sort {$a->[0] <=> $b->[0]} @temparray;
	for ($i = 0; $i < $nc; $i++){
        	$newcontours[$i] = $contsort[$i][1];
        	#print "$contsort[$i][0] $contsort[$i][1]\n";
	}
	#sort completed

	foreach $newcontour (@newcontours){
		#print "newcontour $newcontour\n";
		#details of contour file
		open(CONTFILE, "< $prog_dir/$newcontour")
			or die "Couldn't open $prog_dir/$newcontour for reading: $!\n";
		($dum, $value, $num, $dum) = split("_", $newcontour);
		$cont = sprintf("%0.1f", $value);
		#colour from contour value (all semi-transparent)
		#colour order is aabbggrr, where aa is opacity
		if ($cont == 0.2) {
			$colour = "80ffffff"}	#white
		elsif ($cont == 0.5) {
			$colour = "80c0c0c0"}	#silver
		elsif ($cont == 1.0) {
			$colour = "808ce6f0"}	#khaki
		elsif ($cont == 5.0) {
			$colour = "804763ff"}	#tomato
		elsif ($cont == 10.0) {
			$colour = "80578b2e"}	#seagreen
		elsif ($cont == 50.0) {
			$colour = "80aab220"}	#lightseagreen
		elsif ($cont == 100.0) {
			$colour = "80d0e040"}	#tuqoise
		elsif ($cont == 500.0) {
			$colour = "80ffbf00"}	#deepskyblue
		elsif ($cont == 1000.0) {
			$colour = "80ff0000"}	#blue
		else {
			$colour = "80000000"};	#black
		#header line
		#20120105_0600_ruapehu_hi_sml.thk 10000. 0.01
		$line = <CONTFILE>;
		($thkfile, $height, $vol) = split (" +", $line);

		kml_head_2 ();
		kml_head_3 ();

		#contour data
		while ($line = <CONTFILE>) {
			($lon, $lat, $cont) = split("\t", $line); 
			printf KMLFILE "%s,%s,0\n", $lon, $lat;
		}
		kml_tail_1();
		
	}
	foreach $newcontour (@newcontours){
		#remove contour file
		unlink("$prog_dir/$newcontour")
			or die "Can't delete $prog_dir/$newcontour: $!\n";
	}
	#clear sort arrays before next loop
	@contours = ();
	@newcontours = ();
	@contsort = ();
	@temparray = ();
	kml_tail_2();
}


sub kml_head_1{
	#write kml header data, part for all placemarks
	printf KMLFILE "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
	printf KMLFILE "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n";
	printf KMLFILE "\n";

	printf KMLFILE "<Document>\n";
	printf KMLFILE "<name>$fbase</name>\n";
	printf KMLFILE "\n";

	#initial view position
	printf KMLFILE "<LookAt>\n";
	printf KMLFILE "<longitude>175.9</longitude>\n";
	printf KMLFILE "<latitude>-38.9</latitude>\n";
	printf KMLFILE "<altitude>0</altitude>\n";
	printf KMLFILE "<range>1000000</range>\n";
	printf KMLFILE "<tilt>0</tilt>\n";
	printf KMLFILE "<heading>0</heading>\n";
	printf KMLFILE "</LookAt>\n";
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
	printf KMLFILE "<name><![CDATA[%.1f mm]]></name>\n", $cont;
	printf KMLFILE "<styleUrl>#track</styleUrl>\n";
	printf KMLFILE "<description><![CDATA[Thickness: %.1f mm]]></description>\n", $cont;
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
