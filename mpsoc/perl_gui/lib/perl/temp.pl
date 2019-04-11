#!/usr/bin/perl -w

use strict;

use FindBin;
use lib $FindBin::Bin;

my $target_dir = "/home/alireza/work/mpsoc_work/MPSOC/mor1k_mpsoc/src_verilator";

if (-d "$target_dir"){
		print "TTTTTTTTTTTTTTTTTTTTTTT\n";
	}else{
		print "NOoooooooooooooooooooo:  $target_dir \n";
	}
