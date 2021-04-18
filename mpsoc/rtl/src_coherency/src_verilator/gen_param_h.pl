#!/usr/bin/perl -w
use FindBin;
use lib $FindBin::Bin;
use Scanf; # imports sscanf()




my $param_v   = $ARGV[0];
my $map_v = $ARGV[1]; 
my $traces_file =  $ARGV[2]; 

my ($topology,$T1,$T2,$T3,$rn);
my ($NE,$NR,$NL);

if(!defined $param_v){
	print "Error: the script needs parameter.v file as input\n";
	exit;
}

unless (-f $param_v){
	print "Could not find File $param_v\n";
	exit;
}

if(!defined $map_v){
	print "Error: the script needs topology_mapping.v file as input\n";
	exit;
}

unless (-f $map_v){
	print "Could not find File $map_v\n";
	exit;
}


if(!defined $traces_file){
	print "Error: the script needs trace_files.v file as input\n";
	exit;
}

unless (-f $traces_file){
	print "Could not find File $traces_file\n";
	exit;
}




sub load_file {
	my $file_path=shift;
	my $str;
	if (-f "$file_path") { 
				
		$str = do {
	    		local $/ = undef;
	    		open my $fh, "<", $file_path
			or die "could not open $file_path: $!";
	    		<$fh>;
		};

	}
	return $str;
}

sub capture_param_value{
	my ($param,$text)=@_;
	my @q =split  (/$param\s*=/,$text);
	#print "$q[1]\n";	
	my @p =split (/[,;]/,$q[1]);
	return $p[0];		  
}

sub save_file {
	my  ($file_path,$text)=@_;
	open my $fd, ">$file_path" or die "could not open $file_path: $!";
	print $fd $text;
	close $fd;	
}

sub remove_all_white_spaces($)
{
  my $string = shift;
  $string =~ s/\s+//g;
  return $string;
}

sub get_map_array{
	my ($nam,$map,$text)=@_;
	my @lines=split(/\n/, $text);
	my @array;
	foreach my $p (@lines){
		my ($l,$m)=sscanf("%u:$map=%u;",remove_all_white_spaces($p));		
		if(defined $l && defined $m) {
			$array[$l]=$m; 
		}
	}
	my $out="\tconst char $nam\[\] ={".join(',',  @array)."};\n";	
	return $out;
}

sub powi{ # x^y
	my ($x,$y)=@_; # compute x to the y
	my $r=1;
	for (my $i = 0; $i < $y; ++$i ) {
    	$r *= $x;
  	}
  return $r;
}





sub get_NE{
	
	if($topology eq "TREE") {
		my $K =  $T1;
        	my $L =  $T2;
        	$NE = powi( $K,$L );
		$NR = sum_powi ( $K,$L );	
		
        	 
	}elsif($topology eq "FATTREE") {
		my $K =  $T1;
		my $L =  $T2;
		$NE = powi( $K,$L );
		$NR = $L * powi( $K , $L - 1 );
        	 
        }elsif ($topology eq '"RING"' || $topology eq '"LINE"'){
		my $NX=$T1;
		my $NY=1;
		$NL=$T3;
		$NE = $NX*$NY*$NL;
		$NR = $NX*$NY;   
        	 
        }elsif ($topology eq '"MESH"' || $topology eq '"TORUS"' ) {
		my $NX=$T1;
		my $NY=$T2;
		$NL=$T3;
		$NE = $NX*$NY*$NL;
		$NR = $NX*$NY;  
       
	}	
	else{ #custom
		$NE= $T1; 
		$NR= $T2;				
	}
		
}


sub get_map_traces{
	my ($nam,$map,$text)=@_;
	my @lines=split(/\n/, $text);
	my @array;
	foreach my $p (@lines){
		my ($l,$m)=sscanf("%u:$map=%s;",remove_all_white_spaces($p));	
		#print " ($l,$m)=sscanf(\%u:$map=\%s;,remove_all_white_spaces($p))\n";		
		if(defined $l && defined $m) {
			$array[$l]=$m; 
		}
	}
	my $out="\tconst char * $nam\[\] ={".join(',', @array)."};\n";	
	return $out;
}


sub get_param_h{

	my @params=('REPEAT_NUM','DEBUG_EN','T1','T2','T3','T4','B','TOPOLOGY','ROUTE_NAME',
	'SYS_CACHE_EN','NUM_OF_RNs','NUM_OF_HNs','NUM_OF_SNs','SNPF_WAY_NUM','SNPF_ADDRw','SNPF_INDEXw',
	'CACHE_WAY_NUM','CACHE_INDEXw','WRAP_REQ_W','MEM_RD_PIPE_LATENCY','MEM_WR_PIPE_LATENCY');

	my $text = load_file($param_v);

	my $param_h="";
	
	foreach my $p (@params){
		my $v=capture_param_value($p,$text);
		$param_h = $param_h."\t#define\t$p\t$v\n";
		$topology =$v  if($p eq 'TOPOLOGY');
		$T1 =$v  if($p eq 'T1');
		$T2 =$v  if($p eq 'T2');
		$T3 =$v  if($p eq 'T3');
		$rn =$v  if($p eq 'NUM_OF_RNs');
	}

	$param_h=$param_h.get_trace_h();
	return $param_h;
}

sub get_trace_h{

	my $text = load_file($traces_file);
	return get_map_traces('TRACE_FILES','get_trace_file',$text);

}

sub get_mapping_info{

	my $param_h="\n";

	$text = load_file($map_v);
	$param_h.=get_map_array('RN_ID','gen_rn_endp_id',$text);
	$param_h.=get_map_array('HN_ID','gen_hn_endp_id',$text);
	$param_h.=get_map_array('SN_ID','gen_sn_endp_id',$text);
	$param_h.="\t//assigned snf id to each home node.\n";
	$param_h.=get_map_array('HN_SN_ID','gen_assigned_sn_enp_id_to_hn',$text);
	$param_h.=get_map_array('HN_LOC_SN','gen_hn_loc_in_sn',$text);	
	



	return  $param_h;

}

my $param_h="#ifndef PARAM_H
		#define PARAM_H

";

$param_h.=get_param_h();
$param_h.=get_mapping_info();
get_NE();
$param_h.="\t#define\tNE\t$NE\n";
$param_h.="\t#define\tNR\t$NR\n";
$param_h.="\t#define\tNL\t$NL\n";

$param_h.="\n#endif";



save_file ("parameter.h",$param_h);











