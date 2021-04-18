#!/bin/bash

#!/bin/bash

source "../check_functions.sh"
source "../run_sim.sh"


full_path=$(realpath $0)
dir_path=$(dirname $full_path)
p_path=$(dirname $dir_path )
pname1=$(basename $dir_path)
pname2=$(basename $p_path)
log_path="${PRONOC_WORK}/simulation/$pname2/$pname1"


echo "save logfile in $log_path"
mkdir -p "$log_path"
cp -f ./test_localparam.v   $log_path/test_localparam.v


transcript="$log_path/transcript"
rm -f "$transcript"

run_vsim $transcript	

ln -s $transcript ./transcript


cd $log_path; 



result="passed";
message="";



#check write on mem
get_repeat_num 
check_write_on_mem $REPEAT




# check write on cache
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
	$r=1 if ($a != $b);
   }
}

say "All writes on caches are done correctly" if($r==0); 
close($fh);

'




check_general


