#!/usr/bin/perl -w

use Proc::Background;
use File::Path qw( rmtree );

my $script_path = dirname(__FILE__);
my $dirname = "$script_path/..";


my $rtl_dir = "$ENV{PRONOC_WORK}/verify/rtl";
my $work    = "$ENV{PRONOC_WORK}/verify/work";
my $src_verilator = "$dirname/../src_verilator";
my $src = "$script_path";
my $report = "$dirname/report";

require "$dirname/../perl_gui/lib/perl/common.pl";
require "$dirname/../perl_gui/lib/perl/topology.pl";







my $pp;
	$pp= do "$src/deafult_noc_param";
	die "Error reading: $@" if $@;

	my $param = $pp->{'noc_param'};
	my %default_noc_param=%{$param};
	my @params=object_get_attribute_order($pp,'noc_param');



#read default param


sub gen_noc_param_h{
	my $mpsoc=shift;
	my $param_h="\n\n//NoC parameters\n";
	
	my $topology = $mpsoc->object_get_attribute('noc_param','TOPOLOGY');
	$topology =~ s/"//g;
	$param_h.="\t#define  IS_${topology}\n";
	
	
	my @params=$mpsoc->object_get_attribute_order('noc_param');
	my $custom_topology = $mpsoc->object_get_attribute('noc_param','CUSTOM_TOPOLOGY_NAME');
	foreach my $p (@params){
		my $val=$mpsoc->object_get_attribute('noc_param',$p);
		next if($p eq "CUSTOM_TOPOLOGY_NAME");
		$val=$custom_topology if($p eq "TOPOLOGY" && $val eq "\"CUSTOM\"");
		$param_h=$param_h."\t#define $p\t$val\n";
		
		#print "$p:$val\n";
		
	}
	my $class=$mpsoc->object_get_attribute('noc_param',"C");
	my $str;
	if( $class > 1){
		for (my $i=0; $i<=$class-1; $i++){
			my $n="Cn_$i";
			my $val=$mpsoc->object_get_attribute('class_param',$n);
			$param_h=$param_h."\t#define $n\t$val\n";
		}
		$str="CLASS_SETTING  {";
		for (my $i=$class-1; $i>=0;$i--){
			$str=($i==0)?  "${str}Cn_0};\n " : "${str}Cn_$i,";
		}
	}else {
		$str="CLASS_SETTING={V{1\'b1}}\n";
	}	
	#add_text_to_string (\$param_h,"\t#define $str");
	 
	my $v=$mpsoc->object_get_attribute('noc_param',"V")-1;
	my $escape=$mpsoc->object_get_attribute('noc_param',"ESCAP_VC_MASK");
	if (! defined $escape){
		#add_text_to_string (\$param_h,"\tlocalparam [$v	:0] ESCAP_VC_MASK=1;\n");
		#add_text_to_string (\$pass_param,".ESCAP_VC_MASK(ESCAP_VC_MASK),\n"); 
	}
	#add_text_to_string (\$param_h," \tlocalparam  CVw=(C==0)? V : C * V;\n");
	#add_text_to_string (\$pass_param,".CVw(CVw)\n");
	
	
	
	
	return  $param_h;	
}


sub gen_sim_parameter_h {
	my ($param_h,$includ_h,$ne,$nr,$router_p,$fifow)=@_;
	
	$param_h =~ s/\d\'b/ /g;
	my $text=  "
#ifndef     INCLUDE_PARAM
	#define   INCLUDE_PARAM \n \n 

	$param_h 
	 	
 	#define NE  $ne
 	#define NR  $nr
 	#define ROUTER_P_NUM $router_p
 	
	extern Vtraffic		*traffic[NE];
	extern int reset,clk;
	
	//simulation parameter	
	#define MAX_RATIO   1000
	#define AVG_LATENCY_METRIC \"HEAD_2_TAIL\"
	#define TIMSTMP_FIFO_NUM   $fifow
	
	$includ_h
\n \n \#endif" ; 
	return $text;	
}	


sub extract_and_update_noc_sim_statistic {
	my ($stdout)=@_;
	my $avg_latency =capture_number_after("average packet latency =",$stdout);
	my $avg_flit_latency =capture_number_after("average flit latency =",$stdout);
	my $sd_latency =capture_number_after("standard_dev =",$stdout);
	my $avg_thput =capture_number_after("Avg throughput is:",$stdout);
	my $total_time =capture_number_after("simulation clock cycles:",$stdout);
	my $latency_perhop = capture_number_after("average latency per hop =",$stdout);
	my %packet_rsvd_per_core = capture_cores_data("total number of received packets:",$stdout);
	my %worst_rsvd_delay_per_core = capture_cores_data('worst-case-delay of received packets \(clks\):',$stdout);
	my %packet_sent_per_core = capture_cores_data("total number of sent packets:",$stdout);
	my %worst_sent_delay_per_core = capture_cores_data('worst-case-delay of sent packets \(clks\):',$stdout);


}

