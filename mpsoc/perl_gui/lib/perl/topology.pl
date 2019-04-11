#!/usr/bin/perl -w

#this fle contains NoC topology related subfunctions

use Glib qw/TRUE FALSE/;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;


sub get_topology_info {
	my ($self) =@_;
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	my $T1=$self->object_get_attribute('noc_param','T1');
	my $T2=$self->object_get_attribute('noc_param','T2');
	my $T3=$self->object_get_attribute('noc_param','T3');
	my $V = $self->object_get_attribute('noc_param','V');
	my $Fpay = $self->object_get_attribute('noc_param','Fpay');
	
	my $NE; # number of end points
	my $NR; # number of routers
	my ($RXw,$RYw); # routers address width
	my ($EXw,$EYw); # Endpoints address width
	
	
	my $Fw = 2+$V+$Fpay; 
	if($topology eq '"TREE"') {
		my $K =  $T1;
        my $L =  $T2;
        $NE = powi( $K,$L );
        $NR = sum_powi ( $K,$L );
        my $Kw=log2($K);
        my $LKw=$L*$Kw;
        my $Lw=log2($L);  
        $RXw=$LKw;  
        $RYw=$Lw;   
        $EXw = $LKw; 
        $EYw = $Lw;   
	
	}elsif($topology eq '"FATTREE"') {
		my $K =  $T1;
        my $L =  $T2;
		$NE = powi( $K,$L );
        $NR = $L * powi( $L , $L - 1 );
        my $Kw=log2($K);
        my $LKw=$L*$Kw;
        my $Lw=log2($L);  
        $RXw=$LKw;  
        $RYw=$Lw;   
        $EXw = $LKw; 
        $EYw = $Lw;       
		
	}elsif ($topology eq '"RING"' || $topology eq '"LINE"'){
		my $NX=$T1;
		my $NY=1;
		my $NZ=$T3;
		$NE = $NX*$NY*$NZ;
        $NR = $NX*$NY;    
        my $Xw=log2($NX);
        my $Yw=log2($NY);        
        $RXw =$Xw; 
        $RYw =$Yw;   
        $EXw =$Xw; 
        $EYw =$Yw;
		
       
	}else {#mesh torus
		my $NX=$T1;
		my $NY=$T2;
		my $NZ=$T3;
		$NE = $NX*$NY*$NZ;
		$NR = $NX*$NY;    
        my $Xw=log2($NX);
        my $Yw=log2($NY);        
        $RXw =$Xw; 
        $RYw =$Yw;   
        $EXw =$Xw; 
        $EYw =$Yw;        
	}	
		
	return ($NE, $NR, $RXw, $RYw, $EXw, $EYw, $Fw); 	
}


sub fattree_addrencode {
	my ( $pos, $k, $l)=@_;
	my  $pow; my $ tmp;
	my $addrencode=0;
	my $kw=log2($k);
	$pow=1;
	for (my $i = 0; $i <$l; $i=$i+1 ) {
		$tmp=int($pos/$pow);
		$tmp=$tmp % $k;
		$tmp=$tmp<<($i)*$kw;
		$addrencode=$addrencode | $tmp;
		$pow=$pow * $k;
	}
	 return $addrencode;
}

sub fattree_addrdecode{
	my ($addrencode, $k, $l)=@_;
	my $kw=0;
	my $mask=0;
	my $pow; my $tmp;
	my $pos=0;
	while((0x1<<$kw) < $k){
		$kw++;
		$mask<<=1;
		$mask|=0x1;
	}
	$pow=1;
	for (my $i = 0; $i <$l; $i=$i+1 ) {
		$tmp = $addrencode & $mask;
		#printf("tmp1=%u\n",tmp);
		$tmp=($tmp*$pow);
		$pos= $pos + $tmp;
		$pow=$pow * $k;
		$addrencode>>=$kw;
	}
	return $pos;
}


sub get_ex_addr{
	my ($self,$num)=@_;
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	my $T1=$self->object_get_attribute('noc_param','T1');
	my $T2=$self->object_get_attribute('noc_param','T2');
	if($topology eq '"FATTREE"') {
		return fattree_addrencode($num, $T1, $T2);

	}else{#mesh_torus
		return $num % $T1;
	}
}

