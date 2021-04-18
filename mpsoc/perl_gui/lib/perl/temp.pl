#! /usr/bin/perl -w
use strict;
use Glib ':constants';
use Gtk2 -init;
use FindBin;
use lib $FindBin::Bin;




my $str1 = 'Usage:524944/1000000 messages';

my $str = '"T3"    -> "R3"  :"p1" [  dir=none];';

#\s*->\s*\"R(\d+)\"\s*:\s*\"[pP](\d+)\"
if ( $str =~  m{\s*\"[Tt](\d+)\"\s*->\s*\"R(\d+)\"\s*:\s*\"[pP](\d+)\"} ) {
   my ($R1, $P1, $R2) = ($1, $2,$3);
	print "($R1, $P1, $R2)\n" ;
   # here we will have the 524944 in the $used variable
   # and 1000000 in $total.
}






####
