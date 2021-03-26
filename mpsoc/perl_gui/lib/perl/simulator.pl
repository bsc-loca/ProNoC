#! /usr/bin/perl -w
use Glib qw/TRUE FALSE/;
use strict;
use warnings;
use FindBin;
use lib $FindBin::Bin;



use GD::Graph::Data;
use emulator;
use GD::Graph::colour qw/:colours/;

use File::Basename;
use File::Path qw/make_path/;
use File::Copy;
use File::Find::Rule;

require "widget.pl"; 
require "mpsoc_gen.pl"; 
require "emulator.pl";
require "mpsoc_verilog_gen.pl"; 
require "readme_gen.pl";
require "graph.pl";


use List::MoreUtils qw(uniq);




sub generate_sim_bin_file {
	my ($simulate,$info_text) =@_;
	#check simulator envirement
	my $simulator =$simulate->object_get_attribute("Simulator");
	#TODO generate .sim file only for modelsim simulator
		
	$simulate->object_add_attribute('status',undef,'run');
	set_gui_status($simulate,"ref",1);
	
	my ($nr,$ne,$router_p,$ref_tops,$includ_h)= get_noc_verilator_top_modules_info($simulate);
	my %tops = %{$ref_tops};
	
	$tops{Vtraffic} = "--top-module traffic_gen_top_v";	
	my $target_dir= "$ENV{PRONOC_WORK}/simulate";
	
	my $dir = Cwd::getcwd();
	my $project_dir	  = abs_path("$dir/..");
	my $src_verilator_dir="$project_dir/src_verilator";
	my $src_noc_dir="$project_dir/rtl/src_noc";	
	my $script_dir="$project_dir/script";
	my $testbench_file= "$src_verilator_dir/simulator.cpp";
	
	my $target_verilog_dr ="$target_dir/src_verilog";
	my $obj_dir ="$target_dir/verilator/obj_dir/";
	
	rmtree("$target_dir/verilator");
	rmtree("$target_verilog_dr");
	mkpath("$target_verilog_dr/",1,01777);
	
	#copy src_verilator files
	my @files_list = File::Find::Rule->file()
                            ->name( '*.v','*.V','*.sv' )
                            ->in( "$src_verilator_dir" );

	#make sure source files have key word 'module' 
	my @files;
	foreach my $p (@files_list){
		push (@files,$p)	if(check_file_has_string($p,'module')); 
	}
	push (@files,$src_noc_dir);
	push (@files,"$project_dir/rtl/arbiter.v");
	push (@files,"$project_dir/rtl/main_comp.v");
	
		
	#my @files=(
	#	$src_noc_dir,
	#	"$src_verilator_dir/noc_connection.sv",
	#	"$src_verilator_dir/mesh_torus_noc_connection.sv",			
	#	"$src_verilator_dir/router_verilator.v",
	#	"$src_verilator_dir/traffic_gen_verilator.v"		
	#);
	
	copy_file_and_folders (\@files,$project_dir,$target_verilog_dr);
	copy_file_and_folders (\@files,$project_dir,"$target_dir/modelsim/src_verilog/");
	
	my $target_modelsim_dr ="$target_dir/modelsim/src_modelsim";
	my $src_modelsim_dir="$project_dir/rtl/src_modelsim";	
	rmtree("$target_modelsim_dr");
	mkpath("$target_modelsim_dr/",1,01777);
	
	#copy src_verilator files
	@files_list = File::Find::Rule->file()
                            ->name( '*.v','*.V','*.sv' )
                            ->in( "$src_modelsim_dir" );

	#make sure source files have key word 'module' 
	@files=();
	foreach my $p (@files_list){
		push (@files,$p)	if(check_file_has_string($p,'module')); 
	}
	copy_file_and_folders (\@files,$project_dir,$target_modelsim_dr);
	
		
		
	
	#check if we have a custom topology 
	my $topology=$simulate->object_get_attribute('noc_param','TOPOLOGY');
	if ($topology eq '"CUSTOM"'){ 
		my $name=$simulate->object_get_attribute('noc_param','CUSTOM_TOPOLOGY_NAME');
		$name=~s/["]//gs;     
		my $dir1=  get_project_dir()."/mpsoc/rtl/src_topolgy/$name";
		my $dir2=  get_project_dir()."/mpsoc/rtl/src_topolgy/common";
		my @files = File::Find::Rule->file()
                            ->name( '*.v','*.V','*.sv' )
                            ->in( "$dir1" );
		copy_file_and_folders (\@files,$project_dir,$target_verilog_dr);
		copy_file_and_folders (\@files,$project_dir,"$target_dir/modelsim/src_verilog/");
		
		@files = File::Find::Rule->file()
                            ->name( '*.v','*.V','*.sv' )
                            ->in( "$dir2" );
                         
		copy_file_and_folders (\@files,$project_dir,$target_verilog_dr);
		copy_file_and_folders (\@files,$project_dir,"$target_dir/modelsim/src_verilog/");
		
		
	
	}
	# generate NoC parameter file
	#my ($noc_param,$pass_param)=gen_noc_param_v($simulate);
	#open(FILE,  ">$target_verilog_dr/parameter.v") || die "Can not open: $!";
	my $fifow=$simulate->object_get_attribute('fpga_param','TIMSTMP_FIFO_NUM');
	gen_noc_localparam_v_file($simulate,"$target_verilog_dr/src_noc");

	#generate routers with different port num		
	my $cpu_num = $simulate->object_get_attribute('compile', 'cpu_num');
	my $result = verilator_compilation (\%tops,$target_dir,$info_text,$cpu_num);
	
	
	if ($result){
		add_colored_info($info_text,"Veriator model has been generated successfully!\n",'blue');
	}else {
		add_colored_info($info_text,"Verilator compilation failed!\n","red"); 
		$simulate->object_add_attribute('status',undef,'programmer_failed');
		set_gui_status($simulate,"ref",1);
		print "gen-ended!\n";
		return;
	}
	
	#copy simulation c header files
	@files = File::Find::Rule->file()
                            ->name( '*.h')
                            ->in( "$src_verilator_dir" );
	
	copy_file_and_folders (\@files,$project_dir,$obj_dir);
	copy($testbench_file,"$obj_dir/testbench.cpp"); 
		
	#compile the testbench
	my $param_h=gen_noc_param_h($simulate);
	my $text = gen_sim_parameter_h($param_h,$includ_h,$ne,$nr,$router_p,$fifow);	
	
	$param_h =~ s/\d\'b/ /g;
	open(FILE,  ">$obj_dir/parameter.h") || die "Can not open: $!";
	print FILE  "$text";
	
	close FILE;
	
	
	
	#$result = run_make_file("$obj_dir/",$info_text,'lib');	
	my $lib_num=0;
	add_colored_info($info_text,"Makefie will use the maximum number of $cpu_num core(s) in parallel for compilation\n",'green');
	my $length=scalar (keys %tops);
	my $cmd="";
	foreach my $top (sort keys %tops) { 
		$cmd.= "lib$lib_num & ";
		$lib_num++;				
		if( $lib_num % $cpu_num == 0 || $lib_num == $length){
			$cmd.="wait\n";
			$result = run_make_file("$obj_dir/",$info_text,$cmd);	
			if ($result ==0){
				$simulate->object_add_attribute('status',undef,'programmer_failed');
				set_gui_status($simulate,"ref",1);
				print "gen-ended!\n";
				return;
			}		
			$cmd="";
		}else {
			$cmd.=" make ";
		}	
	}
		
		
	
	
	run_make_file("$obj_dir/",$info_text);	
	if ($result ==0){
		$simulate->object_add_attribute('status',undef,'programmer_failed');
		set_gui_status($simulate,"ref",1);
		print "gen-ended!\n";
		return;
	}		
	
	
	
	
	#my $end = localtime; 		
	

	
	#save the binarry file
	my $bin= "$obj_dir/testbench";
	my $path=$simulate->object_get_attribute ('sim_param',"BIN_DIR");
	my $name=$simulate->object_get_attribute ('sim_param',"SAVE_NAME");
	
	#create project directory if it does not exist
	my	($stdout,$exit)=run_cmd_in_back_ground_get_stdout("mkdir -p $path" );
	if($exit != 0 ){ 	print "$stdout\n";  print "gen-ended!\n";	message_dialog($stdout,'error'); return;}
	

	
	#check if the verilation was successful
	if ((-e $bin)==0) {#something goes wrong 		
    	#message_dialog("Verilator compilation was unsuccessful please check the $path/$name.log files for more information",'error'); 
    	add_colored_info($info_text,"Verilator compilation failed!\n","red"); 
    	$simulate->object_add_attribute('status',undef,'programmer_failed');
		set_gui_status($simulate,"ref",1);
		print "gen-ended!\n";
		return;
	}
	
	
	#copy ($bin,"$path/$name") or  die "Can not copy: $!";
	($stdout,$exit)=run_cmd_in_back_ground_get_stdout("cp -f $bin $path/$name");
	if($exit != 0 ){ 	print "$stdout\n";  print "gen-ended!\n";	message_dialog($stdout,'error'); return;}
		
	#save noc info
	open(FILE,  ">$path/$name.inf") || die "Can not open: $!";
	print FILE perl_file_header("$name.inf");
	my %pp;
	$pp{'noc_param'}= $simulate->{'noc_param'};
	$pp{'sim_param'}= $simulate->{'sim_param'};
	print FILE Data::Dumper->Dump([\%pp],["emulate_info"]);
	close(FILE) || die "Error closing file: $!";		
	
	print "gen-ended successfully!\n";
	message_dialog("The simulation binary file has been successfully generated in $path!"); 

	$simulate->object_add_attribute('status',undef,'ideal');
	set_gui_status($simulate,"ref",1);
	
	#make project dir
	#my $dir= $simulate->object_get_attribute ("sim_param","BIN_DIR");
	#my $name=$simulate->object_get_attribute ("sim_param","SAVE_NAME");	
	#my $path= "$dir/$name";
	#add_info($info_text, "$src_verilator_dir!\n");
	#mkpath("$path",1,01777);
}






##########
#	save_simulation
##########
sub save_simulation {
	my ($simulate)=@_;
	# read emulation name
	my $name=$simulate->object_get_attribute ("simulate_name",undef);	
	my $s= (!defined $name)? 0 : (length($name)==0)? 0 :1;	
	if ($s == 0){
		message_dialog("Please set Simulation name!");
		return 0;
	}
	# Write object file
	open(FILE,  ">lib/simulate/$name.SIM") || die "Can not open: $!";
	print FILE perl_file_header("$name.SIM");
	print FILE Data::Dumper->Dump([\%$simulate],["simulate"]);
	close(FILE) || die "Error closing file: $!";
	message_dialog("Simulation has saved as lib/simulate/$name.SIM!");
	return 1;
}

#############
#	load_simulation
############

sub load_simulation {
	my ($simulate,$info)=@_;
	my $file;
	my $dialog =  gen_file_dialog (undef, 'SIM');	
	
	my $dir = Cwd::getcwd();
	$dialog->set_current_folder ("$dir/lib/simulate");		


	if ( "ok" eq $dialog->run ) {
		$file = $dialog->get_filename;
		my ($name,$path,$suffix) = fileparse("$file",qr"\..[^.]*$");
		if($suffix eq '.SIM'){
			my ($pp,$r,$err) = regen_object($file);
			if ($r){		
				add_colored_info($info,"**Error reading $file file: $err\n",'red');
				$dialog->destroy;
				return;
			} 
			#deactivate running simulations
			$pp->object_add_attribute('status',undef,'ideal');
			my @samples =$pp->object_get_attribute_order("samples");
			foreach my $sample (@samples){
				my $st=$pp->object_get_attribute ($sample,"status");	
				$pp->object_add_attribute ($sample,"status",'done');# if ($st eq "run");	
			}
			clone_obj($simulate,$pp);
			#message_dialog("done!");				
		}					
     }
     $dialog->destroy;
}




sub check_hotspot_parameters{
	my ($self,$sample)=@_;
	my $num=$self->object_get_attribute($sample,"HOTSPOT_NUM");
	my $result;
	if (defined $num){
		my @hotspots;	
		my $acuum=0;	
		for (my $i=0;$i<$num;$i++){
			my $w1 = $self->object_get_attribute($sample,"HOTSPOT_CORE_$i");
			if( grep (/^\Q$w1\E$/,@hotspots)){
				$result="Error: Tile $w1 has been selected for Two or more than two hotspot nodes.\n";					
			}
			push( @hotspots,$w1);			
			my $w2 = $self->object_get_attribute($sample,"HOTSPOT_PERCENT_$i");
			$acuum+=$w2;
					
		}
		if ($acuum > 100){
			$result="Error: The traffic summation of all hotspot nodes is $acuum. The hotspot summation must be <=100";
			
		}
	}
	return $result;
}


sub get_simulator_noc_configuration{
	my ($self,$mode,$sample,$set_win) =@_;
	
	
	
	
	my $table=def_table(10,2,FALSE);
	my $row=0;
	
	my $scrolled_win = add_widget_to_scrolled_win ($table);
		
	my $ok = def_image_button('icons/select.png','OK');
	my $mtable = def_table(10, 1, TRUE);

	$mtable->attach_defaults($scrolled_win,0,1,0,9);
	$mtable-> attach ($ok , 0, 1,  9, 10,'expand','shrink',2,2); 
	
	

	$set_win ->signal_connect (destroy => sub{		
		$self->object_add_attribute("active_setting",undef,undef);
		
	});	
		
	
	my $dir = Cwd::getcwd();
	my $open_in	  = abs_path("$ENV{PRONOC_WORK}/simulate");	
	
	
	attach_widget_to_table ($table,$row,gen_label_in_left(" Search Path:"),gen_button_message ("Select the Path where the verilator simulation files are located. Different NoC verilated models can be generated using Generate NoC configuration tab.","icons/help.png"), 
	get_dir_in_object ($self,$sample,"sof_path",undef,'ref_set_win',1,$open_in)); $row++;
	
	$open_in	= $self->object_get_attribute($sample,"sof_path");	
	
	
	
	my @files = glob "$open_in/*";
	my $exe_files="";
	foreach my $file (@files){
		#print "$file is executable\n" if( -x $file && -f $file) ;
		
		if( -x $file && -f $file){
			my ($name,$path,$suffix) = fileparse("$file",qr"\..[^.]*$");
			$exe_files="$exe_files,$name"
			
		} 
		
	}
		
	attach_widget_to_table ($table,$row,gen_label_in_left(" Verilated Model:"),gen_button_message ("Select the verilator simulation file. Different NoC simulators can be generated using Generate NoC configuration tab.","icons/help.png"), 
	gen_combobox_object ($self,$sample, "sof_file", $exe_files, undef,'ref_set_win',1)); $row++;
                            
   
   
    my $coltmp=0;
    ($row,$coltmp)=add_param_widget  ($self, "Traffic Type", "TRAFFIC_TYPE", "Synthetic", 'Combo-box', "Synthetic,Task-graph", undef, $table,$row,undef,1, $sample, 1,'ref_set_win');
    
    my $traffictype=$self->object_get_attribute($sample,"TRAFFIC_TYPE");
    my $MIN_PCK_SIZE=$self->object_get_attribute($sample,"MIN_PCK_SIZE");
    
   
    
   my $max_pck_num = get_MAX_PCK_NUM();
   my $max_sim_clk = get_MAX_SIM_CLKs();
	
	if($traffictype eq "Synthetic"){
		
		my $min=$self->object_get_attribute($sample,'MIN_PCK_SIZE');
		my $max=$self->object_get_attribute($sample,'MAX_PCK_SIZE');
		$min=$max=5 if(!defined $min);
		my $avg=floor(($min+$max)/2);	
		
		my $max_pck_size =	 get_MAX_PCK_SIZ();
		
		
			my $traffics="tornado,transposed 1,transposed 2,bit reverse,bit complement,random,hot spot,shuffle,bit rotation,neighbor,custom"; 	
		my @synthinfo = (
		
		
		{ label=>'Configuration name:', param_name=>'line_name', type=>'Entry', default_val=>$sample, content=>undef, info=>"NoC configuration name. This name will be shown in load-latency graph for this configuration", param_parent=>$sample, ref_delay=> undef, new_status=>undef},
	
		
	
	  
		{ label=>"Min pck size :", param_name=>'MIN_PCK_SIZE', type=>'Spin-button', default_val=>5, content=>"1,$max,1", info=>"Minimum packet size in flit. The injected packet size is randomly selected between minimum and maximum packet size", param_parent=>$sample, ref_delay=>10, new_status=>'ref_set_win'},
		{ label=>"Max pck size :", param_name=>'MAX_PCK_SIZE', type=>'Spin-button', default_val=>5, content=>"$min,$max_pck_size,1", info=>"Maximum packet size in flit. The injected packet size is randomly selected between minimum and maximum packet size", param_parent=>$sample, ref_delay=>10, new_status=>'ref_set_win'},
		
		
		
		{ label=>"Avg. Packet size:", param_name=>'PCK_SIZE', type=>'Combo-box', default_val=>$avg, content=>"$avg", info=>undef, param_parent=>$sample, ref_delay=>undef},
	
		{ label=>"Total packet number limit:", param_name=>'PCK_NUM_LIMIT', type=>'Spin-button', default_val=>200000, content=>"2,$max_pck_num,1", info=>"Simulation will stop when total number of sent packets by all nodes reaches packet number limit  or total simulation clock reach its limit", param_parent=>$sample, ref_delay=>undef, new_status=>undef},
	
		{ label=>"Simulator clocks limit:", param_name=>'SIM_CLOCK_LIMIT', type=>'Spin-button', default_val=>100000, content=>"2,$max_sim_clk,1", info=>"Each node stops sending packets when it reaches packet number limit  or simulation clock number limit", param_parent=>$sample, ref_delay=>undef,  new_status=>undef},
		
		{ label=>"Traffic name", param_name=>'traffic', type=>'Combo-box', default_val=>'random', content=>$traffics, info=>"Select traffic pattern", param_parent=>$sample, ref_delay=>1, new_status=>'ref_set_win'},
	
		
		);
		my $coltmp=0;
		
		foreach my $d (@synthinfo) {
			($row,$coltmp)=add_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,undef,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status});
		}
			
	
		my $traffic=$self->object_get_attribute($sample,"traffic");
		
		my $NE;
		my ($infobox,$info)= create_txview();
		my $st =  check_sim_sample($self,$sample,$info);  
		if ($st==0){
				$NE=100;
		}else{
			my ($topology, $T1, $T2, $T3, $V, $Fpay) = get_sample_emulation_param($self,$sample);
			my ($NEe, $NR, $RAw, $EAw, $Fw) = get_topology_info_sub ($topology, $T1, $T2, $T3, $V, $Fpay);
			$NE=$NEe;				
		}
			
		
		if ($traffic eq 'custom'){
						
			
			my $htable=def_table(10,2,FALSE);
			
			my $d= { label=>'number of active nodes:', param_name=>'CUSTOM_SRC_NUM', type=>'Spin-button', default_val=>1,  content=>"1,$NE,1", info=>"Number of active nodes which injects packets to the NoC",			  param_parent=>$sample, ref_delay=> 1, new_status=>'ref_set_win'};
			($row,$coltmp)=add_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,undef,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status});
			my $num=$self->object_get_attribute($sample,"CUSTOM_SRC_NUM");
			$htable->attach ( gen_label_in_left ("Source "), 0, 1,  $row,$row+1,'fill','shrink',2,2);
			$htable->attach ( gen_label_in_left (" -> "), 1, 2,  $row,$row+1,'fill','shrink',2,2);
			$htable->attach ( gen_label_in_left ("Destination"), 2, 3,  $row,$row+1,'fill','shrink',2,2);						
			
			$row++;
			
			
			my $tiles="0";
			for (my $i=1;$i<$NE;$i++){$tiles.=",$i";}
			
						
			for (my $i=0;$i<$num;$i++){
				my $w1 = gen_combobox_object ($self,$sample,"SRC_$i",$tiles, $i,undef,undef);
				my $w2 = gen_combobox_object ($self,$sample,"DST_$i",$tiles, $i+1,undef,undef);
				$htable->attach  ($w1 , 0, 1,  $row,$row+1,'shrink','shrink',2,2);
				$htable->attach  ($w2 , 2, 3,  $row,$row+1,'shrink','shrink',2,2);
				$row++;
					
			}	
			$table->attach  ($htable , 0, 3,  $row,$row+1,'shrink','shrink',2,2); $row++;
				
		}
		
		
		

		if ($traffic eq 'hot spot'){
			my $htable=def_table(10,2,FALSE);
			
			my $d= { label=>'number of Hot Spot nodes:', param_name=>'HOTSPOT_NUM', type=>'Spin-button', default_val=>1,  content=>"1,256,1", info=>"Number of hot spot nodes in the network",			  param_parent=>$sample, ref_delay=> 1, new_status=>'ref_set_win'};
			($row,$coltmp)=add_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,undef,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status});
				
				my $l1=gen_label_help("Define the tile number which is  hotspt. All other nodes will send [Hot Spot traffic percentage] of their traffic to this node","  Hot Spot tile number \%");
				my $l2=gen_label_help("If it is set as \"n\" then each node sends n % of its traffic to each hotspot node","  Hot Spot traffic \%");
				my $l3=gen_label_help("If it is checked then hot spot node also sends packets to other nodes otherwise it only receives packets from other nodes","  send enable");
				
				$htable->attach  ($l1 , 0, 1,  $row,$row+1,'fill','shrink',2,2);
				$htable->attach  ($l2 , 1, 2,  $row,$row+1,'fill','shrink',2,2);
				$htable->attach  ($l3 , 2,3,  $row,$row+1,'fill','shrink',2,2);
				$row++;
						
				my $num=$self->object_get_attribute($sample,"HOTSPOT_NUM");
				for (my $i=0;$i<$num;$i++){
					my $w1 = gen_spin_object ($self,$sample,"HOTSPOT_CORE_$i","0,256,1", $i,undef,undef);
					my $w2 = gen_spin_object ($self,$sample,"HOTSPOT_PERCENT_$i","0.1,100,0.1", 0.1,undef,undef);
					my $w3 = gen_check_box_object ($self,$sample,"HOTSPOT_SEND_EN_$i", 0,undef,undef);
					$htable->attach  ($w1 , 0, 1,  $row,$row+1,'fill','shrink',2,2);
					$htable->attach  ($w2 ,1, 2,  $row,$row+1,'fill','shrink',2,2);
					$htable->attach  ($w3 , 2,3,  $row,$row+1,'fill','shrink',2,2);
					$row++;
				
				}
				
				$table->attach  ($htable , 0, 3,  $row,$row+1,'shrink','shrink',2,2); $row++;
			
			
			
			
			
			
		
		}
		my $l= "Define injection ratios. You can define individual ratios separating by comma (\',\') or define a range of injection ratios with \$min:\$max:\$step format.
			As an example defining 2,3,4:10:2 will result in (2,3,4,6,8,10) injection ratios." ;
		my $u=get_injection_ratios ($self,$sample,"ratios");
		
		attach_widget_to_table ($table,$row,gen_label_in_left(" Injection ratios:"),gen_button_message ($l,"icons/help.png") , $u); $row++;
	
		$ok->signal_connect("clicked"=> sub{
			#check if sof file has been selected
			my $s=$self->object_get_attribute($sample,"sof_file");
			#check if injection ratios are valid
			my $r=$self->object_get_attribute($sample,"ratios");
			my $h;
			if ($traffic eq 'hot spot'){
				$h=	check_hotspot_parameters($self,$sample);
			}	
			
			if(defined $s && defined $r && !defined $h) {	
					#$set_win->destroy;
					$set_win->hide();
					$self->object_add_attribute("active_setting",undef,undef);
					set_gui_status($self,"ref",1);
			} else {
				
				if(!defined $s){
					my $m= "Please select NoC verilated file";
					message_dialog($m);  
				} elsif (! defined $r) {
					 message_dialog("Please define valid injection ratio(s)!");
				} else {
					 message_dialog("$h");					
				}
			}
		});
	
	}	
	
	
	if($traffictype eq "Task-graph"){
		
		my @custominfo = (
		#{ label=>"Verilated Model", param_name=>'sof_file', type=>'Combo-box', default_val=>undef, content=>$exe_files, info=>"Select the verilator simulation file. Different NoC simulators can be generated using Generate NoC configuration tab.", param_parent=>$sample, ref_delay=>undef, new_status=>undef},
		
		{ label=>'Configuration name:', param_name=>'line_name', type=>'Entry', default_val=>$sample, content=>undef, info=>"NoC configuration name. This name will be shown in load-latency graph for this configuration", param_parent=>$sample, ref_delay=> undef, new_status=>undef},
	
	  	{ label=>"Number of Files", param_name=>"TRAFFIC_FILE_NUM", type=>'Spin-button', default_val=>1, content=>"1,100,1", info=>"Select number of input files", param_parent=>$sample, ref_delay=>1, new_status=>'ref_set_win'},
		
		{ label=>"Simulator clocks limit:", param_name=>'SIM_CLOCK_LIMIT', type=>'Spin-button', default_val=>100000, content=>"2,$max_sim_clk,1", info=>"Each node stops sending packets when it reaches packet number limit  or simulation clock number limit", param_parent=>$sample, ref_delay=>undef,  new_status=>undef},
		);
		
		foreach my $d (@custominfo) {
			($row,$coltmp)=add_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,undef,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status});
			
		}	
		
	
		my $open_in  = "$ENV{'PRONOC_WORK'}/traffic_pattern";
		
		
	
		 my $num=$self->object_get_attribute($sample,"TRAFFIC_FILE_NUM");
		 for (my $i=0; $i<$num; $i++){
		 	attach_widget_to_table ($table,$row,gen_label_in_left("traffic pattern file $i:"),gen_button_message ("Select the traffic pattern input file. Any custom traffic based on application task graphs can be generated using ProNoC Trace Generator tool.","icons/help.png"), get_file_name_object ($self,$sample,"traffic_file$i",undef,$open_in)); $row++;
		 }
		 
		$ok->signal_connect("clicked"=> sub{
			#check if sof file has been selected
			my $s=$self->object_get_attribute($sample,"sof_file");
			if(!defined $s){
					message_dialog("Please select NoC verilated file"); 
					return;
			}
						
			#check if traffic files have been selected
			for (my $i=0; $i<$num; $i++){
				my $f=$self->object_get_attribute($sample,"traffic_file$i");
				if(!defined $f){
					my $m= "Please select traffic_file$i";
					message_dialog($m); 
					return;
				}
			 	
			}
			#$set_win->destroy;
			$set_win->hide();
			set_gui_status($self,"ref",1);
				
		});
		 
		 
	}
	
	
	add_widget_to_scrolled_win ($mtable,$set_win);
	
	$set_win->show_all();	
	
	
}



