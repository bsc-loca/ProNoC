#!/usr/bin/perl -w

use strict;
use warnings;

#add home dir in perl 5.6
use FindBin;
use lib $FindBin::Bin;
use rvp;


package TB_gen;

sub read_verilog_file{
	my @files            = @_;
	my %cmd_line_defines = ();
	my $quiet            = 1;
	my @inc_dirs         = ();
	my @lib_dirs         = ();
	my @lib_exts         = ();
	my $vdb = rvp->read_verilog(\@files,[],\%cmd_line_defines,
			  $quiet,\@inc_dirs,\@lib_dirs,\@lib_exts);

	my @problems = $vdb->get_problems();
	if (@problems) {
	    foreach my $problem ($vdb->get_problems()) {
		print STDERR "$problem.\n";
	    }
	    # die "Warnings parsing files!";
	}

	return $vdb;
}



sub get_ports_type{
	my ($vdb,$top_module)=@_;
	my %ports;
	
	foreach my $sig (sort $vdb->get_modules_signals($top_module)) {
	my ($line,$a_line,$i_line,$type,$file,$posedge,$negedge,
	 $type2,$s_file,$s_line,$range,$a_file,$i_file,$dims) = 
	   $vdb->get_module_signal($top_module,$sig);

		if($type eq "input" or $type eq "inout" or $type eq "output" ){
			$ports{$sig}=$type;
			
		}
	}
	return %ports;
}








sub get_ports_rang{
	my ($vdb,$top_module)=@_;
	my %ports;
	
	foreach my $sig (sort $vdb->get_modules_signals($top_module)) {
	my ($line,$a_line,$i_line,$type,$file,$posedge,$negedge,
	 $type2,$s_file,$s_line,$range,$a_file,$i_file,$dims) = 
	   $vdb->get_module_signal($top_module,$sig);

		if($type eq "input" or $type eq "inout" or $type eq "output" ){
		 
		
			
			$ports{$sig}=remove_all_white_spaces($range);
			
		}
	}
	return %ports;
}

sub remove_all_white_spaces($)
{
  my $string = shift;
  $string =~ s/\s+//g;
  return $string;
}

sub save_file {
	my  ($file_path,$text)=@_;
	open my $fd, ">$file_path" or die "could not open $file_path: $!";
	print $fd $text;
	close $fd;	
}


sub get_a_number_from_user {
	my ($text,$min,$max)=@_;
	my $num;
	do {
		print "Please enter the $text number:";
		$num = <STDIN>;
		chomp $num;
		print "\t $num is an invalid number\n" if((!( $num =~ /^[0-9]*$/) || ($num>$max) || $num <$min));	
		
	}while (!( $num =~ /^[0-9]*$/) || ($num>$max) || $num <$min);
	return $num;	
}



my ($infile, $outfile) = @ARGV;
if(!defined $infile){
	print "Usage: perl testbench_gen.pl  input_file.v [output_file.v]\n";
	exit();	
	
}

if(!defined $outfile){
	$outfile="testbech.v"
}	

print "testbench_gen.pl $infile, $outfile\n";

#step 1 parse the verilog  input file
my $vdb=read_verilog_file($infile);

#step 2 read modules name 
my @modules=sort $vdb->get_modules($infile);
my $size = @modules;
my $top;
my $num;
if ( $size==0){
	print "Error: Parser was not able to find any verilog module inside the $infile\n";
	exit();	
}elsif($size>1){
	print "Parser found multiple verilog modules inside the $infile. Please select the verilog top module:\n";
	my $n=0;
	foreach my $p (@modules) {
		$n++;
		print "\t $n:\t $p\n";
	}
	my $num = get_a_number_from_user ("topmodule",1,$size);
	$top=$modules[$num-1];	
}else{
	$top=$modules[0];
	
}

print "$top has been selected as the top module\n";


my $t="`timescale     1ns/1ps

module ${top}_testbench;
";




#step 3 get list of parameters
my $passparam;
my $passport;
$t=$t."// parameters\n";	
my %parameters = $vdb->get_modules_parameters_not_local($top);
my @parameters_order= $vdb->get_modules_parameters_not_local_order($top);
my $f=0;
foreach my $p (keys %parameters){
			#print "$p\n";
			my $v = $parameters{$p};
			$v =~s/[\n]//gs;
			$t=$t."\t parameter $p = $v;\n";
			$passparam= ($f==0)? "\t\t.${p}(${p})" : $passparam.",\n\t\t.${p}(${p})";	
			$f=1;		
}


#step 4 get list of ports
$t=$t."\n// Ports\n";	
my @ports_order=$vdb->get_module_ports_order($top);
my %Ptypes=get_ports_type($vdb,$top);
my %Pranges=get_ports_rang($vdb,$top);
$f=0;
foreach my $p (sort keys %Ptypes){
	my $Ptype=$Ptypes{$p};
	my $Prange=$Pranges{$p};		
	my $type=($Ptype eq "input")? "reg" : 'wire';
	
	$Prange= "[$Prange]" if (  $Prange ne '');
	
	$t=$t."\t $type $Prange $p;\n";	
	$passport= ($f==0)? "\t\t.${p}(${p})" : $passport.",\n\t\t.${p}(${p})";	
	$f=1;			
}	
	
#step 5 write topmodule instance
$t=$t."\n// top module instance\n \t $top ";
$t=$t."#(\n$passparam\n\t)\n" if defined ($passparam);
$t=$t."\tuut";
$t=$t."\n\t(\n$passport\n\t)" if defined ($passport);
$t=$t.";\n"; 
	


#step 6 define clock
my @posedges;
foreach my $p (@ports_order){
	my ($s_line,$s_a_line,$s_i_line,$s_type,$s_file,$s_p,$s_n,$s_type2,$s_r_file,$s_r_line,$range,$s_a_file,$s_i_file) = 
                      $vdb->get_module_signal($top,$p);
	push (@posedges,$p) if($s_p==1);
	
}

$size = @posedges;
my $clk;
if ($size ==1){
	$clk=$posedges[0];	
}elsif($size>1){
	print "Parser found two signals ever seen with posedge:\n";
	my $n=0;
	foreach my $p (@posedges) {
		$n++;
		print "\t $n:\t $p\n";
	}
	my $num = get_a_number_from_user ("which one is the clock",1,$size);
	$clk=$posedges[$num-1];		
	
}

$t=$t."
initial begin 
    $clk = 1'b0;
    forever $clk = #10 ~clk;
end 
" if(defined $clk);


#step 7 initial inputs
$t=$t."\ninitial begin\n"; 
foreach my $p (sort keys %Ptypes){
	my $Ptype=$Ptypes{$p};
	my $Prange=$Pranges{$p};		
	my $type=($Ptype eq "input")? "reg" : 'wire';
	
	$t=$t."\t $p=0;\n" if($type eq "reg" && $p ne $clk);	
}
$t=$t."\n //write your testbench code here\n 


end //initial "; 


#last step save the output file
$t=$t."\nendmodule";

save_file ($outfile,$t);

