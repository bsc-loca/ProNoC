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

my %memory;
my %status;


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
	{ label=>" JTAG Index: ", param_name=>'JTAG_INDEX', type=>"Spin-button", default_val=>126, content=>"0,128,1", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_ctrl', loc=>'vertical'}	
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
	
	$col=0; 
	$table->attach ( Gtk2::HSeparator->new, 0, 10 , $row, $row+1, 'fill','shrink',2,2); 
	$row++;
	
	my $d={ label=>" Number of Sources/Probes:", param_name=>'SP_NUM', type=>"Spin-button", default_val=>1, content=>"1,128,1", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_all', loc=>'vertical'};		
	($row,$col)=add_param_widget  ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status}, $d->{loc});
	
	
	
	my $scrolled_win=gen_scr_win_with_adjst ($self,"recive_box");
	$scrolled_win->add_with_viewport($table);
	return $scrolled_win;		
}




sub file_bin_ctrl {
	my ($self,$main_tview)=@_;
	my $table= def_table(2,10,FALSE);
	my @info = (
	{ label=>" Input bin file: ", param_name=>'IN_FILE', type=>"FILE_path", default_val=>undef, content=>'bin', info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'load_in_file', loc=>'vertical'},
	{ label=>" Offset address: ", param_name=>'IN_FILE_OFFSET', type=>"Spin-button", default_val=>0, content=>'0,9999999999,1', info=>'The Wishbone bus offset address where the beginning of the memory bin file is written there (It can be the base address of the peripheral device where the memory file is intended to be written to.)   ', param_parent=>'CTRL', ref_delay=> 1, new_status=>'load_in_file', loc=>'vertical'},
	);	
	
	
	
	
	
	my ($row,$col)=(0,0);
	
	foreach my $d (@info) {
		my $wiget;		
		($row,$col,$wiget)=add_param_widget  ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status}, $d->{loc});
		
	
	
	}	
	
	$col=0; 
	$table->attach ( Gtk2::HSeparator->new, 0, 10 , $row, $row+1, 'fill','shrink',2,2); 
	$row++;
	
	
	
	
	my $scrolled_win=gen_scr_win_with_adjst ($self,"recive_box");
	$scrolled_win->add_with_viewport($table);
	return $scrolled_win;		
}





