use strict;
use Glib ':constants';
use Gtk2 -init;

sub cut_dir_path{ 
	my ($dir,$folder_name) = @_;
	my @p=  split (/$folder_name/,$dir);
	return $p[-1];
}

my $file="/home/alireza/work/git/hca_git/mpsoc_work/simulate/src_verilog";
my $exec_path="/home/alireza/work/git/hca_git/mpsoc_work/simulate";

$file =~ s/$exec_path//; 	
print $file."\n";
print cut_dir_path($file,$exec_path);
















####
