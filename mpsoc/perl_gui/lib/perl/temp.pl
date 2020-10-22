#! /usr/bin/perl

use strict;
use warnings;




sub replace_value{
	my ($string,$param,$value)=@_;

	my $new_string=$string;
	#print "$new_range\n";
	my $new_param= $value;
	($new_string=$new_string)=~ s/\b$param\b/$new_param/g;
	return eval $new_string;

		
}	



print  replace_value("WB_Aw+2","WB_Aw",20);

1;
