use strict;
use warnings;
use 5.012;
 
my $file = 'transcript';
my $core=$ARGV[0];

open my $fh, '<', $file or die "Could not open '$file' $!\n";
 
while (my $line = <$fh>) {
   chomp $line;
   my @strings = $line =~ /^#\s+\d+:\s+\w\w\w\s+\(\s+$core\)/g;
   foreach my $s (@strings) {
     say "'$line'";
   }
}
