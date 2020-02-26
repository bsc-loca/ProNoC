#!/usr/bin/perl -w
use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;

use String::Scanf; # imports sscanf()

use Gtk2;

my $file = "/home/alireza/work/hca_git/mpsoc_work/SOC/mor1k_soc/sw/image";

sub get_elf_file_addr_range {
	my $file=shift;	
	my $command=  "size -A $file";
	#add_info($tview,"$command\n");
	my	($stdout,$exit,$stderr)=run_cmd_in_back_ground_get_stdout($command);
	return undef if(length $stderr>1);			
	my @lines = split ("\n" ,$stdout);
	my $max_addr=0;
	my $file_size;	
	foreach my $p (@lines ){
		$p =~ s/\s+/ /g; # remove extra spaces
	    	$p =~ s/^\s+//; #ltrim
		my ($sec,$size,$addr)= sscanf("%s %u %u","$p");
		if(defined $size && defined $addr){
			if($max_addr < $addr) {
				$max_addr = $addr;
				 $file_size = $addr + $size;			
			}
		} 
	}
	return $file_size;
	
}


print get_elf_file_addr_range ($file);

1;