sub soure_probe_widgets_old {
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



sub soure_probe_widgets {
	my $self=shift;
	my $table= def_table(2,10,FALSE);	
	my $scrolled_win=gen_scr_win_with_adjst ($self,"recive_box");
	$scrolled_win->add_with_viewport($table);
	my $num = $self->object_get_attribute('CTRL','SP_NUM');
	
	my $y= 0;
   	my $x= 0; 	
	
	$table->attach (gen_label_in_center(" Address "), 0, 3 , $y, $y+1,'shrink','shrink',2,2); 
	$table->attach (gen_label_in_center(" Content  "), 4, 7 , $y, $y+1,'shrink','shrink',2,2); 
	$table->attach (gen_label_in_center(" Action  "), 8, 10 , $y, $y+1,'shrink','shrink',2,2); 
	$y++;
	$table->attach ( Gtk2::HSeparator->new, 0, 10 , $y, $y+1, 'fill','shrink',2,2); 
	
	$y++;
	$x= 0; 	
	
	for (my $i=0; $i<$num; $i+=1){	
			my $n=$i+1;
			#$table->attach (gen_label_in_left("  $n-address "), $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++;
			my ($addr,$entry);
			($y,$x,$addr)=add_param_widget  ($self,"$n-", "$n-address", 0, "Spin-button", "0,99999999,1", undef, $table,$y,$x,1, "JTAG_WB", undef, undef, 'horizental');
		    ($y,$x,$entry)=add_param_widget  ($self,undef, "$n-value", 0, "Entry", undef, undef, $table,$y,$x,1, "JTAG_WB", undef, undef, 'horizental');
		    
		    $entry->set_max_length (8);
			$entry->set_width_chars(8);
		    
		    my $read=def_image_button($path."icons/simulator.png","Read"); 
	        $table->attach ($read, $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++; 	
		    my $write=def_image_button($path."icons/write.png","Write");   
			$table->attach ($write, $x, $x+1 , $y, $y+1,'shrink','shrink',2,2); $x++;
			        
	        $y++; $x=0; 
	        $table->attach ( Gtk2::HSeparator->new, 0, 10 , $y, $y+1, 'fill','shrink',2,2); 
	        $y++;
	        
	        $read-> signal_connect("clicked" => sub{
	        	
	        });
	        
	        $write-> signal_connect("clicked" => sub{
	        	
	        });
	        
	        
	}	
	
	$table->attach ( Gtk2::VSeparator->new, 3, 4 , 0, $y+1,'fill','fill',2,2);
	$table->attach ( Gtk2::VSeparator->new, 6, 7 , 0, $y+1,'fill','fill',2,2);
		
	return $scrolled_win;
}

sub get_file_b_setting{
	my($self)=@_;
	my $window = def_popwin_size (30,30,'Source Probe','percent');
    my $table= def_table(2,10,FALSE);	
    my @info = (
	{ label=>" Address format: ", param_name=>'R_ADDR_FORMAT', type=>"Combo-box", default_val=>'Decimal', content=>"Decimal,Hexadecimal", info=>undef, param_parent=>'FILE_VIEW', ref_delay=> 1, new_status=>'ref_file_view', loc=>'vertical'},
	{ label=>" Page row number: ", param_name=>'PAGE_MAX_X', type=>"Spin-button", default_val=>10, content=>"0,128,1", info=>undef, param_parent=>'FILE_VIEW', ref_delay=> 1, new_status=>'ref_file_view', loc=>'vertical'},
	{ label=>" Page column number:", param_name=>'PAGE_MAX_Y', type=>"Spin-button", default_val=>10, content=>"1,128,1", info=>undef, param_parent=>'FILE_VIEW', ref_delay=> 1, new_status=>'ref_file_view', loc=>'vertical'}
	);	
	my $row=0;
	my $col=0;
	foreach my $d (@info) {
		($row,$col)=add_param_widget  ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status}, $d->{loc});
	}
	$table->attach (gen_label_in_center(' '), 2, 3,$row,$row+1,'shrink','shrink',2,2); $row++; 
	$table->attach (gen_label_in_center(' '), 2, 3,$row,$row+1,'shrink','shrink',2,2); $row++; 
	$table->attach (gen_label_in_center(' '), 2, 3,$row,$row+1,'shrink','shrink',2,2); $row++; 
	
	
	my $ok=def_image_button($path."icons/select.png",'OK');
	$table->attach ($ok, 2, 3,$row,$row+1,'shrink','shrink',2,2); 
	$ok-> signal_connect("clicked" => sub{
		$window->destroy(); 
	});
	
	$window->add(add_widget_to_scrolled_win($table));	
	$window->show_all;

}

sub fill_memory_array_from_file{
	my  ($self,$fname,$tview)=@_;
	
	my $offset = $self->object_get_attribute('FILE_VIEW','IN_FILE_OFFSET');
	my $BLOCK_SIZE =4;
	
	open(F,"<$fname") or die("Unable to open file $fname, $!");
	binmode(F);
	my $buf;
	my $ct=$offset;

	my $start = $offset;
	while(read(F,$buf,$BLOCK_SIZE)){
		my $v='';
		foreach(split(//, $buf)){
			$v.=sprintf("%02x",ord($_));			
		}
		$memory{$ct}= $v;
	    $status{$ct}=2;
		$ct++;
	}
	close(F);
	
	add_info($tview,"Load $fname\n"); 
	add_info($tview,"address $offset to $ct\n"); 
}

sub get_file_in_name{
	my ($self,$tview)=@_;
	
	my $file;
	my $title ='select bin file';
	my $dialog = Gtk2::FileChooserDialog->new(
           	'Select a File', undef,
           	'open',
           	'gtk-cancel' => 'cancel',
           	'gtk-ok'     => 'ok',
    );
	
	if ( "ok" eq $dialog->run ) {
	    	$file = $dialog->get_filename;
			$dialog->destroy;
			$self->object_add_attribute('FILE_VIEW','IN_FILE',$file);
				
			#get offsset address;
			my $window = def_popwin_size (30,20,'Get Offset Address','percent');
			my $table= def_table(2,10,FALSE);	
			my $d=
			{ label=>" Offset address: ", param_name=>'IN_FILE_OFFSET', type=>"Spin-button", default_val=>0, content=>'0,9999999999,1', info=>'The Wishbone bus offset address where the beginning of the memory bin file is written there (It can be the base address of the peripheral device where the memory file is intended to be written to.)   ', param_parent=>'FILE_VIEW', ref_delay=> undef, new_status=>undef, loc=>'vertical'};
			my $row=0;
			my $col=0;
			($row,$col)=add_param_widget  ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status}, $d->{loc});
			my $ok=def_image_button($path."icons/select.png",'OK');
			$table->attach ($ok, 2, 3,$row,$row+1,'shrink','shrink',2,2); 
			$ok-> signal_connect("clicked" => sub{
				fill_memory_array_from_file ($self,$file,$tview);
				set_gui_status($self,'ref_file_view',1);
				$window->destroy(); 
			});
			$window->add(add_widget_to_scrolled_win($table));	
			$window->show_all;
			
			
	} 
	
	
	
}	



