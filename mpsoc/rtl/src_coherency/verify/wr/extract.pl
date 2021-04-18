use strict;
use warnings;
use 5.012;
 
my $file = 'transcript';
my $core=$ARGV[0];

open my $fh, '<', $file or die "Could not open '$file' $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /gen\s?\(\s+4\s+\)\s+releases txn\s+\(\s+203\s+\)/g;      #/^#\s+\d+:\s+\w\w\w\s+\(\s+$core\)/g;
  # my @strings = $line =~ /26624/g; 	  

 foreach my $s (@strings) {
     say "'$line'";
   }
}
