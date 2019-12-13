#!/usr/bin/perl
use strict;
use warnings;
use Glib qw(TRUE FALSE);
use Gtk2 '-init';
use Cwd 'abs_path';
use base 'Class::Accessor::Fast';
require "widget.pl"; 
require "diagram.pl";
require "topology_verilog_gen.pl";

use String::Scanf; # imports sscanf()

use FindBin;
use lib $FindBin::Bin;
use tsort;



__PACKAGE__->mk_accessors(qw{
	window
	sourceview		
});

my $NAME = 'Network_maker';
exit network_maker_main() unless caller;


sub network_maker_main {
	my $app = __PACKAGE__->new();
	
	my @parameters = (
	{param_name=> "V ", value=>2},    
    {param_name=> "B ", value=>4},    
    {param_name=> "C ", value=>2},     
    {param_name=> "Fpay ", value=>32},
    {param_name=> "MUX_TYPE", value=>'"ONE_HOT"'},    
    {param_name=> "VC_REALLOCATION_TYPE ", value=>'"NONATOMIC"'},
    {param_name=> "COMBINATION_TYPE", value=>'"COMB_NONSPEC"'},
    {param_name=> "FIRST_ARBITER_EXT_P_EN ", value=>1},  
    {param_name=> "CONGESTION_INDEX ", value=>7},
    {param_name=> "DEBUG_EN", value=>0},
    {param_name=> "AVC_ATOMIC_EN", value=>0},
    {param_name=> "CONGw ", value=>3},  
    {param_name=> "ADD_PIPREG_AFTER_CROSSBAR", value=>0},
    {param_name=> "CVw", value=>"(C==0)? V : C * V"},
    {param_name=> "CLASS_SETTING ", value=>"{CVw{1\'b1}}"}, 
    {param_name=> "SSA_EN", value=>'"NO"'},
    {param_name=> "SWA_ARBITER_TYPE ", value=>'"RRA"'}, 
    {param_name=> "WEIGHTw ", value=>7},  
    {param_name=> "MIN_PCK_SIZE", value=>2}
); 

my @ports =(
	{name=> "flit_in_all", type=>"input", width=>"PFw", connect=>"flit_out_all",  pwidth=>"Fw", pname=> "flit_in", pconnect=>"flit_out", endp=>"yes"},
	{name=> "flit_in_we_all", type=>"input", width=>"P", connect=>"flit_out_we_all",  pwidth=>1, pname=> "flit_in_we", pconnect=>"flit_out_we",endp=>"yes"},
	{name=> "congestion_in_all", type=>"input", width=>"CONG_ALw", connect=>"congestion_out_all",  pwidth=>"CONGw", pname=> "congestion_in", pconnect=>"congestion_out",endp=>"no"},
	{name=> "credit_out_all", type=>"output", width=>"PV", connect=>"credit_in_all",  pwidth=>"V" ,pname=> "credit_out", pconnect=>"credit_in",endp=>"yes"}
);

  
  $app->object_add_attribute ('Verilog','Router_param',\@parameters);
  $app->object_add_attribute ('Verilog','Router_ports',\@ports);
 
  

	
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
			save_inline_diagram_as ($self);
		});	
	
	
	#if(gen_custom_diagram($self,'custom_topology')){
		show_custom_topology_diagram ($self,$scrolled_win,$table,"topology_diagram");
	#}
	return $table;
}





sub gen_right_paned {
	my ($self,$info) =@_;
	my $page_num=$self->object_get_attribute ("process_notebook","currentpage");
	
	return route_info_window($self,$info) if($page_num==3);
	return custom_topology_diagram ($self,$info);
	
}


sub endp_node_dot {
	my ($T,$instance)=@_;
	
	
	return 
	"
	$T\[
	label = \"$instance\"
    shape=house
    margin=0
	color=orange
	style=filled
	fillcolor=orange
];
";	
}

sub router_node_dot{
	my ($Pnum,$R,$instance)=@_;	
	$Pnum=1 if(!defined $Pnum);
	my $label =
		($Pnum==2)? "                        \{<p1>1|$instance|<p0>0\}":
		($Pnum==3)? "\{     |<p2>2|     \} | \{<p1>1|$instance|<p0>0\} ":
		($Pnum==4)? "\{     |<p3>3|     \} | \{<p2>2|$instance|<p0>0\} | \{  <p1>1\}":
		($Pnum==5)? "\{     |<p3>3|     \} | \{<p2>2|$instance|<p4>4\} | \{ |<p1>1|<p0>0\}":
		($Pnum==6)? "\{<p3>3|<p4>4|     \} | \{<p2>2|$instance|<p5>5\} | \{ |<p1>1|<p0>0\}":
		($Pnum==7)? "\{<p4>4|<p5>5|     \} | \{<p3>3|$instance|<p6>6\} | \{<p2>2 |<p1>1|<p0>0\}":
		($Pnum==8)? "\{<p4>4|<p5>5|<p6>6\} | \{<p3>3|$instance|<p7>7\} | \{<p2>2 |<p1>1|<p0>0\}":
		($Pnum==9)? "\{<p5>5|<p6>6|<p7>7\} | \{<p4>4|$instance|<p8>8\} | \{<p3>3 |<p2>2|<p1>1|<p0>0\}":
		($Pnum==10)? "\{<p5>5|<p6>6|<p7>7|<p8>8\} | \{<p4>4|$instance|<p9>9\} | \{<p3>3 |<p2>2|<p1>1|<p0>0\}":
		($Pnum==11)? "\{<p6>6|<p7>7|<p8>8|<p9>9\}| \{<p5>5| | |<p10>10\}  | \{<p4>4|$instance| \} | \{<p3>3 |<p2>2|<p1>1|<p0>0\}":
		($Pnum==12)? "\{<p6>6|<p7>7|<p8>8|<p9>9\}| \{<p5>5| | |<p10>10\}  | \{<p4>4|$instance|<p11>11\} | \{<p3>3 |<p2>2|<p1>1|<p0>0\}":
		  "\{ |<p2>2| \} | \{<p3>3|$instance|<p1>1\} | \{ |<p4>4|<p0>0\}";	
	
	
	return 
	"$R\[
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
	#Add endpoints
	my @nodes=get_list_of_all_endpoints($self);
	my $i=0;
	foreach my $p (@nodes){
		my $instance= $self->object_get_attribute("$p","NAME");
		$instance = "T$i" if(!defined $instance);
		$dotfile=$dotfile.endp_node_dot($p,$instance);		
		$i++;
	}
	
	
	
	#add routers
	@nodes=get_list_of_all_routers($self);
	$i=0;
	foreach my $p (@nodes){
		my $instance= $self->object_get_attribute("$p","NAME");
		$instance = "R$i" if(!defined $instance);
		my $pnum=$self->object_get_attribute("$p",'PNUM');
		$dotfile=$dotfile.router_node_dot($pnum,$p,$instance);	
		$i++;
	}
		
	
	#add connections
	my @all_nodes=get_list_of_all_nodes($self);
	my @draw;
	foreach my $p (@all_nodes){
   	   	my $pnum=$self->object_get_attribute("$p",'PNUM');
   	   #	my $inst=$self->object_get_attribute("$p",'NAME');
   	   	my $type = $self->object_get_attribute("$p",'TYPE');   	   
   	   	$pnum = 0 if(!defined $pnum);
   	   	for (my $i=0;$i<$pnum; $i++){ 
   	   		my $src_port = "Port[${i}]";
   	   		my $connect = $self->{$p}{'PCONNECT'}{$src_port};
			
			if (defined $connect) { 
				my $pos = get_scolar_pos($connect,@draw);
				if ( !defined $pos ){
				
				
				my ($node,$pnode)=split(',',$connect);
				# check if $node exist
				if ( defined get_scolar_pos($node, @all_nodes)){
				 
	   	   		    my ($cp)= sscanf("Port[%u]","$pnode");
	   	   		    # my $cinst=$self->object_get_attribute("$node",'NAME');
	   	   		    my $ctype = $self->object_get_attribute("$node",'TYPE');
	   	   		  	my $t2 = ($type eq "ENDP" )? "\"$p\"" : "\"$p\" : \"p$i\"";
	   	   		  	my $t1 = ($ctype eq "ENDP" )? "\"$node\"" : "\"$node\" : \"p$cp\"";
	   	   		
	   	   			my $t= "$t1 -> $t2 [ dir=none];\n"; 
	   	   			$dotfile=$dotfile."$t";
				}
   	   			push(@draw,$connect);
   	   			push(@draw,"$p,$src_port");
   	   			#print "@draw\n";
   	   		}
   	   		
	
   	   	}}
	}
	$dotfile=$dotfile."\n}\n";
	#print  $dotfile;
	return $dotfile;
}

