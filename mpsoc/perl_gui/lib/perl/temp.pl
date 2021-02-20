#! /usr/bin/perl -w
use strict;
use Glib ':constants';
use Gtk2 -init;
use FindBin;
use lib $FindBin::Bin;

require "widget2.pl";
require "common.pl";


#my @errors = unix_grep("/home/alireza/work/git/hca_git/mpsoc_work/simulate//sim_out5","ERROR:");

#print @errors;

my $cmds='/home/alireza/work/git/hca_git/mpsoc_work/simulate/simulate1 -t "random"  -s 1 -m 1  -n  200000  -c	100000   -i 5 -p "100,0,0,0,0"   > /home/alireza/work/git/hca_git/mpsoc_work/simulate//sim_out5 &  ';
my ($stdout,$exit,$stderr)=run_cmd_in_back_ground_get_stdout("$cmds\n wait\n");

print ($stdout,$exit,$stderr);









####
