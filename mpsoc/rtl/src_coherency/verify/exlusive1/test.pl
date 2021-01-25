#!/usr/bin/perl -w

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $rn=$ARGV[0];

my $file = "./transcript";
open my $fh, "<", $file or die "Could not open $file $!\n";
my $count=0;


while (my $line = <$fh>) {
   chomp $line;
   $line =~ s/\s+/ /g;
   my  ($t,$c,$a) = sscanf("\# %d: rnf ( $rn ) txn ( %d ) got exclusive fail response", $line);
   $count++ if(defined $t);
 }
close($fh);
print "$count\n";
