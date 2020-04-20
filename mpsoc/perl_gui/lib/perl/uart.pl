#!/usr/bin/perl -w
use strict;
use warnings;

use Glib qw(TRUE FALSE);
use Gtk2 '-init';
use Gtk2::SourceView2;
use Data::Dumper;

use IPC::Run qw( harness start pump finish timeout );


require "widget.pl";
use FindBin;
use lib $FindBin::Bin;
use String::Scanf; # imports sscanf()


use base 'Class::Accessor::Fast';
__PACKAGE__->mk_accessors(qw{
	window
	sourceview		
});

my $NAME = 'Uart Terminal';
my 	$path = "";
sub uart_stand_alone(){
	$path = "../../";
	Gtk2->init;
	my $window=uart_main();
	$window->signal_connect (delete_event => sub { Gtk2->main_quit });
	Gtk2->main();
}

exit uart_stand_alone() unless caller;




sub create_rsv_box {
	my ($self,$num)=@_;
	my ($sw,$tview) =create_text(); 
    $sw->set_policy('never','automatic');
    $sw->set_border_width(3);
    my($width,$hight)=max_win_size();
	$sw->set_size_request($width/10,$hight/10);
    my $frame = Gtk2::Frame->new;
	$frame->set_shadow_type ('in');
	$frame->add ($sw);
	my $def = 126-$num;
	my $spin=gen_spin_object($self,'CTRL',"INDEX_$num",'0,128,1',$def,undef,undef);	
	my $lable=gen_label_in_center("INDEX#");
	my $box=def_pack_hbox( FALSE, 0 , $lable,$spin);	
	$frame->set_label_widget ($box);        
    return ($frame,$tview);	
}



sub receive_boxes{
	my $self=shift;
	my $table= def_table(2,10,FALSE);	
	my $scrolled_win=gen_scr_win_with_adjst ($self,"recive_box");
	$scrolled_win->add_with_viewport($table);
	my $num = $self->object_get_attribute('CTRL','UART_NUM');
	my $dim_y = floor(sqrt($num));
	my @tviews;
	for (my $i=0; $i<$num; $i+=1){	
			my ($box,$tview) = create_rsv_box($self,$i);
			push(@tviews,$tview);  			
  			my $y= int($i/$dim_y);
    		my $x= $i % $dim_y;    		
	        $table->attach_defaults ($box, $x, $x+1 , $y, $y+1);	
	}	
	return ($scrolled_win,\@tviews);
}

sub ctrl_boxes{
	my $self=shift;
	my $table= def_table(2,10,FALSE);	
	my $scrolled_win=add_widget_to_scrolled_win ($table);
	my ($row,$col)=(0,0);
	my @info = (
	#Altera_Qsys_UART
		{ label=>" UART name ", param_name=>'UART_NAME', type=>"Combo-box", default_val=>'ProNoC_XILINX_UART', content=>"ProNoC_XILINX_UART", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_ctrl', loc=>'vertical'},
		{ label=>" Number of UART", param_name=>'UART_NUM', type=>"Spin-button", default_val=>1, content=>"1,128,1", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_all', loc=>'vertical'},
		{ label=>" JTAG CHAIN ", param_name=>'JTAG_CHAIN', type=>"Combo-box", default_val=>3, content=>"1,2,3,4", info=>undef, param_parent=>'CTRL', ref_delay=> 1, new_status=>'ref_ctrl', loc=>'vertical'},
		
		
	);	

	foreach my $d (@info) {		
		($row,$col)=add_param_widget  ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay}, $d->{new_status}, $d->{loc});
	} 
	
	my $state=$self->object_get_attribute("CTRL","RUN");
	if (!defined $state){
		$state='OFF' ;
		$self->object_add_attribute("CTRL","RUN",$state);
	}		
	my $lable=gen_label_in_center("JTAG Connect");
	my $run= ($state eq 'ON')? def_colored_button('ON',17): def_colored_button('OFF',4); 
	$table->attach ($lable,  $col, $col+1,$row,$row+1,'shrink','shrink',2,2); $col++; 
	$table->attach ($run,  $col, $col+1,$row,$row+1,'shrink','shrink',2,2); $row++;$col=0;
	$run -> signal_connect("clicked" => sub{ 
			my $state=$self->object_get_attribute("CTRL","RUN");			
			my $new = ($state eq "ON")? "OFF" : "ON";
			$self->object_add_attribute("CTRL","CONNECT",1) if($new eq 'ON');
			$self->object_add_attribute("CTRL","DISCONNECT",1) if($new eq 'OFF');
			set_gui_status($self,"ON-OFF",1);		
	});		
	
	return $scrolled_win;
}


