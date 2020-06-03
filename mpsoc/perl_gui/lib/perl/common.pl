use strict;
use warnings;

use String::Similarity;
use Proc::Background;
use Time::HiRes qw( usleep ualarm gettimeofday tv_interval nanosleep  clock_gettime clock_getres clock_nanosleep clock stat );
use IO::CaptureOutput qw(capture qxx qxy);
use List::MoreUtils qw(uniq);
use POSIX qw(ceil floor);

use Cwd 'abs_path';
use Term::ANSIColor qw(:constants);
 
sub find_the_most_similar_position{
	my ($item ,@list)=@_;
	my $most_similar_pos=0;
	my $lastsim=0;
	my $i=0;
	# convert item to lowercase
	$item = lc $item;
	foreach my $p(@list){
		my $similarity= similarity $item, $p;
		if ($similarity > $lastsim){
			$lastsim=$similarity;
			$most_similar_pos=$i;
		}
		$i++;
	}
	return $most_similar_pos;
}




####################
#	 verilog file
##################


sub read_verilog_file{
	my @files            = @_;
	my %cmd_line_defines = ();
	my $quiet            = 1;
	my @inc_dirs         = ();
	my @lib_dirs         = ();
	my @lib_exts         = ();
	my $vdb = rvp->read_verilog(\@files,[],\%cmd_line_defines,
			  $quiet,\@inc_dirs,\@lib_dirs,\@lib_exts);

	my @problems = $vdb->get_problems();
	if (@problems) {
	    foreach my $problem ($vdb->get_problems()) {
		print STDERR "$problem.\n";
	    }
	    # die "Warnings parsing files!";
	}
	return $vdb;
}


sub verilog_file_get_ports_list{
	my ($vdb,$top_module)=@_;
	my @ports;
	
	foreach my $sig (sort $vdb->get_modules_signals($top_module)) {
	my ($line,$a_line,$i_line,$type,$file,$posedge,$negedge,
	 $type2,$s_file,$s_line,$range,$a_file,$i_file,$dims) = 
	   $vdb->get_module_signal($top_module,$sig);

		if($type eq "input" or $type eq "inout" or $type eq "output" ){
			push(@ports, $sig);
			
		}
	}
	return @ports;
}



sub get_ports_type{
	my ($vdb,$top_module)=@_;
	my %ports;
	
	foreach my $sig (sort $vdb->get_modules_signals($top_module)) {
	my ($line,$a_line,$i_line,$type,$file,$posedge,$negedge,
	 $type2,$s_file,$s_line,$range,$a_file,$i_file,$dims) = 
	   $vdb->get_module_signal($top_module,$sig);

		if($type eq "input" or $type eq "inout" or $type eq "output" ){
			$ports{$sig}=$type;
			
		}
	}
	return %ports;
}



sub get_ports_rang{
	my ($vdb,$top_module)=@_;
	my %ports;
	
	foreach my $sig (sort $vdb->get_modules_signals($top_module)) {
	my ($line,$a_line,$i_line,$type,$file,$posedge,$negedge,
	 $type2,$s_file,$s_line,$range,$a_file,$i_file,$dims) = 
	   $vdb->get_module_signal($top_module,$sig);

		if($type eq "input" or $type eq "inout" or $type eq "output" ){
		 
		
			
			$ports{$sig}=remove_all_white_spaces($range);
			
		}
	}
	return %ports;
}




sub get_param_list_in_order {
   my $ref =shift;
   return undef if (!defined $ref);
   my %param=%{$ref};
   my @array = sort keys %param;
   my $l= scalar @array;
   SCAN: {
   foreach my $i (0..($l-2)) {     
      my $str1=$array[$i];
      foreach my $j ($i+1..($l-1)) {
      my $str2=$array[$j];
       	if ($param{$str1} =~ /\b$str2\b/ ) {
      	
        my $tmp = $array[$i];
        $array[$i] =$array[$j];
	$array[$j]=$tmp;
        
        redo SCAN;
      }
    }
    }
  }

  return @array;
}



####################
#	 file
##################


