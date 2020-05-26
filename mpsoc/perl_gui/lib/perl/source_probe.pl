#!/usr/bin/perl -w
use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Gtk2 '-init';
use Gtk2::SourceView2;
use Data::Dumper;
use File::Which;
use File::Basename;

use IPC::Run qw( harness start pump finish timeout );


require "widget.pl";
require "uart.pl";

use FindBin;
use lib $FindBin::Bin;
use String::Scanf; # imports sscanf()


use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw{
	window
	sourceview		
});

my $NAME = 'Soure Probe';
my 	$path = "";
sub source_probe_stand_alone(){
	$path = "../../";
	set_path_env();
	Gtk2->init;
	my $window=source_probe_main();
	$window->signal_connect (delete_event => sub { Gtk2->main_quit });
	Gtk2->main();
}

exit source_probe_stand_alone() unless caller;




sub source_probe_ctrl {
	my ($self,$main_tview)=@_;
	my $table= def_table(2,10,FALSE);
	my @info = (
	{ label=>" FPGA Vendor name: ", param_name=>'VENDOR', type=>"Combo-box", default_val=>'XILINX', content=>"XILINX,ALTERA", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_ctrl', loc=>'vertical'},
	{ label=>" JTAG Index: ", param_name=>'JTAG_INDEX', type=>"Spin-button", default_val=>126, content=>"0,128,1", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_ctrl', loc=>'vertical'},
	{ label=>" Number of Sources/Probes:", param_name=>'SP_NUM', type=>"Spin-button", default_val=>1, content=>"1,128,1", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_all', loc=>'vertical'}		
	);	
	
	
	my $vendor= $self->object_get_attribute('CTRL','VENDOR');
	$vendor= 'XILINX' if(!defined $vendor);
	
	
	if ($vendor eq "XILINX" ) {
		push (@info,{ label=>" JTAG CHAIN ", param_name=>'JTAG_CHAIN', type=>"Combo-box", default_val=>3, content=>"1,2,3,4", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_ctrl', loc=>'vertical'}) ;
		push (@info,{ label=>" JTAG TARGET ", param_name=>'JTAG_TARGET', type=>"Spin-button", default_val=>3, content=>"1,128,1", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_ctrl', loc=>'vertical'}) ;
	}elsif ($vendor eq "ALTERA" ) {
		my $list= $self->object_get_attribute('CTRL','quartus_device_list');
		push (@info,{ label=>" Hardware Name", param_name=>'quartus_hardware', type=>"Entry", default_val=>undef, content=>undef, info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>undef, loc=>'vertical'}) ;
		push (@info,{ label=>" Device Number",   param_name=>'quartus_device',   type=>"EntryCombo", default_val=>undef,  content=>$list, info=>undef,param_parent=>'CTRL', ref_delay=> 1, new_status=>undef, loc=>'vertical'}) ;
	}
	
	
	
	
	my ($row,$col)=(0,0);
	
	foreach my $d (@info) {
		my $wiget;		
		($row,$col,$wiget)=add_param_widget  ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status}, $d->{loc});
		if($d->{param_name} eq 'JTAG_TARGET' || $d->{param_name} eq "quartus_hardware"){
			my $search=def_image_button($path."icons/browse.png");
			$table->attach ($search,  4, 5,$row-1,$row,'shrink','shrink',2,2); 
			set_tip($search, "Display all Jtag targets. You need to connect your FPGA device to your PC first."); 
			$search-> signal_connect("clicked" => sub{
				show_all_xilinx_targets ($self,$main_tview) if ($vendor eq "XILINX" );
				capture_altera_jtag_info($self,$main_tview) if ($vendor eq "ALTERA" );
			}); 			
			
		}
	
	
	}	
	return $table;		
}



sub soure_probe_widgets {
	my $self=shift;
	my $table= def_table(2,10,FALSE);	
	my $scrolled_win=gen_scr_win_with_adjst ($self,"recive_box");
	$scrolled_win->add_with_viewport($table);
	my $num = $self->object_get_attribute('CTRL','SP_NUM');
	
	my $y= 0;
   	my $x= 0; 	
	
	$table->attach (gen_label_in_center(" Source "), 0, 3 , $y, $y+1,'shrink','shrink',2,2); 
	$table->attach (gen_label_in_center(" Probe  "), 4, 7 , $y, $y+1,'shrink','shrink',2,2); 
	$y++;
	$table->attach ( Gtk2::HSeparator->new, 0, 7 , $y, $y+1, 'fill','shrink',2,2); 
	
	$y++;
	my @sources;
	for (my $i=0; $i<$num; $i+=1){	
			my $n=$i+1;
			$table->attach (gen_label_in_left("  $n- "), $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++;
			my $entry=gen_entry( );
			$table->attach ($entry, $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++;			
  			
    		my $enter=def_image_button($path."icons/write.png","Write");   		

	        $table->attach ($enter, $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++;
	       
	       $x++; #sep
	       
	        #probe 
	        #$table->attach (gen_label_in_left(" Probe:  " )	, $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++; 
	        my $probe_val = $self-> object_get_attribute('SP','PROBE_$n');
	      
	        my $probe_label= gen_label_in_left(" "); 
	        
	        ${probe_val}=25 if ($n ==1);
	        
	        $probe_label->set_markup("<span  foreground= 'red' ><b>XXXX</b></span>") if(!defined $probe_val );	
	        $probe_label->set_markup("<span  foreground= 'blue' ><b></b>    ${probe_val}   </span>") unless(!defined $probe_val );	
	        
	        my $frame = Gtk2::Frame->new;
			$frame->set_shadow_type ('in');
			# Animation
			$frame->add ($probe_label);
	        
	        
	        $table->attach ($frame, $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++; 
	        my $read=def_image_button($path."icons/simulator.png","Read"); 
	        $table->attach ($read, $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++;
	        
	        $y++; $x=0; 
	        $table->attach ( Gtk2::HSeparator->new, 0, 7 , $y, $y+1, 'fill','shrink',2,2); 
	        $y++;
	        
	}	
	
	  $table->attach ( Gtk2::VSeparator->new, 3, 4 , 0, $y+1,'fill','fill',2,2);
	  $table->attach ( Gtk2::VSeparator->new, 6, 7 , 0, $y+1,'fill','fill',2,2);
	
	return ($scrolled_win,\@sources);
}


############
#	main
############



sub source_probe_main {
	my $self = __PACKAGE__->new(); 
	set_gui_status($self,"ideal",0);
	my $window = def_popwin_size (60,85,'Source Probe','percent');
	my ($sw,$tview) =create_text();# a textveiw for showing the info, erro messages etc
	my $ctrl = source_probe_ctrl($self,$tview);
	my ($sp,$sref)= soure_probe_widgets ($self);
	
		
	my $v1 = gen_vpaned ($ctrl,0.3,$sw);
	my $h1 = gen_hpaned ($sp,0.35,$v1);
	
		
	
	
	#check soc status every ? second. referesh device table if there is any changes 
    Glib::Timeout->add (100, sub{ 
        my ($state,$timeout)= get_gui_status($self);
        
        if ($timeout>0){
            $timeout--;
            set_gui_status($self,$state,$timeout);           
        }
        elsif( $state ne "ideal" ){        	
            if($state eq 'ref_all') {
            	$sp->destroy();
            	($sp,$sref)= soure_probe_widgets ($self);
            	$h1-> pack1($sp, TRUE, TRUE);
            }	  
            
            $ctrl->destroy();
            $ctrl = source_probe_ctrl($self,$tview);
            $v1-> pack1($ctrl, TRUE, TRUE);
            $v1-> show_all(); 
            $h1-> show_all();  
            set_gui_status($self,"ideal",0);         
               
            
       }
             
    	return TRUE;
        
    } );
	
	
	
	$window->add($h1);
	$window->show_all();
	return $window;	
}	