sub get_ry_addr {
	my ($self,$num)=@_;
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	my $T1=$self->object_get_attribute('noc_param','T1');
	my $T2=$self->object_get_attribute('noc_param','T2');
	if($topology eq '"FATTREE"') {
			return 0;
	}else{#mesh_torus
		return  int($num/$T1);
	}
}


sub get_rx_addr{
	my ($self,$num)=@_;
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	my $T1=$self->object_get_attribute('noc_param','T1');
	my $T2=$self->object_get_attribute('noc_param','T2');
	if($topology eq '"FATTREE"') {
		return fattree_addrencode(int($num/$T1), $T1, $T2);
	}else{#mesh_torus
		return $num % $T1;
	}
}

sub get_ey_addr {
	my ($self,$num)=@_;
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	my $T1=$self->object_get_attribute('noc_param','T1');
	my $T2=$self->object_get_attribute('noc_param','T2');
	if($topology eq '"FATTREE"') {
			return 0;
	}else{#mesh_torus
		return  int($num/$T1);
	}
}




sub get_router_num {
	my ($self,$x, $y)=@_;
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	my $T1=$self->object_get_attribute('noc_param','T1');
	my $T2=$self->object_get_attribute('noc_param','T2');
	if($topology eq '"FATTREE"') {
		return fattree_addrdecode($x, $T1, $T2);
	}else{
		 return ($y*$T1)+$x;		
	}
}



sub get_phy_addr{
	my ($self,$id)=@_;
	my ($NE, $NR, $RXw, $RYw, $EXw, $EYw)=get_topology_info($self);
	my $x=get_ex_addr($self,$id);
	my $y=get_ey_addr($self,$id);
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	if($topology eq '"FATTREE"' || $topology eq '"RING"' || $topology eq '"LINE"') {
		return $x;
	}
	my $phy = ($x << $EYw) + $y;	
	return $phy;
}	
	
	


