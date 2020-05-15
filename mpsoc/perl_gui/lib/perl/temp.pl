#!/usr/bin/perl -w
#use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;
use Scalar::Util 'looks_like_number'; 

use String::Scanf; # imports sscanf()



my $f= "/Alireza/mpsoc/src_verilog/top.v";
my $p =cut_dir_path($f,'src_verilog');		

print $p;




0;
