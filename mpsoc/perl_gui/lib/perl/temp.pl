#!/usr/bin/perl -w
use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;


use String::Scanf; # imports sscanf()
use 5.012;


 my $line = "extern actor_t source1;";
 if( $line =~ /^\s*extern\s+/){

	    	 $line =~ s/\s+/ /g; # remove extra spaces
	    	 $line =~ s/^\s+//; #ltrim
	    	my  ($actor_name) = sscanf("extern actor_t %s;",$line);

		print "($actor_name)\n";

}


1;
