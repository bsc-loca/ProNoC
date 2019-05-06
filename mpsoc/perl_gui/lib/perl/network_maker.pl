#!/usr/bin/perl
use strict;
use warnings;
use Glib qw(TRUE FALSE);
use Gtk2 '-init';
use Cwd 'abs_path';
use base 'Class::Accessor::Fast';
require "widget.pl"; 
require "diagram.pl";
#use GraphViz;


__PACKAGE__->mk_accessors(qw{
	window
	sourceview		
});

my $NAME = 'Network_maker';
exit network_maker_main() unless caller;


sub network_maker_main {
	my $app = __PACKAGE__->new();
	my $table=$app->build_network_maker_gui();
	return $table;
}


sub custom_topology_diagram {
	my $self= shift;
	my $table=def_table(20,20,FALSE);
	my $scrolled_win = new Gtk2::ScrolledWindow (undef, undef);	
	$scrolled_win->set_policy( "automatic", "automatic" );	
	
	my $plus = def_image_button('icons/plus.png',undef,TRUE);
	my $minues = def_image_button('icons/minus.png',undef,TRUE);
	my $save = def_image_button('icons/save.png',undef,TRUE);
	
	my $scale=$self->object_get_attribute("tile_diagram","scale");
	$scale= 1 if (!defined $scale);	
		
	
	my ($col,$row)=(0,0);
	$table->attach ($plus ,  $col, $col+1,$row,$row+1,'shrink','shrink',2,2); $row++;
	$table->attach ($minues,  $col, $col+1,$row,$row+1,'shrink','shrink',2,2); $row++;
	$table->attach ($save,  $col, $col+1,$row,$row+1,'shrink','shrink',2,2); $row++;
 	($col,$row)=(1,0);
	while ($row<20){		
		my $tmp=gen_label_in_left('');
		$table->attach_defaults ($tmp, $col,  $col+1,$row,$row+1);$row++;
	}
	
	$plus  -> signal_connect("clicked" => sub{ 
		$scale*=1.1 if ($scale <10);
		$self->object_add_attribute("topology_diagram","scale", $scale );
		show_custom_topology_diagram ($self,$scrolled_win,$table,"topology_diagram");
	});	
	$minues  -> signal_connect("clicked" => sub{ 
		$scale*=.9  if ($scale >0.1); ;
		$self->object_add_attribute("topology_diagram","scale", $scale );
		show_custom_topology_diagram ($self,$scrolled_win,$table,"topology_diagram");
	});
	$save-> signal_connect("clicked" => sub{ 
			save_diagram_as ($self);
		});	
	
	
	#if(gen_custom_diagram($self,'custom_topology')){
		show_custom_topology_diagram ($self,$scrolled_win,$table,"topology_diagram");
	#}
	return $table;
}


sub endp_node_dot {
	my $i=shift;
	return 
	"
	T$i\[
	label = \"T$i\"
    shape=house
    margin=0
	color=orange
	style=filled
	fillcolor=orange
];
";	
}