sub get_connection_port_num_between_two_nodes{
	my ($self,$n1,$n2)=@_;
	my $PNUM=$self->object_get_attribute($n1,"PNUM");
	
	for (my $p1=0; $p1<$PNUM; $p1++){
		my $connect=$self->{$n1}{"PCONNECT"}{"Port[$p1]"};
		next if(!defined $connect);
		my ($node,$pnode)=split(',',$connect);
		my ($p2)= sscanf("Port[%u]","$pnode");
		return ($p1,$p2) if($node eq $n2 );		
	}
	return undef;
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
	#$cmd = "twopi  $tmp_dir/diagram.txt -Kfdp -n -Tpng -o $tmp_dir/diagram.png" if ( $type eq 'map' || $type eq 'topology' || $type eq 'custom_topology' );	
	$cmd =  " dot  -Goverlap=false -Kfdp    -Tjpg " ;
	#$cmd =  " dot  | neato -Goverlap=false -n  -Tpng " ;
	
    $cmd = "echo \'$dotfile\' | $cmd";
	my ($stdout,$exit,$stderr)= run_cmd_in_back_ground_get_stdout ($cmd);
	if ( length( $stderr || '' ) !=0)  {
		message_dialog("$stderr\nHave you installed graphviz? If not run \n \t \"sudo apt-get install graphviz\" \n in terminal");
		
	}

		my $diagram =open_inline_image( $stdout,70*$scale,70*$scale,'percent');
		$scrolled_win->add_with_viewport($diagram);
		$scrolled_win->show_all();	
		
		my $save=$self->object_get_attribute("graph_save","enable");
		$save=0 if(!defined $save);
		if($save==1){
			my $file = $self->object_get_attribute("graph_save","name");
			my $ext  = $self->object_get_attribute("graph_save","extension");
			my $pixbuff= $diagram->get_pixbuf;
		    $pixbuff->save ("$file", "$ext");	
		    $self->object_add_attribute("graph_save","enable",'0');	
		}	
		
		
}


sub topology_maker_notebook{
	my ($self,$info)=@_;		
	my $notebook = Gtk2::Notebook->new;
	$notebook->set_tab_pos ('left');
	$notebook->set_scrollable(TRUE);
	$notebook->can_focus(FALSE);
	my $page1=take_node_num_page($self);
	$notebook->append_page ($page1,Gtk2::Label->new  (" Nodes #"));
	my $page2=take_instance_page($self);
	$notebook->append_page ($page2,Gtk2::Label->new  ("Instance"));
	my $page3=connection_page($self,$info);
	$notebook->append_page ($page3,Gtk2::Label->new  ("Connection"));
	my $page4=routing_page($self,$info);
	$notebook->append_page ($page4,Gtk2::Label->new  ("Route Selection"));
	
	
	
	
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
			set_gui_status($self,"redraw",1);
		}
		$first=0;		
	});
	
	return $notebook;
	
}





sub take_node_num_page{
	my ($self)=@_;		
	my $table= def_table(2,10,FALSE);
	my $row=0;
	my $col=4;
	$table->attach (def_label('Network Element'),$col,$col+1,$row,$row+1,'fill','shrink',2,2);$col+=2;
	$table->attach (def_label('Number'),$col,$col+1,$row,$row+1,'fill','shrink',2,2);
	$row++;$col=0;
	
	$table->attach (def_icon('icons/e.png'),$col,$col+1,$row,$row+1,'fill','shrink',2,2);$col++;
	($row,$col)=add_param_widget ($self,"# Endpoints","NUM", 0,'Spin-button','0,1024,1',undef, $table,$row,$col,1,'ENDP',10,'redraw');$col=0;
	for ( my $i=2;$i<=12; $i++){
		$table->attach (def_icon('icons/r.png'),$col,$col+1,$row,$row+1,'fill','shrink',2,2);$col++;
		($row,$col)=add_param_widget ($self,"# $i Port Routers","NUM", 0,'Spin-button','0,1024,1',undef, $table,$row,$col,1,"ROUTER${i}",10,'redraw');$col=0;		
	}	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	return $sc_win;
}



sub take_instance_page{
	my ($self)=@_;		
	my $table= def_table(2,10,FALSE);
	
	my $row=0;
	my $col=0;
	$table->attach (def_label(' Network Element '),$col,$col+1,$row,$row+1,'fill','shrink',2,2);$col+=2;
	$table->attach (def_label(' Instance name '),$col,$col+1,$row,$row+1,'fill','shrink',2,2);
	$row++;$col=0;
	
	
	my $EN= $self->object_get_attribute('ENDP','NUM');
	$EN = 0 if(!defined $EN);
	for (my $i=0;$i<$EN; $i++){	
		 $self->object_add_attribute("ENDP_$i",'PNUM',1);
		 $self->object_add_attribute("ENDP_$i",'TYPE',"ENDP");
		 my $d=get_default_instance_name($self,"ENDP_$i");	                            
		($row,$col)=add_param_widget ($self,"Endpoint $i","NAME",$d ,'Entry',undef,"router instance name", $table,$row,$col,1,"ENDP_$i",10,'redraw');$col=0;
		
	}	
	
	#routers
	my $Rnum=0;
	for ( my $i=2;$i<=12; $i++){
		my $n= $self->object_get_attribute("ROUTER${i}","NUM");
		$n=0 if(!defined $n);
		 for ( my $j=0;$j<$n; $j++){
		 	 $self->object_add_attribute("ROUTER${i}_$j",'PNUM',${i});
			 $self->object_add_attribute("ROUTER${i}_$j",'RNUM',$Rnum);
			 $self->object_add_attribute("ROUTER${i}_$j",'TYPE',"ROUTER");
		 	 my $d=get_default_instance_name($self,"ROUTER${i}_$j");
		 	
			($row,$col)=add_param_widget ($self,"Router $Rnum","NAME", "$d",'Entry',undef,"router instance name", $table,$row,$col,1,"ROUTER${i}_$j",10,'redraw');$col=0;
			
			 
			 $Rnum++;
		 }
	}	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	return $sc_win;
}


sub get_default_instance_name {
	my ($self,$name)=@_;
	my $type = $self->object_get_attribute($name,'TYPE');
	my @nodes =($type eq 'ENDP')? get_list_of_all_endpoints($self):get_list_of_all_routers($self);
		
	my @R=("--");
	foreach my $p (@nodes){
		my $n= $self->object_get_attribute("$p","NAME");
		push( @R, $n) if(defined $n);			
	}	
	
	my $i=0;
	my $inst = 	($type eq 'ENDP')? "T$i": "R$i";
	my $pos= get_scolar_pos($inst,@R);
	while (defined $pos){
		$i++;	
		$inst = 	($type eq 'ENDP')? "T$i": "R$i";
		$pos= get_scolar_pos($inst,@R);				
	}
		
	
	return 	$inst;	
}	
	
	
	
	




sub get_list_of_all_routers {
	my ($self)=@_;	
	my @R;
	for ( my $i=2;$i<=12; $i++){
		 my $n= $self->object_get_attribute("ROUTER${i}","NUM");
		 $n=0 if(!defined $n);
		 for ( my $j=0;$j<$n; $j++){
		 	push( @R, "ROUTER${i}_$j");		 	
		 }
	}	
	return @R;
}

