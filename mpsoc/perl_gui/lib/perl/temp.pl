#!/usr/bin/perl -w
#use strict;
use warnings;
require "widget.pl";
require "common.pl";
require "mpsoc_gen.pl";
use FindBin;
use lib $FindBin::Bin;
use Glib qw(TRUE FALSE);
use HexSpin;
use mpsoc;


   use Gtk2 qw(-init);

 


my ($infobox,$info)= create_text();    

 my $self= mpsoc->mpsoc_new();
$self->object_add_attribute('mpsoc_name','tmp');
$self->object_add_attribute('noc_param','TOPOLOGY','MESH');
$self->object_add_attribute('noc_param','T1',2);
$self->object_add_attribute('noc_param','T2',2);
$self->object_add_attribute('noc_param','T3',1);
$self->object_add_attribute('noc_param','V',1);
$self->object_add_attribute('noc_param','Fpay',32);

linker_setting($self,$info);




Gtk2->main;
exit ();









0;
