#!/usr/bin/perl -w
use Glib qw/TRUE FALSE/;
use strict;
use warnings;

use FindBin;
use lib $FindBin::Bin;




sub select_orcc_generated_srcs {
	my ($self)=@_;
	my $window = def_popwin_size(40,40,"Step 1: Select path to ORCC generated source file",'percent');	
	
	my $table = def_table(2, 2, FALSE);
	my $col=0;
	my $row=0;
	($row,$col)=add_param_widget ($self,"generated src path",'GEN_SRC', undef,'DIR_path',undef,"Select the path to ORCC generated C codes", $table,$row,$col,1,"ORCC",undef,undef,undef);


	
	my $i;	
	for ($i=$row; $i<5; $i++){
		
		my $temp=gen_label_in_center(" ");
		$table->attach_defaults ($temp, 0, 6 , $i, $i+1);
	}
	$row=$i;	
		

	$window->add ($table);
	$window->show_all();
	$col=5;
	my $next=def_image_button('icons/right.png','Next');
	$table->attach($next,$col,$col+1,$row,$row+1,'shrink','shrink',2,2);$col++;
	$next-> signal_connect("clicked" => sub{
		

		$window->destroy;
		
	});



}

















1;