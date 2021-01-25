#!/bin/bash




check_all_snpf_are_freed () {

perl -e '

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
my $num=0;
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^\s+\d+:\s+hnf\s+\(\s+\d+\s+\)\s+snpf/g;
   
   foreach my $s (@strings) {
   	$line =~ s/\s+/ /g; # remove extra spaces
	my  ($t1, $c1, $addr,$l,$w,$st,$spv) = sscanf(" %d: hnf ( %d ) snpf addr ( %d ) in ram line ( %d ) way num ( %d ) is updated with status ( %s ) and spv ( %x )",$line);
	$txn{$addr}=$st if (defined $st);
	$num++;

  }
}

foreach my $s (sort keys %txn) {
   	print "Errr:  addr $s is left busy at the end of simulation\n" if($txn{$s} eq "BUSY");
	$error=1 if($txn{$s} eq "BUSY");
	
  }
say "All snpf adresses are freed at the end of simulation. total of $num snpf updates happend" if($error==0); 

close($fh);

'

}


check_taxn_gen_release(){

perl -e '
use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";

my $r=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 
#            319710000: gen (           4 ) releases txn (  92 )
#            267470000: gen (           0 ) generates txn ( 111 )


my %txn;
my $error="";
my $num=0;
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^\s+\d+:\s+gen\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	   $line =~ s/\s+/ /g; # remove extra spaces
	   my  ($t1, $c1,$a1) = sscanf(" %d: gen ( %d ) txn ( %d ) is generated", $line);
	   my  ($t2, $c2,$a2) = sscanf(" %d: gen ( %d ) txn ( %d ) is released", $line);	   
	   if(defined $t1){ 
	   		my $id= "${c1}_${a1}";
			$num++;
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



foreach my $p (sort keys %txn) {
        $r=1;
	say "Error: txn $p is generated at $txn{$p} but not released at end of simulation. ";
}

say "txn Error are detected:\n $error" if($r==1);
say "All of $num txns are generated/released correctly." if($r==0); 
close($fh);
'
}


check_eviction_buff(){

perl -e '
use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $file = "./transcript";

my $r=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 

#           2507590000: EVB (          5 ) refill buffer is written on addr         521280
#           2508130000: EVB (          5 )  addr         521280 is evicted from eviction buffer
my %txn;
my %txn2;
my $num=0;
my $error="";
while (my $line = <$fh>) {
   chomp $line;
   
   my @strings2 = $line =~ /^\s+\d+:\s+hnf\s+\(\s+\d+\s+\)\s+snpf/g;
   
   foreach my $s (@strings2) {
   	$line =~ s/\s+/ /g; # remove extra spaces
	my  ($t1, $c1, $addr,$l,$w,$st,$spv) = sscanf(" %d: hnf ( %d ) snpf addr ( %d ) in ram line ( %d ) way num ( %d ) is updated with status ( %s ) and spv ( %x )",$line);
	$txn2{$addr}=$st if (defined $st);	
  }


   my @strings = $line =~ /^\s+\d+:\s+EVB\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	   $line =~ s/\s+/ /g; # remove extra spaces
	   my  ($t1, $c1,$a1) = sscanf(" %d: EVB ( %d ) refill buffer is written on addr ( %d )", $line);
	   my  ($t2, $c2,$a2) = sscanf(" %d: EVB ( %d ) addr ( %d ) is evicted from eviction buffer", $line);	   
	
	  if(defined $t1){ 
	   		my $id= ${a1};
	   		#Check that this ID was not be active before:
	   		if(defined $txn{$id}){
	   			$error=$error."\tError at time $t1: got refill for addr $a1 while this address is still waiting for eviction. It was before refilled at $txn{$id} time\n";
	   			$r=1;
	   		}else {
	   			$txn{$id}=$t1;
                                $num++;
	   		}	
			#check if the eviction happened on non BUSY address
			if($txn2{$id} eq "BUSY"){
				$error=$error."\tError at time $t1: got refill for addr $a1 while this address is still BUSY in snpf\n";
	   			$r=1;

			}



   
	   }
	   if(defined $t2){ 
			my $id= ${a2};
	   		#Check that this ID was active before:
	   		if(defined $txn{$id}){#remove it
	   			delete $txn{$id};	   			
	   		}else {
	   			$error=$error."\tError at time $t2: got eviction on addr $a2 while it is not refilled before\n";
	   			$r=1;
	   		}	   
	   
	   
	   }
	#$r=1 if ($a != $b);
   }
}

 

foreach my $p (sort keys %txn) {
        $r=1;
	say "Error: evication on addr $p is refilled at $txn{$p} but not evicted at end of simulation.";
}

say "All evication of $num number are done correctly." if($r==0);
say "Total evication of $num number are done correctly." if($r==1);
say "Eviction Error are detected:\n $error." if($r==1);
close($fh);
'
}