sub sender_box{
	my ($self,$main_tview)=@_;
	my $table= def_table(2,10,FALSE);	
	my $scrolled_win=add_widget_to_scrolled_win ($table);
	my ($sw,$tview) =create_text(); 
    $sw->set_policy('never','automatic');
    $sw->set_border_width(3);
    my($width,$hight)=max_win_size();
	$sw->set_size_request($width/10,$hight/10);
    my $frame = Gtk2::Frame->new;
	$frame->set_shadow_type ('in');
	$frame->add ($sw);
	my $num = $self->object_get_attribute('CTRL','UART_NUM');
	my @indexs;
	my $def;
	for (my $i=0; $i<$num; $i+=1){	
		my $index= $self->object_get_attribute("CTRL","INDEX_$i");	
		$def= $index if(!defined $def);
		push(@indexs,$index);
	}
	my $indexs = join(',',@indexs);
	my $comb=gen_combobox_object($self,'CTRL',"SEND_TO_INDEX",$indexs,$def,undef,undef);	
	my $lable=gen_label_in_center("SEND_TO INDEX#");
	my $send = def_image_button($path.'icons/run.png');	
	my $box=def_pack_hbox( FALSE, 0 , $lable,$comb,$send);	
	$frame->set_label_widget ($box);   		
	$table->attach_defaults ($frame, 0, 1 , 0,1);
	$send-> signal_connect("clicked" => sub{ 
			my $st =$self->object_get_attribute("CTRL","RUN");
			my $index =$self->object_get_attribute("CTRL","SEND_TO_INDEX");
			if ($st eq 'OFF'){
				add_colored_info($main_tview,"Error: Cannot send the data. Jtag connection is not stablished yet.\n",'red');
				return;
			}
			my $text_buffer = $tview->get_buffer;
	        my $txt=$text_buffer->get_text($text_buffer->get_bounds, TRUE);
			if(length ($txt) >0 ){	
				my $buf=$self->object_get_attribute("SEND","TXT_$index");
				$txt=	$buf.$txt if(length $buf);		
				$self->object_add_attribute("SEND","TXT_$index",$txt);
				set_gui_status($self,"REF_SEND",1);	   
				
			}			
	});		
	
		
	return ($scrolled_win,$tview);	
}

sub run_pipe{
	my ($self,$pipe,$in,$out,$err,$tview)=@_;
	$$out='';	
	$$in .= "puts done\n";
	pump $$pipe while (length $$in);
    until ($$out =~ /done/ || (length $$err)){
    	pump $$pipe; 
    	refresh_gui();    	
    }	 
    if(length $$err){
    	add_colored_info($tview,"XSCT got an Error: $$err\n",'red');
    	$self->object_add_attribute("CTRL","DISCONNECT",1);	
    	set_gui_status($self,"ON-OFF",0);	    	
    	return 0;    	
    }
    refresh_gui();
	return 1;	
}




sub start_xsct{
	my ($self,$pipe,$tview,$in, $out, $err)=@_;
	my $xsct="/home/alireza/xilinx/SDK/2019.1/bin/xsct";
	
	#check if $xsct exits
	unless(-f $xsct){
		add_colored_info($tview,"Error file not found: $xsct\n",'red');
		return 0;	
	}	
	my @cat = ( $xsct );
	my $r;
	
	$$pipe =start \@cat, $in, $out, $err or $r=$?;
	if(defined $r){
		add_colored_info($tview,"XSCT got an Error: $r\n",'red');
		return 0;		
	}
	
	$$in = "";
    return 0 unless run_pipe($self,$pipe,$in,$out,$err,$tview);
    $$in = "set jseq [jtag sequence]\n connect\n jtag targets 3\n puts done\n";
    return 0 unless run_pipe($self,$pipe,$in,$out,$err,$tview);
         
    return 1;
}

