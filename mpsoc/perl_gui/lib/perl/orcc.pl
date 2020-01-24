#!/usr/bin/perl -w
use Glib qw/TRUE FALSE/;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;


use String::Scanf; # imports sscanf()


sub select_orcc_generated_srcs {
	my ($self)=@_;
	my $window = def_popwin_size(80,80,"Generate software using ORCC compiler",'percent');	
	#my $table = def_table(10, 10, FALSE);
	#$table->attach_defaults($infobox,0,20,$row,$row+1);
	
	#pass noc parameter to trace generator
	my %p;
	my $params_ref=$self->object_get_attribute('noc_param');
	if(defined $params_ref ){
		
		$p{'noc_param'}=$params_ref;	
	}
	#pass mpsoc name to trace genrator
	my $mpsoc_name=$self->object_get_attribute('mpsoc_name');
	$p{'mpsoc_name'}=$mpsoc_name;
	
	#pass soc names to trace genrator
	my ($NE, $NR, $RAw, $EAw, $Fw)=get_topology_info($self);	
    for (my $tile_num=0;$tile_num<$NE;$tile_num++){
        my ($soc_name,$num)= $self->mpsoc_get_tile_soc_name($tile_num);
        my $top=$self->mpsoc_get_soc($soc_name);
        my @nis=get_NI_instance_list($top);
        my $inst_name=$top->top_get_def_of_instance($nis[0],'instance');
        $p{'ni_name'}{$tile_num}=$inst_name; 
		$p{'soc_name'}{$tile_num}=$soc_name;
    }
    
    
    
        
    
    			
	my $trace_gen= trace_gen_main('orcc',\%p,$window);	

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
	
	my %channels;
	
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
    			$channels{"${src}:$src_port"}= (defined $channels{"${src}:$src_port"})? $channels{"${src}:$src_port"}+1 : 0;
    			
    			
    			add_trace($self, "${net}:${f_id}:",$t_id, $src,$dest, 1,$file, $src_port,$dst_port,$buff_Size,$channels{"${src}:$src_port"});	
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
	my ($self,$tview,$window)=@_;
	
	# Code each actor destination port
	my %dstp_number=get_destport_constant_list($self); 
	my %srcp_number=get_srcport_constant_list($self); 
	my %soc_names=%{$self->object_get_attribute('soc_name')};
    my %ni_names =%{$self->object_get_attribute('ni_name')};
   
	add_info($tview,"Generating source files\n");
	my @actors= get_all_tasks($self);
	foreach my $actor (@actors){
		my ($net,$num,$name)=split(':',$actor);
		
		my $actor_tile = $self->object_get_attribute("MAP_TILE",$actor);
		my $actor_tile_id=get_tile_id($self,$actor);
		
		my $soc_name=$soc_names{$actor_tile_id};
		my $ni_name=$ni_names{$actor_tile_id};
		
		
		my $schedul='';
		my $Hw_fifo_define='
static unsigned int credit_send_buff=0;
		' ;
		my $transfer_str='';
		my $sink_str='';
		my $crdit_update='';
		my %fifos;

		my $fifo_num=0;
		my $actors_str='';
		
		my $actor_got_pck_func= "
char ${name}_got_packet_funtion( unsigned char iport, unsigned int v){	
";
		my $actor_update_credit= "
char ${name}_update_credit (unsigned int credit_port,unsigned int credit_value){
";

		my $actor_check_pck_func= "
char ${name}_check_packet_funtion (unsigned char iport,unsigned int size){
";		
		my $got_pck_func= "
unsigned char iport_array[${ni_name}_NUM_VCs];
unsigned int credit_buff[${ni_name}_NUM_VCs];
	
void got_packet_funtion(void){
	unsigned int i ;
	unsigned char iport;
	for (i=0;i<${ni_name}_NUM_VCs;i++){
		if(${ni_name}_got_packet(i)) {
			iport =${ni_name}_RECEIVE_PRECAP_DATA_REG(i); 	
			if(iport==0){ //a credit update packet is recived;
				${ni_name}_receive (i, (unsigned int)& credit_buff[i] , 4, 0);	
			}else{
				${name}_got_packet_funtion(iport,i);
			}
			iport_array[i]=iport;
		}//If ${ni_name} got packet
	}//for	
}// got_packet_funtion
";	
		
		my $check_pck_func ="		
void check_packet_funtion(void){
	unsigned char iport;
	unsigned int i ,size ;
	unsigned int credit_value,credit_port;
	//struct SRC_INFOS  src_info;
	for (i=0;i<${ni_name}_NUM_VCs;i++){
		if(${ni_name}_packet_is_saved(i)) {
			//src_info=get_src_info(i);
			size=${ni_name}_RECEIVE_DATA_SIZE_REG(i); //size in byte
			iport= iport_array[i];
			if(iport==0){ // a credit update packet has been recived
				credit_port  = credit_buff[i] >> 16; //output port num
				credit_value = (credit_buff[i] & 0xFFFF)<<2; // credit value in byte
				${name}_update_credit(credit_port,credit_value);
			}else{	
				${name}_check_packet_funtion(iport,size);
			}
			
		}//If ${ni_name}_packet_is_saved
	}//for	
}// check_packet_funtion
				
";				
		#schedular function 
		
	    $schedul ="
			${name}_scheduler(&${name}.sched_func);"; 
		
		#each actor is mapped to one tile. we need to find all the the traces going in and out to this tile 
		#1- get the actor generated C file name:
		my $actor_file= get_actr_file_name($self,$actor);	   
		#2- where it mapped?
#		my $actor_tile = $self->object_get_attribute("MAP_TILE",$actor);
#		my $actor_tile_id=get_tile_id($self,$actor);
		#3- How many traces it transfers?
		my @injectors= get_all_source_traces_of_actr($self,$actor);
				
		
		#4- Where does it transffer?
		foreach my $inject (@injectors) {
				my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var,$src_port,$dst_port,$buff_size,$channel
				)=get_trace($self,$inject);
				my $dst_actor=$dst;
				my $dst_tile = $self->object_get_attribute("MAP_TILE",$dst_actor);
				my $dst_tile_id=get_tile_id($self,$dst_actor);
				#5-Now generate all transfer functions (add inject ports) 	
				my ($net,$num,$name)=split(':',$actor);	
				
				#print "dstp_number{$dst}{$dst_port}= $dstp_number{$dst}{$dst_port};\n";
				
	$fifos{"${name}_${src_port}"}{'size'}=$buff_size;	
	$fifos{"$name"}{'file'}="$file_name";
	#print  "\$fifos{\"$name\"}{'file'}=$file_name\n";
    #print "\$fifos (${name}_${src_port}'size'=${buff_size};\n";		
	
	if($channel==0){			
		$Hw_fifo_define=$Hw_fifo_define."	
//	transfer ${src_port} port definitions:		
#define ${src_port}_w  1
#define ${src_port}_v  0				
#define ${src_port}_class_num  0
#define ${src_port}_dest_port_num  $dstp_number{$dst}{$dst_port}
	
#define ${src_port}_queue_pointer (unsigned int)&tokens_${src_port}[0]
#define ${src_port}_queue_size_in_byte  (SIZE_${src_port} << ${name}_${src_port}_size_shift)	
#define ${src_port}_end_index   index_${src_port} 
#define ${src_port}_end_index_in_byte   (${src_port}_end_index << ${name}_${src_port}_size_shift)
#define ${src_port}_dest_phy_addr PHY_ADDR_ENDP_${dst_tile_id}

";
	}
	
	$Hw_fifo_define=$Hw_fifo_define."
// ${src_port} read channel ${channel}	definition
#define ${src_port}_ch${channel}_src_port_num   $srcp_number{$src}{$src_port}{$channel}
#define ${src_port}_ch${channel}_start_index ${name}_${src_port}->read_inds[$channel]
#define ${src_port}_ch${channel}_start_index_in_byte (${src_port}_ch${channel}_start_index << ${name}_${src_port}_size_shift)
#define ${src_port}_ch${channel}_has_data_to_send    (${src_port}_end_index > ${src_port}_ch${channel}_start_index)	
static unsigned int ${src_port}_ch${channel}_credit =  ${src_port}_queue_size_in_byte;	
";
				
				
				
	$transfer_str=$transfer_str."		
			
	if(${src_port}_ch${channel}_has_data_to_send){
			//ask NI to transfer the data   
			int send_data_${src_port} = transfer_manage (${src_port}_w, ${src_port}_v, ${src_port}_class_num,${src_port}_dest_port_num , ${src_port}_queue_pointer , ${src_port}_queue_size_in_byte, 
			${src_port}_ch${channel}_start_index_in_byte, ${src_port}_end_index_in_byte, ${src_port}_dest_phy_addr, ${src_port}_ch${channel}_credit  );
			while (${ni_name}_send_is_busy(${src_port}_v));
			${src_port}_ch${channel}_start_index= ${src_port}_ch${channel}_start_index+ (send_data_${src_port}>>${name}_${src_port}_size_shift);	
			${src_port}_ch${channel}_credit-=send_data_${src_port};					 
	}
	";
	
	
	
	$actor_update_credit =$actor_update_credit."	
	if( credit_port  == ${src_port}_ch${channel}_src_port_num){
		${src_port}_ch${channel}_credit = credit_value; //credit value in byte
		return 1;
	}	
";



	
	
	
		}# end inject
		
		
		
		
		#6-Where the packet come from? we need to update the sender with the remaining credit 
		my @sinkers =   get_all_dest_traces_of_actr ($self,$actor);
		foreach my $sink (@sinkers){
			my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var,$src_port,$dst_port,$buff_size,$channel
				)=get_trace($self,$sink);
				
			my $src_tile_id=get_tile_id($self,$src);
			my $srcportnum = $srcp_number{$src}{$src_port}{$channel};					
				#7 We need to add sink ports 
			
				
			#save the input  port index before running the credit	
			$schedul =	"
			index_${dst_port}_sender=index_$dst_port;$schedul";
		
	
			
	$Hw_fifo_define=$Hw_fifo_define."
//	Receiver port  ${dst_port} port definitions:
static unsigned int index_${dst_port}_sender; 

#define ${dst_port}_credit_w  1
#define ${dst_port}_credit_v  0   //Alternatively it can be another VC				
#define ${dst_port}_credit_class_num  0 //Alternatively it can be another class
#define ${dst_port}_credit_dest_port  0 //0 is rec=served for credit
#define ${dst_port}_credit_pointer (unsigned int)&credit_send_buff
#define ${dst_port}_credit_size_in_byte  4
#define ${dst_port}_credit_start_index  0
#define ${dst_port}_credit_end_index_in_byte   4
#define ${dst_port}_credit_dest_phy_addr PHY_ADDR_ENDP_${src_tile_id}
#define ${dst_port}_has_credit_to_send    (index_$dst_port > index_${dst_port}_sender)
#define ${dst_port}_src_port_num  $srcportnum
#define ${dst_port}_dst_port_num  $dstp_number{$dst}{$dst_port}
#define ${dst_port}_queu_pointer (unsigned int)&tokens_${dst_port}[0]
#define ${dst_port}_queue_size_in_byte  (SIZE_${dst_port} << ${name}_${dst_port}_size_shift)	
#define ${dst_port}_start_index_in_byte	((${name}_${dst_port}->write_ind % SIZE_${dst_port})<< ${name}_${dst_port}_size_shift)
";
			
			
	$crdit_update=$crdit_update."
	
	if( ${dst_port}_has_credit_to_send){
			credit_send_buff= ((${dst_port}_src_port_num <<16) |  (SIZE_$dst_port-(numTokens_${dst_port} - index_${dst_port}) )); // most significent 16 bits ondicates the port, list  significent 16 bits are credit in word 
			if( transfer_manage (${dst_port}_credit_w, ${dst_port}_credit_v, ${dst_port}_credit_class_num, ${dst_port}_credit_dest_port, ${dst_port}_credit_pointer, ${dst_port}_credit_size_in_byte, ${dst_port}_credit_start_index, ${dst_port}_credit_end_index_in_byte, ${dst_port}_credit_dest_phy_addr, 5 ) ) index_${dst_port}_sender=index_${dst_port};
			while (${ni_name}_send_is_busy(${dst_port}_credit_v));
	} 			
	";
	
	$actor_got_pck_func=$actor_got_pck_func."
	if (iport == ${dst_port}_dst_port_num){	
		${ni_name}_receive (v, ${dst_port}_queu_pointer , ${dst_port}_queue_size_in_byte, ${dst_port}_start_index_in_byte);	
		return 1; 
	}				
";
	
	$actor_check_pck_func =$actor_check_pck_func."	
	if(iport==${dst_port}_dst_port_num){
		${name}_${dst_port}->write_ind = ${name}_${dst_port}->write_ind + (size >> ${name}_${dst_port}_size_shift);								
		return 1; 		
	}						
	";
	
	$fifos{"${name}_${dst_port}"}{'size'}=$buff_size;	
	$fifos{"$name"}{'file'}="$file_name";		
	#print  "\$fifos{\"$name\"}{'file'}=$file_name\n";
	#print "\$fifos ${name}_${dst_port}'size'=$buff_size;\n";	
	
				
			
		} #sink
		
$actor_got_pck_func=$actor_got_pck_func."
	return 0;
}	
";

$actor_check_pck_func=$actor_check_pck_func."
	return 0;
}	
";

$actor_update_credit =$actor_update_credit."	
	return 0;
}
";		
	
	
	my $ni_isr='
	
