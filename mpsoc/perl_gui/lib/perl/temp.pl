#!/usr/bin/perl -w
#use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;

use String::Scanf; # imports sscanf()


use Glib qw/TRUE FALSE/;

my @initial_files=('/home/alireza/work/hca_git/mpsoc_work/SOC/mor1k_soc/sw/RAM/ram0.mif','/home/alireza/work/hca_git/mpsoc_work/MPSOC/newAdder/sw/tile0/RAM/ram0.mif');


foreach my $f 	(@initial_files){
	my @m = split('\/sw\/',$f );
	#print "m= $m[-1]\n";	
	my $d = $m[-1];#take the last file path name after /sw/
	$d=~ s/RAM//g; #remove RAM
	$d=~ s/\///g; #remove /
	$d = "tile0".$d unless($m[-1]=~/^tile/); 
	print "$d\n";	
	}




0;
