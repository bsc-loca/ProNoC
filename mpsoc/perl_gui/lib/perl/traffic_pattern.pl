#!/usr/bin/perl -w


sub getBit{
	my ($num, $b, $W)=@_;
	while($b<0) {$b=$b+$W; }
	$b=$b % $W;
	return ($num >> $b) & 1;
}

# number; b:bit location;  W: number width log2(num); v: 1 assert the bit, 0 deassert the bit; 
sub setBit{
	my ($num ,$b,$W,$v)=@_;
	while($b<0) {$b=$b+$W;}
	$b=$b % $W;
		
    my $mask = 1 << $b;
    if ($v == 0) {$$num  = $$num & ~$mask;} # assert bit
    else {$$num = $$num | $mask;} #deassert bit      
}

sub pck_dst_gen_2D {
	my ($self,$traffic,$core_num,$line_num,$rnd)=@_;
	my ($NE, $NR, $RAw, $EAw, $Fw)=get_topology_info($self);
	my $NEw=log2($NE);      
	#for mesh-tori
	my  ($current_l,$current_x, $current_y);
	my  ($dest_l,$dest_x,$dest_y);
	my $T1=$self->object_get_attribute('noc_param','T1');
	my $T2=$self->object_get_attribute('noc_param','T2');
	my $T3=$self->object_get_attribute('noc_param','T3');
	($current_x,$current_y,$current_l)=mesh_tori_addrencod_sep($core_num,$T1, $T2,$T3);

	if( $traffic eq "random") {				
		my @randoms=@{$rnd};		
		my $tmp = @{$randoms[$core_num]}[$line_num-1];
		return endp_addr_encoder($self,$tmp);			
	}
	
	if( $traffic eq "transposed 1"){
		 $dest_x = $T1-$current_y-1;
		 $dest_y = $T2-$current_x-1;
		 $dest_l = $T3-$current_l-1;
		 return mesh_tori_addr_join($dest_x,$dest_y,$dest_l,$T1, $T2,$T3);
	}

	if( $traffic eq "transposed 2"){
		$dest_x = $current_y;
		$dest_y = $current_x;
		$dest_l = $current_l;
		return mesh_tori_addr_join($dest_x,$dest_y,$dest_l,$T1, $T2,$T3);
	}

	if( $traffic eq "bit reverse"){
		#di = sb−i−1
		my $tmp=0;
		for(my $i=0; $i< $NEw; $i++) {setBit(\$tmp, $i, $NEw, getBit($core_num, $NEw-$i-1, $NEw));}
		return endp_addr_encoder($self,$tmp);		
	}

	if( $traffic  eq "bit complement") {
		my $tmp=0;
		for(my $i=0; $i< $NEw; $i++) {  setBit(\$tmp, $i, $NEw, getBit($core_num, $i, $NEw)==0)};
		return endp_addr_encoder($self,$tmp);
	}

	if( $traffic eq "tornado") {
		#[(x+(k/2-1)) mod k, (y+(k/2-1)) mod k],
			$dest_x = (($current_x + (int($T1/2)-1)) % $T1);
			$dest_y = (($current_y + (int($T2/2)-1)) % $T2);
			$dest_l = $current_l;
			return mesh_tori_addr_join($dest_x,$dest_y,$dest_l,$T1, $T2,$T3);
     }

    if($traffic eq "shuffle"){
		#di = si−1 mod b
		my $tmp=0;
		for(my $i=0; $i< $NEw; $i++) { setBit(\$tmp, $i, $NEw, getBit($core_num, $i-1, $NEw));}
		return endp_addr_encoder($self,$tmp);
     }

    if($traffic eq "bit rotation"){
		#di = si+1 mod b
		my $tmp=0;
		for(my $i=0; $i< $NEw; $i++) { setBit(\$tmp, $i, $NEw, getBit($core_num, $i+1, $NEw));}
		return endp_addr_encoder($self,$tmp);
     }

     if($traffic eq "neighbor"){
		#dx = sx + 1 mod k
		 $dest_x = ($current_x + 1) % $T1;
		 $dest_y = ($current_y + 1) % $T2;
		 $dest_l = $current_l;
		 return mesh_tori_addr_join($dest_x,$dest_y,$dest_l,$T1, $T2,$T3);
     }        
    
		 print ("$traffic is an unsupported traffic pattern\n");
		 $dest_x = $current_x;
		 $dest_y = $current_y;
		 $dest_l = $current_l;
		 return mesh_tori_addr_join($dest_x,$dest_y,$dest_l,$T1, $T2,$T3);
}




sub pck_dst_gen_1D {
	my ($self,$traffic,$core_num,$line_num,$rnd)=@_;
	my ($NE, $NR, $RAw, $EAw, $Fw)=get_topology_info($self);
	my $NEw=log2($NE);      
	    
	if( $traffic eq "random") {				
		my @randoms=@{$rnd};		
		my $tmp = @{$randoms[$core_num]}[$line_num-1];
		return endp_addr_encoder($self,$tmp);			
	}		
	
	if( $traffic eq "transposed 1"){
		  return endp_addr_encoder($self,$NE-$core_num-1);
	} 
	
	if( $traffic eq "transposed 2"){
		  return endp_addr_encoder($self,$NE-$core_num-1);
	} 	
	
	if( $traffic eq "bit reverse"){
		my $tmp=0;
		for(my $i=0; $i< $NEw; $i++) {setBit(\$tmp, $i, $NEw, getBit($core_num, $NEw-$i-1, $NEw));}
		return endp_addr_encoder($self,$tmp);		
	 } 
	 
	 if( $traffic  eq "bit complement") {
		my $tmp=0;
		for(my $i=0; $i< $NEw; $i++) {  setBit(\$tmp, $i, $NEw, getBit($core_num, $i, $NEw)==0)};
		return endp_addr_encoder($self,$tmp);
	}
	 
	if( $traffic eq "tornado") {
		#[(x+(k/2-1)) mod k, (y+(k/2-1)) mod k],
		 return endp_addr_encoder($self, ($core_num + (int($NE/2)-1)) % $NE);
     }

      if($traffic eq "shuffle"){
		#di = si−1 mod b
		my $tmp=0;
		for(my $i=0; $i< $NEw; $i++) { setBit(\$tmp, $i, $NEw, getBit($core_num, $i-1, $NEw));}
		return endp_addr_encoder($self,$tmp);
     }

    if($traffic eq "bit rotation"){
		#di = si+1 mod b
		my $tmp=0;
		for(my $i=0; $i< $NEw; $i++) { setBit(\$tmp, $i, $NEw, getBit($core_num, $i+1, $NEw));}
		return endp_addr_encoder($self,$tmp);
     }

     if($traffic eq "neighbor"){
		#dx = sx + 1 mod k
    	 return endp_addr_encoder($self,($core_num + 1) % $NE);
	 }     
     
	 printf ("$traffic is an unsupported traffic pattern\n");
	 return  endp_addr_encoder($self,$core_num);
}



sub pck_dst_gen{ 
	($self,$traffic,$core_num,$line_num,$rnd)=@_;
	my $topology=$self->object_get_attribute('noc_param','TOPOLOGY');
	return  pck_dst_gen_2D ($self,$traffic,$core_num,$line_num,$rnd) if(( $topology eq "MESH") ||( $topology eq "TORUS"));
	return  pck_dst_gen_1D ($self,$traffic,$core_num,$line_num,$rnd);
}

 1;       
    