#!/usr/bin/perl
#extract_wind.pl

#extract wind data from Metservice format files
#extract for a single volcano specified as input

#2011 metservice file format
#Forecast issued by MetService at 06:30am 23-12-2011
#
#For GNS Wairakei Research Centre - Volcano Watch All times NZDT e.g. 230600 is 6am on 23rd. Winds in degrees/knots, heights in metres.
#Model of the day is ECMWF
#
#Data for model UKMO
#Auckland
#Height  Valid at      Valid at      Valid at      Valid at      Valid at
#        230600        231200        231800        240000        240600
#1000    210/03        110/02        085/06        115/05        150/05
#2000    180/09        150/06        150/11        165/08        160/11
#3000    165/07        160/08        155/08        140/11        145/09
#4000    160/08        160/10        160/11        165/08        185/10
#6000    140/12        160/11        160/13        190/11        215/14
#8000    140/13        155/15        175/15        205/16        230/22
#10000   170/10        165/15        195/16        215/20        230/25
#12000   205/14        210/11        215/16        240/24        235/21
#
#then data section repeated for Haroharo, Mayor Island, Ngauruhoe, Ruapehu
#Taranaki (Egmont), Tarawera, Taupo, Tongariro, White Island

#for high elevation volcanoes (Ngauruhoe, Ruapehu) 1000 m wind data are not produced by models
#Height  Valid at      Valid at      Valid at      Valid at      Valid at
#        040600        041200        041800        050000        050600
#1000    -             -             -             -             -
#2000    265/09        265/08        275/07        280/07        265/09
#3000    230/08        235/07        230/07        245/05        250/05
#ashfall program does not know about the volcano elevation, in the above case assign 1000 m wind to that at 2000 m


#output file, known as a .win file by ashfall
#wind time (hrs), number of levels, level interval (m), wind profile coordinates (kme kmn)
#velocity (m/s), direction (deg) for each level
#00.   6 2000   6500  2700
#04. 160
#05. 150
#08. 155
#11. 145
#11. 135
#11. 165
#12.   6 2000   6500  2700
#05. 115
#07. 150
#11. 185
#12. 195
#15. 190
#16. 195
#24.   6 2000   6500  2700
#04. 145
#07. 150
#09. 175
#09. 190
#14. 205
#15. 210

#for a low level plume output levels 1000, 2000, 3000, 4000
#for a high level plume output 2000, 4000, 6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000, 22000, 24000, 26000
#highest levels required for tallest plumes, but not in data file supplied so use highest available value at these elevations

use File::Basename;
#use File::Path qw(make_path); #preferred but not in perl 5.8
use File::Path; 
use Date::Calc qw(Add_Delta_DHMS);

#definition stuff
$data_dir = "/home/volcano/data/new_ashfall";

#hash for volcano names
%names = ("auckland", Auckland, "haroharo", Haroharo, "mayor", "Mayor Island", "ngauruhoe", Ngauruhoe, "ruapehu", Ruapehu, "taranaki", "Taranaki (Egmont)", "tarawera", Tarawera, "taupo", Taupo, "tongariro", Tongariro, "white", "White Island");

#number lines for each volcano data block, including volcano name
$nlines = 11;

$usage = "extract_wind.pl infile volcano_name\n";