sub router_node_dot{
	my ($Pnum,$Rnum)=@_;	
	
	my $label =
		($Pnum==2)? "                        \{<p1>1|R$Rnum|<p0>0\}":
		($Pnum==3)? "\{     |<p2>2|     \} | \{<p1>1|R$Rnum|<p0>0\} ":
		($Pnum==4)? "\{     |<p3>3|     \} | \{<p2>2|R$Rnum|<p0>0\} | \{  <p1>1\}":
		($Pnum==5)? "\{     |<p3>3|     \} | \{<p2>2|R$Rnum|<p4>4\} | \{ |<p1>1|<p0>0\}":
		($Pnum==6)? "\{<p3>3|<p4>4|     \} | \{<p2>2|R$Rnum|<p5>5\} | \{ |<p1>1|<p0>0\}":
		($Pnum==7)? "\{<p4>4|<p5>5|     \} | \{<p3>3|R$Rnum|<p6>6\} | \{<p2>2 |<p1>1|<p0>0\}":
		($Pnum==8)? "\{<p4>4|<p5>5|<p6>6\} | \{<p3>3|R$Rnum|<p7>7\} | \{<p2>2 |<p1>1|<p0>0\}":
		($Pnum==9)? "\{<p5>5|<p6>6|<p7>7\} | \{<p4>4|R$Rnum|<p8>8\} | \{<p3>3 |<p2>2|<p1>1|<p0>0\}":
		($Pnum==10)? "\{<p5>5|<p6>6|<p7>7|<p8>8\} | \{<p4>4|R$Rnum|<p9>9\} | \{<p3>3 |<p2>2|<p1>1|<p0>0\}":
		($Pnum==11)? "\{<p6>6|<p7>7|<p8>8|<p9>9\}| \{<p5>5| | |<p10>10\}  | \{<p4>4|R$Rnum| \} | \{<p3>3 |<p2>2|<p1>1|<p0>0\}":
		($Pnum==12)? "\{<p6>6|<p7>7|<p8>8|<p9>9\}| \{<p5>5| | |<p10>10\}  | \{<p4>4|R$Rnum|<p11>11\} | \{<p3>3 |<p2>2|<p1>1|<p0>0\}":
		  "\{ |<p2>2| \} | \{<p3>3|R$Rnum|<p1>1\} | \{ |<p4>4|<p0>0\}";	
	
	
	return 
	"R${Rnum}\[
	label = \"$label\"
    shape=record
	color=blue
	style=filled
	fillcolor=blue
];
";

}

sub generate_custom_topology_dot_file{
	my $self=shift;
		
	my $dotfile=
"digraph G {
	graph [rankdir = LR , splines = true]; 	
	node[shape=record];	
	";	
	#show endpoints
	my $EN= $self->object_get_attribute('noc_param','ENDP_NUM');
	
	for (my $i=0;$i<$EN; $i++){
		$dotfile=$dotfile.endp_node_dot($i);
	}	
	
	my $Rnum=0;
	for ( my $i=2;$i<=12; $i++){
		 my $n= $self->object_get_attribute('noc_param',"ROUTER${i}_NUM");
		 for ( my $j=0;$j<$n; $j++){
			$dotfile=$dotfile.router_node_dot($i,$Rnum);	
			 $Rnum++;
		 }
	}	
	
	
	$dotfile=$dotfile."\n}\n";
	#print  $dotfile;
	return $dotfile;

}




sub show_custom_topology_diagram {
	my ($self,$scrolled_win,$table, $name)=@_;

	$scrolled_win->destroy;
	$scrolled_win = new Gtk2::ScrolledWindow (undef, undef);	
	$scrolled_win->set_policy( "automatic", "automatic" );
	$table->attach_defaults ($scrolled_win, 1, 20, 0, 20); #,'fill','shrink',2,2);		
	my $scale=$self->object_get_attribute($name,"scale");
	$scale= 1 if (!defined $scale);
	
	my $dotfile = generate_custom_topology_dot_file($self);
	
	my $cmd;
	#$cmd=  "dot  $tmp_dir/diagram.txt | neato -n  -Tpng -o $tmp_dir/diagram.png" if ($type eq 'tile' || $type eq 'trace'  );
	#$cmd = "dot  $tmp_dir/diagram.txt -Kfdp -n -Tpng -o $tmp_dir/diagram.png" if ( $type eq 'map' || $type eq 'topology' || $type eq 'custom_topology' );	
	$cmd =  " twopi   -Kfdp -n  -Tjpg " ;
    $cmd = "echo \'$dotfile\' | $cmd";
	my ($stdout,$exit,$stderr)= run_cmd_in_back_ground_get_stdout ($cmd);
	if ( length( $stderr || '' ) !=0)  {
		message_dialog("$stderr\nHave you installed graphviz? If not run \n \t \"sudo apt-get install graphviz\" \n in terminal");
		
	}

		 my $diagram =open_inline_image( $stdout,70*$scale,70*$scale,'percent');
		$scrolled_win->add_with_viewport($diagram);
		$scrolled_win->show_all();	
}