############
#	run_simulator
###########

sub run_simulator {
	my ($simulate,$info)=@_;
	#return if(!check_samples($emulate,$info));
	$simulate->object_add_attribute('status',undef,'run');
	set_gui_status($simulate,"ref",1);
	show_info($info, "Start Simulation\n");
	my $name=$simulate->object_get_attribute ("simulate_name",undef);	
	
	#unlink $log; # remove old log file
	
	my @samples =$simulate->object_get_attribute_order("samples");
	foreach my $sample (@samples){
		my $status=$simulate->object_get_attribute ($sample,"status");	
		next if($status ne "run");
		next if(!check_sim_sample($simulate,$sample,$info));
		my $traffictype=$simulate->object_get_attribute($sample,"TRAFFIC_TYPE");
		run_synthetic_simulation($simulate,$info,$sample,$name) if($traffictype eq "Synthetic");
		run_custom_simulation($simulate,$info,$sample,$name) if($traffictype eq "Task-graph");
		
    	
	}
	
	add_info($info, "Simulation is done!\n");
	printf "Simulation is done!\n";
	$simulate->object_add_attribute('status',undef,'ideal');
	set_gui_status($simulate,"ref",1);
}	


sub run_synthetic_simulation {
	my ($simulate,$info,$sample,$name)=@_;
	

	my %traffic= (
	'tornado' => 'TORNADO',
	'transposed 1' => "TRANSPOSE1",
	'transposed 2' => "TRANSPOSE2",
	'bit reverse'  => "BIT_REVERSE",
	'bit complement' => "BIT_COMPLEMENT",
	'random' => "RANDOM",
	'hot spot' => "HOTSPOT",
	'shuffle' => "SHUFFLE",
	'bit rotation' => "BIT_ROTATE",
	'neighbor' => "NEIGHBOR",
	'custom' => "CUSTOM"	 
	);
	
	my $simulator =$simulate->object_get_attribute("Simulator");
	my $log= (defined $name)? "$ENV{PRONOC_WORK}/simulate/$name.log": "$ENV{PRONOC_WORK}/simulate/sim.log";
	my $out_path ="$ENV{PRONOC_WORK}/simulate/"; 
	my $r= $simulate->object_get_attribute($sample,"ratios");
	my @ratios=@{check_inserted_ratios($r)};
	#$emulate->object_add_attribute ("sample$i","status","run");
	my $bin=get_sim_bin_path($simulate,$sample,$info);
	
	#load traffic configuration
	my $patern=$simulate->object_get_attribute ($sample,'traffic');
	my $MIN_PCK_SIZE=$simulate->object_get_attribute ($sample,"MIN_PCK_SIZE");
	my $MAX_PCK_SIZE=$simulate->object_get_attribute ($sample,"MAX_PCK_SIZE");
	my $PCK_NUM_LIMIT=$simulate->object_get_attribute ($sample,"PCK_NUM_LIMIT");
	my $SIM_CLOCK_LIMIT=$simulate->object_get_attribute ($sample,"SIM_CLOCK_LIMIT");
	
	
	
	#hotspot 
	my $custom="";
	my $custom_sv="";
	if ($patern eq 'custom'){
		$custom="";
		my $num=$simulate->object_get_attribute($sample,"CUSTOM_SRC_NUM");
		$custom_sv.="localparam CUSTOM_NODE_NUM=$num;\n\twire [NEw-1 : 0] custom_traffic_t   [NE-1 : 0];\n";
			my @srcs;
		for (my $i=0;$i<$num; $i++){
			my $src = $simulate->object_get_attribute($sample,"SRC_$i");
			my $dst = $simulate->object_get_attribute($sample,"DST_$i");
			
			$custom.=($i==0)? "-H \"$src,$dst" : ",$src,$dst";
			
		}
		my ($topology, $T1, $T2, $T3, $V, $Fpay) = get_sample_emulation_param($simulate,$sample);
		my ($NE, $NR, $RAw, $EAw, $Fw) = get_topology_info_sub ($topology, $T1, $T2, $T3, $V, $Fpay);
			
		for (my $i=0;$i<$NE; $i++){
			my ($src,$dst) = custom_traffic_dest ($simulate,$sample,$i);
			$custom_sv.="\tassign custom_traffic_t[$src]=$dst;";
			$custom_sv.=($src==$dst)? "//off \n" : "\n"
		}	
		$custom.="\"";	
		
	}
	else{
		$custom_sv.="localparam CUSTOM_NODE_NUM=0;\n\twire [NEw-1 : 0] custom_traffic_t   [NE-1 : 0];
		";		
	}
	
	
	
	
	
	my $hotspot="";
	my $hotspot_sv="";
	if($patern eq "hot spot"){
		$hotspot="-h \" ";
		my $num=$simulate->object_get_attribute($sample,"HOTSPOT_NUM");
		if (defined $num){
			$hotspot="$hotspot $num";
			
			$hotspot_sv.="localparam HOTSPOT_NODE_NUM=$num;\n\thotspot_t  hotspot_info [HOTSPOT_NODE_NUM-1 : 0];\n";
			my $acum=0;
			
			for (my $i=0;$i<$num;$i++){
				my $w1 = $simulate->object_get_attribute($sample,"HOTSPOT_CORE_$i");
				my $w2 = $simulate->object_get_attribute($sample,"HOTSPOT_PERCENT_$i");
				$w2=$w2*10;
				my $w3 = $simulate->object_get_attribute($sample,"HOTSPOT_SEND_EN_$i");
				$hotspot="$hotspot,$w1,$w3,$w2";
				$acum+=$w2;
				
				$hotspot_sv.="
	assign  hotspot_info[$i].ip_num=$w1;
	assign  hotspot_info[$i].send_enable=$w3;
	assign  hotspot_info[$i].percentage=$acum;	// $w2
";			}
			
		}
		
		$hotspot.="$hotspot \"";
				
	}
	else{ $hotspot_sv.="localparam HOTSPOT_NODE_NUM = 0;\n\thotspot_t  hotspot_info [0:0];\n" }		
	
	
	
	
	
	
	my $modelsim_bin=  $ENV{MODELSIM_BIN};
			if(! defined $modelsim_bin){
				add_colored_info($info, "Error: Path to modelsim bin directory is not defined in ProNoC setting\n",'red');
				show_setting(0);
				return;
			}	
		
	my $cpu_num = $simulate->object_get_attribute('compile', 'cpu_num');
	$cpu_num = 1 if (!defined $cpu_num);
	
	if ($simulator eq 'Modelsim'){
		for (my $i=0; $i<$cpu_num; $i++  ){
			my $out="$out_path/modelsim/work$i";
			rmtree("$out");
			mkpath("$out",1,01777);
						
			gen_noc_localparam_v_file($simulate,"$out",$sample);
			my $param="
// simulation parameter setting
// injected packet class percentage
`ifdef INCLUDE_SIM_PARAM
	localparam 
		TRAFFIC=\"$traffic{$patern}\",
			
	  	AVG_LATENCY_METRIC= \"HEAD_2_TAIL\",
		//simulation min and max packet size. The injected packet take a size randomly selected between min and max value
		MIN_PACKET_SIZE=$MIN_PCK_SIZE,
		MAX_PACKET_SIZE=$MAX_PCK_SIZE,
		STOP_PCK_NUM=$PCK_NUM_LIMIT,
		STOP_SIM_CLK=$SIM_CLOCK_LIMIT;
	    		
		$hotspot_sv	
		
		$custom_sv
		
		parameter INJRATIO=90; 
`endif			
			";
			save_file("$out/sim_param.sv",$param);
			
			
			#Get the list of  all verilog files in src_verilog folder
			my @files = File::Find::Rule->file()
			->name( '*.v','*.V','*.sv' )
			->in( "$out_path/modelsim/src_verilog" );
		
			#get list of all verilog files in src_sim folder 
    		my @sim_files = File::Find::Rule->file()
			->name( '*.v','*.V','*.sv' )
			->in( "$out_path/modelsim/src_modelsim" );		
			push (@files, @sim_files);	
			my $tt =create_file_list("$out_path/modelsim",\@files,'modelsim');
			$tt="+incdir+./ \n$tt";	
			save_file("$out/file_list.f",  "$tt");
			my $tcl="#!/usr/bin/tclsh


transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work


vlog  +acc=rn  -F $out/file_list.f

vsim -t 1ps  -L rtl_work -L work -voptargs=\"+acc\"  testbench_noc

add wave *
view structure
view signals
run -all
";
	
			save_file ("$out/model.tcl",$tcl);
			
			my $cmd="cd $out; rm -Rf rtl_work; $modelsim_bin/vsim -do $out/model.tcl ";
			save_file ("$out/run.sh",'#!/bin/bash'."			
			sed -i \"s/ INJRATIO=\[\[:digit:\]\]\\+/ INJRATIO=\$1/\" $out/sim_param.sv
			".$cmd);			
			add_info($info, "model.tcl is created in $out\n");
		}#for		
	}
	
	
	
	my @paralel_ratio;
	my $total=scalar @ratios;
	my $jobs=0;	
	my $c=0;
	my $cmds="";
	foreach  my $ratio_in (@ratios){						
	    	#my $r= $ratio_in * MAX_RATIO/100;
	    	my $cmd;
	    	
	    	if ($simulator eq 'Modelsim'){
	    		add_info($info, "Run $bin with  injection ratio of $ratio_in \% \n");
	    		my $out="$out_path/modelsim/work$c";
	    		$cmd="	    		
	    		cd $out; sed -i \"s/ INJRATIO=\[\[:digit:\]\]\\+/ INJRATIO=$ratio_in/\" $out/sim_param.sv;  rm -Rf rtl_work; $modelsim_bin/vsim -do $out/model.tcl; 	";			
	    	
	    	}else{	
	    		add_info($info, "Run $bin with  injection ratio of $ratio_in \% \n");
		    	$cmd="$bin -t \"$patern\"  -s $MIN_PCK_SIZE -m $MAX_PCK_SIZE  -n  $PCK_NUM_LIMIT  -c	$SIM_CLOCK_LIMIT   -i $ratio_in -p \"100,0,0,0,0\"  $hotspot $custom > $out_path/sim_out$ratio_in & ";
							
	    	}
	    	$cmds .=$cmd;	
			add_info($info, "$cmd \n");
			
			my $time_strg = localtime;
			#append_text_to_file($log,"started at:$time_strg\n"); #save simulation output
			$jobs++;
			
			push (@paralel_ratio,$ratio_in);
			$c++;
			if($jobs % $cpu_num ==0 || $jobs == $total){
				#run paralle simulation				
				my ($stdout,$exit,$stderr)=run_cmd_in_back_ground_get_stdout("$cmds\n wait\n");
				if($exit || (length $stderr >4)){
						add_colored_info($info, "Error in running simulation: $stderr \n",'red');
						$simulate->object_add_attribute ($sample,"status","failed");	
						$simulate->object_add_attribute('status',undef,'ideal');
						return;
				 } 
				#save results
				for (my $i=0; $i<$c; $i++){
					my $r      = $paralel_ratio[$i];
					
					my @errors = unix_grep("$out_path/sim_out$r","ERROR:");
					if (scalar @errors  ){
						add_colored_info($info, "Error in running simulation: @errors \n",'red');
						$simulate->object_add_attribute ($sample,"status","failed");	
						$simulate->object_add_attribute('status',undef,'ideal');
						return;						
					}		
					
					
					my $stdout = load_file("$out_path/sim_out$r");
							
					extract_and_update_noc_sim_statistic ($simulate,$sample,$r,$stdout);
					    
		   
				} 
				
				$cmds="";
				@paralel_ratio=();
				$c=0;
				
				set_gui_status($simulate,"ref",2);
			}  	
	    		    	
		}#@ratios	
		
		$simulate->object_add_attribute ($sample,"status","done");	
	
}

sub extract_and_update_noc_sim_statistic {
	my ($simulate,$sample,$ratio_in,$stdout)=@_;
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
		
	next if (!defined $avg_latency);
	update_result($simulate,$sample,"latency_result",$ratio_in,$avg_latency);
	update_result($simulate,$sample,"latency_flit_result",$ratio_in,$avg_flit_latency);
	update_result($simulate,$sample,"sd_latency_result",$ratio_in,$sd_latency);
	update_result($simulate,$sample,"throughput_result",$ratio_in,$avg_thput);
	update_result($simulate,$sample,"exe_time_result",$ratio_in,$total_time);
	update_result($simulate,$sample,"latency_perhop_result",$ratio_in,$latency_perhop);
	foreach my $p (sort keys %packet_rsvd_per_core){
		update_result($simulate,$sample,"packet_rsvd_result",$ratio_in,$p,$packet_rsvd_per_core{$p} );
		update_result($simulate,$sample,"worst_delay_rsvd_result",$ratio_in,$p,$worst_rsvd_delay_per_core{$p});
		update_result($simulate,$sample,"packet_sent_result",$ratio_in,$p,$packet_sent_per_core{$p} );
		update_result($simulate,$sample,"worst_delay_sent_result",$ratio_in,$p,$worst_sent_delay_per_core{$p});
	}	
}


sub run_custom_simulation{
	my ($simulate,$info,$sample,$name)=@_;
	my $log= (defined $name)? "$ENV{PRONOC_WORK}/simulate/$name.log": "$ENV{PRONOC_WORK}/simulate/sim.log";
	my $SIM_CLOCK_LIMIT=$simulate->object_get_attribute ($sample,"SIM_CLOCK_LIMIT");
	
	my $bin=get_sim_bin_path($simulate,$sample,$info);
	
	my $dir = Cwd::getcwd();
	my $project_dir	  = abs_path("$dir/../.."); #mpsoc directory address
	$bin= "$project_dir/$bin"   if(!(-f $bin));
	my $num=$simulate->object_get_attribute($sample,"TRAFFIC_FILE_NUM");
	
	my $cpu_num = $simulate->object_get_attribute('compile', 'cpu_num');
	$cpu_num = 1 if (!defined $cpu_num);
	
	my @paralel_ratio;
	my $total=$num;
	my $jobs=0;	
	my $c=0;
	my $cmds="";
	my $out_path ="$ENV{PRONOC_WORK}/simulate/"; 
	
	for (my $i=0; $i<$num; $i++){
		 my $f=$simulate->object_get_attribute($sample,"traffic_file$i");
		 add_info($info, "Run $bin for $f  file \n");	
		 my $cmd="$bin -c $SIM_CLOCK_LIMIT -f  \"$f\" > $out_path/sim_out$i & ";
		 $cmds .=$cmd;
		 add_info($info, "$cmd \n");
		 $jobs++;
		 push (@paralel_ratio,$i);
		 $c++;
		 if($jobs % $cpu_num ==0 || $jobs == $total){
			#run paralle simulation
			my ($stdout,$exit,$stderr)=run_cmd_in_back_ground_get_stdout("$cmds\n wait\n");
		
			if($exit || (length $stderr >4)){
				add_colored_info($info, "Error in running simulation: $stderr \n",'red');
				$simulate->object_add_attribute ($sample,"status","failed");	
				$simulate->object_add_attribute('status',undef,'ideal');
				return;
			 } 
			 
			#save results
			for (my $j=0; $j<$c; $j++){
				my $r      = $paralel_ratio[$j];
				my $stdout = load_file("$out_path/sim_out$r");
			
				extract_and_update_noc_sim_statistic ($simulate,$sample,$r,$stdout);
			} 
			
			$cmds="";
			@paralel_ratio=();
			$c=0;
			set_gui_status($simulate,"ref",2);	
		} 		 
		    	 
	}#for i
	
	$simulate->object_add_attribute ($sample,"status","done");	
}	



##########
# check_sample
##########

sub get_sim_bin_path {
	my ($self,$sample,$info)=@_;
	my $bin_path=$self->object_get_attribute ($sample,"sof_path");	
	unless (-d $bin_path){
		my $path= $self->object_get_attribute ("sim_param","BIN_DIR");
		if(-d $path){
			add_colored_info($info, "Warning: The given path ($bin_path) for searching $sample bin file does not exist. The system search in default $path instead.\n",'green');
			$bin_path=$path;
		}
	}	
	my $bin_file=$self->object_get_attribute ($sample,"sof_file");	
	$bin_file = "-" if(!defined $bin_file);		
	my $sof="$bin_path/$bin_file";
	return $sof;
}

sub check_sim_sample{
	my ($self,$sample,$info)=@_;
	my $status=1;
	my $sof=get_sim_bin_path($self,$sample,$info);
			
	# ckeck if sample have sof file
	if(!defined $sof){
		add_colored_info($info, "Error: bin file has not set for $sample!\n",'red');
		$self->object_add_attribute ($sample,"status","failed");	
		$status=0;
	} else {
		# ckeck if bin file has info file 
		my ($name,$path,$suffix) = fileparse("$sof",qr"\..[^.]*$");
		my $sof_info= "$path$name.inf";
		if(!(-f $sof_info)){
			add_colored_info($info, "Could not find $name.inf file in $path. An information file is required for each sof file containing the device name and  NoC configuration. Press F3 for more help.\n",'red');
			$self->object_add_attribute ($sample,"status","failed");	
			$status=0;
		}else { #add info
			my $pp= do $sof_info ;

			my $p=$pp->{'noc_param'};
			
			$status=0 if $@;
			message_dialog("Error reading: $@") if $@;
			if ($status==1){
				$self->object_add_attribute ($sample,"noc_info",$p) ;
					
			
			}			
		}		
	}
	#check if sample min packet size matches in simulation 
	
	my $p= $self->object_get_attribute ($sample,"noc_info");    
    my $HW_MIN_PCK_SIZE=$p->{"MIN_PCK_SIZE"};
    my $SIM_MIN_PCK_SIZE=$self->object_get_attribute ($sample,"MIN_PCK_SIZE");
   if(!defined $HW_MIN_PCK_SIZE){
    	$HW_MIN_PCK_SIZE= 2;   
    	#print "undef\n"; 	
    }
	if($HW_MIN_PCK_SIZE>$SIM_MIN_PCK_SIZE){
		add_colored_info($info, "Error: The minimum simulation packet size of $SIM_MIN_PCK_SIZE flit(s) is smaller than $HW_MIN_PCK_SIZE which is defined in generating verilog model of NoC!\n",'red');
		$self->object_add_attribute ($sample,"status","failed");	
		$status=0;
	}	
	#print "$HW_MIN_PCK_SIZE>$SIM_MIN_PCK_SIZE\n"; 			
	return $status;
}

sub noc_sim_ctrl{
	my ($simulate,$info)=@_;
	
	my $generate = def_image_button('icons/forward.png','R_un all',FALSE,1);
	my $open = def_image_button('icons/browse.png',"_Load",FALSE,1);
	my $save = def_image_button('icons/save.png','Sav_e',FALSE,1);
	my $save_all_results = def_image_button('icons/copy.png',"E_xtract all results",FALSE,1);
	my $cpus=select_parallel_process_num($simulate);
	my ($object,$attribute1,$attribute2,$content,$default,$status,$timeout)=@_;
	
	my $compiler =def_pack_hbox('FALSE',0, gen_label_in_center('Simulator:'), gen_combobox_object($simulate,'Simulator',undef,"Modelsim,Verilator","Verilator",'ref',1));
	
	
	my $entry = gen_entry_object($simulate,'simulate_name',undef,undef,undef,undef);
	my $entrybox=gen_label_info(" Save as:",$entry);
	$entrybox->pack_start( $save, FALSE, FALSE, 0);
	
	my $simulator =$simulate->object_get_attribute("Simulator");	
	my $table = def_table (1, 12, FALSE);
	$table->attach ($open,		0, 1, 0,1,'expand','shrink',2,2);
	$table->attach ($compiler, 1, 2, 0,1,'expand','shrink',2,2);
	
	$table->attach ($cpus, 		2, 4, 0,1,'expand','shrink',2,2);
	$table->attach ($entrybox,	4, 7, 0,1,'expand','shrink',2,2);
	$table->attach ($save_all_results, 7, 8, 0,1,'shrink','shrink',2,2);
	$table->attach ($generate, 	8, 9, 0,1,'expand','shrink',2,2);
	
	$generate-> signal_connect("clicked" => sub{ 
		my @samples =$simulate->object_get_attribute_order("samples");	
		foreach my $sample (@samples){
			$simulate->object_add_attribute ("$sample","status","run");	
		}
		run_simulator($simulate,$info);
		#set_gui_status($emulate,"ideal",2);

	});

#	$wb-> signal_connect("clicked" => sub{ 
#		wb_address_setting($mpsoc);
#	
#	});

	$open-> signal_connect("clicked" => sub{ 
		
		load_simulation($simulate,$info);
		#print Dumper($simulate);
		set_gui_status($simulate,"ref",5);
	
	});	

	$save-> signal_connect("clicked" => sub{ 
		save_simulation($simulate);		
		set_gui_status($simulate,"ref",5);
		
	
	});	
	
	$save_all_results-> signal_connect("clicked" => sub{ 
		#Get the path where to save all the simulation results
		my $open_in = $simulate->object_get_attribute ('sim_param','BIN_DIR');
     	get_dir_name($simulate,"Select the target directory","sim_param","ALL_RESULT_DIR",$open_in,'ref',1);
		$simulate->object_add_attribute ("graph_save","save_all_result",1);
		
	});	
	
	
	return $table;
	
}


############
#    main
############
sub simulator_main{
	
	add_color_to_gd();
	my $simulate= emulator->emulator_new();
	set_gui_status($simulate,"ideal",0);
	

	my $main_table = def_table (25, 12, FALSE);
	$main_table->show_all;
	my ($infobox,$info)= create_txview();	
	
	

my @pages =(
	{page_name=>" Avg. throughput/latency", page_num=>0},
	{page_name=>" Injected Packet ", page_num=>1},
	{page_name=>" Worst-Case Delay ",page_num=>2},
	{page_name=>" Execution Time ",page_num=>3},
);



my @charts = (
	{ type=>"2D_line", page_num=>0, graph_name=> "Avg. packet Latency", result_name => "latency_result", X_Title=> 'Desired Avg. Injected Load Per Router (flits/clock (%))', Y_Title=>'Avg. Packet Latency (clock)', Z_Title=>undef, Y_Max=>100},
  	{ type=>"2D_line", page_num=>0, graph_name=> "Avg. flit Latency", result_name => "latency_flit_result", X_Title=> 'Desired Avg. Injected Load Per Router (flits/clock (%))', Y_Title=>'Avg. Flit Latency (clock)', Z_Title=>undef, Y_Max=>100},
  	{ type=>"2D_line", page_num=>0, graph_name=> "Avg. flit Latency per hop", result_name => "latency_perhop_result", X_Title=> 'Desired Avg. Injected Load Per Router (flits/clock (%))', Y_Title=>'Avg. Flit Latency per hop (clock)', Z_Title=>undef, Y_Max=>100},
    { type=>"2D_line", page_num=>0, graph_name=> "Throughput", result_name => "throughput_result", X_Title=> 'Desired Avg. Injected Load Per Router (flits/clock (%))', Y_Title=>'Avg. Throughput (flits/clock (%))', Z_Title=>undef,Y_Max=>100},
	
  	{ type=>"2D_line", page_num=>0, graph_name=> "SD latency", result_name => "sd_latency_result", X_Title=> 'Desired Avg. Injected Load Per Router (flits/clock (%))', Y_Title=>'Latency Standard Deviation (clock)', Z_Title=>undef},
	{ type=>"3D_bar",  page_num=>1, graph_name=> "Received", result_name => "packet_rsvd_result", X_Title=>'Core ID' , Y_Title=>'Received Packets Per Router', Z_Title=>undef},
	{ type=>"3D_bar",  page_num=>1, graph_name=> "Sent", result_name => "packet_sent_result", X_Title=>'Core ID' , Y_Title=>'Sent Packets Per Router', Z_Title=>undef},
	{ type=>"3D_bar",  page_num=>2, graph_name=> "Received", result_name => "worst_delay_rsvd_result",X_Title=>'Core ID' , Y_Title=>'Worst-Case Delay (clk)', Z_Title=>undef},
	{ type=>"3D_bar",  page_num=>2, graph_name=> "Sent", result_name => "worst_delay_sent_result",X_Title=>'Core ID' , Y_Title=>'Worst-Case Delay (clk)', Z_Title=>undef},
	{ type=>"2D_line", page_num=>3, graph_name=> "-", result_name => "exe_time_result",X_Title=>'Desired Avg. Injected Load Per Router (flits/clock (%))' , Y_Title=>'Total Simulation Time (clk)', Z_Title=>undef},
	
	);
	
	
	my ($conf_box,$set_win)=process_notebook_gen($simulate,$info,"simulate",undef,@charts);
	my $chart   =gen_multiple_charts  ($simulate,\@pages,\@charts,0.4);
    


	$main_table->set_row_spacings (4);
	$main_table->set_col_spacings (1);
	
	
	#my  $device_win=show_active_dev($soc,$soc,$infc,$soc_state,\$refresh,$info);
	
	
	
	
	my $image = get_status_gif($simulate);
	my $ctrl  = noc_sim_ctrl ($simulate,$info);
	
	my $v1=gen_vpaned($conf_box,.45,$image);
	my $v2=gen_vpaned($infobox,.2,$chart);
	my $h1=gen_hpaned($v1,.4,$v2);
	
	
	
	$main_table->attach_defaults ($h1  , 0, 12, 0,24);
	$main_table->attach ($ctrl, 0,12, 24,25,'fill','fill',2,2);
	
	


	#check soc status every 0.5 second. refresh device table if there is any changes 
	Glib::Timeout->add (100, sub{ 
	 
		my ($state,$timeout)= get_gui_status($simulate);
		
		if ($timeout>0){
			$timeout--;
			set_gui_status($simulate,$state,$timeout);	
			return TRUE;
			
		}
		if($state eq "ideal"){
			return TRUE;
			 
		}
		
		
		
		#refresh GUI
		
		$ctrl->destroy();							
		$conf_box->destroy();
		$chart->destroy();
		$image->destroy(); 
		$image = get_status_gif($simulate);
		($conf_box,$set_win)=process_notebook_gen($simulate,$info,"simulate",$set_win,@charts);				
		$chart = gen_multiple_charts  ($simulate,\@pages,\@charts,0.4);
		$ctrl  = noc_sim_ctrl ($simulate,$info);
		$main_table->attach ($ctrl,0, 12, 24,25,'fill','fill',2,2);
        $v1 -> pack1($conf_box, TRUE, TRUE); 	
		$v1 -> pack2($image, TRUE, TRUE); 		
		$v2 -> pack2($chart, TRUE, TRUE); 	
		
		
		
		
		$conf_box->show_all();
		$main_table->show_all();			
		set_gui_status($simulate,"ideal",0);
		
		return TRUE;
		
	} );
		
		
	
		
	

	return add_widget_to_scrolled_win($main_table);	

		

}

sub custom_traffic_dest{
	my ($self,$sample,$core_num)	=@_;
	
	my $num=$self->object_get_attribute($sample,"CUSTOM_SRC_NUM");
    for (my $i=0;$i<$num;$i++){
			my $src = $self->object_get_attribute($sample,"SRC_$i");
			my $dst = $self->object_get_attribute($sample,"DST_$i");
			return  ($core_num,$dst) if($src == $core_num);
    }
	return ($core_num, $core_num);#off	
}

