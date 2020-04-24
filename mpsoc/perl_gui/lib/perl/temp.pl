#!/usr/bin/perl -w
#use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;

use String::Scanf; # imports sscanf()




my %param;
$param{"B1"}="A*B";
$param{"C"}="A+B+AB";
$param{"A"}=20;
$param{"B"}="A+30";
$param{"BB"}="AA+30";
$param{"AA"}="30";
$param{"A1"}="C";
$param{"A0"}="log2(C)";


my @p=get_param_list_in_order(\%param);
print join(',',@p);
print "\n";
		












0;