sub get_list_of_all_endpoints {
	my ($self)=@_;	
	my @E;
	my $EN= $self->object_get_attribute('ENDP','NUM');
	$EN = 0 if(!defined $EN);
	for (my $i=0;$i<$EN; $i++){	
		push( @E, "ENDP_$i");		
	}
	return @E;
}

sub get_list_of_all_nodes {
	my ($self)=@_;	
	my @R=get_list_of_all_routers($self);
    my @E=get_list_of_all_endpoints($self);
    my @all_nodes= (@E,@R);
	return @all_nodes;
}	

sub remove_connected_port{
	my ($self,$node,$port,$info)=@_;
	my @all_nodes=get_list_of_all_nodes($self);
	foreach my $p (@all_nodes){
   	   	my $pnum=$self->object_get_attribute("$p",'PNUM');
   	   	my $inst=$self->object_get_attribute("$p",'NAME');
   	   
   	   	$pnum = 0 if(!defined $pnum);
   	   	for (my $i=0;$i<$pnum; $i++){ 
   	   		my $src_port = "Port[${i}]";
   	   		if(defined $self->{$p}{'PCONNECT'}{$src_port}){ if ($self->{$p}{'PCONNECT'}{$src_port} eq "$node,$port"){
   	   			delete $self->{$p}{'PCONNECT'}{$src_port};
   	   			my $con_inst=$self->object_get_attribute("$node",'NAME');
   	   			add_info(\$info,"** $inst  $src_port is disconnected from $con_inst $port \n") if (defined $info);
   	   		
   	   		}}
   	   	} 
	}	   	 	
}	


sub get_instance_to_node_name {
	my $self=shift;
	my @all_nodes=get_list_of_all_nodes($self);
    my %par;
    foreach my $p (@all_nodes){
   	   	my $inst=$self->object_get_attribute("$p",'NAME');
   	   	$par{$inst}= $p;
    }
    return %par;	
}


##############
#	create_tree 
##############
sub create_tree_view {
   my ($self,$source,$src_port,$info)=@_;  
   my $window = def_popwin_size(30,85,"Select Connetion Element and Port",'percent');
     
   my $model = Gtk2::TreeStore->new ('Glib::String', 'Glib::String', 'Glib::Scalar', 'Glib::Boolean');
   my $tree_view = Gtk2::TreeView->new;
   $tree_view->set_model ($model);
   my $selection = $tree_view->get_selection;
   $selection->set_mode ("single");
   
   my @all_nodes=get_list_of_all_nodes($self);
 
   unshift(@all_nodes,"-");
   my %par;
 
   foreach my $p (@all_nodes){
   	    my @childs;
   	   	my $pnum=$self->object_get_attribute("$p",'PNUM');
   	   	my $inst=$self->object_get_attribute("$p",'NAME');
   	   	
   	   	$pnum = 0 if(!defined $pnum);
   	   	$inst = "-" if(!defined $inst);
   	   	
   	   	$par{$inst}= $p;
   	   	for (my $i=0;$i<$pnum; $i++){ 
   	   		#donot add the source port itself to connection list
   	   		if(($source ne $p)|| ($src_port ne "Port[${i}]")){
   				push(@childs, "Port[${i}]");
   	   		}
   	   	}  	
		my $iter = $model->append (undef);
	    $model->set ($iter, 0, $inst, 1, $inst || '', 2, 0 || '', 3,   FALSE);
		foreach my $v ( @childs){
			 my $child_iter = $model->append ($iter);
			 $model->set ($child_iter, 0, $v, 1, $inst|| '', 2, $v || '', 3,   FALSE);
		}	
   }
	
   my $cell = Gtk2::CellRendererText->new;
   $cell->set ('style' => 'italic');
   my $column = Gtk2::TreeViewColumn->new_with_attributes ("select", $cell, 'text' => 0, 'style_set' => 3);
   $tree_view->append_column ($column);
   
   
   
   $tree_view->signal_connect (row_activated => sub{

		my ($tree_view, $path, $column) = @_;
		my $model = $tree_view->get_model;
		my $iter = $model->get_iter ($path);
		my $parent = $model->get ($iter, 1);
		my $child = $model->get ($iter, 2);
		
		if ($child){ 
			   	my $node=$par{$parent};
			   	connect_nodes ($self,$node,$child,$source,$src_port,$info);
		  		
		  		
		  		
		  
		  		set_gui_status($self,'ref',1);		
		  		$window->destroy;
		  		
				#add parent child
			}
		elsif($parent ){
			
			my $node=$par{$parent};
			if ($node eq "-"){
				remove_connected_port($self,$source,$src_port);
				delete $self->{$source}{'PCONNECT'}{$src_port};
			}
			
			
			
			set_gui_status($self,'ref',1);		
		  	$window->destroy;
		  		
			
		}
	
  
	#add parent child

	});

  #$tree_view->expand_all;

  my $scrolled_window = Gtk2::ScrolledWindow->new;
  $scrolled_window->set_policy ('automatic', 'automatic');
  $scrolled_window->set_shadow_type ('in');
  $scrolled_window->add($tree_view);

  my $hbox = Gtk2::HBox->new (FALSE, 0);
  $hbox->pack_start ( $scrolled_window, TRUE, TRUE, 0);
  $window ->add($hbox);
  $window->show_all;
}

sub connect_nodes {
	my ($self,$node1,$src_port1,$node2,$src_port2,$info)=@_;
	
		
		
	#add_colored_info(\$info,"$node1,$src_port1,$node2,$src_port2;\n","red") if (defined $info);	
	
	#check if the selected port has been connected to another port before and remove the connection
	remove_connected_port($self,$node1,$src_port1,$info);
	remove_connected_port($self,$node2,$src_port2,$info);
		  		
	$self->{$node1}{'PCONNECT'}{$src_port1}="$node2,$src_port2";
	$self->{$node2}{'PCONNECT'}{$src_port2}="$node1,$src_port1";
	
}



sub connection_page{
	my ($self,$info)=@_;		
	my $table= def_table(2,10,FALSE);
	my $row=0;
	my $col=0;
	
	my $eq = def_table(1,8,TRUE);
	
	my $label = gen_label_help("Eg: R[i]P[0]->T[i]P[0];i[0,10,1]","Equation:");
	my $entry = Gtk2::Entry->new;
	my $open= def_image_button("icons/enter.png",undef,TRUE);
	$eq->attach ($label,0,2,  $row, $row+1,'fill','fill',2,2);
	$eq->attach_defaults ($entry,2, 9,  $row, $row+1);
	$eq->attach ($open,9, 10,  $row, $row+1,'fill','shrink',2,2);
	$table->attach ($eq,0, 20,  $row, $row+1,'expand','fill',2,2);$row++;	
	
	$open->signal_connect("clicked" => sub {
				evaluate_eqation($self,$entry->get_text(),$info);
				
	});
	
	$row++;
	
	
	
	$table->attach (Gtk2::HSeparator->new,0, 20,  $row, $row+1,'fill','fill',2,2);$row++;	
	my $savr=$row;$row++;	
	
	my $maxp=1;	
	
	my @all_nodes=get_list_of_all_nodes($self);
		
	foreach  my $p  (@all_nodes ){	
		my $inst=$self->object_get_attribute("$p",'NAME');
		my $pnum=$self->object_get_attribute("$p",'PNUM');
   	   	$maxp=	$pnum if($pnum > $maxp );  	   		
   	   
   	   	
   	   	
		my $lable =gen_label_in_left("$inst:");
		attach_widget_to_table ($table,$row,undef,undef,$lable,$col);  $col++;
		
		for (my $i=0;$i<$pnum; $i++){ 
			my $pname= "Port[${i}]";
			my $connect = $self->{$p}{'PCONNECT'}{$pname};
			my $button =  Gtk2::Button->new_from_stock(" -> ");
			if (defined $connect) { 
				my ($node,$pnode)=split(',',$connect);
		    	my $e=$self->object_get_attribute("$node",'NAME');
				$button = Gtk2::Button->new_from_stock("$e->$pnode") if(defined $e);
			}
			$button->signal_connect("clicked" => sub {
				create_tree_view($self,$p,$pname,$info);
				
			});
			attach_widget_to_table ($table,$row,undef,undef,$button,$col);  $col++;
		}   
		$col=0;
			                            
		#($row,$col)=add_param_widget ($self,"$instance","CNNT", undef,"Combo-box",$list,"router instance name", $table,$row,$col,1,"ENDP_$i",1,'ref','horizental');
		# my $connect_r= $self->object_get_attribute("ENDP_$i","CNNT");
		# if( defined $connect_r){
		# 	print "cponnection is $R{$connect_r}\n";
		# 	my $conr= $R{$connect_r};
		# 	my $p=0;
		# 	($row,$col)=add_param_widget ($self,"P$p","P_$p", undef,"Combo-box",$list,undef, $table,$row,$col,1,"ENDP_$i",1,'ref','horizental');
		 	
		 	
		 	
		# }
		 $row++;$col=0;
		
	}	
	
	#routers
    for ( my $i=2;$i<=12; $i++){
		 my $n= $self->object_get_attribute("ROUTER${i}","NUM");
		 $n=0 if(!defined $n);
		 for ( my $j=0;$j<$n; $j++){
			my $pnum=	 $self->object_get_attribute("ROUTER${i}_$j",'PNUM');
			 for ( my $p=0;$p<$pnum; $p++){
			 	#	($row,$col)=add_param_widget ($self,"P$p","P_$p", undef,"Combo-box",$list,undef, $table,$row,$col,1,"ROUTER${i}_$j",1,'ref','horizental');
		 	
			 }
			  $row++;$col=0;
			
		 }
	}	
	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	
	
	#add lables
	$row=$savr;$col=0;
	$table->attach (def_label(' Network Element '),$col,$col+1,$row,$row+1,'fill','shrink',2,2);$col+=4;
	for (my $i=0;$i<$maxp; $i++){ 
		$table->attach (def_label(" P$i "),$col,$col+1,$row,$row+1,'fill','shrink',2,2);$col+=4;
		
	}
	return $sc_win;
	
}


