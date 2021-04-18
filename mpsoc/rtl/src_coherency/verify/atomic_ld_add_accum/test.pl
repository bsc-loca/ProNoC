#!/usr/bin/perl -w


use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;

my $core=$ARGV[0];
my $addr=$ARGV[1];
my $val=$ARGV[2];
my $r=0;

 
my $file = "./transcript";
my $w=0;
my $m;
open my $fh, "<", $file or die "Could not open $file $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+cch\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
   	my  ($t,$c,$a,$s) = sscanf("\# %d: cch ( $core ) Write ( %s ) with state %s on addr ( $addr )", $line);
	if(defined $a){ 
                $r=0;
                $m = $a; 
		$r=1 if  ($a eq $val);
		$w++;
	}
   }
}



say "checked. cch ( $core ) Addr $addr is written $w times. Last values written as expected" if($r==1); 
say "Error.   cch ( $core ) Addr $addr is written $w times. Last values is written as $m but expected $val" if($r==0);



close($fh);

