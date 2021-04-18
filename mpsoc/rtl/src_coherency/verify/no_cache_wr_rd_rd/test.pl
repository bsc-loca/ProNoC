#!/usr/bin/perl -w

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";
my $core=8;
my $r=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+snf\s+\(\s+$core\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
        my  ($t,$a, $b) = sscanf("\# %d: snf ( 8) Write %d on addr %d", $line);
	if(defined $a && defined $b){        
		if ($a != $b){
		 say "failed on $line\n";
		 $r=1; 
		}
	}
   }
}
say "All writes on main memory are correct" if($r==0); 
close($fh);