sub refresh_gui{
	while (Gtk2->events_pending) {
      Gtk2->main_iteration;
    }
    Gtk2::Gdk->flush;
}

sub close_xsct{
	my ($self,$pipe,$tview,$in, $out, $err)=@_;
	$$in = "exit\n";
  	pump $$pipe while (length $$in);
   	finish $$pipe;
}


sub check_jtag_connect {
	my ($self,$pipe,$tview,$in, $out, $err)=@_;
	my $run =$self->object_get_attribute("CTRL","RUN");
	my $connect = $self->object_get_attribute("CTRL","CONNECT");
	my $disconnect = $self->object_get_attribute("CTRL","DISCONNECT");
	if($connect){
       	my $r=start_xsct($self,$pipe,$tview,$in, $out, $err);
       	if($r){
       		$self->object_add_attribute("CTRL","RUN",'ON');
       		add_info($tview,"Connected!\n");
       		set_gui_status($self,"ref",1); 
       		
          		
       	}else{
       		$self->object_add_attribute("CTRL","RUN",'OFF');
       		add_info($tview,"failed to connect!\n");
      		set_gui_status($self,"ref",1); 
      		
       	}            					
		$self->object_add_attribute("CTRL","CONNECT",0);
	}if($disconnect){
		close_xsct($self,$pipe,$tview,$in, $out, $err);
		$self->object_add_attribute("CTRL","RUN",'OFF');
		$self->object_add_attribute("CTRL","DISCONNECT",0);	
		add_info($tview,"disconnected!\n");
		set_gui_status($self,"ref",1); 			
	}	
}	


use constant JTAG_UPDATE_WB_ADDR => 7;
use constant JTAG_UPDATE_WB_WR_DATA=>  6;
use constant JTAG_UPDATE_WB_RD_DATA => 5;	

# Converts pairs of hex digits to asci
sub hex_to_ascii { # $ascii ($hex)
  my $s = shift;
 
  return pack 'H*', $s;
}
	
sub run_jtag_scaner{
	my ($self,$tview,$tv_ref,$pipe,$in, $out, $err)=@_; 
	
	
	
	
	
	
	
	my $num = $self->object_get_attribute('CTRL','UART_NUM');
	my $chain= $self->object_get_attribute('CTRL','JTAG_CHAIN');
	my $chain_code=
		($chain==1)? '02':
		($chain==2)? '03':
		($chain==3)? '22':
		'23';
	
	my @tviews=@{$tv_ref};
	
	for (my $i=0; $i<$num; $i+=1){	
		my $index= $self->object_get_attribute("CTRL","INDEX_$i");	
	
		my $txt= $self->object_get_attribute("SEND","TXT_$index");
		my $send_char =0;
		my $l=length $txt;
		if ($l){
			$send_char = substr $txt, 0,1;
			$txt =  substr $txt, 1,$l;
			$self->object_add_attribute("SEND","TXT_$index",$txt );
		}
		
	
		#select index		
		#print"select index\n";
		$$in=jtag_vindex ($index,32,$chain_code);
		return  unless run_pipe($self,$pipe,$in,$out,$err,$tview);
			
		
		#select instruction
		#print"select instruction\n";
		$$in=jtag_vir (JTAG_UPDATE_WB_RD_DATA,32,$chain_code);	
		return  unless run_pipe($self,$pipe,$in,$out,$err,$tview);
				
		
		#read uart reg 0 
		#print"read reg 0\n";
		my $str=jtag_vdr   ($send_char,32,$chain_code);	
		$$in=$str;
		#print "$$in\n";
		return  unless run_pipe($self,$pipe,$in,$out,$err,$tview);
		print "$$out\n";
		my ($hex)= sscanf("R:%s:R",$$out);
		my $char= substr $hex, 0, 2;
		if($char ne '00'){	
			$char =hex_to_ascii(substr $hex, 0, 2);	
			append_to_textview($tviews[$i],$char) if(defined $tviews[$i]);
		}
	}
}




###############
#	xsct 
##############

use constant UPDATE_INDEX => "01";
use constant UPDATE_IR    => "02";
use constant UPDATE_DAT   => "04";

#USER1 000010 Access user-defined register 1.
#USER2 000011 Access user-defined register 2.
#USER3 100010 Access user-defined register 3.
#USER4 100011 Access user-defined register 4