sub read_write_bin_file {
	my ($self,$tview)=@_;
	my $table= def_table(2,10,FALSE);	
	my $scrolled_win=gen_scr_win_with_adjst ($self,"recive_box");
	$scrolled_win->add_with_viewport($table);
	my @data;
	
	
	my $MAX_X=$self->	object_get_attribute('FILE_VIEW','PAGE_MAX_X');
	$MAX_X=10 if (!defined $MAX_X);
	my $MAX_Y=$self->	object_get_attribute('FILE_VIEW','PAGE_MAX_Y');
	$MAX_Y=10 if (!defined $MAX_Y);
	my $format =$self->	object_get_attribute('FILE_VIEW','R_ADDR_FORMAT');
	$format= 'Decimal' if (!defined $format);
	
	
	my $OFFSET=0;
	
	my $table1= def_table(2,10,FALSE);
	add_param_widget  ($self,"Page_num", 'FILE_VIEW',  0, "Spin-button", "0,999999,1", undef, $table1,$MAX_X+1,$MAX_Y/2, 1, "R_PAGE_NUM",1,'ref_file_view');
	
	my $page_num =$self->object_get_attribute("R_PAGE_NUM",'FILE_VIEW'); 
	#$page_num= 0 if(!defined $page_num);

	
	
	my $base_addr=$page_num*$MAX_X*$MAX_Y+$OFFSET;	
	my $setting=def_image_button("icons/setting.png","setting");
	my $load=def_image_button("icons/download.png","Load File");
	my $read=def_image_button($path."icons/simulator.png","Read Memory");		
	my $write=def_image_button($path."icons/write.png","Write Memory");   
	my $clear=def_image_button($path."icons/clear.png");  
	my $x=0;
	
	
	$table->attach ($setting, $x, $x+1, 0, 1,'fill','fill',2,2);$x++; 
	$table->attach ($load, $x, $x+1 , 0, 1,'fill','fill',2,2);$x++; 
	$table->attach ($read, $x, $x+1 , 0, 1,'shrink','shrink',2,2); $x++; 
	$table->attach ($write, $x, $x+1 , 0, 1,'shrink','shrink',2,2); $x++;
	$table->attach ($clear, $x, $x+1 , 0, 1,'shrink','shrink',2,2); $x++;
	
	$setting-> signal_connect("clicked" => sub{
				get_file_b_setting($self);
	}); 	
	
	$load-> signal_connect("clicked" => sub{
				get_file_in_name($self,$tview);
	}); 	
	
	$clear-> signal_connect("clicked" => sub{
		undef %memory;
		undef %status;
		set_gui_status($self,'ref_file_view',1);
	}); 	
	
	
	#column address labels
	for (my $y=1; $y<=$MAX_Y; $y++){
		my $addr =($format eq 'Hexadecimal')? sprintf("%x", $y-1) : $y-1;
		my $l=gen_label_in_center (" $addr ");
		$table1->attach ( $l, $y, $y+1 , 0, 1,'fill','fill',2,2);
	}	
	
	
	#row address lables
	for (my $x=1; $x<=$MAX_X; $x++){
		my $addr=$base_addr+($x-1) * $MAX_Y;
		
		$addr = ($format eq 'Hexadecimal')? sprintf("%x",$addr)   : $addr;
		
		
		my $l=gen_label_in_left (" $addr ");
		$table1->attach ( $l, 0, 1 , $x, $x+1,'fill','fill',2,2);
	}	
	
	#entries	
	for (my $x=1; $x<=$MAX_X; $x++){
		for (my $y=1; $y<=$MAX_Y; $y++){
			
			
			my $state=0;# not modified
			
			my $addr =$base_addr+ (($x-1) * $MAX_Y ) + $y-1;
			my $addr_tip=($format eq 'Hexadecimal')? sprintf("0x%x",$addr)   : $addr;
			
			my $v= $memory{$addr};
			my $s = $status{$addr};
			
			$v= "xxxxxxxx" if (!defined $v);
			$s = 0 if (!defined $s); #0 dontcare
			
			
			
			
			my $entry =gen_entry($v );
			$entry->set_max_length (8);
			$entry->set_width_chars(8);
			set_tip($entry,"$addr_tip");
			$table1->attach ( $entry, $y, $y+1 , $x, $x+1,'fill','fill',2,2);
			
			if($s==2 ){
				#change color to red
				my ($red,$green,$blue) = get_color(11);
		   		my $color = Gtk2::Gdk::Color->new ($red,$green,$blue);
				$entry->modify_text('normal' , $color); 
			}
			
			$entry->signal_connect("changed" => sub{
				if($s==0 || $s==1 ){
					$status{$addr} =2;#modified
					#change color to red
					my ($red,$green,$blue) = get_color(11);
		   			my $color = Gtk2::Gdk::Color->new ($red,$green,$blue);
					$entry->modify_text('normal' , $color); 
					
				}
				my $in = $entry->get_text();
				$memory{$addr}=$in;
				$entry->set_text(remove_not_hex($in));
				
			});	
		
		}
	}
 		  
  		  
     
	
	$table->attach ( $table1, 0, 20 , 1, 10,'fill','fill',2,2);
	
	$scrolled_win->show_all;
	return $scrolled_win;
	
}



