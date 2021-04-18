#!/bin/bash
result="passed";
message="";

r=$(grep -r "snf (          8) Write" ./transcript | wc -l);
if [ "$r" = "600" ]; then
	message="$message";  
else
        result="failed";
        message="$message Error: Expected 600 write on memory but got $r\n";  
fi

perl -e '

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";

my $r=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+cch\s+\(\s+\d+\)/g;
   foreach my $s (@strings) {
   $line =~ s/\s+/ /g;
   my  ($t,$c,$a, $b) = sscanf("\# %d: cch ( %d) Write %d with state UC on Address %d", $line);
	   
	say "failed on $line\n" if ($a != $b);
	#$r=1 if ($a != $b);
   }
}

say "All writes on caches are done correctly" if($r==0); 
close($fh);

'
