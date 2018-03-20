#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use diagnostics;
use File::Basename;

### subroutine to unzip the pattern files and place them in a specified folder

my $zipdir ="D:\\Patterns\\";
my $unzipdir = "D:\\Imports";
my $exportdir = "D:\\Imports\\Atoll_Imports";

	sub extract{
		
		my $zipdir = shift;
		
		while ( my $inf = <$zipdir/*.zip> ) {

			($unzipdir = $inf) =~ s/\.zip$//;

			system('C:\Program Files\WinRAR\WinRAR.exe', 'e', '-y', $inf, '*.*', "D:\\Imports\\") or warn "$!\n";
			
		}

  }
	
extract($zipdir);

### for loop to iterate over the unzipped files

no warnings 'uninitialized';

my ($line, $file);

my @unzip = <"D:\\Imports\\*.txt">;

foreach  my $unzip(@unzip) {

open my $file, '<', $unzip or die "couldn't open $unzip\n";

open my $import,  ">$exportdir/" . basename($unzip) or die "couldn't open $exportdir/$file\n";

### while loop to read and edit each file
    
	while (my $line = <$file>) {  
	
	chomp $line;
	
	my @pattern = split(/\t/,$line);
	my @namearray = split(/_/,$pattern[0]);

	#next if $. < 2;
			
		if ($namearray[3] =~ m/dg$/) {

				$namearray[3] =~ s/dg/F/;
			}
			
		elsif ($namearray[3] =~ m/T$/){

		    $namearray[3] =~ s/T/V/;
		    
			 }
		else {}

	
		my @antname = ($namearray[0],$namearray[1],$namearray[3]); 

		@antname = $pattern[0] if ( $. == 1);
		
		my $name = join "_", @antname;

		 if ($name =~ m/^8/) {
			$name =~ s/^8/K8/;
		 }
			else {
			$name =~ s/^\d/K7/;
		 }
		
		
		my $newline = splice @pattern, 0, 1, $name;
		
		my $freqchk = $namearray[1];

		$freqchk =~ s/(\d+).*$/$1/;

		  if ($freqchk >= 698 and $freqchk <= 890 ) {
			$pattern[3] =~ s/dt/dt_L800/;
		   }
		  elsif ($freqchk >= 891 and $freqchk <= 960){
			$pattern[3] =~ s/dt/dt_GU900/;
		   }
		  elsif ($freqchk >= 1695 and $freqchk <= 1880){
			$pattern[3] =~ s/dt/dt_G1800/;
		   }
		  elsif ($freqchk >= 1881 and $freqchk <= 2200){
		
			$pattern[3] =~ s/dt/dt_U2100/;
		   }
		  else {
		    $pattern[3] =~ s/dt/dt_2600/;
		   }
			
		   $line = join "\t", @pattern;

	   ### save the modified files to a different folder ready for import into Atoll  
			
			 print $import "$line\n";

		}
		
}
