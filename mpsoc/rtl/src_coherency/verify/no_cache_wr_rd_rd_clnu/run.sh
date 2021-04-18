#!/bin/bash

source "../check_functions.sh"

rm "./transcript";

export LM_LICENSE_FILE=1717@84.88.187.145
echo "Write 6000 cache block"

/home/alireza/intelFPGA_lite/questa/questasim/bin/vsim -c -do model.tcl
wait 
echo "End of Simulation"




result="passed";
message="";

r=$(grep -r "snf (          8) Write" ./transcript | wc -l);
if [ "$r" = "6000" ]; then
	message="$message"; 
	echo "Number of write on min mem passed: $r\n";   
else
        result="failed";
        echo " Error: Expected 6000 write on memory but got $r\n";  
fi


#check write on mem
perl -e '

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

'

# check write on cache
perl -e '

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";

my $r=0;
my $sc=0;
my $uc1=0; 
my $uc2=0; 

open my $fh, "<", $file or die "Could not open $file $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+cch\s+\(\s+\d+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
   	my  ($t,$c,$a,$s, $b) = sscanf("\# %d: cch ( %d) Write %d with state %s on Address %d", $line);
	$uc1++ if($c == 0 && ($s eq "UC")); 
        $uc2++ if($c >= 4 && ($s eq "UC")); 
	$sc++ if($s eq "SC"); 
	say "failed on $line\n" if ($a != $b);
	$r=1 if ($a != $b);
   }
}



say "All writes on caches are done correctly" if($r==0); 
say "Error Expected 12000 Cache wr in cache RN0 in UC state but got $uc1" if( $uc1!=12000) ;
say "Error Expected 0 Cache wr in syscache in UC state but got $uc2" if( $uc2!=0) ;
say "Error Expected 12000 Cache wr in  in SC state but got $sc" if( $sc!=12000) ;

close($fh);

'

check_general