sub get_noc_verilator_top_modules_info {
	my ($self) =@_;
	
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	my $T1=$self->object_get_attribute('noc_param','T1');
	my $T2=$self->object_get_attribute('noc_param','T2');
	
	my %tops;
	my %nr_p; # number of routers have $p port num
	my $router_p; #number of routers with different port number in topology 
	
	my ($ne,$nr) =get_topology_info($self);
	if($topology eq '"FATTREE"') {
		my $K =  $T1;
        my $L =  $T2;
		
        my $p2 = 2*$K;       
        $router_p=2;
        my $NRL= $ne/$K; #number of router in  each layer
        $nr_p{1}=$NRL;
        $nr_p{2}=$nr-$NRL;
        $nr_p{p1}=$K;
        $nr_p{p2}=2*$K;
       
        %tops = (
			"Vrouter1" => "router_verilator_p${K}.v", 
			"Vrouter2" => "router_verilator_p${p2}.v", 
	        "Vnoc" => "noc_connection.sv",
	 		
    	);
        
		
	}elsif ($topology eq '"RING"' || $topology eq '"LINE"'){
		
		$router_p=1;
		$nr_p{1}=$nr;
		$nr_p{p1}=3;
		%tops = (
			"Vrouter1" => "router_verilator_p3.v", 
	        "Vnoc" => "noc_connection.sv",
	 		
    	);
				
       
	}else {#mesh torus
		
        $router_p=1;
        $nr_p{1}=$nr;
        $nr_p{p1}=5;
        %tops = (
			"Vrouter1" => "router_verilator_p5.v", 
	        "Vnoc" => "noc_connection.sv",
	 		
    	);
        
	}
	
	my $includ_h="\n";
	for (my $p=1; $p<=$router_p ; $p++){
		 $includ_h=$includ_h."#include \"Vrouter$p.h\" \n";
	}
	for (my $p=1; $p<=$router_p ; $p++){
		 $includ_h=$includ_h."#define NR${p} $nr_p{$p}\n";
		 $includ_h=$includ_h."Vrouter${p}		*router${p}[ $nr_p{$p} ];   // Instantiation of router with   port number\n";
	}
	
	for (my $p=1; $p<=$router_p ; $p++){
		$includ_h=$includ_h."
		
	#define NE  $ne
 	#define NR  $nr
 	#define ROUTER_P_NUM $router_p
		
void router${p}_connect_to_noc (unsigned int r, unsigned int n){
	unsigned int j;
	int flit_out_all_size = sizeof(router${p}[0]->flit_out_all)/sizeof(router${p}[0]->flit_out_all[0]);
	router${p}[r]->current_r_addr	= noc->current_r_addr[n];
	router${p}[r]->neighbors_r_addr 	= noc->neighbors_r_addr[n];
	

	router${p}[r]->flit_in_we_all	= noc->router_flit_out_we_all[n];
	router${p}[r]->credit_in_all	= noc->router_credit_out_all[n];
	router${p}[r]->congestion_in_all	= noc->router_congestion_out_all[n];
	for(j=0;j<flit_out_all_size;j++)router${p}[r]->flit_in_all[j] 	= noc->router_flit_out_all[n][j];
		noc->router_flit_in_we_all[n]	=	router${p}[r]->flit_out_we_all ;
		noc->router_credit_in_all[n]	=	router${p}[r]->credit_out_all;
		noc->router_congestion_in_all[n]=	router${p}[r]->congestion_out_all;
	for(j=0;j<flit_out_all_size;j++) noc->router_flit_in_all[n][j]	= router${p}[r]->flit_out_all[j] ;	
}
";
	}
$includ_h=$includ_h."
void inline connect_all_routers_to_noc ( ){
	int i;
if(strcmp(TOPOLOGY ,\"FATTREE\")==0){
				
				for(i=0;i<NR1;i++) router1_connect_to_noc (i, i);
#if		ROUTER_P_NUM >1
				for(i=0;i<NR2;i++) router2_connect_to_noc (i, i+NR1);
#endif
				
			}else{
				for (i=0;i<NR1;i++) 	router1_connect_to_noc (i, i);						
			}
}

void Vrouter_new(){
	int i=0;
	for(i=0;i<NR1;i++)	router1[i] 	= new Vrouter1;             // root nodes
#if		ROUTER_P_NUM >1
	for(i=0;i<NR2;i++)	router2[i] 	= new Vrouter2;             // leaves
#endif

	
}

void inline connect_routers_reset_clk(){
	int i;

	for(i=0;i<NR1;i++) {
		router1[i]->reset= reset;
		router1[i]->clk= clk ;
	}
#if		ROUTER_P_NUM >1
	for(i=0;i<NR2;i++) {
		router2[i]->reset= reset;
		router2[i]->clk= clk ;
	}
#endif
}


void inline routers_eval(){
	int i=0;
	for(i=0;i<NR1;i++) router1[i]->eval();
#if		ROUTER_P_NUM >1
	for(i=0;i<NR2;i++) router2[i]->eval();
#endif
}

void inline routers_final(){
	int i;
	for(i=0;i<NR1;i++) router1[i]->final();
#if		ROUTER_P_NUM >1
		for(i=0;i<NR2;i++) router2[i]->final();
#endif
}	
	
	
";
	
	
	 return ($nr,$ne,$router_p,\%tops,$includ_h);	
}


sub gen_tiles_physical_addrsses_header_file{
	my ($self,$file)=@_;
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	my $txt = "#ifndef PHY_ADDR_H
	#define PHY_ADDR_H\n\n";
	
	#add phy addresses
	my ($NE, $NR, $RXw, $RYw, $EXw, $EYw)=get_topology_info($self);
	for (my $id=0; $id<$NE; $id++){
		my $phy= get_phy_addr($self,$id);	
		my $hex = sprintf("0x%x", $phy);
		$txt=$txt."\t#define PHY_ADDR_ENDP_$id  $hex\n";	
		
	}	
		
	
	$txt=$txt."#endif\n";
	save_file($file,$txt);		
}



1
