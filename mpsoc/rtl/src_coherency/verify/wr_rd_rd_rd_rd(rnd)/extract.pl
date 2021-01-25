use strict;
use warnings;
use 5.012;
 
my $file = 'transcript';
my $core=$ARGV[0];

open my $fh, '<', $file or die "Could not open '$file' $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /456960/g;      #/^#\s+\d+:\s+\w\w\w\s+\(\s+$core\)/g;
	my @strings = $line =~ /\w+ \(           4 \) txn \(\s+144\s+\)/g;  
 foreach my $s (@strings) {
     say "'$line'";
   }
}
