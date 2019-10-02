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
	
	my %p;
	my $params_ref=$self->object_get_attribute('noc_param');
	if(defined $params_ref ){
		
		$p{'noc_param'}=$params_ref;	
	}	
	my $trace_gen= trace_gen_main('orcc',\%p);	

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
    			my $src_port=$fileds[1];
    			my $dest=$fileds[2];
    			my $dst_port=$fileds[3];
    			my $buff_Size=$fileds[4];
    			add_trace($self, "${net}:${f_id}:",$t_id, $src,$dest, 1,$file, $src_port,$dst_port,$buff_Size);	
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


sub genereate_output_orcc{
	my ($self,$tview)=@_;
	
	# Code each actor destination port
	my %dstp_number=get_destport_constant_list($self); 
	
	add_info($tview,"Generating source files\n");
	my @actors= get_all_tasks($self);
	foreach my $actor (@actors){
		my $transfer_str='';
		my $sink_str='';
		#each actor is mapped to one tile. we need to find all the the traces going in and out to this tile 
		#1- get the actor generated c file name:
		my $actor_file= get_actr_file_name($self,$actor);	   
		#2- where it mapped?
		my $actor_tile = $self->object_get_attribute("MAP_TILE",$actor);
		my $actor_tile_id=get_tile_id($self,$actor);
		#3- How many traces it transfers?
		my @injectors= get_all_source_traces_of_actr($self,$actor);
		#4- Where does it transffer?
		foreach my $inject (@injectors) {
				my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var,$src_port,$dst_port,$buff_size
				)=get_trace($self,$inject);
				my $dst_actor=$dst;
				my $dst_tile = $self->object_get_attribute("MAP_TILE",$dst_actor);
				my $dst_tile_id=get_tile_id($self,$dst_actor);
				#5-Now generate all transfer functions (add inject ports) 	
				my ($net,$num,$name)=split(':',$actor);	
				my $dstportnum = $dstp_number{$dst}{$dst_port};
				#print "dstp_number{$dst}{$dst_port}= $dstp_number{$dst}{$dst_port};\n";
				
				$transfer_str=$transfer_str."
			
	if(index_${src_port} > ${name}_${src_port}->read_inds[0]){
			//${name}_${src_port} FiFo has some data to be sent   
			int send_data_${src_port} = transfer_manage (1, 0, 0,0, $dstportnum ,(unsigned int)tokens_${src_port}[0],SIZE_${src_port}, 
			${name}_${src_port}->read_inds[0],  index_${src_port}, unsigned int dest_phy_addr,PHY_ADDR_ENDP_${dst_tile_id},1000);
						
			while (ni_send_is_busy(0));
			${name}_${src_port}->read_inds[0]= ${name}_${src_port}->read_inds[0]+send_data_${src_port};
			${name}_scheduler(x);		
					 
	}
				";
		}
		#6-Where from it receive packets?
		my @sinkers =   get_all_dest_traces_of_actr ($self,$actor);
		foreach my $sink (@sinkers){
			my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var,$src_port,$dst_port
				)=get_trace($self,$sink);				
				#7 We need to add sink ports 
				$sink_str=$sink_str."
				$actor sink packts via $dst_port port;
				"; 
				
			
		}
		
		
		
		
		add_colored_info($tview,"actor name: $actor\n",'green');
		
		add_info ($tview,"
		
		actor file name: $actor_file
		actor map dest: sw/tile${actor_tile_id}/main.c
		transffer function: $transfer_str
		sink function:$sink_str 		
		");
		
	}	
		
}


sub get_destport_constant_list{
	my ($self,$tview)=@_;
	my %destport_const;
	#1- Get list of all actors
	my @actors= get_all_tasks($self);
	foreach my $actor (@actors){
	
		my $i=1;
		#2- for each actor get the list of all input ports
		my @injectors= get_all_dest_traces_of_actr($self,$actor);
		#3- number each source port of this actor
		foreach my $inject (@injectors){
			
			my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var,$src_port,$dst_port,$buff_size
				)=get_trace($self,$inject);
			
			$destport_const{$actor}{$dst_port}= $i;
			#print "destport_const{$actor}{$dst_port}= $i;\n";
			$i++;
		}
	}	
	return %destport_const;
}


sub get_all_dest_traces_of_actr{
	my ($self,$actor)=@_;
	my @traces =get_trace_list($self);
	my @sources;
	foreach my $p (@traces){
		my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var)=get_trace($self,$p);
		push (@sources,$p) if($dst eq $actor);
	}
	return  @sources;	
}

sub get_all_source_traces_of_actr{
	my ($self,$actor)=@_;
	my @traces =get_trace_list($self);
	my @dests;
	foreach my $p (@traces){
		my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var)=get_trace($self,$p);
		push (@dests,$p) if($src eq $actor);
	}
	return  @dests;	
}	

sub get_actr_file_name {
	my ($self,$actor)=@_;
	my @traces =get_trace_list($self);
	foreach my $p (@traces){
		my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var)=get_trace($self,$p);
		if($src eq $actor || $dst eq $actor){
			#the actor supposed to be located next to CSV file and have the same file name as actor name
			my ($fname,$path,$suffix) = fileparse("$file_name",qr"\..[^.]*$");	
			my ($net,$num,$name)=split(':',$actor);
			return "$path/$name.c"; 
		}
	}
	return undef;
}

















1;