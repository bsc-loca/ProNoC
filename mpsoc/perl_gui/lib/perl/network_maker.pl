#!/usr/bin/perl
use strict;
use warnings;
use Glib qw(TRUE FALSE);
use Gtk2 '-init';
use Cwd 'abs_path';
use base 'Class::Accessor::Fast';
require "widget.pl"; 
require "diagram.pl";
use String::Scanf; # imports sscanf()



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





sub gen_right_paned {
	my ($self,$info) =@_;
	my $page_num=$self->object_get_attribute ("process_notebook","currentpage");
	
	return show_paths_between_two_endps($self,$info) if($page_num==3);
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
	$table->attach ($auto,0, 10,  $row, $row+1,'fill','fill',2,2);$row++;
	$table->attach (Gtk2::HSeparator->new,0, 200,  $row, $row+1,'fill','fill',2,2);$row++;	
	$table->attach (def_label(' source -> destination '),0,10,$row,$row+1,'fill','shrink',2,2);	$row++;	


	$auto-> signal_connect("clicked" => sub{
			auto_route($self,$info);	
	});
	

		
	my @all_endpoints=get_list_of_all_endpoints($self);
		
	foreach  my $src  (@all_endpoints ){	
		foreach  my $dst  (@all_endpoints ){	
			my $src_inst=$self->object_get_attribute("$src",'NAME');
			my $dst_inst=$self->object_get_attribute("$dst",'NAME');
		   	my $selected= $self->object_get_attribute("$src","PATH_TO_$dst");
		   	my $color =( defined $selected)? 0 :17;		   		   	
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
		my $selected= $self->object_get_attribute("$src","PATH_TO_$dst");
		if(defined $selected ) {$selected=undef if($selected> scalar (@paths));}
		foreach my $p (@paths){
			my $scal;
			my $path_num=$n;
			my $path=$p;
			foreach my $q ( @{$p}){
				my $inst=$self->object_get_attribute("$q",'NAME');
				$scal= (defined $scal)? $scal."->$inst" : $inst;
			}
			
				
			my $check= Gtk2::CheckButton->new();
			if(defined $selected) {if($selected == $path_num) {$check->set_active(TRUE);}}
			else {$check->set_active(FALSE);}
			
			$check-> signal_connect("toggled" => sub{
				if($check->get_active()) {
					$self->object_add_attribute("$src","PATH_TO_$dst",$path_num);
					$self->object_add_attribute('Route',"${src}::$dst",$path);
				}
				else {$self->object_add_attribute("$src","PATH_TO_$dst",undef);}
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
	# read emulation name
	my $name=$self->object_get_attribute('save_as');	
	#print $name;
	my $s= (!defined $name)? 0 : (length($name)==0)? 0 :1;	
	if ($s == 0){
		message_dialog("Please set a name!");
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
#    load_mpsoc
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











sub auto_route {
	my ($self,$info)=@_;
	my %Psize;
	
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
	#step 3 sort source destination based on the number of paths
	my @keys = sort { $Psize{$a} <=> $Psize{$b} } keys(%Psize);
	for my $key ( @keys) {
		my $size=$Psize{$key};
		next if(defined $self->object_get_attribute('Route',$key));
		
        print "($key)->($Psize{$key})\n";
        my ($src , $dst)=split ('::',$key);
        my ($paths_to_dst,$ports_to_dst) = get_all_paths_between_two_endps($self,$src, $dst);
        my @sort_paths=sort_paths_based_on_cngestion($self,$paths_to_dst);
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
		$self->object_add_attribute("$src","PATH_TO_$dst",$n);
	}
	
	set_gui_status($self,"ref",1);
	add_colored_info(\$info,"Route function is generated successfully!\n",'blue');
	return TRUE;
}	



sub sort_paths_based_on_cngestion{
	my ($self,$paths_to_dst)=@_;
	return @{$paths_to_dst};#TODO sort based on congestion	
	
}

sub check_cyclick_loop{
	my ($self,$paths_to_dst)=@_;
	return 0;
	
	
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
	
	
	my ($entrybox,$entry) = def_h_labeled_entry('Save as:',undef);
	
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
	
	
	
	$open-> signal_connect("clicked" => sub{ 
		
		load_net_maker($self,$info);
		set_gui_status($self,"ref",5);
	
	});	

	$save-> signal_connect("clicked" => sub{ 		
			
		save_network($self);		
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
		if($state eq "redraw"){
			$draw->destroy;
			$draw=gen_right_paned($self);
			$h1 -> pack2($draw, TRUE, TRUE);    
			
			print "REDRAW\n";
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
						
			print "ref\n";
			set_gui_status($self,"ideal",0);
			$main_table->show_all();	
			return TRUE;
			 
		}
		
		
		#refresh GUI
		my $saved_name=$self->object_get_attribute('save_as');
		if(defined $saved_name) {$entry->set_text($saved_name);}
											
		
		
		$main_table->show_all();			
		set_gui_status($self,"ideal",0);
		
		return TRUE;
		
	} );	



	return $sc_win;

	
	
}