sub topology_maker_notebook{
	my ($self,$tview)=@_;		
	my $notebook = Gtk2::Notebook->new;
	$notebook->set_tab_pos ('left');
	$notebook->set_scrollable(TRUE);
	$notebook->can_focus(FALSE);
	my $page1=take_node_num_page($self,$tview);
	$notebook->append_page ($page1,Gtk2::Label->new  (" Connection"));
	return $notebook;
	
}





sub take_node_num_page{
	my ($self,$tview)=@_;		
	my $table= def_table(2,10,FALSE);
	my $row=0;
	my $col=0;
	$table->attach (def_icon('icons/e.png'),$col,$col+1,$row,$row+1,'fill','shrink',2,2);$col++;
	($row,$col)=add_param_widget ($self,"# Endpoints","ENDP_NUM", 0,'Spin-button','0,1024,1',undef, $table,$row,$col,1,'noc_param',1);$col=0;
	for ( my $i=2;$i<=12; $i++){
		$table->attach (def_icon('icons/r.png'),$col,$col+1,$row,$row+1,'fill','shrink',2,2);$col++;
		($row,$col)=add_param_widget ($self,"# $i Port Routers","ROUTER${i}_NUM", 0,'Spin-button','0,1024,1',undef, $table,$row,$col,1,'noc_param',1);$col=0;		
	}	
	
	
	
	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	
	
	return $sc_win;
	
}




sub build_network_maker_gui {
	my ($self) = @_;
	set_gui_status($self,"ideal",0);
	my $main_table= def_table(2,10,FALSE);
	my ($scwin_info,$tview)= create_text();	
	
	my $h1=gen_hpaned(topology_maker_notebook($self,$tview),.25,custom_topology_diagram($self));
	
	
#	my $h1=gen_hpaned($traces_ctrl,.25,$traces);
#	my $h2=gen_hpaned($map_ctrl,.25,$map);
#	my $h3=gen_hpaned($h2,.65,$map_info);

	#my $v1=gen_vpaned($h1,.3,$h3);
	#my $v2=gen_vpaned($v1,.6,$scwin_info);
	
	my $generate = def_image_button('icons/gen.png','Generate');
	my $open = def_image_button('icons/browse.png','Load');	
	my ($entrybox,$entry) = def_h_labeled_entry('Save as:',undef);
	$entry->signal_connect( 'changed'=> sub{
		my $name=$entry->get_text();
		$self->object_add_attribute ("save_as",undef,$name);	
	});	
	
	my $entry2=gen_entry_object($self,'out_name',undef,undef,undef,undef);
	my $entrybox2=labele_widget_info(" Output file name:",$entry2);
	
	my $save = def_image_button('icons/save.png','Save');
	$entrybox->pack_end($save,   FALSE, FALSE,0);

	$main_table->attach_defaults ($h1  , 0, 12, 0,24);
	$main_table->attach ($open,0, 3, 24,25,'expand','shrink',2,2);
	$main_table->attach ($entrybox,3, 5, 24,25,'expand','shrink',2,2);
	$main_table->attach ($entrybox2,5,6 , 24,25,'expand','shrink',2,2);
	$main_table->attach ($generate, 6, 9, 24,25,'expand','shrink',2,2);
	

	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($main_table);
	
	
	
	$open-> signal_connect("clicked" => sub{ 
		
		
		set_gui_status($self,"ref",5);
	
	});	

	$save-> signal_connect("clicked" => sub{ 
		
		set_gui_status($self,"ref",5);
		
	
	});	
	
	$generate->signal_connect("clicked" => sub{ 
			
	
	});	
		
	
	
	#check soc status every 0.5 second. referesh device table if there is any changes 
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
		
		
									
		
		
		$main_table->show_all();			
		set_gui_status($self,"ideal",0);
		
		return TRUE;
		
	} );	



	return $sc_win;

	
	
}
