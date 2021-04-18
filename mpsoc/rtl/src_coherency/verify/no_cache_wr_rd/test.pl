#!/usr/bin/perl -w


use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";

my $r=0;
my $sc=0;
my $uc=0; 

open my $fh, "<", $file or die "Could not open $file $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+cch\s+\(\s+\d+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
   	my  ($t,$c,$a,$s, $b) = sscanf("\# %d: cch ( %d) Write %d with state %s on Address %d", $line);
	$sc++ if($s eq "SC"); 
        $uc++ if($s eq "UC"); 

	say "failed on $line\n" if ($a != $b);
	$r=1 if ($a != $b);
   }
}



say "All writes on caches are done correctly" if($r==0); 
say "Error Expected 600 Cache wr in SC but got $sc" if( $sc!=600) ;
say "Error Expected 600 Cache wr in UC but got $uc" if( $uc!=600) ;

close($fh);