/*
transfer_manage
	w: initial weight
	v: Virtual channel number
	class_num: message class number
	dest_port: destination queue number
	queue_pointer: address in byte
	queue_size: queue size in byte
	start_index: start index byte number
	end_index:  end index byte number
	dest_phy_addr
	credit: Number of byte available in destination queue
*/



unsigned int  transfer_manage (unsigned int w, unsigned int v, unsigned int class_num, unsigned char dest_port, unsigned int queue_pointer,unsigned int queue_size, unsigned int start_index,  unsigned int end_index, unsigned int dest_phy_addr,unsigned int credit){
    
//printf ( "core:%u transfer_manage (w=%u, v=%u, c=%u, dest_port=%u, queue_pointer=%u, queue_size=%u,  start_index=%u, end_index=%u,dest_phy_addr=%u, credit=%u", COREID,
// w,  v,  class_num,  dest_port,  queue_pointer, queue_size,  start_index,  end_index,  dest_phy_addr, credit);
   

	unsigned int start_addr_pointer;
	unsigned int data_size;
';
	
$ni_isr=$ni_isr."
    if (${ni_name}_send_is_busy(v)) return 0 ; // if VC is busy sending previous packet do nothing
";

$ni_isr=$ni_isr.'
    unsigned int start_addr_in_Q = start_index % queue_size;
    start_addr_pointer = queue_pointer + start_addr_in_Q;

// printf("start_addr_pointer(%u) = queue_pointer(%u) + start_addr_in_Q(%u)\n)", start_addr_pointer , queue_pointer , start_addr_in_Q);

    data_size =  end_index-start_index;

    if(data_size> credit) data_size =  credit; // we dont want to send more data than the receiver credit

    if((start_addr_in_Q + data_size)> queue_size) data_size =  queue_size-start_addr_in_Q; // we only send data until end of the queque. The rest will be sent in next round starting from begining of the queue   
';

$ni_isr=$ni_isr."
	if(data_size>0) ${ni_name}_transfer (w, v, class_num, dest_port , start_addr_pointer, data_size, dest_phy_addr);

    return data_size;   
}	
	
	
	
	
void error_handelling_function(){
	unsigned int i;
	for (i=0;i<${ni_name}_NUM_VCs;i++){
			if(${ni_name}_ERROR_FLAGS_REG(i)){
				printf (\"Error in vc \%u\\n\",i);
				if(${ni_name}_ERROR_FLAGS_REG(i) & BUFF_OVER_FLOW_ERR) printf (\"The receiver allocated buffer size is smaller than the received packet size in core\%u\\n\",COREID);
				if(${ni_name}_ERROR_FLAGS_REG(i) & SEND_DATA_SIZE_ERR)  printf (\"the send data size is not set in core\%u\\n\",COREID);
				if(${ni_name}_ERROR_FLAGS_REG(i) & BURST_SIZE_ERR)	 printf (\" the burst size is not set in core%u\\n\",COREID);
				if(${ni_name}_ERROR_FLAGS_REG(i) & ILLEGAL_SEND_REQ)  printf( \"A new send request is received while the DMA is still busy sending previous packet in core\%u\\n\",COREID);
				if(${ni_name}_ERROR_FLAGS_REG(i) & CRC_MISS_MATCH)	    printf( \"CRC miss-matched in core\%u\\n\",COREID);
		 } 
	}
}	
	
	
	
void ${ni_name}_isr(void){
	//place your interrupt code here

	if( ${ni_name}_STATUS2_REG & ERRORS_ISR ){
		// An error ocure 
		error_handelling_function();
		${ni_name}_ack_errors_isr();
	}
	if( ${ni_name}_STATUS2_REG & SAVE_DONE_ISR ){
		//check which VC has finished saving the packet. This function must be called before got_packet_funtion
		check_packet_funtion();
		${ni_name}_ack_save_done_isr(); 
	}


	if( ${ni_name}_STATUS2_REG & GOT_PCK_ISR ){
		//check which VC got packet
		got_packet_funtion();
		${ni_name}_ack_got_pck_isr();
	}
	return;
}
	
	";
	
	my $actor_run="
void ${name}_run (void) { 
	//run schedular
	$schedul
		
	//check if input ports have credit update to send
	$crdit_update  
		
	//check if output port has data to send
	$transfer_str 		
}
";	
	my $main="	
int main(){
	general_int_init();
	general_int_add(${ni_name}_INT_PIN, ${ni_name}_isr, 0); //${ni_name}_INT_PIN
	// Enable ${ni_name} interrupt (its connected to inttruupt pin 0)
	general_int_enable(${ni_name}_INT_PIN);
	general_cpu_int_en();
	// hw interrupt enable function:
	// ${ni_name}_initial (burst_size,  errors_int_en,  send_int_en,  save_int_en,  got_pck_int_en)
	${ni_name}_initial (16,1,0,1,1); //enable the intrrupt when a packet is recived, saved or got any error
		
	while(1){
		${name}_run();
	}	
	return 0;
}		
			
";	

   my $r;
   my $mpsoc_name=$self->object_get_attribute('mpsoc_name');
   my $target_dir  = "$ENV{'PRONOC_WORK'}/MPSOC/$mpsoc_name";
   add_colored_info($tview,"actor name: $actor\n",'green');
   
   
  
   #copy orcc lib files
   my $target_orccdir= "$target_dir/sw/tile${actor_tile_id}/orcc";
   mkpath("$target_orccdir",1,0755);
   my $orcc_lib_dir = get_project_dir()."/mpsoc/src_c/orcc/lib";
   opendir(DIR,"$orcc_lib_dir") or $r= "$!\n";
   if(defined $r) {
    	add_colored_info($tview,"cannot open directory: $r",'red');
		return;
   } 
   foreach my $name (readdir(DIR))
   {
   	 # add_colored_info($tview,"copy ($orcc_lib_dir/$name,$target_dir/sw/tile${actor_tile_id}/);\n   ",'red');
   	  copy ("$orcc_lib_dir/$name","$target_orccdir/");    
   }
   
   #generate main.c  
   my $main_c = "$target_dir/sw/tile${actor_tile_id}/main.c";
   unlink $main_c; #delete old main.c file 
   
   my ($fname,$fpath,$fsuffix) = fileparse("$actor_file",qr"\..[^.]*$");
   my $target_actor_file="$target_orccdir/$fname.c";
   open my $fc, ">$target_actor_file" or $r = "$!\n";
   if(defined $r) {
    	add_colored_info($tview,"Could not open $target_actor_file to write: $r",'red');
		return;
   } 
   
   
   open my $fd, ">$main_c" or $r = "$!\n";
   if(defined $r) {
    	add_colored_info($tview,"Could not open $main_c to write: $r",'red');
		return;
   } 
   print $fd autogen_warning();
   print $fd get_license_header($main_c);   
   print $fc " // Generated from $actor_file\n";
  
   
   print $fc "   
#include \"../$soc_name.h\"
#include \"orcc_lib.h\"

extern unsigned int  transfer_manage (unsigned int w, unsigned int v, unsigned int class_num, unsigned char dest_port, unsigned int queue_pointer,unsigned int queue_size, unsigned int start_index,  unsigned int end_index, unsigned int dest_phy_addr,unsigned int credit);
    

";
  
   print $fd "   
#include \"$soc_name.h\"
#include \"orcc/orcc_lib.h\"
#include \"orcc/$fname.c\"
";
  my $origen_def="";
  my $origen_fuctions=""; 
   
   
	#read actor file name and remove unnesserly codes. comment every files start with #include and extern
	open my $fh, "<", $actor_file or $r = "$!\n";
    if(defined $r) {
    	add_colored_info($tview,"Could not open $actor_file: $r",'red');
		return;
    } 
	while (my $line = <$fh>) {
	    chomp $line;
	    $line = '//'.$line if( $line =~ /^\s*#include/); # comment every line start with #include
	    if( $line =~ /^\s*extern\s+/){
	    	 my $extern=0;
	    	 $line =~ s/\s+/ /g; # remove extra spaces
	    	 $line =~ s/^\s+//; #ltrim
	    	 	 
	    	 
	    	 
	    	 #fifo
	    	 my  ($type,$fifo_name) = sscanf("extern fifo_%s_t *%s;",$line);
	    	 if(defined $type){
	    	 	$extern=1;
	    	 	if (defined $fifos{$fifo_name}){
	    	 		#add fifo definition:
	    	 		my $size = $fifos{$fifo_name}{'size'};
	    	 		if(!defined $size ){
	    	 			$size = "$fifo_name";
	    	 			$size=~ s/^\s*${name}_//g;
	    	 			$size = "SIZE_$size";
	    	 		}
	    	 		$origen_fuctions= $origen_fuctions . " DECLARE_FIFO(${type}, $size, $fifo_num, 1);\n";
	    	 		$origen_fuctions= $origen_fuctions . " fifo_${type}_t *$fifo_name = &fifo_$fifo_num;\n  ";
	    	 		
	    	 		  	 		
	    	 		
	    	 		my $shift =
	    	 			($type eq "i8"  || $type eq "u8")  ? 0 :
	    	 			($type eq "i16" || $type eq "u16") ? 1 :
	    	 			($type eq "i32" || $type eq "u32") ? 2 :
	    	 			($type eq "i64" || $type eq "u64") ? 3 : "undef_type check orcc.pl";
	    	 			 
	    	 		$origen_def=$origen_def. "#define ${fifo_name}_size_shift  $shift \n";
	    	 		
	    	 		
	    	 		$fifo_num++;
	    	 	}else{
	    	 		#print Dumper(\%fifos);
	    	 		add_colored_info($tview,"Could not find $fifo_name in csv file\n",'red');	 	 		
	    	 			return;
	    	 	}		    	 	
	    	 }
	    	 
	    	 #connection_t
	    	 my  ($connect_name) = sscanf("extern connection_t %s;",$line);
	    	 if(defined $connect_name ){
	    	   $extern=1;
	    	   $origen_fuctions=$origen_fuctions. " connection_t $connect_name = {0, 0, 0, 0};// We dont need connection as they are done in hardware. just define to prevent error\n";
	    	 }
	    	 
	    	 
	    	 #actor_t
	    	 my  ($actor_name) = sscanf("extern actor_t %s;",$line);
	    	 if(defined $actor_name ){
	    	 	$extern=1;
	    	 	if (defined $fifos{"$actor_name"}{'file'}){
	    	 	#	print "===============================================================\n";
	    	 	#add actor definition
	    	 	#search in network.c file for actor definition
	    	 		my $csv=$fifos{"$actor_name"}{'file'};	
	    	 		my ($fname,$path,$suffix) = fileparse("$csv",qr"\..[^.]*$");	
	    	 		my $net= "$path/${fname}.c";
	    	 		
	    	 	    my @lines = get_line_have_string($net,"actor_t $actor_name",$tview);
	    	 	    if(defined $lines[0]){
	    	 	    	
	    	 	    	#print $fd "void ${actor_name}_initialize(schedinfo_t *);\n";
						#print $fd "void ${actor_name}_scheduler (schedinfo_t *);\n";	    	 	    	
	    	 	    	#print $fd "$lines[0]\n";
	    	 	    	$actors_str=$actors_str."$lines[0]\n";
	    	 	    }
	    	 	     	
	    	 	}
	    	 	
	    	 	
	    	 }
	    	 
	    	 $line= "//$line\n" ; # comment every files start with extern
	    	add_colored_info($tview,"The Auto generator does not know how to define this extern definition:\n $line \n",'red') if($extern == 0);
	    	$origen_fuctions = $origen_fuctions.  "$line\n";
	    }#extern
	    elsif( $line =~ /^\s?#define\s+/){
	    	$origen_def=$origen_def.  "$line\n";
	    }else{	
        	$origen_fuctions = $origen_fuctions.  "$line\n";
	    }

  }
		


print $fc "			
$origen_def

$Hw_fifo_define 


$origen_fuctions	

$actor_got_pck_func

$actor_update_credit

$actor_check_pck_func
	
$actors_str

$actor_run


";		
		

print $fd "	


			
         
		 
$got_pck_func      
		  
$check_pck_func       

$ni_isr



$main
		
";

  close($fc);
  close($fd);

 add_colored_info($tview,"$main_c file has been created successfully from $actor_file file \n",'blue');	
		
	}	#actor
	
	
	#done ask the user if he wants to close the auto generator window
	my $dialog = Gtk2::MessageDialog->new (my $w,
                                      'destroy-with-parent',
                                      'question', # message type
                                      'yes-no', # which set of buttons?
                                      "The source files have been generated successfully. Do you want to close the current window?");
  		my $response = $dialog->run;
  		if ($response eq 'yes') {
      			$window->destroy;
  		}
  		$dialog->destroy;
	
	

		
} #end sub



sub get_line_have_string{
	my ($file,$str,$tview)=@_;
	my $r;
	my @matches;
	open my $fh, "<", $file or $r = "$!\n";
    if(defined $r) {
    	add_colored_info($tview,"Could not open $file: $r",'red');
		return;
    } 
    while (my $line = <$fh>) {
	    chomp $line;
	    $line =~ s/\s+/ /g; # remove extra spaces
	    $line =~ s/^\s+//; #ltrim
	    if ($line =~ /$str/){
	    	push(@matches,$line);
	    }    
    	
    }
	return @matches;
}	

sub get_destport_constant_list{
	my ($self,$tview)=@_;
	my %destport_const;
	#1- Get list of all actors
	my @actors= get_all_tasks($self);
	foreach my $actor (@actors){
	
		my $i=1;
		#2- for each actor get the list of all input ports
		my @sinkers= get_all_dest_traces_of_actr($self,$actor);
		#3- number each source port of this actor
		foreach my $sink (@sinkers){
			
			my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var,$src_port,$dst_port,$buff_size
				)=get_trace($self,$sink);
			
			$destport_const{$actor}{$dst_port}= $i;
			#print "destport_const{$actor}{$dst_port}= $i;\n";
			$i++;
		}
	}	
	return %destport_const;
}




sub get_srcport_constant_list{
	my ($self,$tview)=@_;
	my %srcport_const;
	#1- Get list of all actors
	my @actors= get_all_tasks($self);
	foreach my $actor (@actors){
	
		my $i=1;
		#2- for each actor get the list of all output ports
		my @injectors= get_all_source_traces_of_actr($self,$actor);
		#3- number each source port of this actor
		foreach my $inject (@injectors){
			
			my ($src,$dst, $Mbytes, $file_id, $file_name,$init_weight,$min_pck, $max_pck,  $burst, $injct_rate, $injct_rate_var,$src_port,$dst_port,$buff_size,$channel
				)=get_trace($self,$inject);
			
			$srcport_const{$actor}{$src_port}{$channel}= $i;
			#print "destport_const{$actor}{$dst_port}= $i;\n";
			$i++;
		}
	}	
	return %srcport_const;
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