sub append_text_to_file {
	my  ($file_path,$text)=@_;
	open(my $fd, ">>$file_path") or die "could not open $file_path: $!";
	print $fd $text;
	close $fd;
}




sub save_file {
	my  ($file_path,$text)=@_;
	open my $fd, ">$file_path" or die "could not open $file_path: $!";
	print $fd $text;
	close $fd;	
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

sub merg_files {
	my  ($source_file_path,$dest_file_path)=@_;
	local $/=undef;
  	open FILE, $source_file_path or die "Couldn't open file: $!";
  	my $string = <FILE>;
  	close FILE;
	 append_text_to_file ($dest_file_path,$string);	
}



sub copy_file_and_folders{
	my ($file_ref,$project_dir,$target_dir)=@_;

	foreach my $f(@{$file_ref}){
		my $name= basename($f);	
				
		my $n="$project_dir$f";
		if (-f "$n") { #copy file
			copy ("$n","$target_dir/$name"); 		
		}elsif(-f "$f" ){
			copy ("$f","$target_dir/$name");     			 	
		}elsif (-d "$n") {#copy folder
			dircopy ("$n","$target_dir/$name"); 		
		}elsif(-d "$f" ){
			dircopy ("$f","$target_dir/$name"); 		
    			 	
		}
	}

}


sub remove_file_and_folders{
	my ($file_ref,$project_dir)=@_;

	foreach my $f(@{$file_ref}){
		my $name= basename($f);				
		my $n="$project_dir$f";
		if (-f "$n") { #copy file
			unlink ("$n");
		}elsif(-f "$f" ){
			unlink ("$f");     			 	
		}elsif (-d "$n") {#copy folder
			rmtree ("$n");
		}elsif(-d "$f" ){
			rmtree ("$f");    			 	
		}
	}

}

sub read_file_cntent {
	my ($f,$project_dir)=@_;
	my $n="$project_dir$f";
	my $str;
	if (-f "$n") { 
				
		$str = do {
	    		local $/ = undef;
	    		open my $fh, "<", $n
			or die "could not open $n: $!";
	    		<$fh>;
		};

	}elsif(-f "$f" ){
		$str = do {
	    		local $/ = undef;
	    		open my $fh, "<", $f
			or die "could not open $f: $!";
	    		<$fh>;
		};
		
						 	
	}
	return $str;

}


sub check_file_has_string {
    my ($file,$string)=@_;
    my $r;
    open(FILE,$file);
    if (grep{/$string/} <FILE>){
       $r= 1; #print "word  found\n";
    }else{
       $r= 0; #print "word not found\n";
    }
    close FILE;
    return $r;
}

sub count_file_line_num {
    my ($file)=@_;
    open(FILE,$file);
    my $n=0;
    while (my $line = <FILE>) {
	   $n++;
	}
    close FILE;
    return $n;
}

sub set_path_env{
	my $project_dir	  = get_project_dir(); #mpsoc dir addr
	my $paths_file= "$project_dir/mpsoc/perl_gui/lib/Paths";
	#print "$paths_file\n";
	my $paths= do $paths_file;
	my $pronoc_work =object_get_attribute($paths,"PATH","PRONOC_WORK");	
	my $quartus = object_get_attribute($paths,"PATH","QUARTUS_BIN");
	my $vivado  = object_get_attribute($paths,"PATH","VIVADO_BIN");
	my $sdk     = object_get_attribute($paths,"PATH","SDK_BIN");
		
	my $modelsim = object_get_attribute($paths,"PATH","MODELSIM_BIN");
	$ENV{'PRONOC_WORK'}= $pronoc_work if( defined $pronoc_work);
	$ENV{'QUARTUS_BIN'}= $quartus if( defined $quartus);
	$ENV{'VIVADO_BIN'}= $vivado if( defined $vivado);
	$ENV{'SDK_BIN'}= $vivado if( defined $sdk);
	$ENV{'MODELSIM_BIN'}= $modelsim if( defined $modelsim);	
	
	if( defined $pronoc_work){if(-d $pronoc_work ){
			mkpath("$pronoc_work/emulate",1,01777) unless -d "$pronoc_work/emulate";
			mkpath("$pronoc_work/simulate",1,01777) unless -d "$pronoc_work/simulate";	
			mkpath("$pronoc_work/tmp",1,01777) unless -d "$pronoc_work/tmp";			
	}}
	
	#add quartus_bin to PATH linux envirement if it does not exist in PATH
	my $add;
	if( defined $quartus){
		my @q =split  (/:/,$ENV{'PATH'});
		my $p=get_scolar_pos ($quartus,@q);
		$ENV{'PATH'}= $ENV{'PATH'}.":$quartus" unless ( defined $p); 
		$add=(defined $add)? $add.":$quartus" : $quartus unless ( defined $p);
		
	}
	
	if( defined $vivado){
		my @q =split  (/:/,$ENV{'PATH'});
		my $p=get_scolar_pos ($vivado,@q);
		$ENV{'PATH'}= $ENV{'PATH'}.":$vivado" unless ( defined $p); 
		$add=(defined $add)? $add.":$vivado" : $vivado unless ( defined $p);
		
	}
	
	if( defined $sdk){
		my @q =split  (/:/,$ENV{'PATH'});
		my $p=get_scolar_pos ($sdk,@q);
		$ENV{'PATH'}= $ENV{'PATH'}.":$sdk" unless ( defined $p); 
		$add=(defined $add)? $add.":$sdk" : $sdk unless ( defined $p);
		   
	}
	if(defined $add){
		print GREEN, "Info: $add has been added to linux PATH envirement.\n",RESET,"\n";
		
	}
	
	
}



##############
#  clone_obj
#############

sub clone_obj{
	my ($self,$clone)=@_;
	
	foreach my $p (keys %$self){
		delete ($self->{$p});
	}
	foreach my $p (keys %$clone){
		$self->{$p}= $clone->{$p};
		my $ref= ref ($clone->{$p});
		if( $ref eq 'HASH' ){
			
			foreach my $q (keys %{$clone->{$p}}){
				$self->{$p}{$q}= $clone->{$p}{$q};	
				my $ref= ref ($self->{$p}{$q});
				if( $ref eq 'HASH' ){
				
					foreach my $z (keys %{$clone->{$p}{$q}}){
						$self->{$p}{$q}{$z}= $clone->{$p}{$q}{$z};	
						my $ref= ref ($self->{$p}{$q}{$z});
						if( $ref eq 'HASH' ){
							
							foreach my $w (keys %{$clone->{$p}{$q}{$z}}){
								$self->{$p}{$q}{$z}{$w}= $clone->{$p}{$q}{$z}{$w};	
								my $ref= ref ($self->{$p}{$q}{$z}{$w});
								if( $ref eq 'HASH' ){
									
							
									foreach my $m (keys %{$clone->{$p}{$q}{$z}{$w}}){
										$self->{$p}{$q}{$z}{$w}{$m}= $clone->{$p}{$q}{$z}{$w}{$m};	
										my $ref= ref ($self->{$p}{$q}{$z}{$w}{$m});
										if( $ref eq 'HASH' ){
											
											foreach my $n (keys %{$clone->{$p}{$q}{$z}{$w}{$m}}){
												$self->{$p}{$q}{$z}{$w}{$m}{$n}= $clone->{$p}{$q}{$z}{$w}{$m}{$n};	
												my $ref= ref ($self->{$p}{$q}{$z}{$w}{$m}{$n});	
												if( $ref eq 'HASH' ){
												
													foreach my $l (keys %{$clone->{$p}{$q}{$z}{$w}{$m}{$n}}){
														$self->{$p}{$q}{$z}{$w}{$m}{$n}{$l}= $clone->{$p}{$q}{$z}{$w}{$m}{$n}{$l};	
														my $ref= ref ($self->{$p}{$q}{$z}{$w}{$m}{$n}{$l});	
														if( $ref eq 'HASH' ){
														}
													}
												
												}#if														
											}#n
										}#if
									}#m							
								}#if
							}#w
						}#if
					}#z
				}#if
			}#q
		}#if	
	}#p
}#sub	


sub get_project_dir{ #mpsoc directory address
	my $dir = Cwd::getcwd();
	my @p=	split('/perl_gui',$dir);
    my $d	  = abs_path("$p[0]/../");
	return $d;
}

sub cut_dir_path{ 
	my ($dir,$folder_name) = @_;
	my @p=  split (/\/$folder_name\//,$dir);
	return $p[-1];
}


sub remove_project_dir_from_addr{
	my $file=shift;	
	my $project_dir	  = get_project_dir(); 
	$file =~ s/$project_dir//; 
	return $file;	
}

sub add_project_dir_to_addr{
	my $file=shift;
	my $project_dir	  = get_project_dir(); 
	return $file if(-f $file ); 
	return "$project_dir/$file";	
	
}

sub get_full_path_addr{
	my $file=shift;
	my $dir = Cwd::getcwd();
	my $full_path = "$dir/$file";	
	return $full_path  if -f ($full_path );
	return $file;
}

sub regen_object {
	my $path=shift;
	$path = get_full_path_addr($path);
	my $pp= eval { do $path };
	my $r= ($@ || !defined $pp);
	return ($pp,$r,$@);
}


################
#	general
#################

sub remove_not_hex {
	my $s=shift;
	$s =~ s/[^0-9a-fA-F]//g;
	return $s;	
}


sub  trim { my $s = shift;  $s=~s/[\n]//gs; return $s };

sub remove_all_white_spaces($)
{
  my $string = shift;
  $string =~ s/\s+//g;
  return $string;
}


sub check_scolar_exist_in_array{
	my ($value,$ref)=@_;
	my @array= @{$ref};
	if ( grep( /^\Q$value\E$/, @array ) ) {
	  return 1;
	}
	return 0
}

sub get_item_pos{#if not in return 0
		my ($item,@list)=@_;
		my $pos=0;
		foreach my $p (@list){
				#print "$p eq $item\n";
				if ($p eq $item){return $pos;}
				$pos++;
		}	
		return 0;
	
}	

sub get_scolar_pos{
	my ($item,@list)=@_;
	my $pos;
	my $i=0;
	foreach my $c (@list)
	{
		if(  $c eq $item) {$pos=$i}
		$i++;
	}	
	return $pos;	
}

sub get_pos{
        my ($item,@list)=@_;
        my $pos=0;
        foreach my $p (@list){
                #print "$p eq $item\n";
                if ($p eq $item){return $pos;}
                $pos++;
        }    
        return undef;
}    	

sub remove_scolar_from_array{
	my ($array_ref,$item)=@_;
	my @array=@{$array_ref};
	my @new;
	foreach my $p (@array){
		if($p ne $item ){
			push(@new,$p);
		}		
	}
	return @new;	
}

sub replace_in_array{
	my ($array_ref,$item1,$item2)=@_;
	my @array=@{$array_ref};
	my @new;
	foreach my $p (@array){
		if($p eq $item1 ){
			push(@new,$item2);
		}else{
			push(@new,$p);
		}		
	}
	return @new;	
}



# return an array of common elemnts between two input arays 
sub get_common_array{
	my ($a_ref,$b_ref)=@_;
	my @A=@{$a_ref};
	my @B=@{$b_ref};
	my @C;
	foreach my $p (@A){
		if( grep (/^\Q$p\E$/,@B)){push(@C,$p)};
	}
	return  @C;	
}

#a-b
sub get_diff_array{
	my ($a_ref,$b_ref)=@_;
	my @A=@{$a_ref};
	my @B=@{$b_ref};
	my @C;
	foreach my $p (@A){
		if( !grep  (/^\Q$p\E$/,@B)){push(@C,$p)};
	}
	return  @C;	
	
}


sub return_not_unique_names_in_array{
	my @array = @_;
	my %seen;
	my @r;
	foreach my $value (@array) {
  		if (! $seen{$value}) {
    		$seen{$value} = 1;
  		}else{
  			push(@r,$value);
  		}
	}
	return @r;
}


sub compress_nums{
	my 	@nums=@_;
	my @f=sort { $a <=> $b } @nums;
	my $s;
	my $ls;	
	my $range=0;
	my $x;	
	

	foreach my $p (@f){
		if(!defined $x) {
			$s="$p";
			$ls=$p;		
			
		}
		else{ 
			if($p-$x>1){ #gap exist
				if( $range){
					$s=($x-$ls>1 )? "$s:$x,$p": "$s,$x,$p";
					$ls=$p;
					$range=0;
				}else{
				$s= "$s,$p";
				$ls=$p;

				}
			
			}else {$range=1;}


		
		}
	
		$x=$p
	}
 	if($range==1){ $s= ($x-$ls>1 )? "$s:$x":  "$s,$x";}
	#update $s($ls,$hs);

	return $s;
	
}



sub metric_conversion{
	my $size=shift;	
	my $size_text=	$size==0	 ? 'Error': 
			$size<(1 << 10)? $size:
			$size<(1 << 20)? join (' ', ($size>>10,"K")) :
			$size<(1 << 30)? join (' ', ($size>>20,"M")) :
					 join (' ', ($size>>30,"G")) ;
return $size_text;
}





######
#  state
#####
sub set_gui_status{
	my ($object,$status,$timeout)=@_;
	$object->object_add_attribute('gui_status','status',$status);
	$object->object_add_attribute('gui_status','timeout',$timeout);
}	


sub get_gui_status{
	my ($object)=@_;
	my $status= $object->object_get_attribute('gui_status','status');
	my $timeout=$object->object_get_attribute('gui_status','timeout');
	return ($status,$timeout);	
}




###########
#  color
#########


	
sub get_color {
	my $num=shift;
	
	my @colors=(
	0x6495ED,#Cornflower Blue
	0xFAEBD7,#Antiquewhite
	0xC71585,#Violet Red
	0xC0C0C0,#silver
	0xADD8E6,#Lightblue	
	0x6A5ACD,#Slate Blue
	0x00CED1,#Dark Turquoise
	0x008080,#Teal
	0x2E8B57,#SeaGreen
	0xFFB6C1,#Light Pink
	0x008000,#Green
	0xFF0000,#red
	0x808080,#Gray
	0x808000,#Olive
	0xFF69B4,#Hot Pink
	0xFFD700,#Gold
	0xDAA520,#Goldenrod
	0xFFA500,#Orange
	0x32CD32,#LimeGreen
	0x0000FF,#Blue
	0xFF8C00,#DarkOrange
	0xA0522D,#Sienna
	0xFF6347,#Tomato
	0x0000CD,#Medium Blue
	0xFF4500,#OrangeRed
	0xDC143C,#Crimson	
	0x9932CC,#Dark Orchid
	0x800000,#marron
	0x800080,#Purple
	0x4B0082,#Indigo
	0xFFFFFF,#white	
	0x000000 #Black		
		);
	
	my $color= 	($num< scalar (@colors))? $colors[$num]: 0xFFFFFF;	
	my $red= 	($color & 0xFF0000) >> 8;
	my $green=	($color & 0x00FF00);
	my $blue=	($color & 0x0000FF) << 8;
	
	return ($red,$green,$blue);
	
}


sub get_color_hex_string {
	my $num=shift;
	
	my @colors=(
	"6495ED",#Cornflower Blue
	"FAEBD7",#Antiquewhite
	"C71585",#Violet Red
	"C0C0C0",#silver
	"ADD8E6",#Lightblue	
	"6A5ACD",#Slate Blue
	"00CED1",#Dark Turquoise
	"008080",#Teal
	"2E8B57",#SeaGreen
	"FFB6C1",#Light Pink
	"008000",#Green
	"FF0000",#red
	"808080",#Gray
	"808000",#Olive
	"FF69B4",#Hot Pink
	"FFD700",#Gold
	"DAA520",#Goldenrod
	"FFA500",#Orange
	"32CD32",#LimeGreen
	"0000FF",#Blue
	"FF8C00",#DarkOrange
	"A0522D",#Sienna
	"FF6347",#Tomato
	"0000CD",#Medium Blue
	"FF4500",#OrangeRed
	"DC143C",#Crimson	
	"9932CC",#Dark Orchid
	"800000",#marron
	"800080",#Purple
	"4B0082",#Indigo
	"FFFFFF",#white	
	"000000" #Black		
		);
	
	my $color= 	($num< scalar (@colors))? $colors[$num]: "FFFFFF";	
	return $color;
	
}





sub check_verilog_identifier_syntax {
	my $in=shift;
	my $error=0;
	my $message='';
#check if $in is defined
	if(!defined $in){
		return "Identifier is not defined! An Identifier must begin with an alphabetic character.\n";	
	}

	if(length $in ==0){
		return "Identifier length is zero! An Identifier must begin with an alphabetic character.\n";	
	}

# an Identifiers must begin with an alphabetic character or the underscore character
	if ($in =~ /^[0-9\$]/){
		return "An Identifier must begin with an alphabetic character or the underscore character.\n";
	}
	

#	Identifiers may contain alphabetic characters, numeric characters, the underscore, and the dollar sign (a-z A-Z 0-9 _ $ )
	if ($in =~ /[^a-zA-Z0-9_\$]+/){
		 #print "use of illegal character after\n" ;
		 my @w= split /([^a-zA-Z0-9_\$]+)/, $in; 
		 return "Contain illegal character of \"$w[1]\" after $w[0]. Identifiers may contain alphabetic characters, numeric characters, the underscore, and the dollar sign (a-z A-Z 0-9 _ \$ )\n";
		
	}


# check Verilog reserved words
	my @keys =			("always","and","assign","automatic","begin","buf","bufif0","bufif1","case","casex","casez","cell","cmos","config","deassign","default","defparam","design","disable","edge","else","end","endcase","endconfig","endfunction","endgenerate","endmodule","endprimitive","endspecify","endtable","endtask","event","for","force","forever","fork","function","generate","genvar","highz0","highz1","if","ifnone","incdir","include","initial","inout","input","instance","integer","join","large","liblist","library","localparam","macromodule","medium","module","nand","negedge","nmos","nor","noshowcancelled","not","notif0","notif1","or","output","parameter","pmos","posedge","primitive","pull0","pull1","pulldown","pullup","pulsestyle_onevent","pulsestyle_ondetect","remos","real","realtime","reg","release","repeat","rnmos","rpmos","rtran","rtranif0","rtranif1","scalared","showcancelled","signed","small","specify","specparam","strong0","strong1","supply0","supply1","table","task","time","tran","tranif0","tranif1","tri","tri0","tri1","triand","trior","trireg","unsigned","use","vectored","wait","wand","weak0","weak1","while","wire","wor","xnor","xor");
	if( grep (/^$in$/,@keys)){
		return  "$in is a Verlig reserved word.\n";
	}
	return undef;
	
}


sub capture_number_after {
	my ($after,$text)=@_;
	my @q =split  (/$after/,$text);
	#my $d=$q[1];
	my @d = split (/[^0-9. ]/,$q[1]);
	return $d[0]; 

}

sub capture_string_between {
	my ($start,$text,$end)=@_;
	my @q =split  (/$start/,$text);
	my @d = split (/$end/,$q[1]);
	return $d[0];
}


sub make_undef_as_string {
	foreach my $p  (@_){
		$$p= 'undef' if (! defined $$p);
		
	}	
}

sub powi{ # x^y
	my ($x,$y)=@_; # compute x to the y
	my $r=1;
	for (my $i = 0; $i < $y; ++$i ) {
    	$r *= $x;
  	}
  return $r;
}

sub sum_powi{ # x^(y-1) + x^(y-2) + ...+ 1;
	my ($x,$y)=@_; # compute x to the y
	my $r = 0;
    for (my $i = 0; $i < $y; $i++){
    	$r += powi( $x, $i );
    }
  	return $r;
}	


##########
#  run external commands
##########

sub run_cmd_in_back_ground
{
  my $command = shift;
  #print "\t$command\n";
 
  ### Start running the Background Job:
    my $proc = Proc::Background->new($command);
    my $PID = $proc->pid;
    my $start_time = $proc->start_time;
    my $alive = $proc->alive;

  ### While $alive is NOT '0', then keep checking till it is...
  #  *When $alive is '0', it has finished executing.
  while($alive ne 0)
  {
    $alive = $proc->alive;

    # This while loop will cause Gtk2 to conti processing events, if
    # there are events pending... *which there are...
    while (Gtk2->events_pending) {
      Gtk2->main_iteration;
    }
    Gtk2::Gdk->flush;

    usleep(1000);
  }
  
  my $end_time = $proc->end_time;
 # print "*Command Completed at $end_time, with PID = $PID\n\n";

  # Since the while loop has exited, the BG job has finished running:
  # so close the pop-up window...
 # $popup_window->hide;

  # Get the RETCODE from the Background Job using the 'wait' method
  my $retcode = $proc->wait;
  $retcode /= 256;

  #print "\t*RETCODE == $retcode\n\n";
  Gtk2::Gdk->flush;
  ### Check if the RETCODE returned with an Error:
  if ($retcode ne 0) {
    print "Error: The Background Job ($command) returned with an Error...!\n";
    return 1;
  } else {
    #print "Success: The Background Job Completed Successfully...!\n";
    return 0;
  }
	
}

sub run_cmd_in_back_ground_get_stdout
{
	my $cmd=shift;
	my $exit;
	my ($stdout, $stderr);
	capture { $exit=run_cmd_in_back_ground($cmd) } \$stdout, \$stderr;
	return ($stdout,$exit,$stderr);
	
}		
	
sub run_cmd_message_dialog_errors{
	my ($cmd)=@_;
	my ($stdout,$exit,$stderr)=run_cmd_in_back_ground_get_stdout($cmd);
	if(length $stderr>1){			
		message_dialog("$stderr\n",'error');
		return 1;
	}if($exit){
		message_dialog("Error $cmd failed: $stdout\n",'error');
		return 1;		
	}
	return 0;
	
}


sub run_cmd_textview_errors{
	my ($cmd,$tview)=@_;
	my ($stdout,$exit,$stderr)=run_cmd_in_back_ground_get_stdout($cmd);
	if(length $stderr>1){			
		add_colored_info($tview,"Error: $stderr\n",'red');
		add_colored_info($tview,"$cmd was not run successfully!\n",'red');
		return undef;
	}
	if($exit){
		add_colored_info($tview,"Error:$stdout\n",'red');
		add_colored_info($tview,"$cmd was not run successfully!\n",'red');
		return undef;
	}
	$stdout = "" if (!defined $stdout);
	return 	$stdout
}	


#############
# object
############

sub object_add_attribute{
	my ($self,$attribute1,$attribute2,$value)=@_;
	if(!defined $attribute2){$self->{$attribute1}=$value;}
	else {$self->{$attribute1}{$attribute2}=$value;}

}



sub object_get_attribute{
	my ($self,$attribute1,$attribute2)=@_;
	if(!defined $attribute2) {return $self->{$attribute1};}
	return $self->{$attribute1}{$attribute2};
}


sub object_add_attribute_order{
	my ($self,$attribute,@param)=@_;
	$self->{'parameters_order'}{$attribute}=[] if (!defined $self->{parameters_order}{$attribute});	
	foreach my $p (uniq @param){
		push (@{$self->{parameters_order}{$attribute}},$p);
	}
}


sub object_get_attribute_order{
	my ($self,$attribute)=@_;
	return undef unless(defined $self->{parameters_order}{$attribute});
	my @order=@{$self->{parameters_order}{$attribute}};
	return uniq(@order)
}

sub object_remove_attribute{
	my ($self,$attribute1,$attribute2)=@_;
	if(!defined $attribute2){
		delete $self->{$attribute1} if ( exists( $self->{$attribute1})); 
	}
	else {
		delete $self->{$attribute1}{$attribute2} if ( exists( $self->{$attribute1}{$attribute2})); ;
	}
}


1	 
