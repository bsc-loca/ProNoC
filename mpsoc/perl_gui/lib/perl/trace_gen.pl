#!/usr/bin/perl
use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Gtk2 '-init';
use Gtk2::SourceView2;
use Data::Dumper;
use List::Util 'shuffle';
use File::Path;
use File::Copy;
use POSIX qw(ceil floor);
use Cwd 'abs_path';
use List::MoreUtils qw(uniq);


use base 'Class::Accessor::Fast';
require "widget.pl"; 
require "diagram.pl";
require "orcc.pl";
require "drag_drop.pl";

__PACKAGE__->mk_accessors(qw{
	window
	sourceview
	buffer
	filename
	search_regexp
	search_case
	search_entry
	regexp
	highlighted
	
});

my $NAME = 'Trace_gen';


exit trace_gen_main() unless caller;


sub trace_gen_main {
	my ($mode,$ref,$w)=@_;
	my $app = __PACKAGE__->new();
	my $table=$app->build_trace_gui($mode,$ref,$w);
		
	return $table;
}



########
#  trace_ctr
########

sub trace_pad_ctrl{
	my ($self,$tview,$mode)=@_;
		
	my $table= def_table(2,10,FALSE);
	#my $separator = Gtk2::HSeparator->new;	
	my $row=0;
	my $col=0;
	#$table->attach ($separator , 0, 10 , $row, $row+1,'fill','fill',2,2);	$row++;	
	
	my $add = def_image_button('icons/import.png');
	set_tip($add,'Load Task Graph') if($mode eq "task");
	set_tip($add,'Load ORCC source files') if($mode eq "orcc");
	my $remove = def_image_button('icons/cancel.png');
	set_tip($remove,'Remove Selected Trace(s)');
	my $draw = def_image_button('icons/diagram.png');
	set_tip($draw,'View Task Graph');
	my $auto = def_image_button('icons/refresh.png');
	set_tip($auto,'Automatically calculate the traces burst size and injection ratio according to their bandwidth');
	my $box=def_pack_hbox(FALSE,FALSE,$add,$draw,$remove,$auto);
	
	#my $auto = def_image_button('icons/setting.png');
	#set_tip($auto,'Automatically set the burst size and injection ratio according to the packet size and bandwidth');
	
	
	$col=0;
	$table->attach ($box,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);$col++;
	
	$row++;	
	$col=0;
	my $info="Automatically set the burst size and injection ratio according to the packet size and bandwidth";
	#add_param_widget($self,"Auto inject rate \& burst size",'Auto_inject', 0,"Check-box",1,$info, $table,$row,$col,1,'Auto',0,'ref',"vertical");
	$row++;	
	$col=0;	
	my $info1="If hard-build QoS is enabled in NoC by using Weighted round robin arbiter (WRRA) instead of RRA, then the initial weights allow QoS support in NoC as in presence of contention, packets with higher initial weights receive higher bandwidth and lower worst case delay compared to others." ;
	
	#my $selects="tornado,transposed 1,transposed 2,bit reverse,bit complement,random,hot spot"; 
	my $min=$self->object_get_attribute('select_multiple','min_pck_size');
	my $max=$self->object_get_attribute('select_multiple','max_pck_size');	
	$min=$max=5 if(!defined $min);
	
	my @selectedinfo;
	$self->object_add_attribute('Auto','Auto_inject',"1\'b0" );
	my $a= $self->object_get_attribute('Auto','Auto_inject');
	
	if ($a eq "1\'b0"){
		@selectedinfo = (
		{ label=>" Initial weight ", param_name=>'init_weight', type=>'Spin-button', default_val=>1, content=>"1,16,1", info=>$info1, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
		{ label=>" Min pck size ", param_name=>'min_pck_size', type=>'Spin-button', default_val=>5, content=>"2,$max,1", info=>undef, param_parent=>'select_multiple', ref_delay=> 10, new_status=>'ref'},
		{ label=>" Max pck size ",param_name=>'max_pck_size', type=>'Spin-button', default_val=>5, content=>"$min,1024,1", info=>undef, param_parent=>'select_multiple', ref_delay=> 10, new_status=>'ref'},
		{ label=>" Burst_size ", param_name=>'burst_size', type=>'Spin-button', default_val=>1, content=>"1,1024,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
		{ label=>" Inject rate(%) ", param_name=>'injct_rate', type=>'Spin-button', default_val=>10, content=>"1,100,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
		{ label=>" Inject rate variation(%) ", param_name=>'injct_rate_var', type=>'Spin-button', default_val=>20, content=>"0,100,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},

	);
		
		
	}else{
		@selectedinfo = (
		{ label=>" Initial weight ", param_name=>'init_weight', type=>'Spin-button', default_val=>1, content=>"1,16,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
		{ label=>" Min pck size ", param_name=>'min_pck_size', type=>'Spin-button', default_val=>5, content=>"2,$max,1", info=>undef, param_parent=>'select_multiple', ref_delay=> 10, new_status=>'ref'},
		{ label=>" Max pck size ",param_name=>'max_pck_size', type=>'Spin-button', default_val=>5, content=>"$min,1024,1", info=>undef, param_parent=>'select_multiple', ref_delay=> 10, new_status=>'ref'},
		
	);
	}
	if($mode eq "orcc"){
		my $v_val= $self->object_get_attribute('noc_param','V');
		my $v_max=$v_val-1;	
		my $c_val= $self->object_get_attribute('noc_param','C');
		my $c_max=($c_val==0)? 0 : $c_val-1;	
	 
	 	@selectedinfo = (
	 	{ label=>" Initial weight ", param_name=>'init_weight', type=>'Spin-button', default_val=>1, content=>"1,16,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
	 	{ label=>" Virtual channel#", param_name=>'vc', type=>'Spin-button', default_val=>0, content=>"0,$v_max,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
	 	{ label=>" Message class# ", param_name=>'class', type=>'Spin-button', default_val=>0, content=>"0,$c_max,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef}
	 	);
		
	}
	
	
	my @traces= get_trace_list($self,'raw');
	my $any_selected=0;
	foreach my $p (@traces) {	
		my ($src,$dst, $Mbytes, $file_id, $file_name)=get_trace($self,'raw',$p);
		$any_selected=1 if($self->object_get_attribute("raw_$p",'selected')==1); 
	
	}	
	
	if($any_selected){
		$table->attach (Gtk2::HSeparator->new,0, 10,  $row, $row+1,'fill','fill',2,2);$row++;	
		$table->attach (gen_label_in_center('Apply to all selected traces'),0, 10,  $row, $row+1,'fill','fill',2,2);$row++;	
	}
	
	foreach my $d (@selectedinfo) {
		my $apply= def_image_button("icons/enter.png",undef);
		$apply->signal_connect( 'clicked'=> sub{
			$self->object_add_attribute('select_multiple','action',$d->{param_name});
			$self->set_gui_status('ref',0);
		});
		if($any_selected){
			($row,$col)=add_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay},$d->{new_status},"horizontal");
			$table->attach  ($apply , $col, $col+1,  $row,$row+1,'shrink','shrink',2,2);$row++;$col=0;
		#	$row=noc_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status});
		}
		}
	
	
	
	
			
	my $dir = Cwd::getcwd();
	my $project_dir	  = abs_path("$dir/.."); #mpsoc directory address
	
	
	$add->signal_connect ( 'clicked'=> sub{
		load_task_file($self,$project_dir,$tview) if($mode eq 'task');
 		load_orcc_file($self,$tview) if($mode eq 'orcc');
	});
	
	$draw->signal_connect ( 'clicked'=> sub{
		show_trace_diagram($self,'trace');
	});
	
	$remove->signal_connect ( 'clicked'=> sub{
		$self->remove_selected_traces('raw');
	});
	
	$auto->signal_connect ( 'clicked'=> sub{
		$self->auto_generate_injtratio('raw');
	});
	
	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	
	
	return $sc_win;
	
}

sub load_task_file{
	my($self,$project_dir,$tview)=@_;
 		my $file;
        my $dialog = Gtk2::FileChooserDialog->new(
            	'Select a File', undef,
            	'open',
            	'gtk-cancel' => 'cancel',
            	'gtk-ok'     => 'ok',
        	);
        	my $open_in	  = abs_path("${project_dir}/perl_gui/lib/simulate/embedded_app_graphs");
        	$dialog->set_current_folder ($open_in); 
        	my $filter = Gtk2::FileFilter->new();
			$filter->set_name("app");
			$filter->add_pattern("*.app");
			$dialog->add_filter ($filter);
		

        	if ( "ok" eq $dialog->run ) {
            		$file = $dialog->get_filename;
					$self->load_tarce_file($file,$tview);
            }
       		$dialog->destroy;	
}

######
# map_ctr
######	
	
sub trace_map_ctrl{
	
	my ($self,$tview,$mode,$NE)=@_;
	my $table= def_table(2,10,FALSE);
	
	my $run_map= def_image_button("icons/enter.png",undef);
	my $drawmap = def_image_button('icons/trace.png');
	my $diagram = def_image_button('icons/diagram.png');
	set_tip($drawmap,'View Task Mapping Diagram');
	set_tip($diagram,'View Topology Diagram');
	my $auto = def_image_button('icons/refresh.png');
	set_tip($auto,'Automatically set the network dimensions according to the task number');	
	my $clean = def_image_button('icons/clear.png');
	set_tip($clean,'Remove mapping');	
	
	my $box;
	$box=def_pack_hbox(FALSE,FALSE,$drawmap,$diagram,$clean,$auto) if($mode eq 'task');
	$box=def_pack_hbox(FALSE,FALSE,$drawmap,$clean) if($mode eq 'orcc');	
	
	my $col=0;
	my $row=0;
	$table->attach ($box,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);$row++;	
	
	
	if($mode eq 'task'){
		($row,$col) =noc_topology_setting_gui($self,$table,$tview,$row,1);
		
		$diagram-> signal_connect("clicked" => sub{ 
        	show_topology_diagram ($self);
    	});
		
		
	}
	
	
	
	
	my @info = ($mode eq 'task')? (
  #	{ label=>'Routers per Row', param_name=>'T1', type=>"Spin-button", default_val=>2, content=>"2,64,1", info=>undef, param_parent=>'noc_param', ref_delay=>1,placement=>'vertical'},
	#{ label=>"Routers per Column", param_name=>"T2", type=>"Spin-button", default_val=>2, content=>"1,64,1", info=>undef, param_parent=>'noc_param',ref_delay=>1, placement=>'vertical'},
	{ label=>"Mapping Algorithm", param_name=>"Map_Algrm", type=>"Combo-box", default_val=>'Random', content=>"Nmap,Random,Reverse-NMAP,Direct", info=>undef, param_parent=>'map_param',ref_delay=>undef,placement=>'horizontal'},
	) :
	
	(	{ label=>"Mapping Algorithm", param_name=>"Map_Algrm", type=>"Combo-box", default_val=>'Random', content=>"Nmap,Random,Reverse-NMAP,Direct", info=>undef, param_parent=>'map_param',ref_delay=>undef,placement=>'horizontal'},
	);
	
	foreach my $d (@info) {
		($row,$col)=add_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay},'ref',$d->{placement});
		if($d->{param_name} eq "Map_Algrm"){$table->attach  ($run_map , $col, $col+1,  $row,$row+1,'shrink','shrink',2,2);$row++;$col=0;}
		
	}

	
	
	$run_map->signal_connect( 'clicked'=> sub{
		my $alg=$self->object_get_attribute('map_param','Map_Algrm');
		update_merge_actor_list($self,$tview);
		$self->random_map() if ($alg eq 'Random');
		$self->worst_map_algorithm() if ($alg eq 'Reverse-NMAP');		
		$self->nmap_algorithm() if ($alg eq 'Nmap');
		$self->direct_map() if ($alg eq 'Direct');
		
	
	});
	
	$drawmap->signal_connect ( 'clicked'=> sub{
		show_trace_diagram($self,'map');
	});
	
	$auto->signal_connect ( 'clicked'=> sub{
		my @tasks = $self->get_all_merged_tasks();
		my $task_num= scalar @tasks;
		return if($task_num ==0);
		my $topology = $self->object_get_attribute('noc_param','TOPOLOGY');
		if ($topology eq '"MESH"' || $topology eq '"TORUS"' ){
			my ($nx,$ny) =network_dim_cal($task_num);
			$self->object_add_attribute('noc_param','T1',$nx);
			$self->object_add_attribute('noc_param','T2',$ny);	
			$self->object_add_attribute('noc_param','T3',1);	
			set_gui_status($self,"ref",1);
		}elsif ($topology eq '"RING"' || $topology eq '"LINE"'){
			$self->object_add_attribute('noc_param','T1',$task_num);
			$self->object_add_attribute('noc_param','T2',1);
			$self->object_add_attribute('noc_param','T3',1);
			set_gui_status($self,"ref",1);			
		}
	});
	
	$clean->signal_connect ( 'clicked'=> sub{
		remove_mapping($self);
		set_gui_status($self,"ref",1);	
	});
	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	
	return $sc_win;
}


######
# map_ctr
######		
sub trace_group_ctrl{
	
	my ($self,$tview,$mode,$NE)=@_;
	my $table= def_table(2,10,FALSE);
	
	
	
		
	my $clean = def_image_button('icons/clear.png');
	set_tip($clean,'Ungroup all actors');	
	
	my $box;
	$box=def_pack_hbox(FALSE,FALSE,$clean);	
	
	my $col=0;
	my $row=0;
	
	
	
	
	$table->attach ($box,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);$row++;	
	
	#$self->object_add_attribute('grouping','map_limit',$NE);
	#add_param_widget ($self,'Max actors in a group:','map_limit', 4,"Spin-button","1,1024,1","The maximum number of actors that can be grouped to be run in one tile", $table,$row,$col,1,'grouping',undef,undef);
	
	
	
	$clean->signal_connect ( 'clicked'=> sub{
		my $group_num=$self->object_get_attribute('grouping','group_num');
		my $gname=$self->object_get_attribute('grouping','group_name_root');
		for(my $i=0;$i<$group_num;$i=$i+1){
			$self->object_add_attribute('grouping',"$gname($i)",\());		
		}			
		set_gui_status($self,"ref",1);	
	});
	
	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	
	
	return $sc_win;
}








	
#########
# trace
#########

sub trace_pad{
	my ($self,$tview,$mode)=@_;
	my $table= def_table(10,10,FALSE);
	#my $separator = Gtk2::HSeparator->new;	
	my $row=0;
	my $col=0;
		
	
	my @selectedinfo = (
		{ label=>" Initial weight ", param_name=>'init_weight', type=>'Spin-button', default_val=>1, content=>"1,16,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
		{ label=>" Min pck size ", param_name=>'min_pck_size', type=>'Spin-button', default_val=>5, content=>"2,1024,1", info=>undef, param_parent=>'select_multiple', ref_delay=> 10, new_status=>'ref'},
		{ label=>" Max pck size ",param_name=>'max_pck_size', type=>'Spin-button', default_val=>5, content=>"2,1024,1", info=>undef, param_parent=>'select_multiple', ref_delay=> 10, new_status=>'ref'},
		{ label=>" Burst_size ", param_name=>'burst_size', type=>'Spin-button', default_val=>1, content=>"1,1024,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
		{ label=>" Inject rate(%) ", param_name=>'injct_rate', type=>'Spin-button', default_val=>10, content=>"1,100,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
	    { label=>" Inject rate variation (%) ", param_name=>'injct_rate_var', type=>'Spin-button', default_val=>20, content=>"0,100,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
	);
	
	my $v_val= $self->object_get_attribute('noc_param','V');
	my $v_max=$v_val-1;	
	
	my $c_val= $self->object_get_attribute('noc_param','C');
	my $c_max=($c_val==0)? 0 : $c_val-1;
	
	
	if($mode eq "orcc"){
		
		@selectedinfo = (
			{ label=>" Initial weight ", param_name=>'init_weight', type=>'Spin-button', default_val=>1, content=>"1,16,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
			{ label=>" Virtual channel# ", param_name=>'vc', type=>'Spin-button', default_val=>0, content=>"0,$v_max,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef},
			{ label=>" Message class# ", param_name=>'class', type=>'Spin-button', default_val=>0, content=>"0,$c_max,1", info=>undef, param_parent=>'select_multiple', ref_delay=> undef, new_status=>undef}
		);
	}
	
	
	my @traces= get_trace_list($self,'raw');
	my %f;
	
	
	my $sel=$self->object_get_attribute('select_multiple','action');
	
	foreach my $p (@traces) {	
		my ($src,$dst, $Mbytes, $file_id, $file_name)=get_trace($self,'raw',$p);
		$f{$file_id}=$file_id.'*';
		$self->object_add_attribute("raw_$p",'selected', 1 ) if ($sel eq  'All');
		$self->object_add_attribute("raw_$p",'selected', 0 ) if ($sel eq  'None');
		$self->object_add_attribute("raw_$p",'selected', 1 ) if ($sel eq  "All-$file_id*");
		$self->object_add_attribute("raw_$p",'selected', 0 ) if ($sel eq  "None-$file_id*");
		
		my $seleceted =$self->object_get_attribute("raw_$p",'selected');
		foreach my $d (@selectedinfo) {
			my $val=$self->object_get_attribute($d->{param_parent},$d->{param_name}) if ($sel eq  $d->{param_name} && $seleceted);	
			$self->object_add_attribute("raw_$p",$d->{param_name}, $val ) if ($sel eq  $d->{param_name}&& $seleceted);	
			
		}
	}	
	my $sel_options= "Select,All,None";
	if( keys %f > 1){
		foreach my $p (sort keys %f) {
			$sel_options="$sel_options,All-$f{$p}";
			$sel_options="$sel_options,None-$f{$p}";
		}
	}	
	$self->object_add_attribute('select_multiple','action',"Select");
	my $selcombo = $self-> gen_combobox_object ('select_multiple',"action", $sel_options,'-','ref',1);
	
	
	if(scalar @traces ){$table-> attach  ($selcombo, $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;}
	
	
	my @titles;
	#print "******************$mode*******************\n";
	if($mode eq 'task'){
		@titles = (scalar @traces ) ? (" # "," Source "," Destination "," Bandwidth(MB) ", " Initial weight ", " Min pck size ",  " Max pck size "):
	("Load a task graph");
	}
	else{
		@titles = (scalar @traces ) ? (" # "," Source "," Destination "," Bandwidth(MB) ", " Initial weight#", "Virtual channel#", "Message class#"):
	("Load an ORCC file");
	}
	
	my $auto=$self->object_get_attribute('Auto','Auto_inject');
	
	push (@titles, (" Burst_size ", " Inject rate(%) ", " Inject rate variation(%) ")) if ($auto eq "1\'b0" && $mode eq 'task');
	foreach my $p (@titles){
		$table-> attach  (gen_label_in_left($p), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  
		$col++;
	}
		$row++;	
				
	my $i=0;
	#my @t=sort { $a cmp $b } @traces;
	
	foreach my $p (@traces) {	
		$col=0;	
		my ($src,$dst, $Mbytes, $file_id, $file_name)=get_trace($self,'raw',$p);
		
				
		my $check = gen_check_box_object ($self,"raw_$p",'selected',0,'ref',0);
		my $weight= gen_spin_object ($self,"raw_$p",'init_weight',"1,16,1", 1,undef,undef);
		my $vc= gen_spin_object ($self,"raw_$p",'vc',"0,$v_max,1", 0,undef,undef);
		my $class= gen_spin_object ($self,"raw_$p",'class',"0,$c_max,1", 0,undef,undef);
		
		my $min=$self->object_get_attribute("raw_$p",'min_pck_size');
		my $max=$self->object_get_attribute("raw_$p",'max_pck_size');
		$min=$max=5 if(!defined $min);
		my $min_pck_size= gen_spin_object ($self,"raw_$p",'min_pck_size',"2,$max,1", 5,'ref',10);
		my $max_pck_size= gen_spin_object ($self,"raw_$p",'max_pck_size',"$min,1024,1", 5,'ref',10);
		
		my $burst_size	= gen_spin_object ($self,"raw_$p",'burst_size',"1,1024,1", 1,undef,undef);
		my $injct_rate  = gen_spin_object ($self,"raw_$p",'injct_rate',"1,100,1", 10,undef,undef);
		my $injct_rate_var  = gen_spin_object ($self,"raw_$p",'injct_rate_var',"0,100,1", 20,undef,undef);
		
		#my $weight=  trace_$trace_id",'init_weight'
		
		$table-> attach  ($check, $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
		
		$table-> attach (gen_label_in_left($i), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++; 
		$table-> attach (gen_label_in_left("$src") ,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
		$table-> attach (gen_label_in_left("$dst") , $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
		$table-> attach (gen_label_in_left("$Mbytes") ,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
		$table-> attach ($weight ,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
		if($mode eq 'task'){			
			$table-> attach ($min_pck_size, $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
		    $table-> attach ($max_pck_size, $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
		    if ($auto eq "1\'b0"){
				$table-> attach ($burst_size ,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
				$table-> attach ($injct_rate ,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
				$table-> attach ($injct_rate_var ,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;		
		    }
		}else{
			$table-> attach ($vc ,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
			$table-> attach ($class ,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
		}
		
		$row++;	
		
	}
	
	my $sc_win = gen_scr_win_with_adjst($self,'trace_pad');
	$sc_win->add_with_viewport($table);
	
	return $sc_win;
}



sub load_tarce_file{
	my ($self,$file,$tview)=@_;
	#open file
	my @x;
	my %traces;
	if (!defined $file) {return; }
	if (-e $file) { 
		my $f_id=$self->object_get_attribute("file_id",undef);
		my $t_id=$self->object_get_attribute("trace_id",undef);
		open(my $fh, '<:encoding(UTF-8)', $file) or die "Could not open file '$file' $!";
		while (my $row = <$fh>) {
			chomp $row;
			my @data = 	split (/\s/,$row);
			
			next if (! defined $data[0]);
			next if ($data[0] eq '#' || scalar @data < 3);
			
			$self->add_trace($f_id,'raw',$t_id,$data[0],$data[1],$data[2],$file);
			$t_id++;			
		}
		$f_id++;
		$self->object_add_attribute("trace_id",undef,$t_id);
		$self->object_add_attribute("file_id",undef,$f_id);
	}
	set_gui_status($self,"ref",1);
	
}




########
# map
#######


sub group_info {
	my ($self,$tview,$mode)=@_;
	my $table= def_table(10,10,FALSE);
	
	
	my $sc_win = gen_scr_win_with_adjst($self,'trace_map');
	$sc_win->add_with_viewport($table);
	
	my $row=0;
	my $col=0;
	
	my $lab= ($mode eq 'task')? "Task-name" :"Actor-name";
	
	my @titles = (" # "," $lab ", " Internal" , " Sent ", " Resvd ", " Sent+Resvd ");
	foreach my $p (@titles){
		$table-> attach  (gen_label_in_left($p), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $col++;
	}
	$col=0;
	$row++;	
	
	
	
	my $i=0;
	my @tasks=get_all_merged_tasks($self);
	
	
	
	
	#print "tils=@tiles \nass=@assigned  \nlist=@list\n";
	my %com_tasks= $self->get_communication_task('merge');
	#print Dumper(\%com_tasks);
	foreach my $p (@tasks){
		
			
		$table-> attach  (gen_label_in_left($i), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $col++; 
		$table-> attach  (gen_label_in_left($p), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $col++; 
	    
		my @a=('internal' , 'sent','rsv','total');
		foreach my $q (@a){
			my $s = (defined $com_tasks{$p}{$q}) ? $com_tasks{$p}{$q} : '-';
			$table-> attach  (gen_label_in_left($s), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $col++; 
		
		}
		
		
		
		
	
		$i++;
		$col=0;
		$row++;						
	}
		
   
   		
			
	
	return $sc_win;
	
}








########
# map_info
#######


sub map_info {
	my ($self)=@_;
	my $sc_win = gen_scr_win_with_adjst($self,'map_info');
	my $table= def_table(10,10,FALSE);
	$sc_win->add_with_viewport($table);
	
	my $row=0;
	my $col=0;
	my ($avg,$max,$min,$norm)=get_map_info($self);
	
	
	my @data = (
  {label => "Average distance",  value =>"$avg"}, 
  {label => "Max distance",  value =>"$max" },  
  {label => "Min distance",value => "$min"},    
  {label => "Normalized data per hop", value =>"$norm" }
  );
	
	
	
  # create list store
  my $store = Gtk2::ListStore->new (#'Glib::Boolean', # => G_TYPE_BOOLEAN
                                    #'Glib::Uint',    # => G_TYPE_UINT
                                    'Glib::String',  # => G_TYPE_STRING
                                    'Glib::String'); # you get the idea

  # add data to the list store
  foreach my $d (@data) {
      my $iter = $store->append;
      $store->set ($iter,
		   0, $d->{label},
		   1, $d->{value},
      );
  }

	my $treeview = Gtk2::TreeView->new ($store);
    $treeview->set_rules_hint (TRUE);
 

	$treeview->set_search_column (1);

   
    # add columns to the tree view
   my $renderer = Gtk2::CellRendererToggle->new;
   $renderer->signal_connect (toggled => \&fixed_toggled, $store);

 

  # column for severities
  $renderer = Gtk2::CellRendererText->new;
  my $column = Gtk2::TreeViewColumn->new_with_attributes ("Mapping summary",
						       $renderer,
						       text => 0);
  $column->set_sort_column_id (0);
  $treeview->append_column ($column);

  # column for description
  $renderer = Gtk2::CellRendererText->new;
  $column = Gtk2::TreeViewColumn->new_with_attributes (" ",
						       $renderer,
						       text => 1);
  $column->set_sort_column_id (1);
  $treeview->append_column ($column);

	
	$table-> attach  ($treeview, $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $row++; 
	#$table-> attach  (gen_label_in_left("Max distance:  $max  "), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $row++; 
	#$table-> attach  (gen_label_in_left("Min distance: $min   "), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $row++; 
	#$table-> attach  (gen_label_in_left("Normlized data per hop: $norm"), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $row++; 
		
	
	return $sc_win;

}




sub get_map_info {
	my $self=shift;
	my ($avg,$max,$min,$norm)=(0,0,999999,0);
	my $sum=0;	
	my $num=0;	
	
	my $data=0;	
	my $comtotal=0;	
	
	my @traces= get_trace_list($self,'merge');
	
	foreach my $p (@traces) {	
		my ($src, $dst, $Mbytes, $file_id, $file_name)=get_trace($self,'merge',$p);
		#my $src_tile = $self->object_get_attribute('MAP_TILE',"$src");
		my  $src_tile = get_task_give_tile($self,"$src");
		#my $dst_tile = $self->object_get_attribute('MAP_TILE',"$dst");
		my $dst_tile  = get_task_give_tile($self,"$dst");
		next if(!defined $src_tile || !defined  $dst_tile );
		next if($src_tile eq '-' || $dst_tile eq "-" );
		#my ($src_x,$src_y)= tile_id_to_loc($src_tile);
		
		#my ($dst_x,$dst_y)= tile_id_to_loc($dst_tile);		
		#print" ($dst_x,$dst_y)= tile_id_to_loc($dst_tile)\n";
		
		my $mah_distance=get_endpoints_mah_distance($self,tile_id_number($src_tile),tile_id_number($dst_tile));
		#print "$mah_distance=get_mah_distance($src_x,$src_y,$dst_x,$dst_y);\n";
		$min = $mah_distance if($min> $mah_distance);
		$max = $mah_distance if($max< $mah_distance);
		$sum+=$mah_distance;	
		$num++;	
		
		$data+=($Mbytes*$mah_distance);	
	    $comtotal+=$Mbytes;	
		
	}
	
	$avg=$sum/$num if($num!=0);
	$min = 0 if $min == 999999;
	$norm = $data/$comtotal if ($comtotal !=0);
	return ($avg,$max,$min,$norm);
	
}	





sub map_combobox {
 	my ($object,$task_name,$content,$default)=@_;
	my @combo_list=@{$content};
	#my $value=$object->object_get_attribute("MAP_TILE",$task_name);
	my $value=get_task_give_tile($object,$task_name);
	my $pos;
	$pos=get_pos($value, @combo_list) if (defined $value);
	if(!defined $pos && defined $default){
		#$object->object_add_attribute("MAP_TILE",$task_name,$default);	
	 	$pos=get_item_pos($default, @combo_list);
	}
	#print " my $pos=get_item_pos($value, @combo_list);\n";
	my $widget=gen_combo(\@combo_list, $pos);
	$widget-> signal_connect("changed" => sub{
		my $new_tile=$widget->get_active_text();
		$object->map_task($task_name,$new_tile);
				
		set_gui_status($object,'ref',1);
	 });
	return $widget;	
}


##########
#	save_as
##########
sub save_as{
	my ($self)=@_;
	# read emulation name
	my $name=$self->object_get_attribute ("save_as",undef);	
	my $s= (!defined $name)? 0 : (length($name)==0)? 0 :1;	
	if ($s == 0){
		message_dialog("Please define file name!");
		return 0;
	}
	# Write object file
	open(FILE,  ">lib/simulate/$name.TRC") || die "Can not open: $!";
	print FILE perl_file_header("$name.TRC");
	print FILE Data::Dumper->Dump([\%$self],['Trace']);
	close(FILE) || die "Error closing file: $!";
	message_dialog("workspace has been saved as lib/simulate/$name.TRC!");
	return 1;
}




#############
#	load_workspace
############

sub load_workspace {
	my $self=shift;
	my $mpsoc_name=$self->object_get_attribute('mpsoc_name');
	
	my $file;
	my $dialog = Gtk2::FileChooserDialog->new(
            	'Select a File', undef,
            	'open',
            	'gtk-cancel' => 'cancel',
            	'gtk-ok'     => 'ok',
        	);

	my $filter = Gtk2::FileFilter->new();
	$filter->set_name("TRC");
	$filter->add_pattern("*.TRC");
	$dialog->add_filter ($filter);
	my $dir = Cwd::getcwd();
	$dialog->set_current_folder ("$dir/lib/simulate");		

	
	if ( "ok" eq $dialog->run ) {
		$file = $dialog->get_filename;
		my ($name,$path,$suffix) = fileparse("$file",qr"\..[^.]*$");
		if($suffix eq '.TRC'){		
							
			my ($pp,$r,$err) = regen_object($file);
			if ($r){		
				message_dialog("Error reading  $file file: $err\n",'error');
				 $dialog->destroy;
				return;
			} 
			
			my ($tmp,$r1,$err1) = regen_object($file);
			
			
			clone_obj($tmp,$self);
			
								
			clone_obj($self,$pp);
			
			#update current parameter 
			my @pnames=('soc_name','ni_name','noc_param');
			foreach my $n (@pnames){
				my $param=$tmp->object_get_attribute($n);
				if( defined $param){
					my %params=%{$param};
					foreach my $p (sort keys %params){
						$self->{$n}{$p}=$params{$p};			 
					}
				}
			}
			
			#update mpsocname
			$self->object_add_attribute('mpsoc_name',undef,$mpsoc_name) if (defined $mpsoc_name);
			
			
			
			
			
			
			#print Dumper($self);
			
			#message_dialog("done!");				
		}					
     }
     $dialog->destroy;
}


########
# genereate_output_tasks
########

sub genereate_output_tasks{
	my $self=shift;
	my $name= $self->object_get_attribute('out_name');
	my $size= (defined $name)? length($name) :0;
	if ($size ==0) {
		message_dialog("Please define the output file name!");
		return 0;
	}
	
	
	
	# make target dir
	my $dir = Cwd::getcwd();
	my $target_dir  = "$ENV{'PRONOC_WORK'}/traffic_pattern";
	mkpath("$target_dir",1,0755);
	
	my @tasks=get_all_merged_tasks($self);
	foreach my $p (@tasks) {	
		#my $tile=$self->object_get_attribute("MAP_TILE",$p);
		my $tile= get_task_give_tile($self,$p);
		if ( $tile eq "-" ){
			message_dialog("Error: unmapped task. Please map task $p to a tile", 'error' );
			return;
		}
	
	}
	#creat output file
    open(FILE,  ">$target_dir/$name.cfg") || die "Can not open: $!";
	print FILE get_cfg_content($self);
	close(FILE) || die "Error closing file: $!";
	message_dialog("The traffic pattern is saved as $target_dir/$name.cfg" );
	
}

sub get_cfg_content{
	my $self=shift;
	my $file="% source tile, destination tile, bytes, initial_weight, min_pck_size, max_pck_size, burst_size, injection_rate(%), injection_rate variation(%)\n";
	

	
	my @traces= get_trace_list($self,'merge');
	foreach my $p (@traces) {	
		my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var)=get_trace($self,'merge',$p);
				
		
		my  $src_tile = tile_id_number(get_task_give_tile($self,"$src"));
		my  $dst_tile = tile_id_number(get_task_give_tile($self,"$dst"));
		
		my $auto=$self->object_get_attribute('Auto','Auto_inject');
		
		my $bytes = $Mbytes * 1000000;
		
		$file=$file."$src_tile, $dst_tile, $bytes, $init_weight, $min_pck, $max_pck";
		$file=$file.", $burst, $injct_rate, $injct_rate_var \n" if ($auto eq "1\'b0");
		$file=$file." \n" if ($auto eq "1\'b1");
	}
	
	return $file;
}



sub add_trace{
	my ($self, $file_id,$category,$trace_id, $source,$dest, $Mbytes, $file_name,$src_port,$dst_port,$buff_size,$channel,$vc,$class)=@_;	
	$self->object_add_attribute("${category}_$trace_id",'file',$file_id);
	$self->object_add_attribute("${category}_$trace_id",'source',"${source}");
	$self->object_add_attribute("${category}_$trace_id",'destination',"${dest}");
	$self->object_add_attribute("${category}_$trace_id",'Mbytes', $Mbytes);
	$self->object_add_attribute("${category}_$trace_id",'file_name', $file_name);  
	$self->object_add_attribute("${category}_$trace_id",'selected', 0); 
	$self->object_add_attribute("${category}_$trace_id",'init_weight', 1); 
	$self->object_add_attribute("${category}_$trace_id",'scr_port',$src_port);
	$self->object_add_attribute("${category}_$trace_id",'dst_port',$dst_port);	
	$self->object_add_attribute("${category}_$trace_id",'buff_size',$buff_size);	
	$self->object_add_attribute("${category}_$trace_id",'channel',$channel);
	$self->object_add_attribute("${category}_$trace_id",'vc',$vc);
	$self->object_add_attribute("${category}_$trace_id",'class',$class);					
	$self->{"${category}_traces"}{$trace_id}=1;
	
}

sub add_trace_extra {
	my ($self, $file_id,$category,$trace_id,$min_pck, $max_pck,$burst, $injct_rate, $injct_rate_var)=@_;
	$self->object_add_attribute("${category}_$trace_id",'min_pck_size',$min_pck);
	$self->object_add_attribute("${category}_$trace_id",'max_pck_size',$max_pck);
	$self->object_add_attribute("${category}_$trace_id",'burst_size',$burst); 
	$self->object_add_attribute("${category}_$trace_id",'injct_rate',$injct_rate);	
	$self->object_add_attribute("${category}_$trace_id",'injct_rate_var',$injct_rate_var);	
}	


sub remove_trace{
	my ($self,$category, $trace_id)=@_;
	delete $self->{"${category}_$trace_id"};	
	delete $self->{"${category}_traces"}{$trace_id};
}

sub get_trace_list{
	my ($self,$category)=@_;
	#print "($self,$category)\n";
	return sort (keys %{$self->{"${category}_traces"}});	
}

sub remove_all_traces{
	my ($self,$category)=@_;
	my @all =get_trace_list($self,$category);
	foreach my $trace_id (@all ){
		remove_trace ($self,$category, $trace_id);
	}
}


sub get_trace{
	my ($self,$category,$trace_id)=@_;	
	my $file_id		= $self->object_get_attribute("${category}_$trace_id",'file');
	my $source 		= $self->object_get_attribute("${category}_$trace_id",'source');
	my $dest		= $self->object_get_attribute("${category}_$trace_id",'destination');
	my $Mbytes  	= $self->object_get_attribute("${category}_$trace_id",'Mbytes');
	my $file_name	= $self->object_get_attribute("${category}_$trace_id",'file_name');	
	my $init_weight = $self->object_get_attribute("${category}_$trace_id",'init_weight'); 
	my $min_pck_size= $self->object_get_attribute("${category}_$trace_id",'min_pck_size');
	my $max_pck_size= $self->object_get_attribute("${category}_$trace_id",'max_pck_size');
	my $burst_size	= $self->object_get_attribute("${category}_$trace_id",'burst_size'); 
	my $injct_rate  = $self->object_get_attribute("${category}_$trace_id",'injct_rate');	
	my $injct_rate_var = $self->object_get_attribute("${category}_$trace_id",'injct_rate_var');	
	my $src_port = $self->object_get_attribute("${category}_$trace_id",'scr_port');
	my $dst_port = $self->object_get_attribute("${category}_$trace_id",'dst_port');
	my $buff_size= $self->object_get_attribute("${category}_$trace_id",'buff_size');
	my $channel = $self->object_get_attribute("${category}_$trace_id",'channel');
	my $vc= $self->object_get_attribute("${category}_$trace_id",'vc');	
	my $class= $self->object_get_attribute("${category}_$trace_id",'class');	  
	return ($source,$dest, $Mbytes, $file_id,$file_name,$init_weight,$min_pck_size, $max_pck_size, $burst_size, $injct_rate, $injct_rate_var, $src_port,$dst_port,$buff_size,$channel,$vc,$class);	
}

sub get_all_tasks{
	my ($self,$category)=@_;
	my @traces= get_trace_list($self,$category);
	my @x;
	foreach my $p (@traces){
		my ($src,$dst, $Mbytes, $file_id, $file_name)=get_trace($self,$category,$p);
		push(@x,$src);
		push(@x,$dst);		
	}
	my @x2 =  uniq(sort  @x) if (scalar @x);
	return @x2;	
}


sub remove_mapping{
	my $self=shift;
	$self->object_add_attribute('MAP_TASK',undef,undef);
	$self->object_add_attribute('mapping',undef,undef); 
	#$self->object_add_attribute('MAP_TILE',undef,undef);
}



sub remove_nlock_mapping{
	my $self=shift;
	my @tasks=get_all_merged_tasks($self);
	
	foreach my $p (@tasks){
		my $lock=$self->object_get_attribute("MAP_LOCK",$p);
		$lock = 0 if (!defined $lock);
		if($lock == 0){
			#my $tile=$self->object_get_attribute("MAP_TILE",$p);
			my $tile=get_task_give_tile($self,$p);
			#$self->object_add_attribute("MAP_TILE",$p,undef);
			$self->object_add_attribute("MAP_TASK",$tile,undef);
			$self->object_add_attribute("mapping",$tile,undef);
			
			
		}		
	}	
}


sub get_nlock_tasks {
	#my ($self,$taskref,$tileref)=shift;
	my $self=shift;
	my @unluck_tasks;
	my @tasks=get_all_merged_tasks($self);
	
	foreach my $p (@tasks){
		my $lock=$self->object_get_attribute("MAP_LOCK",$p);
		$lock = 0 if (!defined $lock);
		if($lock == 0){
			push(@unluck_tasks,$p);
		}
	
	}
	return  @unluck_tasks;	
}

sub get_nlock_tiles {
	#my ($self,$taskref,$tileref)=shift;
	my $self=shift;
	my @luck_tiles;
	my @tasks=get_all_merged_tasks($self);
	
	foreach my $task (@tasks){
		my $lock=$self->object_get_attribute("MAP_LOCK",$task);
		$lock = 0 if (!defined $lock);
		if($lock == 1){
			#my $tile=$self->object_get_attribute('MAP_TILE',"$task");
			my $tile=get_task_give_tile($self,"$task");
			push(@luck_tiles,$tile);
		}
	
	}
	my @tiles=get_tiles_name($self);
	
	#a-b
	return get_diff_array(\@tiles,\@luck_tiles);	
}


sub get_locked_map {
	my $self=shift;
	my %map; 
	my @tasks=get_all_merged_tasks($self);
	
	foreach my $task (@tasks){
		my $lock=$self->object_get_attribute("MAP_LOCK",$task);
		
		$lock = 0 if (!defined $lock);
		if($lock == 1){
			#my $tile=$self->object_get_attribute('MAP_TILE',"$task");
			my $tile=get_task_give_tile($self,"$task");
			$map{$task}=$tile;
		}
	
	}
	return  %map;	
}


#########
#	Mapping algorithm
#########
sub random_map{
	my $self=shift;
		
	
	
	my $nx=$self->object_get_attribute('noc_param','T1');
	my $ny=$self->object_get_attribute('noc_param','T2');
	my $nc= $nx * $ny;
	
	
	
	my @tasks=get_nlock_tasks($self);	
	my @tiles=get_nlock_tiles($self);	
	$self->remove_nlock_mapping() ;
	
	
	my @rnd= shuffle @tiles;
	
	my $i=0;
	foreach my $task (@tasks){
		if($i>=scalar @rnd){
			last;
		};
		my $tile=$rnd[$i];
		#$self->object_add_attribute('MAP_TILE',"$task",$tile);
		$self->object_add_attribute('MAP_TASK',"$tile",$task);
		my @l=($task);
		$self->object_add_attribute("mapping","$tile",\@l); 
		
		$i++;	
		
	}
	
	set_gui_status($self,"ref",1);
	
}

sub direct_map {
	my $self=shift;
	
	
	my @tasks=get_nlock_tasks($self);	
	my @tiles=get_nlock_tiles($self);	
	$self->remove_nlock_mapping() ;
	
	my @sort_tiles;
	my %tilenum;
	foreach my $tile (@tiles){
		#my ($x,$y)=tile_id_to_loc($tile);
		#my $id= $y*$nx+$x;
		my $id=tile_id_number($tile);
		$tilenum{$id}=$tile;
	}
	
	foreach my $id  (sort  {$a <=> $b} keys %tilenum){
		
		push(@sort_tiles, $tilenum{$id});
	}
	
	
	my @sort_tasks = sort @tasks;
	
	
	my $i=0;
	foreach my $task (@sort_tasks){
		if($i>=scalar @sort_tiles){
			last;
		};
		my $tile=$sort_tiles[$i];
		#$self->object_add_attribute('MAP_TILE',"$task",$tile);
		$self->object_add_attribute('MAP_TASK',"$tile",$task);
		my @l = ($task);
		$self->object_add_attribute("mapping","$tile",\@l); 
	
		$i++;	
		
	}
	
	set_gui_status($self,"ref",1);
	
	
}


sub get_task_give_tile{
	my ($self,$task)=@_;
	my @tiles=get_tiles_name($self);
	foreach my $p (@tiles){
		my $r=$self->object_get_attribute("mapping","$p");
		
		my @l=@{$r} if(defined $r); 		
		if(defined $l[0] ){
			return $p	if($l[0] eq $task );
		}		
	}	
	return undef;
}

	
sub network_3dim_cal{
	my $n_tasks= shift;
	
	my $dim_x = floor($n_tasks**(1/3));
	
	my ($dim_y,$dim_z)=network_dim_cal(ceil($n_tasks/$dim_x));
	 
	
	
	return ($dim_x,$dim_y,$dim_z);

	
}	
	




sub network_dim_cal{
	my $n_tasks= shift;
	 
	my $dim_y = floor(sqrt($n_tasks));

	my $dim_x = ceil($n_tasks/$dim_y);
	
	return ($dim_x,$dim_y);

	#cout << "dim_x = " << dim_x << "; dim_y = " << dim_y << endl;
}


sub get_tiles_name{
	my $self=shift;
	my @tiles;
    my ($NE, $NR, $RAw, $EAw, $Fw)=get_topology_info($self);
    #print " my ($NE, $NR, $RAw, $EAw, $Fw)=get_topology_info($self)\n";
	for (my $tile_num=0;$tile_num<$NE;$tile_num++){
		push(@tiles,"tile($tile_num)");	
	}	
	
	return @tiles;	
}


sub tile_id_number{
	my $tile=shift;
	my ($x) =  $tile =~ /(\d+)/g;  
	return $x;
}



sub get_communication_task{
	my ($self,$category)=@_;
	my %com_tasks;
	my @tasks=get_all_merged_tasks($self);
	my @traces= get_trace_list($self,'raw');
	

	
	foreach my $p (@tasks){
		$com_tasks{$p}{'total'}= 0;
	
		foreach my $q (@tasks){
			$com_tasks{$p}{$q}= 0;
		
		}
	}
	
	foreach my $p (@traces){
		my ($src,$dst, $Mbytes, $file_id, $file_name)=get_trace($self,'raw',$p);
		$src =$self->get_item_group_name('grouping',$src);
		$dst =$self->get_item_group_name('grouping',$dst);
	    if	($src eq  $dst){
	    	$com_tasks{$src}{'internal'} += $Mbytes;
	    	
	    }else{	
		
			$com_tasks{$src}{'sent'} += $Mbytes;
			$com_tasks{$dst}{'rsv'} += $Mbytes;
			
			$com_tasks{$src}{'total'} += $Mbytes;
			$com_tasks{$dst}{'total'} += $Mbytes;
			$com_tasks{$src}{$dst} += $Mbytes;
			$com_tasks{$file_id}{'maxsent'} = $com_tasks{$src}{'sent'} if(!defined $com_tasks{$file_id}{'maxsent'});
			$com_tasks{$file_id}{'maxsent'} = $com_tasks{$src}{'sent'} if( $com_tasks{$file_id}{'maxsent'}<$com_tasks{$src}{'sent'});
			
			
			
			my $minpck = $self->object_get_attribute("raw_$p",'min_pck_size');
			my $maxpck = $self->object_get_attribute("raw_$p",'max_pck_size');
			my $avg_pck_size =($minpck+ $maxpck)/2;
			my $pck_num = ($Mbytes*8) /($avg_pck_size*64);
			$pck_num= 1 if($pck_num==0); 		
			$com_tasks{$src}{'min_pck_num'} =$pck_num if(!defined $com_tasks{$src}{'min_pck_num'}); 
			$com_tasks{$src}{'min_pck_num'} =$pck_num if( $com_tasks{$src}{'min_pck_num'} > $pck_num); 
	    }
		
	}
	return %com_tasks;
}	


sub find_max_neighbor_tile{
	my $self=shift;
	#Select the tile located in center as the max-neighbor if its not locked for any other task
	my ($NE,$NR) = get_topology_info($self);
	
	my $ne_mid = floor($NE/2);
	
	#my $centered_tile= get_tile_name($self,$x_mid ,$y_mid);
	#Select the tile located in center as the max-neighbor if its not locked for any other task
	#therwise select the tile with the min manhatan distance to center tile
	my @tiles=get_nlock_tiles($self);
	my $min=1000000;
	my $max_neighbors_tile_id;
	foreach my $tile (@tiles){
		#my ($x,$y)=tile_id_to_loc($tile);
		my $tile_num = tile_id_number($tile);
		my $mah_distance=get_endpoints_mah_distance($self,$ne_mid,$tile_num);
		
		if($min > $mah_distance ){
			$min = $mah_distance;
			$max_neighbors_tile_id=$tile;
		}
		
	} 	

	return $max_neighbors_tile_id;
}	
	
	
sub find_min_neighbor_tile	{
	my $self=shift;

	my $ne_mid = 0;

	#my $centered_tile= get_tile_name($self,$x_mid ,$y_mid);
	#Select the tile located in center as the max-neighbor if its not locked for any other task
	#otherwise select the tile with the min Manhattan distance to center tile
	my @tiles=get_nlock_tiles($self);
	my $min=1000000;
	my $min_neighbors_tile_id;
	foreach my $tile (@tiles){
		#my ($x,$y)=tile_id_to_loc($tile);
		my $tile_num = tile_id_number($tile);
		my $mah_distance=get_endpoints_mah_distance($self,$ne_mid,$tile_num );
		if($min > $mah_distance ){
			$min = $mah_distance;
			$min_neighbors_tile_id=$tile;
		}
		
	} 	

	return $min_neighbors_tile_id;
}	
	


sub nmap_algorithm{
	my $self=shift;	
	my $nx=$self->object_get_attribute('noc_param','T1');
	my $ny=$self->object_get_attribute('noc_param','T2');
	my $nc= $nx * $ny;
	
	my @tasks=get_all_merged_tasks($self);
	my @tiles= get_tiles_name($self);	
	my $n_tasks = scalar  @tasks;
	
	
	my @unmapped_tasks_set=@tasks; # unmapped set of tasks
	my @unallocated_tiles_set=@tiles;	# tile ids which are not allocated yet
	
#	print "@unmapped_tasks_set *** @unallocated_tiles_set\n";
	
	
	#------ step 1: find the task with highest weighted communication volume
	# find the max of com_vol
	# consider all incoming and outgoing connections of each tasks
	
	my %com_tasks= $self->get_communication_task('merge');
	#print  Data::Dumper->Dump([\%com_tasks],['mpsoc']);	
	
	my $max_com_task;
	my $max_com =0;
	foreach my $p (sort keys %com_tasks){
		#print "**$p\n";
		if(defined $com_tasks{$p}{'total'}){
		if ($com_tasks{$p}{'total'} >$max_com){
			$max_com = $com_tasks{$p}{'total'};
			$max_com_task = $p;
		}}
	}
	
	#print "m=$max_com 	t=$max_com_task\n";
	
	
	#------ step 2: find the tile with max number of neighbors
	# normally, this tile is in the middle of the array
	my $max_neighbors_tile_id = find_max_neighbor_tile($self);
	
	#print "\$max_neighbors_tile_id = $max_neighbors_tile_id\n";
	
	
	
	my %map=get_locked_map ($self);	
	$self->remove_nlock_mapping();
	foreach my $mapped_task (sort keys %map){
			my $mapped_tile=$map{$mapped_task};
			@unmapped_tasks_set=remove_scolar_from_array(\@unmapped_tasks_set,$mapped_task);
			@unallocated_tiles_set=remove_scolar_from_array(\@unallocated_tiles_set,$mapped_tile);
	}
		
	
	
	
	# add this task with highest weighted communication volume to the mapped task set
	#push(@mapped_tasks_set,$max_com_task);
	#task_mapping[max_com_task] = max_neighbors_tile_id;
	
	if(!defined $map{$max_com_task}){
		$map{$max_com_task}=$max_neighbors_tile_id;
		@unmapped_tasks_set=remove_scolar_from_array(\@unmapped_tasks_set,$max_com_task);
		@unallocated_tiles_set=remove_scolar_from_array(\@unallocated_tiles_set,$max_neighbors_tile_id);
	}



	#------ step 3: map all unmapped tasks
	while(scalar @unmapped_tasks_set){
		$max_com =0;
		my $max_com_unmapped_task;
		my $max_overall_com=0;
		#--------- step 3.1:
		# find the unmapped task which communicates most with mapped_tasks_set
		# among many tasks which have the same communication volume with mapped_tasks,
		# choose the task with highest communication volume with others
		
		foreach my $unmapped_task (@unmapped_tasks_set){
			
			my $com_vol=0;
			foreach my $mapped_task (sort keys %map){
				$com_vol += $com_tasks{$unmapped_task}{$mapped_task};
				$com_vol += $com_tasks{$mapped_task}{$unmapped_task};
			}
			
			my $overall_com_vol = 0;
			foreach my $p (@tasks){
				$overall_com_vol += $com_tasks{$unmapped_task}{$p};
				$overall_com_vol += $com_tasks{$p}{$unmapped_task};
			}
			
			
			if ($com_vol > $max_com){
				$max_com = $com_vol;
				$max_com_unmapped_task = $unmapped_task;
				$max_overall_com = $overall_com_vol;
			}
			elsif ($com_vol == $max_com){ # choose if it have higher comm volume
				if ($overall_com_vol > $max_overall_com){
					$max_com_unmapped_task = $unmapped_task;
					$max_overall_com = $overall_com_vol;
				}
			}
		}#foreach my $unmapped_task (@unmapped_tasks_set)

		#--------- step 3.2, find the unallocated tile with lowest communication cost to/from allocated_tile_set
		my $min_com_cost;
		my $min_com_cost_tile_id;
		
		
		foreach my $unallocated_tile(@unallocated_tiles_set){
			my $com_cost = 0;
			#my ($unallocated_x,$unallocated_y)=tile_id_to_loc($unallocated_tile);
			my $unallocated_tile_num = tile_id_number($unallocated_tile);
			# scan all mapped tasks
			foreach my $mapped_task (sort keys %map){
				# get location of this mapped task
				my $mapped_tile=$map{$mapped_task};
				#my ($allocated_x,$allocated_y)=tile_id_to_loc($mapped_tile);
				my $mapped_tile_num = tile_id_number($mapped_tile);				
				# mahattan distance of 2 tiles
				my $mah_distance=get_endpoints_mah_distance($self,$unallocated_tile_num,$mapped_tile_num);
				

				$com_cost += $com_tasks{$max_com_unmapped_task}{$mapped_task} * $mah_distance;
				$com_cost += $com_tasks{$mapped_task}{$max_com_unmapped_task} * $mah_distance;
					
			}
			$min_com_cost = $com_cost+1 if(!defined $min_com_cost);
			if ($com_cost < $min_com_cost){
				$min_com_cost = $com_cost;
				$min_com_cost_tile_id = $unallocated_tile;
			}
		}
		
		# add max_com_unmapped_task to the mapped_tasks_set set
		#task_mapping[max_com_unmapped_task] = min_com_cost_tile_id;
		$map{$max_com_unmapped_task}=$min_com_cost_tile_id;
		@unmapped_tasks_set=remove_scolar_from_array(\@unmapped_tasks_set,$max_com_unmapped_task);
		@unallocated_tiles_set=remove_scolar_from_array(\@unallocated_tiles_set,$min_com_cost_tile_id);
		
	}
	
	
	foreach my $mapped_task (sort keys %map){
			my $mapped_tile=$map{$mapped_task};
			#print "$mapped_tile=\$map{$mapped_task};\n";
			#$self->object_add_attribute('MAP_TILE',"$mapped_task", $mapped_tile) if(defined $mapped_tile);
			$self->object_add_attribute('MAP_TASK',"$mapped_tile",$mapped_task) if(defined $mapped_tile);
			my @l = ($mapped_task);
			$self->object_add_attribute('mapping',"$mapped_tile",\@l) if(defined $mapped_tile);		
			#print "\$self->object_add_attribute('mapping',$mapped_tile,@l) if(defined $mapped_tile);\n";
	}
	set_gui_status($self,"ref",1);
		
}	
		
		






sub worst_map_algorithm{

	my $self=shift;
	
	
	my $nx=$self->object_get_attribute('noc_param','T1');
	my $ny=$self->object_get_attribute('noc_param','T2');
	my $nc= $nx * $ny;
	
	my @tasks=get_all_merged_tasks($self);
	my @tiles= get_tiles_name($self);
	
	my $n_tasks = scalar  @tasks;
	
	
	
	
	my @unmapped_tasks_set=@tasks; # unmapped set of tasks
	my @unallocated_tiles_set=@tiles;	# tile ids which are not allocated yet
	
	
	
	
	#------ step 1: find the task with highest weighted communication volume
	# find the max of com_vol
	# consider all incoming and outgoing connections of each tasks
	
	my %com_tasks= $self->get_communication_task('merge');
	#print  Data::Dumper->Dump([\%com_tasks],['mpsoc']);	
	
	my $max_com_task;
	my $max_com =0;
	foreach my $p (sort keys %com_tasks){
		#print "$p\n";
		if(defined $com_tasks{$p}{'total'}){
		if ($com_tasks{$p}{'total'} >$max_com){
			$max_com = $com_tasks{$p}{'total'};
			$max_com_task = $p;
		}}
	}
	
	
	
	
	#------ step 2: find the tile with min number of neighbors
	# normally, this tile is in the corners 
	my $min_neighbors_tile_id = find_min_neighbor_tile($self);
	
	
	
	
	my %map=get_locked_map ($self);	
	$self->remove_nlock_mapping();
	foreach my $mapped_task (sort keys %map){
			my $mapped_tile=$map{$mapped_task};
			@unmapped_tasks_set=remove_scolar_from_array(\@unmapped_tasks_set,$mapped_task);
			@unallocated_tiles_set=remove_scolar_from_array(\@unallocated_tiles_set,$mapped_tile);
	}
		
	
	
	
	# add this task with highest weighted communication volume to the mapped task set
	#push(@mapped_tasks_set,$max_com_task);
	#task_mapping[max_com_task] = max_neighbors_tile_id;
	
	if(!defined $map{$max_com_task}){
		$map{$max_com_task}=$min_neighbors_tile_id;
		@unmapped_tasks_set=remove_scolar_from_array(\@unmapped_tasks_set,$max_com_task);
		@unallocated_tiles_set=remove_scolar_from_array(\@unallocated_tiles_set,$min_neighbors_tile_id);
	}







	#------ step 3: map all unmapped tasks
	while(scalar @unmapped_tasks_set){
		$max_com =0;
		my $max_com_unmapped_task;
		my $max_overall_com=0;
		#--------- step 3.1:
		# find the unmapped task which communicates most with mapped_tasks_set
		# among many tasks which have the same communication volume with mapped_tasks,
		# choose the task with highest communication volume with others
		
		foreach my $unmapped_task (@unmapped_tasks_set){
			
			my $com_vol=0;
			foreach my $mapped_task (sort keys %map){
				$com_vol += $com_tasks{$unmapped_task}{$mapped_task};
				$com_vol += $com_tasks{$mapped_task}{$unmapped_task};
			}
			
			my $overall_com_vol = 0;
			foreach my $p (@tasks){
				$overall_com_vol += $com_tasks{$unmapped_task}{$p};
				$overall_com_vol += $com_tasks{$p}{$unmapped_task};
			}
			
			
			if ($com_vol > $max_com){
				$max_com = $com_vol;
				$max_com_unmapped_task = $unmapped_task;
				$max_overall_com = $overall_com_vol;
			}
			elsif ($com_vol == $max_com){ # choose if it have higher comm volume
				if ($overall_com_vol > $max_overall_com){
					$max_com_unmapped_task = $unmapped_task;
					$max_overall_com = $overall_com_vol;
				}
			}
		}#foreach my $unmapped_task (@unmapped_tasks_set)

		#--------- step 3.2, find the unallocated tile with highest communication cost to/from allocated_tile_set
		my $max_com_cost;
		my $max_com_cost_tile_id;
		
		
		foreach my $unallocated_tile(@unallocated_tiles_set){
			my $com_cost = 0;
			#my ($unallocated_x,$unallocated_y)=tile_id_to_loc($unallocated_tile);
			my $unallocated_tile_num = tile_id_number($unallocated_tile);
			# scan all mapped tasks
			foreach my $mapped_task (sort keys %map){
				# get location of this mapped task
				my $mapped_tile=$map{$mapped_task};
				#my ($allocated_x,$allocated_y)=tile_id_to_loc($mapped_tile);
				my $mapped_tile_num = tile_id_number($mapped_tile);				
				# mahattan distance of 2 tiles				
				my $mah_distance=get_endpoints_mah_distance($self,$unallocated_tile_num,$mapped_tile_num);
				
				$com_cost += $com_tasks{$max_com_unmapped_task}{$mapped_task} * $mah_distance;
				$com_cost += $com_tasks{$mapped_task}{$max_com_unmapped_task} * $mah_distance;
					
			}
			$max_com_cost = $com_cost-1 if(!defined $max_com_cost);
			if ($com_cost > $max_com_cost){
				$max_com_cost = $com_cost;
				$max_com_cost_tile_id = $unallocated_tile;
			}
		}
		
		# add max_com_unmapped_task to the mapped_tasks_set set
		#task_mapping[max_com_unmapped_task] = min_com_cost_tile_id;
		$map{$max_com_unmapped_task}=$max_com_cost_tile_id;
		@unmapped_tasks_set=remove_scolar_from_array(\@unmapped_tasks_set,$max_com_unmapped_task);
		@unallocated_tiles_set=remove_scolar_from_array(\@unallocated_tiles_set,$max_com_cost_tile_id);
		
	}
	
	
	foreach my $mapped_task (sort keys %map){
			my $mapped_tile=$map{$mapped_task};
			#print "$mapped_tile=\$map{$mapped_task};\n";
			#$self->object_add_attribute('MAP_TILE',"$mapped_task", $mapped_tile) if(defined $mapped_tile);
			 	
			$self->object_add_attribute('MAP_TASK',"$mapped_tile",$mapped_task) if(defined $mapped_tile);
			my @l=($mapped_task);
			$self->object_add_attribute("mapping","$mapped_tile",\@l) if(defined $mapped_tile); 
			#print "$self->object_add_attribute(\"mapping\",\"$mapped_tile\",$mapped_task);\n"; 
	}
	set_gui_status($self,"ref",1);
		
}	





sub get_task_assigned_to_tile {
	my ($self,$i)=@_;
	#my $p= $self->object_get_attribute("MAP_TASK","tile($i)");
	my $r=$self->object_get_attribute("mapping","tile($i)");
	return undef if(!defined $r);
	my @l=@{$r}; 
	return $l[0]; 	
}



sub get_assigned_tiles{
	my $self=shift;
	my @assigned_tiles;
	my @tiles=get_tiles_name($self);
	foreach my $p (@tiles){
		my @l=@{$self->object_get_attribute("mapping","$p")}; 
		push(@assigned_tiles,$p)if(defined $l[0] );		
	}	
	#my @assigned_tiles = sort keys %{$self->{'MAP_TASK'}};
	return @assigned_tiles;		
}

sub map_task {
	my ($self,$task,$tile)=@_;
	#my $oldtile= $self->{"MAP_TILE"}{$task};
	my $oldtile=get_task_give_tile($self,$task);
	if($tile eq "-"){		
	 	#delete $self->{"MAP_TILE"}{$task};	 	
	}else{
		#$self->{"MAP_TILE"}{$task}= $tile;
		$self->{'MAP_TASK'}{$tile}= $task;
		my @l=($task);
		$self->object_add_attribute("mapping","$tile",\@l); 
	}	
	delete $self->{"MAP_TASK"}{$oldtile} if(defined $oldtile);	
	$self->object_add_attribute("mapping",$oldtile,undef) if(defined $oldtile);	
}

sub remove_selected_traces{
	my ($self,$category)=@_;
	my @traces= get_trace_list($self,$category);
	foreach my $p (@traces) {	
		my $select=$self->object_get_attribute("${category}_$p",'selected', 0); 
		
		if($select){
			$self->remove_trace($category,"$p");
			
		}
	}
	set_gui_status($self,"ref",1);
}



sub auto_generate_injtratio{
	my ($self,$category)=@_;
	my %com_tasks= $self->get_communication_task($category);
	my @traces= get_trace_list($self,'raw');
	foreach my $p (@traces) {	
		my ($src,$dst, $Mbytes, $file_id, $file_name)=get_trace($self,$category,$p);
		my $max= $com_tasks{$file_id}{'maxsent'};
		my $sent= $com_tasks{$src}{'sent'};
		my $ratio = ($sent*100)/$max;
		$self->object_add_attribute("raw_$p",'injct_rate',$ratio);
		
		my $minpck = $self->object_get_attribute("raw_$p",'min_pck_size');
		my $maxpck = $self->object_get_attribute("raw_$p",'max_pck_size' );
		my $avg_pck_size =($minpck+ $maxpck)/2;
		my $pck_num = ($Mbytes*8) /($avg_pck_size*64);
		
				
		my $burst =$pck_num/ $com_tasks{$src}{'min_pck_num'} ;
		$self->object_add_attribute("raw_$p",'burst_size',ceil($burst));
		
		#my $burst_size	= gen_spin_object ($self,"raw_$p",'burst_size',"1,1024,1", 1,undef,undef);
		
		
		
	}
	set_gui_status($self,"ref",1);
	
	
}


sub trace_merger{
	my ($self,$tview,$mode)=@_;	
	my $table= def_table(2,10,FALSE);
	my $row=0;
	my $col=0;
	
	my $m= ($mode eq 'task')? "Task" :"Actor";
	
	
	my $label = Gtk2::Label->new;
    $label->set_markup ("<u>Group ${m}s</u>      ");	
	$table->attach ($label,$col, $col+5,  $row, $row+1,'shrink','shrink',2,2);$col+=5;	
	my ($Ebox,$entry)=def_h_labeled_entry ("New group name:",undef);
	$table->attach ($Ebox,$col, $col+4,  $row, $row+1,'shrink','shrink',2,2);$col+=5;
	my $add=def_image_button('icons/plus.png');
	$table->attach ($add,$col, $col+1,  $row, $row+1,'shrink','shrink',2,2);$col+=1;
	
	$row++;
	$col=0;
	
	#my @info =  (
  	#{ label=>'Number of Group', param_name=>'GROUP_NUM', type=>"Spin-button", default_val=>1, content=>"1,1000,1", info=>"Several  ${m}s can be grouped and mapped on the same tile. Define the number of groups which ${m} can be categorized to.", param_parent=>'noc_param', ref_delay=>1,placement=>'vertical'}
	#);
	
	#foreach my $d (@info) {
	#	($row,$col)=add_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay},'ref',$d->{placement});
	#}
	
	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	return $sc_win;	
}




sub select_trace_file {
	my ($self,$tview,$mode)=@_;
	my $traces=trace_pad($self,$tview,$mode);
	my $traces_ctrl=trace_pad_ctrl($self,$tview,$mode);
	my $h=gen_hpaned($traces_ctrl,.20,$traces);
	return $h;
}


sub trace_maker_notebook{
	my ($self,$mode,$tview)=@_;		
	my $notebook = Gtk2::Notebook->new;
	my $lb= ($mode eq 'orcc')?  'Actor' : 'Trace';
	my $group_num=16;
	
	
	$notebook->set_tab_pos ('left');
	$notebook->set_scrollable(TRUE);
	$notebook->can_focus(FALSE);
	my $page1=select_trace_file($self,$tview,$mode);
	$notebook->append_page ($page1,Gtk2::Label->new  ("1-Select $mode file"));
	
	my ($NE, $NR, $RAw, $EAw, $Fw)=get_topology_info($self);
	
	#group tasks
	$self->object_add_attribute('grouping','group_name_root','group');	
	$self->object_add_attribute('grouping','group_name_editble','YES');	
	$self->object_add_attribute('grouping','trace_icon','icons/cd.png');
	$self->object_add_attribute('grouping','group_num',$NE);
	$self->object_add_attribute('grouping','map_limit',1024);
	$self->object_add_attribute('grouping','lable',"${lb}s: Drag and drop ${lb}s to bottom group list");	
	my $group_ctrl =gen_group_ctrl_box($self,$tview,$mode);
		
	my @tasks=get_all_tasks($self,'raw');
	my $page2=drag_and_drop_page($self,$tview,'grouping',\@tasks,$group_ctrl);
	$notebook->append_page ($page2,Gtk2::Label->new  ("2-Group ${lb}s   "));
	
	#map tasks	
	$self->object_add_attribute('mapping','group_name_root','tile');	
	$self->object_add_attribute('mapping','group_name_editble','NO');
	$self->object_add_attribute('mapping','trace_icon','icons/cd2.png');	
	$self->object_add_attribute('mapping','lable',"${lb}s: Drag and drop ${lb}s/grouped ${lb}s to bottom tile list");
	$self->object_add_attribute('mapping','map_limit',1);
	$self->object_add_attribute('mapping','group_num',$NE);
	
	#get list of non-empty groups	
	my @merged_tasks=get_all_merged_tasks($self);
	my $map_ctrl =gen_mapping_ctrl_box($self,$tview,$mode);
	
	# check task names to be uniq 
	my @r= return_not_unique_names_in_array(@merged_tasks);
    foreach my $p (@r){
    	add_colored_info($tview,"$lb name $p is not unique!\n",'red');
    }
	
	
	my $page3=drag_and_drop_page($self,$tview,'mapping',\@merged_tasks,$map_ctrl);
	$notebook->append_page ($page3,Gtk2::Label->new  ("3-Map ${lb}s"));
	
	
	
	
	#my $page4=routing_page($self,$tview);
	#$notebook->append_page ($page4,Gtk2::Label->new  ("Route Selection"));
	
	
	
	$notebook->show_all;
		
	my $first=1;
	my $page_num=$self->object_get_attribute ("process_notebook","currentpage");		
	$notebook->set_current_page ($page_num) if(defined $page_num);
	$notebook->signal_connect( 'switch-page'=> sub{			
		$self->object_add_attribute ("process_notebook","currentpage",$_[2]);	#save the new pagenumber
	});	
	$notebook->signal_connect("switch-page" => sub{ 		
		if(!$first){
			
			set_gui_status($self,"ref",1);
		}else {
			set_gui_status($self,"ref",1);
		}
		$first=0;		
	});
	
	return $notebook;
	
}

sub get_all_merged_tasks {
	my($self)=@_;
	my @merged;
	my $group_num=$self->object_get_attribute('mapping','group_num');	
	$group_num = 0 if(!defined $group_num);
	for(my $i=0;$i<$group_num;$i=$i+1){
		my $gref = $self->object_get_attribute('grouping',"group($i)");
		next if(! defined $gref);
		next if (scalar @{$gref} == 0);
		
		my $lable =  $self->object_get_attribute('grouping',"group($i)"."_name");
		$lable = "group($i)" if(!defined $lable);		
		push (@merged,"$lable");
	}
	my $uref= $self->object_get_attribute('grouping','ungrouped');	
	push (@merged, @{$uref}) if(defined  $uref);	
	return @merged;
}



sub gen_mapping_ctrl_box{
	my ($self,$tview,$mode)=@_;
	my $map_ctrl= trace_map_ctrl($self,$tview,$mode);
	my $map_info=map_info($self);
	my $v_paned=gen_vpaned($map_ctrl,.5,$map_info);
	return $v_paned; 
}

sub gen_group_ctrl_box{
	my ($self,$tview,$mode)=@_;
	my $group_ctrl= trace_group_ctrl($self,$tview,$mode);
	#my $map_info=map_info($self);
	#my $v_paned=gen_vpaned($map_ctrl,.5,$map_info);
	#return $v_paned; 
	
	my $group_info = group_info ($self,$tview,$mode);
	my $v_paned=gen_vpaned($group_ctrl,.3,$group_info);
	return $v_paned; 
	
	#return $group_ctrl;
}





sub build_trace_gui {
	my ($self,$mode,$ref,$w) = @_;
	set_gui_status($self,"ideal",0);
	$self->object_add_attribute ("process_notebook","currentpage",0);
	if($mode eq 'task'){
		$self->object_add_attribute('noc_param','T1',2);
		$self->object_add_attribute('noc_param','T2',2);
		$self->object_add_attribute('noc_param','T3',1);
		$self->object_add_attribute('noc_param','Fpay',32);
		$self->object_add_attribute('noc_param','V',1);	
		$self->object_add_attribute('noc_param','C',1);		
		$self->object_add_attribute('noc_param','TOPOLOGY','"MESH"');		
	}
	
	$self->object_add_attribute("file_id",undef,'a');
	$self->object_add_attribute("trace_id",undef,0);
	$self->object_add_attribute('select_multiple','action',"_");
	$self->object_add_attribute('Auto','Auto_inject',"1\'b1");
	if(defined $ref){
	   # add noc parameters
		my %params=%{$ref};
		foreach my $p (sort keys %params){
			$self->{$p}=$params{$p};
			 
		}
		
	}
	
	
	my ($scwin_info,$tview)= create_txview();	
	my $notebook = trace_maker_notebook($self,$mode,$tview);	
	my $v2=gen_vpaned($notebook,.65,$scwin_info);
	
	
	
	
	
	
	
	
	set_gui_status($self,"ideal",0);

	my $main_table= def_table(2,10,FALSE);
	
	
#	my $traces=trace_pad($self,$tview,$mode);
#	my $traces_ctrl=trace_pad_ctrl($self,$tview,$mode);
#	my $traces_mrg=trace_merger($self,$tview,$mode);
	#
	#my $map= trace_map($self,$tview,$mode);
	#my $map_ctrl= trace_map_ctrl($self,$tview,$mode);
	#my $map_info=map_info($self);
	
	#my $h1=gen_hpaned($traces_ctrl,.20,$traces);
	#my $h4=gen_hpaned($h1,.55,$traces_mrg);
	
	#my $h2=gen_hpaned($map_ctrl,.20,$map);
	#my $h3=gen_hpaned($h2,.55,$map_info);

	#my $v1=gen_vpaned($h4,.3,$h3);
	#my $v2=gen_vpaned($v1,.6,$scwin_info);
	
	my $generate = def_image_button('icons/gen.png','Generate');
	my $open = def_image_button('icons/browse.png','Load');	
	my ($entrybox,$entry) = def_h_labeled_entry('Save as:',undef);
	$entry->signal_connect( 'changed'=> sub{
		my $name=$entry->get_text();
		$self->object_add_attribute ("save_as",undef,$name);	
	});	
	
	my $entry2=gen_entry_object($self,'out_name',undef,undef,undef,undef);
	my $entrybox2=gen_label_info(" Output file name:",$entry2);
	
	my $save = def_image_button('icons/save.png','Save');
	$entrybox->pack_end($save,   FALSE, FALSE,0);

	$main_table->attach_defaults ($v2  , 0, 12, 0,24);
	$main_table->attach ($open,0, 3, 24,25,'expand','shrink',2,2);
	$main_table->attach ($entrybox,3, 5, 24,25,'expand','shrink',2,2);
	$main_table->attach ($entrybox2,5,6 , 24,25,'expand','shrink',2,2) if ($mode eq 'task');
	$main_table->attach ($generate, 6, 9, 24,25,'expand','shrink',2,2);
	

	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($main_table);
	
	
	
	$open-> signal_connect("clicked" => sub{ 
		
		load_workspace($self);
		set_gui_status($self,"ref",5);
	
	});	

	$save-> signal_connect("clicked" => sub{ 
		save_as($self);		
		set_gui_status($self,"ref",5);
		
	
	});	
	
	$generate->signal_connect("clicked" => sub{ 
		genereate_output_tasks($self) if ($mode eq 'task');
		genereate_output_orcc ($self,$tview,$w) if ($mode eq 'orcc');
	
	});	
	
	
	
	
	
	
	#check soc status every 0.5 second. refresh device table if there is any changes 
	Glib::Timeout->add (100, sub{ 
	   
		my ($state,$timeout)= get_gui_status($self);
		
		if ($timeout>0){
			$timeout--;
			set_gui_status($self,$state,$timeout);	
			return TRUE;
			
		}
		if($state eq "ideal"){
			return TRUE;
			 
		}
		
		
		
		#refresh GUI
		my $saved_name=$self->object_get_attribute('save_as');
		if(defined $saved_name) {$entry->set_text($saved_name);}
		
		$saved_name=$self->object_get_attribute('out_name');
		if(defined $saved_name) {$entry2->set_text($saved_name);}
		
		
		$notebook->destroy;
		$notebook = trace_maker_notebook($self,$mode,$tview);
		$v2 -> pack1($notebook, TRUE, TRUE); 							
		
		set_gui_status($self,"ideal",0);
		
		return TRUE;
		
	} );	

	return $sc_win;
	
}


	