sub get_model_parameter {
	my $model =shift;	
	my $o;
	$o= do $model;
    die "Error reading: $@" if $@;
	my %temp;
	foreach my $p (@params){
		$temp{$p} = $default_noc_param{$p};       
	}
	foreach my $p (sort keys %model){
		$temp{$p} = $model{$p};
	}
	return %temp;
}

sub gen_noc_localparam_v {
	my ($m,$ref) = @_;
	my %model = %{$ref};
	my %temp;

    
	foreach my $p (@params){
		$temp{$p} = $default_noc_param{$p};
        $m->{noc_param}{$p}=$default_noc_param{$p};
	}
	foreach my $p (sort keys %model){
		$temp{$p} = $model{$p};
		$m->{noc_param}{$p}=$model{$p};
	}

	object_add_attribute_order($m,'noc_param',@params);

	my $param_v="`ifdef NOC_LOCAL_PARAM \n";
	foreach my $p (@params){
		$param_v.="localparam $p = $temp{$p};\n";
	}
	$param_v.="`endif\n";

	my ($nr,$ne,$router_p,$ref_tops,$includ_h) = get_noc_verilator_top_modules_info($m);
	my %tops = %{$ref_tops};	
	$tops{Vtraffic} = "--top-module traffic_gen_top";	

	my $param_h=gen_noc_param_h($m);
	$includ_h = gen_sim_parameter_h($param_h,$includ_h,$ne,$nr,$router_p,'16');	

	return ($param_v,$includ_h,\%tops);

}


sub copy_src_files{
	
	if(defined $ENV{PRONOC_WORK}){
		rmtree("$rtl_dir");
	 	unless (-d "$rtl_dir"){
			print "make a working directory inside $rtl_dir\n"; 
			mkdir("$rtl_dir", 0700);
		}
	}else{
			print  "Please set PRONOC_WORK variable first!";
			exit;
	}
	
	dircopy("$dirname/../rtl/src_noc" , "$rtl_dir/src_noc") or die("$!\n") unless (-d "$rtl_dir/src_noc");
    unlink "$rtl_dir/src_noc/noc_localparam.v";
    for my $file (glob "$dirname/../rtl/*.v") {
   		 copy $file, "$rtl_dir" or die $! ; 
	}
}




sub gen_file_list{
	my $path=shift;
	my $f="+incdir+$rtl_dir/
+incdir+$rtl_dir/src_noc/
+incdir+$path
";

	my @files = File::Find::Rule->file()
                          ->name( '*.v','*.V','*.sv' )
                          ->in( "$rtl_dir" );

 	#make sure source files have key word 'module' 
	my @sources;
	foreach my $p (@files){
		push (@sources,$p)	if(check_file_has_string($p,'endpackage')); 
	}
	foreach my $p (@files){
		push (@sources,$p)	if(check_file_has_string($p,'module')); 
	}
	my $files = join ("\n",@sources);
	$f.=$files;
 

	open(FILE,  ">$path/file_list.f") || die "Can not open: $!";
	print FILE $f;
	close FILE;
}



sub gen_models {
	my @models = glob("$dirname/models/*");
    mkdir("$work", 0700);
	foreach my $m (@models){
		print "$m\n";
		#make noc localparam
		my $o;
		$o= do $m;
        die "Error reading: $@" if $@;
		my $param = $o->{'noc_param'};
		my ($fname,$fpath,$fsuffix) = fileparse("$m",qr"\..[^.]*$");


		my $name = $fname;
		my $make =$o->{'makefile'};
		
        
		my 	($param_v,$include_h,$tops)=   gen_noc_localparam_v( $o,$param);

		mkdir("$work/$name", 0700);
		rmtree("$work/$name/obj_dir");
        mkdir("$work/$name/obj_dir", 0700);
		save_file("$work/$name/noc_localparam.v",$param_v);
		
		#generate file list		
		gen_file_list("$work/$name");
		#copy verlator.sh file
		my $compile = $param = $o->{'compile'};
		copy "$src/$compile", "$work/$name/verilator.sh";
		print "copy $src/$compile, $work/$name/verilator.sh\n";
		#copy C files
		my @files = File::Find::Rule->file()
                          ->name( '*.h' )
                          ->in( "$src_verilator" );
		foreach my $p (@files){
			copy $p, "$work/$name/obj_dir/";
		}
		copy "$src_verilator/simulator.cpp", "$work/$name/obj_dir/testbench.cpp";
		#generate make file
		gen_verilator_makefile($tops,"$work/$name/obj_dir/Makefile");
		#generate param.h file
		
	
		save_file("$work/$name/obj_dir/parameter.h",$include_h);
		
		 
	}

}