sub jtag_reorder{
  my ( $string_in ) =@_;
  my @chars =( $string_in =~ m/../g );#split a string into chunks of two characters
  return join("", reverse @chars);  
}



sub send_to_jtag{
	my ($hex,$width,$chain) =@_;
	my $siz = $width+4;
	#print "$chain\n";
	my $str="\$jseq clear
\$jseq irshift -state IDLE -hex 6 $chain
\$jseq drshift -state IDLE -hex $siz $hex
\$jseq run
";
return $str;
}


sub send_capture_jtag {
	my ($hex,$width,$chain) =@_;
	my $siz = $width+4;
	my $str="\$jseq clear                                                      
\$jseq irshift -state IDLE -hex 6 $chain                 
\$jseq drshift -state IDLE -capture -hex $siz $hex  
set data [\$jseq run]
puts R:\$data:R
"; 
return $str;	
}


sub jtag_vdr{
	my ($dat,$width,$chain)=@_;
	my $digits= $width>>2;	
	my $hex = UPDATE_DAT.sprintf("%0${digits}X", $dat);
	$hex=jtag_reorder($hex);	
	return send_capture_jtag($hex,$width,$chain);
}


sub jtag_vir {
	my ($ir,$width,$chain)=@_;	
	my $digits= $width>>2;	
	my $hex = UPDATE_IR.sprintf("%0${digits}X", $ir);
	$hex=jtag_reorder($hex);
	return send_to_jtag($hex,$width,$chain);
}

sub jtag_vindex {
	my ($index,$width,$chain)=@_;	
	my $digits= $width>>2;	
	my $hex = UPDATE_INDEX.sprintf("%0${digits}X", $index);
	$hex=jtag_reorder($hex);
	return send_to_jtag($hex,$width,$chain);
}




sub uart_main {
	my $self = __PACKAGE__->new(); 
	set_gui_status($self,"ideal",0);
	my $window = def_popwin_size (85,85,'UART Terminal','percent');
	my ($sw,$tview) =create_text();# a textveiw for showing the info, erro messages etc
	my $ctrl= ctrl_boxes($self);
	my ($rsv,$tv_ref) = receive_boxes($self);
	my ($send,$send_tv) =	sender_box($self,$tview);
	 
	my $v1 = gen_vpaned ($ctrl,0.2,$send);	
	my $v2 = gen_vpaned ($v1,0.5,$sw);
	my $h1 = gen_hpaned ($rsv,0.55,$v2);
	
	my ($pipe,$in, $out, $err);
	my $counter=5;
	#check soc status every 0.5 second. referesh device table if there is any changes 
    Glib::Timeout->add (100, sub{ 
        my ($state,$timeout)= get_gui_status($self);
        
        if ($timeout>0){
            $timeout--;
            set_gui_status($self,$state,$timeout);           
        }
        elsif( $state ne "ideal" ){        	
            if($state eq 'ref_all') {
            	 $rsv->destroy();
            	 ($rsv,$tv_ref) = receive_boxes($self);
            	 $h1-> pack1($rsv, TRUE, TRUE);
            }	  
            
            
           
            $ctrl->destroy();
            $send->destroy();
           
            ($send,$send_tv) =	sender_box($self,$tview);
            $ctrl= ctrl_boxes($self);
           
            $v1-> pack1($ctrl, TRUE, TRUE);
            $v1-> pack2($send, TRUE, TRUE);
            $h1->show_all();
            set_gui_status($self,"ideal",0);     
            if($state eq 'ON-OFF') {  
            	check_jtag_connect ($self,\$pipe,$tview,\$in, \$out, \$err);
            	my $st =$self->object_get_attribute("CTRL","RUN");
            	$counter=5 if ($st eq 'OFF');
            	print "ON-OFF\n";
            }
            print "ref\n";
           ;    
            
       }
        my $st =$self->object_get_attribute("CTRL","RUN");
        $counter-- if ($st eq 'ON' && $counter>0);
		run_jtag_scaner($self,$tview,$tv_ref,\$pipe,\$in, \$out, \$err) if($counter ==0);
    	
    	return TRUE;
        
    } );
	
	
	$window->add($h1);
	$window->show_all();
	return $window;	
}	





1;