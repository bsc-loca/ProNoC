#! /usr/bin/perl -w
use strict;
use Glib ':constants';
use Gtk2 -init;
use FindBin;
use lib $FindBin::Bin;

require "widget2.pl";
require "common.pl";

for (my $i=0; $i<256; $i++) {
	print ".C_PROBE_OUT${i}_WIDTH((NE>${i})? ROUTER_CHANEL_w : 1),\n"
	
}








####
