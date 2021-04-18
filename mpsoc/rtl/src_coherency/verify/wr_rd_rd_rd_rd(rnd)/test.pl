#!/usr/bin/perl -w

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";

my $r=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 

#           2508130000: hnf (          6) a new req is accepted on addr         147584  txn 247 dbid  27 snpf_rdhit 1 snpf_status  I  spv 11000'
#           2508130000: hnf (          6) rspsnp will wait for 01010 Nodes to response to the request with txnid 208
my %txn;
my $error="";
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+hnf\s+\(\s+\d+\)/g;
   foreach my $s (@strings) {
	   $line =~ s/\s+/ /g; # remove extra spaces
	   my  ($t1, $c1, $a1, $tx1, $ntx1, $hit1, $st1, $spv1) = sscanf("\# %d: hnf ( %d) a new req is accepted on addr %d txn %d dbid %d snpf_rdhit %s snpf_status %s spv %s", $line);
	   my  ($t2, $c2,$spv2, $tx2) = sscanf("\# %d: hnf ( %d) rspsnp will wait for %s Nodes to response to the request with txnid %d", $line);	   
	
# say "  ($t1, $c1, $a1, $tx1, $ntx1, $hit1, $st1, $spv1)" if(defined $t1);#= sscanf("\# %d: hnf ( %d) a new req is accepted on addr: %d. info: txn=%d, dbid=%d, snpf_rdhit=%d,  snpf_status= %s, spv=%s ", $line);
 #say "  ($t2, $c2,$spv2, $tx2)" if(defined $t2);# = sscanf("\# %d: hnf ( %d) rspsnp will wait for %s Nodes to response to the request with txnid %d", $line);	   

	  if(defined $t1){ 
	   		my $id= "${c1}_${ntx1}";
	   		#Check that this ID was not be active before:
	   		if(defined $txn{$id}){
	   			 say "\tError at time $t1: got refill for addr $a1 while this address is still waiting for eviction. It was before refilled at $txn{$id} time\n";
	   			$r=1;
	   		}else {
	   			$txn{$id}=$spv1;
	   		}	   
	   }
	   if(defined $t2){ 
			my $id= "${c2}_${tx2}";
	   		#Check that this ID was active before:
	   		if(defined $txn{$id}){#remove it
			#check if we are sending to correct SPV
				if ($txn{$id} ne $spv2){
					$error=$error."\tError at time $t2: got different spv in wait list read $txn{$id} but waiting for $spv2 \n";
	   				$r=1;

				} 
	   			delete $txn{$id};	   			
	   		}else {
	   			#say "\tError at time $t2: got wait for txn $id while this txn is not accepted before\n";
	   			#$r=1;
	   		}	   
	   
	   
	   }
	#$r=1 if ($a != $b);
   }
}

 

foreach my $p (sort keys %txn) {
        $r=1;
	say "Error:  $p  $txn{$p} but not .\n ";
}

say "All evication are done correctly" if($r==0);
say "Eviction Error are detected:\n $error" if($r==1);
close($fh);
