#!/usr/bin/perl -w
#use strict;
use warnings;
require "widget.pl";
require "common.pl";
require "mpsoc_gen.pl";
use FindBin;
use lib $FindBin::Bin;
use Glib qw(TRUE FALSE);


my $st='
# set parts [get_parts [get_property PART_NAME [current_board_part]]]
# puts "*RESULT:$parts"
*RESULT:xc7z020clg400-1
# exit
INFO: [Common 17-206] Exiting Vivado at Mon Aug 24 14:47:43 2020...
"';

    my @q =split  (/\n\*RESULT:/,$st);
	my @d = split (/"\n"/,$q[1]);
	my $r= $d[0];

    $r=capture_string_between ('\n\*RESULT:',$st,"\n");

print "r=$r **";











0;
