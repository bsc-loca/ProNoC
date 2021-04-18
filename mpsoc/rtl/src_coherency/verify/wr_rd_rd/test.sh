#!/bin/bash

source "../check_functions.sh"

#check write on mem
get_repeat_num 
check_write_on_mem $REPEAT


# check write on cache
perl -e '

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;

my $low=$ARGV[0];
my $high=$ARGV[1];
my $state=$ARGV[2];
my $expect=$ARGV[3];

 
my $file = "./transcript";

my $r=0;
my $var=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+cch\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
   	my  ($t,$c,$a,$s, $b) = sscanf("\# %d: cch ( %d ) Write %d with state %s on Address %d", $line);
	$var++ if(($c >= $low) && ($c<=$high)  &&  ($s eq $state)); 
       
	say "failed on $line\n" if ($a != $b);
	$r=1 if ($a != $b);
   }
}


if($var != $expect){
	say "Error Expected $expect Cache wr ($low<=n<=$high)  in $state state but got $var";
	$r=1;
} 
say "All writes on caches are done correctly" if($r==0); 


close($fh);

' 0 0 "UC" $REPEAT
