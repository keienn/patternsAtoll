#!/usr/bin/perl

use strict;
use warnings;
use Math::Complex;


my $ASCDIR="D:\\MultiRAT";
my $outdir="D:\\MultiRAT\\";
my $outf="$outdir\\SITES.csv";
my $outf1="$outdir\\MINPAIR.csv";
my $gsm ="$ASCDIR\\2G.csv";
my $umts ="$ASCDIR\\3G.csv";


 #MultiRAT is the directory containing the files
 #2G.csv is the 2G sites
 #3G.csv is the 3G sites
 #SITES is the output file
 #MINPAIR is the output file with results

open PRIMARY, "$gsm" or die "couldn't open $gsm\n";
open DERIVED, "$umts" or die "couldn't open $umts\n";
open COMBINED, ">$outf" or die "couldn't open $outf\n";
open MINPAIR, ">$outf1" or die "couldn't open $outf\n";

until (eof(PRIMARY) and eof (DERIVED)) {
	
	my $copy1 = <PRIMARY>;
	my $copy2 = <DERIVED>;
	$copy1 ||= "";
	$copy2 ||= "";
	chomp($copy1);
	chomp($copy2);
	print COMBINED "$copy1,$copy2\n";
	
	}
close PRIMARY;
close DERIVED;
close COMBINED;

#---------------------------------------------------------------------------------------------------------------------------
no warnings 'uninitialized';

my $pi = atan2(1,1) * 4;

sub distance {
	my ($lat1, $lon1, $lat2, $lon2, $unit) = @_;
	my $theta = $lon1 - $lon2;
	my $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
  $dist  = acos($dist);
  $dist = rad2deg($dist);
  $dist = $dist * 60 * 1.1515;
  if ($unit eq "K") {
  	$dist = $dist * 1.609344;
  } elsif ($unit eq "N") {
  	$dist = $dist * 0.8684;
		}
	return ($dist);
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function get the arccos function using arctan function   :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub acos {
	my ($rad) = @_;
	my $ret = atan2(sqrt(1 - $rad**2), $rad);
	return $ret;
}
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function converts decimal degrees to radians             :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub deg2rad {
	my ($deg) = @_;
	return ($deg * $pi / 180);
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function converts radians to decimal degrees             :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub rad2deg {
	my ($rad) = @_;
	return ($rad * 180 / $pi);
}

#---------------------------------------------------------------------------------------------------------------------------

open COMBINED, "<$outf" or die "couldn't open $outf\n";

my (@gsm_site, @umts_site);

### Create the 3G and 2G arrays

while (<COMBINED>) {

    my ($name1,$lon1,$lat1, $name2,$lon2,$lat2) = split /[\s"]*,["\s]*/, $_;
    next if $. < 2;
   # next unless $lat1 and $lon1; # Avoid title lines
    push @gsm_site, {NAME=>$name1, LAT=>$lat1, LON=>$lon1};   
    push @umts_site,{NAME=>$name2, LAT=>$lat2, LON=>$lon2};
}

### Nested for loops to calculate the distance between one 2G site and all 3G sites, return shortest distance

for my $g (@gsm_site){

      $g->{NEAREST}         =  $umts_site[0]; # Initial assumption till we know better
      $g->{DIST_TO_NEAREST} = distance($g->{LAT},$g->{LON}, $g->{NEAREST}{LAT},$g->{NEAREST}{LON}, "K");
      
	  for my $u (@umts_site[1..$#umts_site]){
        
		 my $this_distance = distance($g->{LAT},$g->{LON}, $u->{LAT},$u->{LON}, "K");
         next unless $this_distance < $g->{DIST_TO_NEAREST};
         $g->{NEAREST} = $u;
         $g->{DIST_TO_NEAREST} = $this_distance;
     
	  }
}

### Print them out

print MINPAIR "2G Site ID, 3G Site ID, Minimum Distance,\n" ;

for my $g (@gsm_site){

   print MINPAIR "$g->{NAME}, $g->{NEAREST}->{NAME}, $g->{DIST_TO_NEAREST},\n";
}