sub evaluate_eqation{
	my ($self,$exp,$info)=@_;

	my @str=split /;/, $exp; 
	my $eq_exp;
	
	my $f=0;
	my %vname;
	my %vars;
	
	my %nodes_name=get_instance_to_node_name($self);
	
	foreach my $p (@str) {
		
		if($f==0){
			$eq_exp= $p;
					
		}	
		else{
			my ($v, $start, $end, $step) = sscanf("%s[%d,%d,%d]", $p);
			print "($v, $start, $end, $step)\n";
			my @a;
			for (my $i=$start; $i<$end;$i++){
				push (@a,$i);
			} 
			$vars{$f}=\@a;
			$vname{$f}=$v;
			
		}
		$f++;
	
	}
	
	
	my %vars2;
	my $v1=$vname{1};
	foreach my $i (@{$vars{1}}){
		$vars2{$v1}=$i;
		my $v2=$vname{2};
		if (defined $v2) {
			foreach my $j (@{$vars{2}}){
				$vars2{$v2}=$j;
				my $v3=$vname{3};
				if (defined $v3) {
					foreach my $k (@{$vars{3}}){
						$vars2{$v3}=$k;
						eval_exp($self,$eq_exp,\%vars2,\%nodes_name,$info);	
					}
						
				}
				else {eval_exp($self,$eq_exp,\%vars2,\%nodes_name,$info)};	
			
			
			}
		}
		else {eval_exp($self,$eq_exp,\%vars2,\%nodes_name,$info)};	
		
	}

set_gui_status($self,'ref',1);	
}




sub eval_exp {
	my ($self,$exp,$ref,$ref2,$info)=@_;
	my  %vars = %{$ref};
	my %nodes_name =%{$ref2};
    foreach my $p (sort keys %vars){
    	
    	chomp $exp;    	
		($exp=$exp)=~ s/\b$p\b/$vars{$p}/g; 
    	   	
    	
    }
    
    my ($s1, $n1, $p1,$s2, $n2, $p2 ) = sscanf("%s[%s]P[%s]->%s[%s]P[%s]", $exp);


$n1 = eval $n1;
$p1 = eval $p1;

$n2 = eval $n2;
$p2 = eval $p2;


my $string= "$s1 [$n1] P [$p1] -> $s2 [$n2] P [$p2]\n";

my $node1=$nodes_name{$s1.$n1};
my $node2=$nodes_name{$s2.$n2};

if(!defined $node1 ){
		add_colored_info(\$info,"No instance is named as \"$s1$n1\";\n","red") if (defined $info);
		return;
	}
	if( !defined $node2 ){
		add_colored_info(\$info,"No instance is named as \"$s2$n2\";\n","red") if (defined $info);
		return;
	}	


 connect_nodes ($self,$node1,"Port[$p1]",$node2,"Port[$p2]",$info);


add_info(\$info,"$string") if (defined $info);

		
}	
	
	
	



sub routing_page{
	my ($self,$info)=@_;		
	my $table= def_table(2,10,FALSE);
	my $row=0;
	my $col=0;
	
	my $auto = def_image_button('icons/gen.png','AutoGenerate');
	$table->attach ($auto,0, 10,  $row, $row+1,'fill','fill',2,2);
	my $clear = def_image_button('icons/clear.png','Clear');
	$table->attach ($clear,10, 20,  $row, $row+1,'fill','fill',2,2);$row++;
	
	
	
	$table->attach (Gtk2::HSeparator->new,0, 200,  $row, $row+1,'fill','fill',2,2);$row++;	
	$table->attach (def_label(' source -> destination '),0,10,$row,$row+1,'fill','shrink',2,2);	$row++;	




	$auto-> signal_connect("clicked" => sub{
			auto_route($self,$info);	
	});
	
	$clear-> signal_connect("clicked" => sub{
			clean_route($self,$info);	
	});
	
	
		
	my @all_endpoints=get_list_of_all_endpoints($self);
		
	foreach  my $src  (@all_endpoints ){	
		foreach  my $dst  (@all_endpoints ){	
			my $src_inst=$self->object_get_attribute("$src",'NAME');
			my $dst_inst=$self->object_get_attribute("$dst",'NAME');
		   	my $select = $self->object_get_attribute('Route',"${src}::$dst");
		   	my $color =( defined $select)? 0 :17;		   		   	
		   	my $button = ($src_inst ne $dst_inst )?  def_colored_button("${src_inst}->$dst_inst",$color): gen_label_in_center(' - ');	
		   	attach_widget_to_table ($table,$row,undef,undef,$button,$col);  $col++;	
		   	
		   	
		   	
		   	$button->signal_connect("clicked" => sub {
		   		$self->object_add_attribute("SELECT_PATH","src",$src);
		   		$self->object_add_attribute("SELECT_PATH","dst",$dst);
		   		set_gui_status($self,"redraw",1);
				
				
			}) if($src_inst ne $dst_inst );	
		   		
   	   
		}$row++;$col=0;
	}   	
   	   	
		
	
	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($table);
	
	
	
	return $sc_win;
	
}



sub route_info_window{
	my ($self,$info)= @_;	
	my $w1 = show_paths_between_two_endps($self,$info);
	my $w2 = routing_summary($self,$info);
	my $h1=gen_hpaned($w1,.30,$w2);		
	return $h1;	
}



sub add_route_edge_to_graph{
	my ($gref,$anodes_ref)=@_;
	my %graph=%{$gref};
	my @a_nodes= @{$anodes_ref};
	
	my $old_r;	
	foreach my $r (@a_nodes){
		
		if(defined $old_r){
			        push(@{$graph{$old_r}},$r);										
		}
		$old_r=$r;
	}	
	
	return %graph;	
}

sub get_adjacent_node_in_a_path{
	my $ref=shift;
	my @result;
	my @path=@{$ref};
	my $old_r;	
	foreach my $r (@path){	
		push (@result,"${old_r}::$r") if(defined $old_r);
		$old_r=$r;
	}	
	return @result;
	
}

