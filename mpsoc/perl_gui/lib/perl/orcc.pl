#!/usr/bin/perl -w
use Glib qw/TRUE FALSE/;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;


use String::Scanf; # imports sscanf()


sub select_orcc_generated_srcs {
	my ($self)=@_;
	my $window = def_popwin_size(80,80,"Geberate software using ORCC compiler",'percent');	
	#my $table = def_table(10, 10, FALSE);
	#$table->attach_defaults($infobox,0,20,$row,$row+1);
	my $trace_gen= trace_gen_main('orcc');	

	$window->add ($trace_gen);
	$window->show_all();
	
	return;
	my $table;
	
	
	
	
	$self->object_add_attribute("file_id",undef,0);
	$self->object_add_attribute("trace_id",undef,0);
	
	
	
	
	
	my $col=0;
	my $row=0;
	my $add = def_image_button('icons/import.png',"Load");
	set_tip($add,'Select ORCC generated CSV file');
	
	
	$table->attach($add,$col,$col+1,$row,$row+1,'shrink','shrink',2,2);$col++;
    my ($infobox,$info)= create_text();   
    
    
    
    my $draw = def_image_button('icons/diagram.png');
	set_tip($draw,'View Actor Connection Graph');
	$table->attach($draw,$col,$col+1,$row,$row+1,'shrink','shrink',2,2);$col++;
	$draw->signal_connect ( 'clicked'=> sub{
		show_trace_diagram($self,'trace');
	});
    $row++;
    $col=0;
    my $map=actor_map($self,$info);
	$table->attach_defaults($map,0,5,$row,$row+1);
	
	
	my $i;	
	for ($i=$row; $i<5; $i++){
		
		my $temp=gen_label_in_center(" ");
		$table->attach_defaults ($temp, 0, 6 , $i, $i+1);
	}
	$row=$i;	
	
	
	$col=5;
	my $next=def_image_button('icons/right.png','Next');
	$table->attach($next,$col,$col+1,$row,$row+1,'shrink','shrink',2,2);$col++;
	
	
	
	$add->signal_connect ( 'clicked'=> sub{
		
 		my $file;
        my $dialog = Gtk2::FileChooserDialog->new(
            	'Select the ORCC generated CSV File', undef,
            	'open',
            	'gtk-cancel' => 'cancel',
            	'gtk-ok'     => 'ok',
        	);
        	
        
        	my $filter = Gtk2::FileFilter->new();
			$filter->set_name("csv");
			$filter->add_pattern("*.csv");
			$dialog->add_filter ($filter);
		

        	if ( "ok" eq $dialog->run ) {
            		$file = $dialog->get_filename;
					load_orcc_csv($self,$file,\$info);
            }
       		$dialog->destroy;	
	});
	
	


}





sub load_orcc_file{
	my($self,$tview)=@_;
 		my $file;
        my $dialog = Gtk2::FileChooserDialog->new(
            	'Select a File', undef,
            	'open',
            	'gtk-cancel' => 'cancel',
            	'gtk-ok'     => 'ok',
        	);
        	
        	my $filter = Gtk2::FileFilter->new();
			$filter->set_name("csv");
			$filter->add_pattern("*.csv");
			$dialog->add_filter ($filter);
		

        	if ( "ok" eq $dialog->run ) {
            		$file = $dialog->get_filename;
					load_orcc_csv($self,$file,\$tview);
            }
       		$dialog->destroy;	
}





sub load_orcc_csv{
	my ($self,$file,$info)=@_;		

	add_info($info,"Use $file for generating actors network\n");
	unless (-e $file){
		add_colored_info($info,"Cannot find $file\n",'red');
		return;
	} 	
	
	my $f_id=$self->object_get_attribute("file_id",undef);
	my $t_id=$self->object_get_attribute("trace_id",undef);
		
	open my $in, "<:encoding(utf8)", $file or die "$file: $!";
	my $sect=0;
	my $net;
	my @actors;
	
	while (my $line = <$in>) {
    	chomp $line;
    	$line =~ s/[^\S\n]+//g; #remove space
    	
    	if ($line =~ /Name,Package,Actors,Connections/){
    		$sect=1;
    		next;	
    	}
    	if ($line =~ /Name,Incoming,Outgoing,Inputs,Outputs/){
    		$sect=2;
    		next;	
    	}
    	if ($line =~ /Source,SrcPort,Target,TgtPort/){
    		$sect=3;
    		next;	
    	}
    	if($sect==1){
    		my @fileds=split(',',$line);
    		if(defined $fileds[0]){$net=$fileds[0] if($fileds[0]=~/^\w/);}
    	}
    	if($sect==2){
			my @fileds=split(',',$line);
			if(defined $fileds[0]){ push(@actors,$fileds[0]) if($fileds[0]=~/^\w/);}
    	}
    	if($sect==3){
    		my @fileds=split(',',$line);
    		if(defined $fileds[0]){
    			my $src=$fileds[0];
    			my $dest=$fileds[2];
    			add_trace($self, "${net}(${f_id})-",$t_id, $src,$dest, 1,$file );	
    			$t_id++;
    		}
    		
    	}		
    	$self->set_gui_status('ref',0);
    	
	}	
	
	my $num=scalar @actors;
	if($num==0){
		add_colored_info($info,"Could not find any actor in $file\n",'red');
		return;
	}
	add_info($info,"total of $num acotrs have found:\n\t");
	my $n=1;
	foreach my $act (@actors){
		add_colored_info($info,"$n-$act ",'blue');
		$n++;
	}
	add_info($info,"\n");
	
	$f_id++;
	$self->object_add_attribute("trace_id",undef,$t_id);
	$self->object_add_attribute("file_id",undef,$f_id);
	
	
	
}







sub actor_map {
	my ($self,$tview)=@_;
		
	
	
	my ($NE, $NR, $RAw, $EAw, $Fw)=get_topology_info($self);
    my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
 
    
    my $dim_y = floor(sqrt($NE));

	
 
    my	$table=def_table($NE%8,$NE/8,FALSE);#    my ($row,$col,$homogeneous)=@_;
      	for (my $i=0; $i<$NE;$i++){
    		my $tile=get_tile($self,$i);
    		my $y= int($i/$dim_y);
    		my $x= $i % $dim_y;    		
	        $table->attach_defaults ($tile, $x, $x+1 , $y, $y+1);
    	}
    my $sc_win = gen_scr_win_with_adjst($self,'actor_map');
	$sc_win->add_with_viewport($table);	
    return $sc_win;

	
	
	
	
	
	
	
}






##############
#	create_tree 
##############
sub get_list_of_nets {
	my $self=shift;
	my @traces= get_trace_list($self);
	my %f;
    foreach my $p (@traces) {	
		my ($src,$dst, $Mbytes, $file_id, $file_name)=get_trace($self,$p);
		$f{$file_id}=1;	
	}
	
	my @list = sort keys %f;
	return @list;
}

















1;