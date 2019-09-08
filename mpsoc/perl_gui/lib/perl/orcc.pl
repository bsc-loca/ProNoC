#!/usr/bin/perl -w
use Glib qw/TRUE FALSE/;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;


use String::Scanf; # imports sscanf()



sub select_orcc_generated_srcs {
	my ($self)=@_;
	my $window = def_popwin_size(80,80,"Step 1: Select path to ORCC generated source file",'percent');	
	
	my $table = def_table(10, 10, FALSE);
	my $col=0;
	my $row=0;
	($row,$col)=add_param_widget ($self,"generated src path",'SRC_DIR', undef,'DIR_path',undef,"Select the path to ORCC generated C codes", $table,$row,$col,1,"ORCC",undef,undef,'horizental"');
    my $load=def_image_button('icons/enter.png');
	$table->attach($load,$col,$col+1,$row,$row+1,'shrink','shrink',2,2);$col++;
    my ($infobox,$info)= create_text();   
    
    $load-> signal_connect("clicked" => sub{
		process_orcc_dir($self,\$info);
		
	});
    




	
	my $i;	
	for ($i=$row; $i<5; $i++){
		
		my $temp=gen_label_in_center(" ");
		$table->attach_defaults ($temp, 0, 6 , $i, $i+1);
	}
	$row=$i;	
	
	$table->attach_defaults($infobox,0,20,$row,$row+1);
		

	$window->add ($table);
	$window->show_all();
	$col=5;
	my $next=def_image_button('icons/right.png','Next');
	$table->attach($next,$col,$col+1,$row,$row+1,'shrink','shrink',2,2);$col++;
	$next-> signal_connect("clicked" => sub{
		my $src=$self->object_get_attribute('ORCC','SRC_DIR');
		#check dir exists
		unless(-d $src){
			message_dialog("Dir $src does not exist!",'error');
			return;
		}  
		#check it has a csv file
		my @files = File::Find::Rule->file()
        	->name( '*.csv' )
            ->in( "$src" );
        unless (scalar @files){
        	message_dialog("Dir $src does not contain a csv file!",'error');
			return;
        }    
			$self->object_add_attribute('ORCC','SRC_CSV',$files[0]);
			message_dialog("$files[0]");
		

		$window->destroy;
		
	});



}


sub process_orcc_dir{
	my ($self,$info)=@_;
	
	
	my $src=$self->object_get_attribute('ORCC','SRC_DIR');
	#check dir exists
	unless(-d $src){
		add_colored_info($info,"Dir $src does not exist!\n",'red');
		return;
	}  
	#check it has a csv file
	my @files = File::Find::Rule->file()
       	->name( '*.csv' )
        ->in( "$src" );
	unless (scalar @files){
		add_colored_info($info,"Dir $src does not contain a csv file!",'red');
		return;
	}    
		
	my ($name,$path,$suffix) = fileparse("$files[0]",qr"\..[^.]*$");
	$self->object_add_attribute('ORCC','SRC_CSV',$name);
	add_info($info,"Use ${name}.csv for generating actors network\n");
		
	read_orc_csv($self,$info);	

		
}


sub read_orc_csv{
	my ($self,$info)=@_;
	my $src=$self->object_get_attribute('ORCC','SRC_DIR');
	my $name =$self->object_get_attribute('ORCC','SRC_CSV');
	my $file="$src/$name.csv";
	open my $in, "<:encoding(utf8)", $file or die "$file: $!";
	my @actors;
	while (my $line = <$in>) {
    	chomp $line;
    	#acotor1, 0, 1, 0, 1, 1, false, 
    	my  ($actor, $Incoming, $Outgoing, $Inputs, $Outputs, $Actions, $FSM)=
			 sscanf("%s,%d,%d,%d,%d,%d,%s",$line);
		push(@actors,$actor) if (defined $actor);   
	}
	close $in;
	my $num=scalar @actors;
	if($num==0){
		add_colored_info($info,"Could not find any actor in $file\n",'red');
		return;
	}
	add_info($info,"total of $num acotrs have found: @actors \n");




}	











1;