if ($#ARGV != 1) { die "$usage";}
$infile = $ARGV[0];
$volc_name = $ARGV[1];
$volc = $names{$volc_name}; #$volc is full name, possibly with spaces
#print "volcano is $volc\n";

open(INFILE, "< $infile")
    or die "Couldn't open $infile for reading: $!\n";

#get model, date & time from file name
$file = basename($infile);
($dum, $dum, $dum, $dum, $dum, $model, $date, $time) = split /_/, $infile;
($year, $month, $day) = unpack ("a4, a2, a2", $date);
($hour, $min) = unpack ("a2, a2", $time);
$sec = 0;
$dirbase = join ("_", $year . $month . $day, $hour . $min);
#printf ("%s\n", $filebase);
#print "$year $month $day $hour $min $sec\n";

#read infile and get data for volcano
while ($line = <INFILE>) {
	chomp ($line);
	#get data for volcano	
	if ($line eq $volc){
		$data[0] = $line;

		#next lines are all data for this volcano
		for ($i = 1; $i<$nlines; $i++){
			$line = <INFILE>;
			chomp ($line);
			$data[$i] = $line;
		}
	}
}

#for ($i = 0; $i<$nlines; $i++){
#	print "$data[$i]\n";
#}

#extract relevant data
#low level plume
#print "low level plume\n";
$plume = lo;
$nlevels = 4;
$interval = 1000;
@levels = ("1000", "2000", "3000", "4000");
extract();

#high level plume
#print "high level plume\n";
$plume = hi;
$nlevels = 13;
$interval = 2000;
@levels = ("2000", "4000", "6000", "8000", "10000", "12000", "14000", "16000", "18000", "20000", "22000", "24000", "26000");
extract();

sub extract {
	#use global variables
	#output is printed to various files
	$time_interval = 6;
	$nlevel = 0;

	foreach $level (@levels){
		#print "$level\n";
		for ($i = 0; $i<$nlines; $i++){
			@line = split (/ +/, $data[$i]);
			if ($line[0] == $level) { #levels that have a value in input file
				$level[$nlevel] = $line[0];
				$now[$nlevel] = $line[1];
				$plus06[$nlevel] = $line[2];
				$plus12[$nlevel] = $line[3];
				$plus18[$nlevel] = $line[4];
				$plus24[$nlevel] = $line[5];
				$plus99[$nlevel] = $line[5];

				$last_now = $now[$nlevel];
				$last_plus06 = $plus06[$nlevel];
				$last_plus12 = $plus12[$nlevel];
				$last_plus18 = $plus18[$nlevel];
				$last_plus24 = $plus24[$nlevel];
				$last_plus99 = $plus24[$nlevel];
			}
			#levels > 12000, max elevation in file
			#assign to last matching value, which will be 12000
			if ($level > 12000){
				$now[$nlevel] = $last_now;
				$plus06[$nlevel] = $last_plus06;
				$plus12[$nlevel] = $last_plus12;
				$plus18[$nlevel] = $last_plus18;
				$plus24[$nlevel] = $last_plus24;
				$plus99[$nlevel] = $last_plus24;
			}
		}
		$nlevel++;
	}
	#for situation where 1000 m wind is not given
	#assign to 2000 m value
	if ($now[0] eq "-") {$now[0] = $now[1]};
	if ($plus06[0] eq "-") {$plus06[0] = $plus06[1]};
	if ($plus12[0] eq "-") {$plus12[0] = $plus12[1]};
	if ($plus18[0] eq "-") {$plus18[0] = $plus18[1]};
	if ($plus24[0] eq "-") {$plus24[0] = $plus24[1]};
	if ($plus99[0] eq "-") {$plus99[0] = $plus24[1]};


	#for ($i = 0; $i<$nlevels; $i++){
	#	print "$level[$i]\n";
	#	print "$now[$i]\n";
	#	print "$plus06[$i]\n";
	#	print "$plus12[$i]\n";
	#	print "$plus18[$i]\n";
	#	print "$plus24[$i]\n";
	#	print "$plus30[$i]\n";
	#}


	#output file for ashfall - eruption at 'now'
	($eyear, $emonth, $eday, $ehour, $emin, $esec) = Add_Delta_DHMS($year, $month, $day, $hour, $min, $sec, 0, 0, 0, 0);	#add 0 hours
	$eruption_date = $eyear . sprintf("%02d", $emonth) . sprintf("%02d", $eday);
	$eruption_time = sprintf("%02d", $ehour) . "00";
	$eruption_at = join ("_", $eruption_date, $eruption_time);
	$dir = join ("/", $data_dir, $dirbase);
	#make_path ($dir);	#preferred but not in perl 5.8
	mkpath ($dir);
	$file = join (".", join ("_", $eruption_at, $volc_name, $plume), "wind");
	$outfile = join ("/", $dir, $file);
	#print "outfile is $outfile\n";
	open(OUTFILE, "> $outfile")
    		or die "Couldn't open $outfile for writing: $!\n";
	$time = 0;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $now[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 6;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus06[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 12;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus12[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 18;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus18[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 24;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus24[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 99;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus99[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}

	#output file for ashfall - eruption at 'plus06'
	($eyear, $emonth, $eday, $ehour, $emin, $esec) = Add_Delta_DHMS($year, $month, $day, $hour, $min, $sec, 0, 6, 0, 0);	#add 6 hours
	$eruption_date = $eyear . sprintf("%02d", $emonth) . sprintf("%02d", $eday);
	$eruption_time = sprintf("%02d", $ehour) . "00";
	$eruption_at = join ("_", $eruption_date, $eruption_time);
	#print "eruption at $eruption_at\n";
	#$filebase = join ("_", $model, $eruption_at);
	$dir = join ("/", $data_dir, $dirbase);
	#make_path ($dir);	#preferred but not in perl 5.8
	mkpath ($dir);
	$file = join (".", join ("_", $eruption_at, $volc_name, $plume), "wind");
	$outfile = join ("/", $dir, $file);
	#print "outfile is $outfile\n";
	open(OUTFILE, "> $outfile")
    		or die "Couldn't open $outfile for writing: $!\n";
	$time = 0;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus06[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 6;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus12[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 12;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus18[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 18;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus24[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 24;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus30[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 99;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus99[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}

	#output file for ashfall - eruption at 'plus12'
	($eyear, $emonth, $eday, $ehour, $emin, $esec) = Add_Delta_DHMS($year, $month, $day, $hour, $min, $sec, 0, 12, 0, 0);	#add 12 hours
	$eruption_date = $eyear . sprintf("%02d", $emonth) . sprintf("%02d", $eday);
	$eruption_time = sprintf("%02d", $ehour) . "00";
	$eruption_at = join ("_", $eruption_date, $eruption_time);
	#print "eruption at $eruption_at\n";
	#$filebase = join ("_", $model, $eruption_at);
	$dir = join ("/", $data_dir, $dirbase);
	#make_path ($dir);	#preferred but not in perl 5.8
	mkpath ($dir);
	$file = join (".", join ("_", $eruption_at, $volc_name, $plume), "wind");
	$outfile = join ("/", $dir, $file);
	#print "outfile is $outfile\n";
	open(OUTFILE, "> $outfile")
    		or die "Couldn't open $outfile for writing: $!\n";
	$time = 0;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus12[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 6;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus18[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 12;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus24[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 18;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus30[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
	$time = 99;
	printf OUTFILE "%02d %1d %4d 6500  2700\n", $time, $nlevels, $interval;
	for ($level = 0; $level < $nlevel; $level++){
		($dir, $vel) = split ("/", $plus99[$level]);
		$vel /= 2;	#knots to m/s conversion
		printf OUTFILE "%02d %03d\n", $vel, $dir;
	}
}
