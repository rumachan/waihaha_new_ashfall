#!/usr/bin/perl
#win2plt.pl

#convert wind file to format for plotting wind vectors in gmt

#input file
#wind time (hrs), number of levels, level interval (m), wind profile coordinates (kme kmn)
#velocity (m/s), direction (deg) for each level
#00 4 1000 6500  2700
#02 200
#02 200
#03 240
#05 230
#06 4 1000 6500  2700
#03 205
#03 205
#03 220
#06 205
#12 4 1000 6500  2700
#05 215
#05 215
#05 215
#06 205

$usage = "win2plt.pl windfile lonref latref\n";

if ($#ARGV != 2) { die "$usage";}
$windfile = $ARGV[0];
$lonref = $ARGV[1];
$latref = $ARGV[2];

open(INFILE, "< $windfile")
    or die "Couldn't open $windfile for reading: $!\n";

#header line
$line = <INFILE>;
($dum, $num_height, $delta_height, $dum, $dum) = split / +/, $line;

for ($i = 0; $i < $num_height; $i++){
	$line = <INFILE>;
	chomp ($line);
	($mps, $deg) = split / +/, $line;
	
	#prepare for plotting
	$mps /= 50;
	$mps *= 1.5;
	$deg += 180;
	$lonpos = $lonref;
	$latpos = $latref + ($i+1) * 0.2857;
	$label = ($i+1) * $delta_height / 1000;

	print "$lonpos $latpos $deg $mps $label\n";
}