sub get_adjacent_router_in_a_path{
	
	my $ref=shift;
	my @result;
	my @path=@{$ref};
	shift @path; #remove source node from the path
	pop @path; #remove the estination node from the path
	
	
	my $old_r;	
	foreach my $r (@path){	
		push (@result,"${old_r}::$r") if(defined $old_r);
		$old_r=$r;
	}	
	return @result;
	
}


sub get_route_info{
	my ($self)=@_;
	my %R_num;
	my %L_num;
	my @all_endpoints=get_list_of_all_endpoints($self);
	foreach  my $r  (@all_endpoints ){
		$R_num{$r} =0;
	}
	my @nodes=get_list_of_all_routers($self);
	foreach my $p (@nodes){
		$R_num{$p} =0;
	}	
	foreach  my $src  (@all_endpoints ){	
		foreach  my $dst  (@all_endpoints ){	
			my $path = $self->object_get_attribute('Route',"${src}::$dst");
			if (defined $path){
				#router counting
				my @p=@{$path};
				foreach my $r (@p){				
					$R_num{$r} ++;					
				}
				#path counting
				@p= 	get_adjacent_router_in_a_path($path);
				foreach my $r (@p){				
					$L_num{$r} ++;	
							
				}
			
			
			}			
		}
	}
	
	my @Rkeys = sort { $R_num{$a} <=> $R_num{$b} } keys(%R_num);
	my @Lkeys = sort { $L_num{$a} <=> $L_num{$b} } keys(%L_num);
	my $sample="sample0";
	foreach  my $r  (@nodes ){
		my $inst=$self->object_get_attribute("$r",'NAME');
		update_result ($self,$sample,"router_all_paths_result",'-',$inst,$R_num{$r});
	}
	
	my $max_r = (defined $Rkeys[-1]) ? $R_num{$Rkeys[-1]} : 0;
	my $min_r = (defined $Rkeys[ 0]) ? $R_num{$Rkeys[ 0]} : 0;
	my $max_l = (defined $Lkeys[-1]) ? $L_num{$Lkeys[-1]} : 0;
	my $min_l = (defined $Lkeys[ 0]) ? $L_num{$Lkeys[ 0]} : 0;
	my @l = sort  values (%L_num);
	my $std_l=stdev(\@l);	
	
	$self->object_add_attribute ($sample,"link_all_paths_result",undef);
	
	my $nn=0;
	my $min_l_name="-";
	my $max_l_name="-";
	my $siz = $#Lkeys;
	foreach  my $r  (@Lkeys ){
		my ($n1,$n2)=split(/::/,$r);
		my $inst1=$self->object_get_attribute("$n1",'NAME');
		my $inst2=$self->object_get_attribute("$n2",'NAME');
		my $inst = "$inst1-$inst2"; 
		update_result ($self,$sample,"link_all_paths_result",'-',$inst,$L_num{$r});
		$min_l_name= $inst if($nn==0);
		$max_l_name= $inst if($nn==$siz-1);
		$nn++;
	}
	
			
		
	my $max_r_name=$self->object_get_attribute("$Rkeys[-1]",'NAME');
	my $min_r_name=$self->object_get_attribute("$Rkeys[0]",'NAME');	
	
    
		   
	return ($max_r,$min_r,$max_l,$min_l,$std_l,$max_r_name,$min_r_name,$max_l_name,$min_l_name);	
}	


