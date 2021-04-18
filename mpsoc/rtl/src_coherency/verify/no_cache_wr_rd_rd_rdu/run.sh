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
my $sc0=0;
my $sc1=0;
my $uc0=0; 
my $uc1=0; 
my $uc2=0; 

open my $fh, "<", $file or die "Could not open $file $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+cch\s+\(\s+\d+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
   	my  ($t,$c,$a,$s, $b) = sscanf("\# %d: cch ( %d) Write %d with state %s on Address %d", $line);
	$uc0++ if($c == 0 && ($s eq "UC")); 
        $uc1++ if($c == 1 && ($s eq "UC")); 
	$uc2++ if($c == 2 && ($s eq "UC")); 
	$sc0++ if($c == 0 && ($s eq "SC")); 
	$sc1++ if($c == 1 && ($s eq "SC")); 

	say "failed on $line\n" if ($a != $b);
	$r=1 if ($a != $b);
   }
}



say "All writes on caches are done correctly" if($r==0); 
say "Error Expected 6000 Cache wr in cache RN0 in UC state but got $uc0" if( $uc0!=6000) ;
say "Error Expected 0 Cache wr in cache RN1 in UC state but got $uc1" if( $uc1!=0) ;
say "Error Expected 6000 Cache wr in cache RN0 in SC state but got $sc0" if( $sc0!=6000) ;
say "Error Expected 6000 Cache wr in cache RN1 in SC state but got $sc1" if( $sc1!=6000) ;
say "Error Expected 6000 Cache wr in  in cache RN2 UC state but got $uc2" if( $uc2!=6000) ;

close($fh);

'

#check taxn gen/release

perl -e '
use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";

my $r=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 

#             57110000: txn (          7) generates txnid 200
#             57110000: txn (          1) releases txnid: 105
my %txn;
my $error="";
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+txn\s+\(\s+\d+\)/g;
   foreach my $s (@strings) {
	   $line =~ s/\s+/ /g; # remove extra spaces
	   my  ($t1, $c1,$a1) = sscanf("\# %d: txn ( %d) generates txnid %d", $line);
	   my  ($t2, $c2,$a2) = sscanf("\# %d: txn ( %d) releases txnid: %d", $line);	   
	   if(defined $t1){ 
	   		my $id= "${c1}_${a1}";
	   		#Check that this ID was not be active before:
	   		if(defined $txn{$id}){
	   			$error=$error."\tError at time $t1: txn $a1 in core $c1 is generted once it was not released. It was before generated at $txn{$id} time\n";
	   			$r=1;
	   		}else {
	   			$txn{$id}=$t1;
	   		}	   
	   }
	   if(defined $t2){ 
			my $id= "${c2}_${a2}";
	   		#Check that this ID was active before:
	   		if(defined $txn{$id}){#remove it
	   			delete $txn{$id};	   			
	   		}else {
	   			$error=$error."\tError at time $t2: txn $a2 in core $c2 is released once it was not generated before\n";
	   			$r=1;
	   		}	   
	   
	   
	   }
	#$r=1 if ($a != $b);
   }
}


say "All txn are are generated/released correctly" if($r==0); 

foreach my $p (sort keys %txn) {
	say "Error: txn $p is generated at $txn{$p} but not released at end of simulation.\n ";
}

say "txn Error are detected:\n $error" if($r==1);
close($fh);
'
