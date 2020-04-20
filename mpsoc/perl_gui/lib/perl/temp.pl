#!/usr/bin/perl -w
#use strict;
use warnings;
require "common.pl";
use FindBin;
use lib $FindBin::Bin;

use String::Scanf; # imports sscanf()

my @string=(
'R:0000000002:R
done','
R:4820000002:R
done','
R:4920000002:R
done','
R:0a20000002:R
done','
R:6120000002:R
done','
R:6c20000002:R
done','
R:6920000002:R
done','
R:7220000002:R
done','
R:6520000002:R
done','
R:7a20000002:R
done','
R:6120000002:R
done','
R:0a20000002:R
done','
R:6120000002:R
done','
R:6c20000002:R
done','
R:6920000002:R
done','
R:7220000002:R
done','
R:6520000002:R
done','
R:6120000002:R
done','
R:0020000002:R
done','
R:0020000002:R
done','
R:0020000002:R
done','
R:0020000002:R
done','
R:0020000002:R
done','
R:0020000002:R
done','
R:0020000002:R
done','
R:0020000002:R
done','
R:0020000002:R
done'
);

# Converts pairs of hex digits to asci
sub hex_to_ascii { # $ascii ($hex)
  my $s = shift;
 
  return pack 'H*', $s;
}


use Glib qw/TRUE FALSE/;
foreach my $str(@string){
	my ($hex)= sscanf("R:%s:R",$str);
	my $char= substr $hex, 0, 2;
	if($char ne '00'){	
		$char =hex_to_ascii(substr $hex, 0, 2);	
		print "$char";
	}
}

		

0;
