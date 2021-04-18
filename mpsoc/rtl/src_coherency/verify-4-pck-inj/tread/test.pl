#!/usr/bin/perl -w


#check all snpf are freed


use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";

my $r=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 

#            320810000: hnf (          6) snpf addr          63872 in ram line: 998 way num:0 is updated with status  FREE and spv=10001


my %txn;
my $error=0;
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+hnf\s+\(\s+\d+\)\s+snpf/g;
   
   foreach my $s (@strings) {
   	$line =~ s/\s+/ /g; # remove extra spaces
	my  ($t1, $c1, $addr,$l,$w,$st,$spv) = sscanf("\# %d: hnf ( %d) snpf addr %d in ram line %d way num %d is updated with status %s and spv %x",$line);
	$txn{$addr}=$st if (defined $st);

  }
}

foreach my $s (sort keys %txn) {
   	print "Errr:  addr $s is left busy at the end of simulation\n" if($txn{$s} eq "BUSY");
	$error=1 if($txn{$s} eq "BUSY");
	
  }
say "All snpf adresses are freed at the end ofsimulation.\n" if($error==0); 

close($fh);
