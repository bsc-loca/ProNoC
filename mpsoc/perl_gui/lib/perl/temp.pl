#!/usr/bin/perl -w
#use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;
use Scalar::Util 'looks_like_number'; 
use Gtk2;
use Env::Modify qw(:ksh source);

use String::Scanf; # imports sscanf()

sub main{

my $index = 0;
my $lower = 0;
my $upper =10;

    my $pronoc = get_project_dir();
	my $intfc = "$pronoc/mpsoc/boards/Xilinx/Arty_z7_20/jtag_intfc.sh";
	my $t =  "-t  4 " ;
	


	my $comand = "bash -c \"source $intfc;   \\\$JTAG_INTFC $t -n $index -s $lower -e $upper -r\"";
print "$comand\n";
	my ($stdout,$exit,$stderr)=run_cmd_in_back_ground_get_stdout($comand);
	
	

	print "out:$stdout,$exit,$stderr\n";

exit;

}

Gtk2->init;
main;
Gtk2->main();




0;