sub routing_summary{
	my ($self,$info)= @_;		
	
	my $sc_win = gen_scr_win_with_adjst($self,'map_info');
	my $table= def_table(10,10,FALSE);
	$sc_win->add_with_viewport($table);
	
	my $row=0;
	my $col=0;
	my ($max_r,$min_r,$max_l,$min_l,$std_l,$max_r_name,$min_r_name,$max_l_name,$min_l_name)=get_route_info($self);
	
	
	my @data = (
   {label => "The Maximum number that a router is used in routing",  value =>"$max_r", name =>"$max_r_name"}, # The maximum number that a router is located in all paths between all source-destination pair in this routing algorithm.
   {label => "The Minimum number that a router is used in routing",  value =>"$min_r", name =>"$min_r_name" },  
   {label => "The Maximum number that a link is used in routing ",  value =>"$max_l", name =>"$max_l_name"}, # The maximum number that a node-2-node link is located in all paths between all source-destination pair in this routing algorithm.
   {label => "The Minimum number that a link is used in routing",  value =>"$min_l", name =>"$min_l_name" },  
   {label => "Link usgae standard devision ",  value =>"$std_l" } 
  );
	
	
	
  # create list store
  my $store = Gtk2::ListStore->new (#'Glib::Boolean', # => G_TYPE_BOOLEAN
                                    #'Glib::Uint',    # => G_TYPE_UINT
                                    'Glib::String',  # => G_TYPE_STRING
                                    'Glib::String',
                                    'Glib::String'); # you get the idea

  # add data to the list store
  foreach my $d (@data) {
      my $iter = $store->append;
      $store->set ($iter,
		   0, $d->{label},
		   1, $d->{value},
		   2, $d->{name},
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
  my $column = Gtk2::TreeViewColumn->new_with_attributes ("Routing Summary",
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
  
  
  # column for description
  $renderer = Gtk2::CellRendererText->new;
  $column = Gtk2::TreeViewColumn->new_with_attributes (" ",
						       $renderer,
						       text => 2);
  $column->set_sort_column_id (2);
  $treeview->append_column ($column);

	
	$table-> attach  ($treeview, $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $row++; 
	#$table-> attach  (gen_label_in_left("Max distance:  $max  "), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $row++; 
	#$table-> attach  (gen_label_in_left("Min distance: $min   "), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $row++; 
	#$table-> attach  (gen_label_in_left("Normlized data per hop: $norm"), $col, $col+1,  $row, $row+1,'shrink','shrink',2,2); $row++; 
		
	my $charts =  gen_routing_charts($self,$info);
	
	my $v1=gen_vpaned($sc_win,.25,$charts);
	
	
	
	return $v1;
	
	
}


sub gen_routing_charts{
	
	my ($self,$info)=@_;
	
	my @pages =(
	{page_name=>" # Routers in all Paths", page_num=>0},
	{page_name=>" # Links in all Paths ", page_num=>1}	
);



my @charts = (
	{ type=>"3D_bar", page_num=>0, graph_name=> "# Router in all Paths", result_name => "router_all_paths_result", X_Title=> 'Router Name', Y_Title=>'The total number that a router is used in the routing', Z_Title=>undef},
	{ type=>"3D_bar", page_num=>1, graph_name=> "# Links in all paths", result_name => "link_all_paths_result", X_Title=> 'Connection Link', Y_Title=>'The total number that a link is used in the routing', Z_Title=>undef},
  	#{ type=>"2D_line", page_num=>0, graph_name=> "SD latency", result_name => "sd_latency_result", X_Title=> 'Desired Avg. Injected Load Per Router (flits/clock (%))', Y_Title=>'Latency Standard Deviation (clock)', Z_Title=>undef},
	#{ type=>"3D_bar",  page_num=>1, graph_name=> "Received", result_name => "packet_rsvd_result", X_Title=>'Core ID' , Y_Title=>'Received Packets Per Router', Z_Title=>undef},
	#{ type=>"3D_bar",  page_num=>1, graph_name=> "Sent", result_name => "packet_sent_result", X_Title=>'Core ID' , Y_Title=>'Sent Packets Per Router', Z_Title=>undef},
	
	);
	
	
	my $chart   =gen_multiple_charts  ($self,\@pages,\@charts,.3);
    return $chart;
	
}




sub show_paths_between_two_endps{
	my ($self,$info)= @_;
	my $table=def_table(20,20,FALSE);
	my $scrolled_win = new Gtk2::ScrolledWindow (undef, undef);	
	$scrolled_win->set_policy( "automatic", "automatic" );	
	my $row-=0;
	my $col=0;
	
	my $src = $self->object_get_attribute("SELECT_PATH","src");
	my $dst = $self->object_get_attribute("SELECT_PATH","dst");
	
	
	
	if(defined $src && defined $dst ){
		my $s= $self->object_get_attribute("$src","NAME");
		my $d= $self->object_get_attribute("$dst","NAME");		
		$table->attach (def_label("Select path between $s to $d" ),$col,$col+10,$row,$row+1,'fill','shrink',2,2);
		add_info(\$info,"get list of all paths between $s to $d \n") if (defined $info);
		$row=1;
		my ($ref1,$ref2)= get_all_paths_between_two_endps($self,$src, $dst);
		my @paths = @{$ref1};
		my @ports= @{$ref2};
		my $n=0;
		my $select = $self->object_get_attribute('Route',"${src}::$dst");
		foreach my $p (@paths){
			my $scal;
			my $selp;
			my $path_num=$n;
			my $path=$p;
			foreach my $q ( @{$p}){
				my $inst=$self->object_get_attribute("$q",'NAME');
				$scal= (defined $scal)? $scal."->$inst" : $inst;
			}
			
			foreach my $q ( @{$select}){
				my $inst=$self->object_get_attribute("$q",'NAME');
				$selp= (defined $selp)? $selp."->$inst" : $inst;
			}
			
				
			my $check= Gtk2::CheckButton->new();
			#print "if($select eq $path)";
			if(defined $select && defined $scal) {if($selp eq $scal) {$check->set_active(TRUE);}}
			else {$check->set_active(FALSE);}
			
			$check-> signal_connect("toggled" => sub{
				if($check->get_active()) {
					 
					$self->object_add_attribute('Route',"${src}::$dst",$path);
				}
				else {
					 
					$self->object_add_attribute('Route',"${src}::$dst",undef);
				}
				set_gui_status($self,"ref",1);
			});
			
			
			my $lable =gen_label_in_left("$scal");
			$table->attach ($check ,  $col, $col+1,$row,$row+1,'shrink','shrink',2,2); $col++;
			$table->attach ($lable ,  $col, $col+1,$row,$row+1,'shrink','shrink',2,2); $row++;$col=0;
			
			$n++;	
		}
		
		
	}
	
	$scrolled_win->add_with_viewport($table);
	return $scrolled_win;
}



##########
#	save
##########
sub save_network {
	my ($self)=@_;
	# read topology  name
	my $name=$self->object_get_attribute('save_as');	
	#print $name;
	my $s= (!defined $name)? 0 : (length($name)==0)? 0 :1;	
	if ($s == 0){
		message_dialog("Please set the topology name!");
		return 0;
	}
	# Write object file
	my $fname = "$name.NWM";
	open(FILE,  ">lib/netwmaker/$fname") || die "Can not open: $!";
	print FILE perl_file_header("$fname");
	print FILE Data::Dumper->Dump([\%$self],["nwmaker"]);
	close(FILE) || die "Error closing file: $!";
	message_dialog("Current network maker state is saved as lib/netwmaker/$fname!");
	return 1;
}

sub get_all_endp_ids{
	my $self=shift;
	my %e=  $self->object_get_attribute("E");
	my @list = sort keys %e;
	return @list;
	
}



#############
#    load
#############

sub load_net_maker{
    my ($self,$info)=@_;
    my $file;
    my $dialog = Gtk2::FileChooserDialog->new(
                'Select a File', undef,
                'open',
                'gtk-cancel' => 'cancel',
                'gtk-ok'     => 'ok',
            );

    my $filter = Gtk2::FileFilter->new();
    $filter->set_name("NETMAKER");
    $filter->add_pattern("*.NWM");
    $dialog->add_filter ($filter);
    my $dir = Cwd::getcwd();
    $dialog->set_current_folder ("$dir/lib/netwmaker")    ;
   
    if ( "ok" eq $dialog->run ) {
        $file = $dialog->get_filename;
        my ($name,$path,$suffix) = fileparse("$file",qr"\..[^.]*$");
        if($suffix eq '.NWM'){
            my ($pp,$r,$err) = regen_object($file );
            if ($r){        
                add_info(\$info,"**Error: cannot open $file file: $err\n");
                 $dialog->destroy;
                return;
            } 
            

            clone_obj($self,$pp);

                    
        }                    
     }
     $dialog->destroy;
     set_gui_status($self,"ref",1)
}







sub get_all_paths_between_two_endps{
	my ($self,$src, $dst)=@_;
	my @proceed_nodes;
	my @head_nodes;
	
	
	
	push (@head_nodes,$src);
	push (@proceed_nodes,$src);
	
	my @paths;
	my @ports;
	my @paths_to_dst;
	my @ports_to_dst;
	
	my @first_path=($src);
	my @first_port=(0);
	$paths[0]=\@first_path;
	$ports[0]=\@first_port;
	
	# select one path
	my $n=0;
	my $min_dist=1000000;
	do{	
		my @current_path= @{$paths[$n]};
		my @current_port= @{$ports[$n]};
		# get head node
		my $head_node = 	$current_path[-1];
		if(defined $head_node){
			# get connected nodes for all ports 
			#print "hn=$head_node\n";
			my $pnum =  $self->object_get_attribute($head_node,'PNUM');
			
			for (my $i=0;$i<$pnum; $i++){
				my @new_path=@current_path;
				my @new_ports=@current_port;
				my $src_port = "Port[${i}]";
		   	   	my $connect = $self->{$head_node}{'PCONNECT'}{$src_port};	
				if(defined $connect){
					my ($node,$pnode)=split(',',$connect);
					#add connected nodes to head_nodes if they are not in path before
					if(!defined get_scolar_pos($node,@new_path)){
						my $size=scalar @new_path;
						if ($min_dist > $size){
							push (@new_path,$node);
							push (@new_ports,$pnode);
							push (@paths,\@new_path);
							push (@ports,\@new_ports);						 
							if($node eq $dst){
								push(@paths_to_dst,\@new_path);
								push(@ports_to_dst,\@new_ports); 
								$min_dist=$size+1;
							} 
						}
					} #if
				}
			}#for
		}	
		$n++;
	}while( defined $paths[$n]);
	
	return (\@paths_to_dst,\@ports_to_dst);

}

sub get_turn_code {
	my $turn =shift;
	my ($pn1,$rn1,$pn2,$rn2)= sscanf( "ROUTER%u_%u::ROUTER%u_%u",$turn);
	my $code = ($rn1<<20)+ ($pn1<<16) +  ($rn2<< 4) +  $pn2;
	return $code;	
}

sub get_turn_str {
	my $code =shift;
	my $pn2  =  $code & 0xF;
	$code >>=4;
	my $rn2  = $code & 0xFFF;
	$code >>=12;
	my $pn1 =$code & 0xF;
	$code >>=4;
	my $rn1=$code;	
	return   "ROUTER${pn1}_${rn1}::ROUTER${pn2}_${rn2}";
}

sub get_turn_involved_routrs{
	my ($s1,$s2,$info)=@_;
	my ($r1,$ra2) = split /::/, $s1;
	my ($rb2,$r3) = split /::/, $s2;
	add_colored_info(\$info,"Error in turn format. $s1 -> $s2 : $ra2 should be equal with $rb2 ",'red') if($ra2 ne $rb2);
	return ($r1,$ra2,$r3);	
}

sub get_path_edges_graph_file{
	my (@a_nodes) = @_;	
	my $str1='';
	my $str2='';
	my $old_r;	
	foreach my $r (@a_nodes){
		
		if(defined $old_r){
			$str1 = $str1 ."$old_r $r\n" ;
			my $n1  = get_turn_code($old_r);
			my $n2  = get_turn_code($r); 
			$str2 = $str2 ."$n1 $n2\n";			
		}
		$old_r=$r;
	}
	return ($str1,$str2);
}	




sub get_forbiden_turns {
	
	my ($self,$info)=@_;
	my @forbiden_turn;
	add_info(\$info,"Calculate forbiden turns to avoid deadlock \n");
	#step 1: get the list of all  minimal paths between all source and destination pairs
	my $graph='';
	my $graph_coded='';
	my @all_endpoints=get_list_of_all_endpoints($self);
	foreach  my $src  (@all_endpoints ){	
		foreach  my $dst  (@all_endpoints ){
			if($src ne $dst){	
				my ($paths_to_dst,$ports_to_dst) = get_all_paths_between_two_endps($self,$src, $dst);
				foreach my $path (@{$paths_to_dst}) {
					if (defined $path){
						#path counting
						my @a_nodes= 	get_adjacent_router_in_a_path($path);
						my ($str1,$str2) = get_path_edges_graph_file (@a_nodes);
						$graph  =$graph. $str1;
						$graph_coded = $graph_coded . $str2;
					}#defined path	
				}#foreach	
			}#if			
		}#froeach				
			
	}#froeach			
	my $tmp_dir  = "$ENV{'PRONOC_WORK'}/tmp";
	save_file ("$tmp_dir/paths_graph.edges",$graph);
	save_file ("$tmp_dir/paths_graph_coded.edges",$graph_coded);
	
	
	#remove old files 
	my @files = File::Find::Rule->file()
                            ->name( 'paths_graph_coded_removed*.edges')
                            ->in( "$tmp_dir" );	
	foreach my $f (@files){
		unlink  $f if (-f "$f");		
	}			
	
	# run remove_cycle_edges_by_dfs on coded graph 
	my $remover_dire = get_project_dir()."/mpsoc/remove_cycle/";
	my $cmd  =  "cd $remover_dire; 
	python  break_cycles.py  -g $tmp_dir/paths_graph_coded.edges;
	python remove_cycle_edges_by_dfs.py -g $tmp_dir/paths_graph_coded.edges; 
	python remove_cycle_edges_by_minimum_feedback_arc_set_greedy.py  -g $tmp_dir/paths_graph_coded.edges";	
	#sort paths_graph_coded.edges | uniq > newfile.db
	
	my ($stdout,$exit,$stderr)=run_cmd_in_back_ground_get_stdout($cmd);
	if(length $stderr>1){			
		add_colored_info(\$info,"$stderr\n",'red');
	}else {
		add_info(\$info,"$stdout\n");
	}	
	# find the files with the list edges removal
	@files = File::Find::Rule->file()
                         ->name( 'paths_graph_coded_removed*.edges')
                         ->in( "$tmp_dir" );	
	
	                       
	my $line_num;
	my $out;
	foreach my $f (@files){
		my $n =count_file_line_num ($f);
		$line_num = $n if(! defined $line_num);
		if($n <= $line_num){
			$out = $f;
			$line_num=$n; 
		}		
	}			
	
	
	
	
	
			
	# check if the output file is generated 
	if (-f $out ){
		add_colored_info(\$info,"$out file has been selected as it has the minimum number of edfge removal of $line_num \n",'blue');
		
	} else {
		add_colored_info(\$info,"could not find a paths_graph_coded_removed*.edges file.  Please make sure $cmd has been run successfully\n",'red');
		return;
		
	}
	
	
	
	
	my $r;
	open my $fh, "<", $out or $r = "$!\n";
    if(defined $r) {
    	add_colored_info(\$info,"Could not open $out: $r",'red');
		return;
    } 
    
    add_colored_info(\$info,"List of forbidden turns: \n",'blue');
    
	while (my $line = <$fh>) {
    	chomp $line;
    	my ($s1,$s2) = split /\s/, $line;
        $s1  = get_turn_str($s1);  
  		$s2  = get_turn_str($s2);
  		my @turn = get_turn_involved_routrs($s1,$s2);
  		my $str = get_path_instance_string($self,\@turn);
  		my $string=join('->',@turn);
  		push (@forbiden_turn, $string);
  		add_info(\$info,"$str\n");  

  }
  return @forbiden_turn;
  
}
	
sub get_path_instance_string {
	my ($self,$path_ref)=@_;
	my @path = @{$path_ref};
	my @path_inst;
	foreach my $p (@path){
		push (@path_inst, $self->object_get_attribute("$p",'NAME'));	
		
	}
	my $string=join('->',@path_inst);
	return $string;
}	


sub remove_cycle_paths {
	my ($self,$info,$paths_ref, $fturn_ref)=@_;	
	my @free_paths;
	my @paths= @{$paths_ref};
	my @fturns= @{$fturn_ref};
	my $remove;
	
	
	
	foreach my $path (@paths) {
		my @p = @$path;
		my $turn;
		my $string=join('->',@p);
		#print "$string\n";	
		$remove=0;
		foreach my $t (@fturns){
			 if ($string =~ /$t/){
			 	$remove=1;
			 	$turn=$t;
			 	last;
			 }
			 
		}
		push (@free_paths,$path) if($remove == 0);
		if($remove == 1){
			my @ft = split /->/, $turn; 
			add_info(\$info,"path ".get_path_instance_string($self,$path)." is removed due to turn ".get_path_instance_string($self,\@ft)."\n") 
		}
	}	
	return @free_paths;	
}	
	
	
	
	
	



sub auto_route {
	my ($self,$info)=@_;
	my %Psize;
	
	my @forbiden_turn =get_forbiden_turns ($self,$info);
	
	#step 1: calculate all minimal paths between all source and destination pairs
	add_info(\$info,"Calculate all minimal paths between all source and destination pairs\n");
	my @all_endpoints=get_list_of_all_endpoints($self);
	foreach  my $src  (@all_endpoints ){	
		foreach  my $dst  (@all_endpoints ){
			if($src ne $dst){	
				my ($paths_to_dst,$ports_to_dst) = get_all_paths_between_two_endps($self,$src, $dst);
				#step 2 get number of paths for each pair:
				my $size = scalar  @{$paths_to_dst};
				$Psize{"${src}::$dst"} = $size;
			}
		}
	}
	#step 2: Remove cyclic paths between all source and destination pairs
	
	
	
	
	
	
	#step 3 sort source destination based on the number of paths
	my @keys = sort { $Psize{$a} <=> $Psize{$b} } keys(%Psize);
	for my $key ( @keys) {
		my $size=$Psize{$key};
		next if(defined $self->object_get_attribute('Route',$key));
		
       # print "($key)->($Psize{$key})\n";
        my ($src , $dst)=split ('::',$key);
        my ($paths_to_dst,$ports_to_dst) = get_all_paths_between_two_endps($self,$src, $dst);
        my @cyle_free_paths=remove_cycle_paths($self,$info,$paths_to_dst, \@forbiden_turn);
        my @sort_paths=sort_paths_based_on_link_usage($self,\@cyle_free_paths);
        my $path;
        my $n=0;
        foreach my $p (@sort_paths ){
        	if(check_cyclick_loop($self,$p)==0){
        		$path=$p;
        		last;
        	}  
        	$n++;      	
        }
        if(!defined $path){
        	set_gui_status($self,"ref",1);
        	add_colored_info(\$info,"Failed to find an acyclic routing paths for all nodes!\n",'red');
        	return FALSE ;
        	
        }
        
        $self->object_add_attribute('Route',$key,$path);
		
	}
	
	set_gui_status($self,"ref",1);
	add_colored_info(\$info,"The routeing function table is generated successfully!\n",'blue');
	return TRUE;
}	


sub clean_route {
	my ($self,$info)=@_;
	 
	my @all_endpoints=get_list_of_all_endpoints($self);
	foreach  my $src  (@all_endpoints ){	
		foreach  my $dst  (@all_endpoints ){						
        $self->object_add_attribute('Route',"${src}::$dst",undef);
		
	}}
	
	set_gui_status($self,"ref",1);
	add_colored_info(\$info,"The Routing function table is cleared!\n",'blue');
	return TRUE;
}	



sub average{
        my($data) = @_;
        if (not @$data) {
               return 0;
        }
        my $total = 0;
        foreach (@$data) {
                $total += $_;
        }
        my $average = $total / @$data;
        return $average;
}
sub stdev{
        my($data) = @_;
        if(@$data == 1){
                return 0;
        }
        my $average = &average($data);
        my $sqtotal = 0;
        foreach(@$data) {
                $sqtotal += ($average-$_) ** 2;
        }
        my $std = ($sqtotal / (@$data-1)) ** 0.5;
        return $std;
}

sub clone_hash{
	my $ref=shift;
	my %hash=%{$ref};
	my %copy;
	foreach my $p (keys %hash){
		if (defined $hash{$p}){	$copy{$p} =  $hash{$p};}
	}
	return %copy;
}

sub sort_paths_based_on_link_usage{
	my ($self,$paths_to_dst)=@_;
	
	my %L_num;
	my %max;
	my @all_endpoints=get_list_of_all_endpoints($self);
	#get link count
	foreach  my $src  (@all_endpoints ){	
		foreach  my $dst  (@all_endpoints ){	
			my $path = $self->object_get_attribute('Route',"${src}::$dst");
			if (defined $path){
				#path counting
				my @p= 	get_adjacent_router_in_a_path($path);
				foreach my $r (@p){				
					$L_num{$r} ++;						
				}	
			
			}			
		}
	}
	#get std_devision of link  foreach path if added   
	my $i=0;
	foreach my $path (@{$paths_to_dst}) {
		my %copy = clone_hash(\%L_num);
		my @p=get_adjacent_router_in_a_path($path);	
		foreach my $r (@p){				
					$copy{$r} ++;						
		}				
		my @l = sort  values (%copy);
		my $std=stdev(\@l);		
		$max{$i}=$std;
		$i++;	
	}
	
	
	my @order = sort { $max{$b} <=> $max{$a} } keys(%max);
	
	#print "*********** @order ************"; 
	my @sorted;
	$i=0;
	foreach my $a ( @order){
		$sorted[$i]=${$paths_to_dst}[$a];
		#print "\$max{$a}=$max{$a},"
	}
	
	#print "\n";
	
	return @sorted;
	#return @{$paths_to_dst};#TODO sort based on congestion	
	
}

sub check_cyclick_loop{
	my ($self,$paths_to_dst)=@_;
	
	
	my %graph;
	my @all_endpoints=get_list_of_all_endpoints($self);
	# create routing dependency graph
	
	foreach  my $src  (@all_endpoints ){	
		foreach  my $dst  (@all_endpoints ){	
			my $path = $self->object_get_attribute('Route',"${src}::$dst");
			if (defined $path){
				#path counting
				my @p= 	get_adjacent_node_in_a_path($path);
				%graph=add_route_edge_to_graph(\%graph,\@p);
			
			}			
		}
	}
	
	my @p= 	get_adjacent_node_in_a_path($paths_to_dst);
	%graph=add_route_edge_to_graph(\%graph,\@p);
	
	my $result = Algorithm::TSort::cicle_detect( Algorithm::TSort::Graph( ADJ => \%graph ), keys %graph ); 
	
	#print Data::Dumper->Dump([\%graph],["link"]);
	#print "result=$result\n";
	
	
	
	
	
	
	
	return  $result;
	
	
}

sub generate_topology{
	my ($self,$info)=@_;
	my $name=$self->object_get_attribute('save_as');
    my $error = check_verilog_identifier_syntax($name);
    if ( defined $error ){
        #message_dialog("The \"$name\" is given with an unacceptable formatting. The mpsoc name will be used as top level verilog module name so it must follow Verilog identifier declaration formatting:\n $error");
        my $message = "The \"$name\" is given with an unacceptable formatting. The topology name will be used as top level verilog module name so it must follow Verilog identifier declaration formatting:\n $error";
        add_colored_info(\$info, $message,'red' );
        return 0;
    }
	#make destination dir
	my $dir =get_project_dir()."/mpsoc/src_topolgy/$name";
	mkpath("$dir",1,01777) unless (-d $dir) ;  

	#generate topology top module verilog file
	generate_topology_top_v($self,$info,$dir);
	generate_topology_top_genvar_v($self,$info,$dir);
	generate_routing_v($self,$info,$dir);
	generate_connection_v($self,$info,$dir);
	add_routing_instance_v($self,$info,$dir);
	
	
}




sub build_network_maker_gui {
	my ($self) = @_;
	set_gui_status($self,"ideal",0);
	$self->object_add_attribute ("process_notebook","currentpage",0);
	my $main_table= def_table(2,10,FALSE);
	my ($scwin_info)= create_text();	
	# The box which holds the info, warning, error ...  mesages
    my ($infobox,$info)= create_text();
	my $notebook = topology_maker_notebook($self,$info);
	my $draw=gen_right_paned($self);
	my $h1=gen_hpaned($notebook,.35,$draw);
	
	
	my $v2=gen_vpaned($h1,.65,$infobox);
	
	
#	my $h1=gen_hpaned($traces_ctrl,.25,$traces);
#	my $h2=gen_hpaned($map_ctrl,.25,$map);
#	my $h3=gen_hpaned($h2,.65,$map_info);

	#my $v1=gen_vpaned($h1,.3,$h3);
	#my $v2=gen_vpaned($v1,.6,$scwin_info);
	
	my $generate = def_image_button('icons/gen.png','Generate');
	my $open = def_image_button('icons/browse.png','Load');	
	
	
	my ($entrybox,$entry) = def_h_labeled_entry('Topology name:',undef);
	
	$entry->signal_connect( 'changed'=> sub{
		my $name=$entry->get_text();
		$self->object_add_attribute ("save_as",undef,$name);	
	});	
	
	
	
	my $save = def_image_button('icons/save.png','Save');
	$entrybox->pack_end($save,   FALSE, FALSE,0);

	$main_table->attach_defaults ($v2  , 0, 12, 0,24);
	$main_table->attach ($open,0, 3, 24,25,'expand','shrink',2,2);
	$main_table->attach ($entrybox,3, 5, 24,25,'expand','shrink',2,2);
	
	$main_table->attach ($generate, 6, 9, 24,25,'expand','shrink',2,2);
	

	my $sc_win = new Gtk2::ScrolledWindow (undef, undef);
	$sc_win->set_policy( "automatic", "automatic" );
	$sc_win->add_with_viewport($main_table);
	
	
	#setting for graphs
	my $n=0;
    my $sample="sample$n";
	$n++;
	$self->object_add_attribute("id",undef,$n);
	$self->object_add_attribute("active_setting",undef,undef);
	$self->object_add_attribute_order("samples",$sample);
	$self->object_add_attribute($sample,"color",1);
	add_color_to_gd($self);
	
	
	$open-> signal_connect("clicked" => sub{ 
		
		
		
		load_net_maker($self,$info);
		my $n=0;
    my $sample="sample$n";
	$n++;
	$self->object_add_attribute("id",undef,$n);
	$self->object_add_attribute("active_setting",undef,undef);
	$self->object_add_attribute_order("samples",$sample);
	$self->object_add_attribute($sample,"color",1);
	add_color_to_gd($self);	
		
		
		set_gui_status($self,"ref",5);
	
	});	

	$save-> signal_connect("clicked" => sub{ 		
			
		save_network($self);		
		set_gui_status($self,"ref",5);
			
	
	});	
	
	$generate->signal_connect("clicked" => sub{ 
		generate_topology($self,$info);
	
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
		if($state eq "redraw"){
			$draw->destroy;
			$draw=gen_right_paned($self);
			$h1 -> pack2($draw, TRUE, TRUE);    
			
			#print "REDRAW\n";
			set_gui_status($self,"ideal",0);
			$main_table->show_all();	
			return TRUE;			 
		}
		if($state eq "ref"){
			
			$notebook->destroy;
			$notebook = topology_maker_notebook($self,$info);
			$h1 -> pack1($notebook, TRUE, TRUE); 
			
			$draw->destroy;
			$draw=gen_right_paned($self);
			$h1 -> pack2($draw, TRUE, TRUE);    
						
			my $saved_name=$self->object_get_attribute('save_as');
		    if(defined $saved_name) {$entry->set_text($saved_name);}
			set_gui_status($self,"ideal",0);
			$main_table->show_all();	
			
			return TRUE;
			 
		}
		
		
		#refresh GUI
		
											
		
		
		$main_table->show_all();			
		set_gui_status($self,"ideal",0);
		
		return TRUE;
		
	} );	



	return $sc_win;

	
	
}