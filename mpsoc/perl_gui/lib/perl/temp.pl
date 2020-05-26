#!/usr/bin/perl -w
#use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;
use Scalar::Util 'looks_like_number'; 

use String::Scanf; # imports sscanf()

my $o="R:00002032:R";
my $out=\$o;





my ($tmp,$hex)= sscanf("%sR:%s:R",$$out);
$hex = substr($hex, -3);
print "capture $hex\n";




0;
