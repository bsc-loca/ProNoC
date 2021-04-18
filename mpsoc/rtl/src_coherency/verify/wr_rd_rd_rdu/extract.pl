use strict;
use warnings;
use 5.012;
 
my $file = 'transcript';
my $core=$ARGV[0];

open my $fh, '<', $file or die "Could not open '$file' $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /addr\s+\(\s+576\s+\)/g;      #/^#\s+\d+:\s+\w\w\w\s+\(\s+$core\)/g;
	my @strings = $line =~ /\w+ \(           5 \) txn \(\s+239\s+\)/g;  
 foreach my $s (@strings) {
     say "'$line'";
   }
}