get_repeat_num (){
REPEAT=$(perl -e '

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 

sub capture_number_after {
	my ($after,$text)=@_;
	my @q =split  (/$after/,$text);
	#my $d=$q[1];
	my @d = split (/[^0-9. ]/,$q[1]);
	return $d[0]; 
}



my $file = "test_localparam.v";
my $fh;
my $str = do {
	    		local $/ = undef;
	    		open $fh, "<", $file
			or die "could not open $file: $!";
	    		<$fh>;
		};
close($fh);
my $repeat=capture_number_after("localparam REPEAT_NUM=",$str);
print "$repeat\n";
')

}





#check write on mem

check_write_on_mem(){

perl -e'

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 

my $repeat=$ARGV[0];
print "repeat num=$repeat\n";



my $file = "./transcript";

my $r=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
my $w=0; 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^\s+\d+:\s+snf\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
        my  ($t,$c,$a,$b) = sscanf(" %d: snf ( %d ) Write ( %x ) on addr ( %d )", $line);
	if(defined $b){ 
		$w++;       
	}
   }
}


if($repeat != $w){ $r=1; say "Error: Expected $repeat write on memory but got $w";    }
say "Checked $w writes on main memory" if($r==0); 
close($fh);

' $1

}




# check write on cache

check_write_on_cache(){
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
   my @strings = $line =~ /^\s+\d+:\s+cch\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
   	my  ($t,$c,$a,$s, $b) = sscanf(" %d: cch ( %d ) Write ( %s ) with state %s on addr ( %d )", $line);
	$var++ if(($c >= $low) && ($c<=$high)  &&  ($s eq $state)); 
   }
}


if($var != $expect){
	say "Error Expected $expect Cache wr ($low<=n<=$high)  in $state state but got $var";
	$r=1;
} 
say "Checked: $expect Cache wr ($low<=n<=$high)  in $state state" if($r==0); 


close($fh);

' $1 $2 $3 $4


}





check_cache_write_value(){
perl -e '

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;

my $div=$ARGV[0];
my $mul=$ARGV[1];
my $add=$ARGV[2];
my $r=0;
 
my $file = "./transcript";
my $w=0;
open my $fh, "<", $file or die "Could not open $file $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^\s+\d+:\s+cch\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
   	my  ($t,$c,$a,$s, $b) = sscanf(" %d: cch ( %d ) Write ( %x ) with state %s on addr ( %d )", $line);
	my $expct=($b/$div)*$mul+$add;
	say "Write is Failed on $line. Expected value :$expct" if ($a != $expct);
	$r=1 if  ($a != $expct);
	$w++;
   }
}



say "All $w Written values on caches are correct" if($r==0); 


close($fh);

' $1 $2 $3 $4


}


check_cache_last_written_value_on_addr() {
perl -e '

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
   my @strings = $line =~ /^\s+\d+:\s+cch\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
   	my  ($t,$a,$s) = sscanf(" %d: cch ( $core ) Write ( %s ) with state %s on addr ( $addr )", $line);
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

' $1 $2 $3

}




check_mem_write_value(){

perl -e'

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $div=$ARGV[0];
my $mul=$ARGV[1];
my $add=$ARGV[2];
my $r=0;



my $file = "./transcript";
open my $fh, "<", $file or die "Could not open $file $!\n";
my $w=0;

while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^\s+\d+:\s+snf\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
        my  ($t,$c,$a,$b) = sscanf(" %d: snf ( %d ) Write ( %x ) on addr ( %d )", $line);
	if(defined $b){ 
		my $expct=($b/$div)*$mul+$add;	
		say "Write is Failed on $line. Expected value :$expct \n" if ($a != $expct);
		$r=1 if  ($a != $expct);
		$w++;
	}
   }
}

say "All $w written values on main_mem are correct" if($r==0); 

close($fh);

' $1 $2 $3 $4

}




check_last_mem_written_value_on_addr(){

perl -e'

use strict;
use warnings;
use String::Scanf; # imports sscanf()
use 5.012;
 
my $addr=$ARGV[0];
my $val=$ARGV[1];
my $r=0;



my $file = "./transcript";
open my $fh, "<", $file or die "Could not open $file $!\n";
my $w=0;
my $m;
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /\s+\d+:\s+snf\s+\(\s+\d+\s+\)/g;
   foreach my $s (@strings) {
	$line =~ s/\s+/ /g;
        my  ($t,$c,$a) = sscanf(" %d: snf ( %d ) Write ( %s ) on addr ( $addr )", $line);
	if(defined $a){ 
                $r=0;
                $m = $a; 
		$r=1 if  ($a eq $val);
		$w++;
	}
   }
}

say "checked. main_mem Addr $addr is written $w times. Last values on main_mem written as expected" if($r==1); 
say "Error.   main_mem Addr $addr is written $w times. Last values on main_mem is written as $m but expected $val" if($r==0);

close($fh);

' $1 $2 

}




count_string_num(){
	COUNTED=$(grep -r "$1" ./transcript | wc -l);
}



count_excl_fail(){
COUNTED=$(perl -e'

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
   my  ($t,$c,$a) = sscanf(" %d: rnf ( $rn ) txn ( %d ) got exclusive fail response", $line);
   $count++ if(defined $t);
 }
close($fh);
print "$count\n";
 
' $1)


}





count_injected_trace_num(){

	r=$(grep -r "read trace num" ./transcript | wc -l);
        echo "Total read trace number is: $r";

}






check_general (){

	check_taxn_gen_release
	check_all_snpf_are_freed
        check_eviction_buff

}



