#!/usr/bin/perl -w
use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;

my $file="/home/alireza/work/develop/for-friends/zakipur/convert/out/top.csv";
open my $in, "<:encoding(utf8)", $file or die "$file: $!";


my $sect=0;
my $net;
my @actors;
while (my $line = <$in>) {
    	chomp $line;
    	$line =~ s/[^\S\n]+//g; #remove space
    	if ($line =~ /Name,Package,Actors,Connections/){
    		$sect=1;
    		next;	
    	}
    	if ($line =~ /Name,Incoming,Outgoing,Inputs,Outputs/){
    		$sect=2;
    		next;	
    	}
    	if ($line =~ /Source,SrcPort,Target,TgtPort/){
    		$sect=3;
    		next;	
    	}
    	if($sect==1){
    		my @fileds=split(',',$line);
    		if(defined $fileds[0]){$net=$fileds[0] if($fileds[0]=~/^\w/);}
    	}
    	if($sect==2){
			my @fileds=split(',',$line);
			if(defined $fileds[0]){ push(@actors,$fileds[0]) if($fileds[0]=~/^\w/);}
    	}
    	if($sect==3){
    		
    		
    	}		
    	
    	
	}
my $num=scalar @actors;
print ("net_name=$net\ntotal of $num acotrs have found: @actors \n");






1;
