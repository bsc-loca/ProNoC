#!/usr/bin/perl -w
package ProNOC;




use File::Copy::Recursive qw(dircopy);
use File::Basename;
use File::Copy;
use Data::Dumper;
use File::Find::Rule;

#add home dir in perl 5.6
use FindBin;
use lib $FindBin::Bin;
use constant::boolean;




use strict;
use warnings;

use base 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw{
	models	
});

my $app = __PACKAGE__->new();



my $dirname = dirname(__FILE__);
require "$dirname/src/src.pl";

my $paralel_run= 4;
if(defined $ARGV[0]){
 $paralel_run= $ARGV[0] if(is_integer($ARGV[0]));
}
print "maximum number of parallel simulation is $paralel_run\n";




my @log_report_match =("Error","Warning" ); 



save_file ("$dirname/report","Verification Results:\n");


copy_src_files();

gen_models();

compile_models($paralel_run,$app);

check_compilation(@log_report_match);

run_all_models($paralel_run);

print "done!\n"