sub compile_models{
	my($paralel_run)=@_;
	my @models = glob("$dirname/models/*");
	#generate compile command
	my $i=0;
	my $cmd;
	foreach my $m (@models){
		my ($fname,$fpath,$fsuffix) = fileparse("$m",qr"\..[^.]*$");
		$cmd.=" cd $work/$fname; bash verilator.sh >  $work/$fname/out.log 2>&1  &\n";
		$i++;
		$cmd.="wait\n" if(($i % $paralel_run)==0) ;
	}
	$cmd.="wait\n" if(($i % $paralel_run)!=0) ;
	#run command in terminal
	print "*******************compile models******************\n$cmd\n";
	my $proc1 = Proc::Background->new($cmd);
	$proc1->alive;
	$proc1->wait;
	$proc1->die;

}
sub check_compilation_log {
	my ($name,@log_report_match) = @_;
	$logfile	= "$work/$name/out.log";	
	
	my @found;
	foreach my $m (@log_report_match){ 
		open $INPUT, '<', $logfile;
		push(@found , grep ( /$m/, <$INPUT>)) ;
		close($INPUT);
	}
	
	
	foreach my $line (@found) {
              append_text_to_file($report,"\t $line\n");
    }
   


}





sub check_compilation {
	my @log_report_match=@_;
	my @models = glob("$dirname/models/*");
	foreach my $m (@models){
		my ($name,$fpath,$fsuffix) = fileparse("$m",qr"\..[^.]*$");
		append_text_to_file($report,"****************************$name : Compile *******************************:\n");
		#check if testbench is generated successfully	
		if(-f "$work/$name/obj_dir/testbench"){
			append_text_to_file($report,"\t model is generated successfully.\n"); 
			check_compilation_log($name,@log_report_match);

		}else{
			append_text_to_file($report,"\t model generation is FAILED.\n"); 
			check_compilation_log($name,@log_report_match);
		}

	}
}


sub run_all_models {
	my ($paralel_run) =@_;
	my @models = glob("$dirname/models/*");
    foreach my $m (@models){
		run_traffic ($m,'random',$paralel_run);
	}
	foreach my $m (@models){
		run_traffic ($m,'transposed 1',$paralel_run);
	}
}



sub run_traffic {
	my ($model,$traffic,$paralel_run)=@_;
	my ($name,$fpath,$fsuffix) = fileparse("$model",qr"\..[^.]*$");
	
	my %param = get_model_parameter($model);
	my $min_pck = $param{'MIN_PCK_SIZE'};
	
    append_text_to_file($report,"****************************$name	: $traffic traffic *******************************:\n");
	unless (-f "$work/$name/obj_dir/testbench"){
		append_text_to_file($report,"\t failed. Simulation model is not avaialable\n");
		return;
	}

	mkdir("$work/$name/${traffic}_results/", 0700);

	my $i=0;
	my $cmd;
	for (my $inject=75; $inject<=80; $inject+=5){
		$cmd.="$work/$name/obj_dir/testbench -t \"$traffic\"   -m \"R,$min_pck,10\"  -n  20000  -c	10000   -i $inject -p \"100,0,0,0,0\" >  $work/$name/${traffic}_results/sim$inject 2>&1  &\n";
		$i++;
		$cmd.="wait\n" if(($i % $paralel_run)==0) ;
	}
	$cmd.="wait\n" if(($i % $paralel_run)!=0) ;
	#run command in terminal
	print "*******************run models******************\n$cmd\n";
	my $proc1 = Proc::Background->new($cmd);
	$proc1->alive;
	$proc1->wait;
	$proc1->die; 

	check_sim_results("$work/$name/${traffic}_results/");

}




sub check_sim_results{
	my $results_path=shift;
	my @results = glob("$results_path/*");
	#check for error
	
	
	foreach my $result (@results) {
		my @errors = unix_grep("$result","ERROR:");
		if (scalar @errors  ){
			append_text_to_file($report,"\t Error in running simulation: @errors \n");				
			return;						
		}		
	}
	append_text_to_file($report,"\t passed  \n");		
}

