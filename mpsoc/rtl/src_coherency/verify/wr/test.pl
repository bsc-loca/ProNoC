#!/usr/bin/perl -w


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
my $error='';
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
say "txn Error are detected:\n $error" if($r==1);
close($fh);


