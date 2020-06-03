#!/usr/bin/perl -w
#use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;
use Scalar::Util 'looks_like_number'; 

use String::Scanf; # imports sscanf()

my $s="22oA55j";
$s =~ s/[^0-9a-fA-F]//g;

print $s;


0;
