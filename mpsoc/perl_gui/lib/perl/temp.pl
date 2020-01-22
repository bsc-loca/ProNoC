#!/usr/bin/perl -w
use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;


use String::Scanf; # imports sscanf()
use 5.012;


 my $line = "kokomaster is a master with koko master. master and kokomaster;";
 
$line=~ s/(?<!koko)master/kokomaster/g;	

print $line;

1;