############
#	main
############



sub source_probe_main {
	my $self = __PACKAGE__->new(); 
	
	
	
	set_gui_status($self,"ideal",0);
	my $window = def_popwin_size (85,85,'Source Probe','percent');
	my ($sw,$tview) =create_text();# a textveiw for showing the info, erro messages etc
	my $ctrl = source_probe_ctrl($self,$tview);
	my $sp= soure_probe_widgets ($self);
	my $bin_f = read_write_bin_file($self,$tview);
	#my $bin_ctrl = file_bin_ctrl($self,$tview);
	
	
	my $h1 = gen_hpaned ($sp,0.55,$ctrl);
	#my $h2 = gen_hpaned ($bin_f,0.55,$bin_ctrl);
	my $v1 = gen_vpaned ($h1,0.2,$bin_f);
	my $v2 = gen_vpaned ($v1,0.65,$sw);
	
	
	
	
		
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
            	$sp= soure_probe_widgets ($self);
            	$bin_f->destroy(); 
            	$bin_f = read_write_bin_file($self,$tview);
            	$h1-> pack1($sp, TRUE, TRUE);
            	$v1-> pack2($bin_f, TRUE, TRUE);
            	$v2-> show_all(); 
            }
            elsif ($state eq  'ref_file_view'){
            	$bin_f->destroy(); 
            	$bin_f = read_write_bin_file($self,$tview);
            	$v1-> pack2($bin_f, TRUE, TRUE);
            	$v2-> show_all(); 
            	
            	
            } 	  
            
            $ctrl->destroy();
            $ctrl = source_probe_ctrl($self,$tview);
            $h1-> pack2($ctrl, TRUE, TRUE);
            $v2-> show_all(); 
            set_gui_status($self,"ideal",0);         
               
            
       }
             
    	return TRUE;
        
    } );
	
	
	
	$window->add($v2);
	$window->show_all();
	return $window;	
}	



