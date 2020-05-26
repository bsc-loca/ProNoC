#!/usr/bin/perl -w
package ProNOC;


#add home dir in perl 5.6
use FindBin;
use lib $FindBin::Bin;
use Glib qw/TRUE FALSE/;

use Gtk2;
use strict;
use warnings;
use Getopt::Long;



use lib 'lib/perl';
require "widget.pl"; 
require "interface_gen.pl";
require "ip_gen.pl";
require "soc_gen.pl";
require "mpsoc_gen.pl";
require "emulator.pl";
require "simulator.pl";
require "trace_gen.pl";
require "network_maker.pl";
require "uart.pl";
require "source_probe.pl";
require "gdown.pl"; # google drive downlouder

use File::Basename;
our $VERSION = '1.9.1'; 
our $END_YEAR= "2019";

sub main{
	# check if envirement variables are defined
	my $project_dir	  = get_project_dir(); #mpsoc dir addr
	my $paths_file= "$project_dir/mpsoc/perl_gui/lib/Paths";
	if (-f 	$paths_file){#} && defined $ENV{PRONOC_WORK} ) {
		my $paths= do $paths_file;
		main_window();		
	}
	else{
		setting(1);
	}	
}





sub main_window{
	
	set_path_env();

	my($width,$hight)=max_win_size();
	set_defualt_font_size();
	
	if ( !defined $ENV{PRONOC_WORK} ) {
	my $message;
	if ( !defined $ENV{PRONOC_WORK}) {
		my $dir = Cwd::getcwd();
		my $project_dir	  = abs_path("$dir/../../mpsoc_work");
		$ENV{'PRONOC_WORK'}= $project_dir;
		$message= "\n\nWarning: PRONOC_WORK envirement varibale has not been set. The PRONOC_WORK is autumatically set to $ENV{'PRONOC_WORK'}.\n";
    
	}


  	
	#$message= $message."Warning: QUARTUS_BIN environment variable has not been set. It is required only for working with NoC emulator." if(!defined $ENV{QUARTUS_BIN});
	
	#$message= $message."\n\nPlease add aformentioned variables to ~\.bashrc file e.g: export PRONOC_WORK=[path_to]/mpsoc_work.";
    	message_dialog("$message");
    
}

	my $table = def_table(1,3,FALSE);
	
			
	#________
	#radio btn "Generator"	
		
			
	my ($notebook,$noteref) = generate_main_notebook('Generator');
	my $window = def_win_size($width-100,$hight-100,"ProNoC");
	my $navIco = gen_pixbuf("./icons/ProNoC.png");        
	$window->set_default_icon($navIco); 


 my @menu_items = (
  [ "/_File",            undef,        undef,          0, "<Branch>" ],
  [ "/File/_Setting",       "<control>O", sub { setting(0); },  0,  undef ],
  [ "/Tools/_UART Terminal", "<control>U", sub { uart(0); },  0,  undef ],
  [ "/Tools/Sourc Probe", "<control>P", sub { source_probe(0); },  0,  undef ],
  [ "/File/_Quit",       "<control>Q", sub { gui_quite(); },  0, "<StockItem>", 'gtk-quit' ],
  [ "/_View",                  undef, undef,         0, "<Branch>" ],
  [ "/_View/_ProNoC System Generator",  "<control>1", 	sub{ open_page($notebook,$noteref,$table,'Generator'); } ,	0,	undef ],
  [ "/_View/_ProNoC Simulator",  "<control>2", 	sub{ open_page($notebook,$noteref,$table,'Simulator'); } ,	0,	undef ],
 


  [ "/_Help", 		undef,		undef,          0, 	"<Branch>" ],
  [ "/_Help/_About",  	"F1", 		sub{about($VERSION)} ,	0,	undef ],
  [ "/_Help/_ProNoC System Overview",  	"F2", 		\&overview ,	0,	undef ],  
  [ "/_Help/_ProNoC User Manual",  "F3",		\&user_help, 	0,	undef ],
 
);
	
	my $menubar=gen_MenuBar($window,@menu_items);    
	$table->attach ($menubar,0, 1, 0,1,,'fill','fill',0,0); #,'expand','shrink',2,2);
    
    my $tt = Gtk2::Tooltips->new();


	
	
	
	my $rbtn_generator = gen_radiobutton (undef,'Generator','icons/hardware.png','ProNoC System Generator'); 
	my $rbtn_simulator = gen_radiobutton ($rbtn_generator,'Simulator','icons/simulator.png', "ProNoC Simulator");
	my $rbtn_networkgen= gen_radiobutton ($rbtn_generator,'Network maker','icons/diagram.png', "ProNoC Topology Maker");
	
	my $dt=creating_detachable_toolbar($rbtn_generator,$rbtn_simulator,$rbtn_networkgen);
	
	
	$rbtn_generator->signal_connect('toggled', sub{
		open_page($notebook,$noteref,$table,'Generator');				
	});
	
	$rbtn_simulator->signal_connect('toggled', sub{
		open_page($notebook,$noteref,$table,'Simulator');		
	});
	
	$rbtn_networkgen->signal_connect('toggled', sub{
		open_page($notebook,$noteref,$table,'Networkgen');		
	});	
 
   $table->attach ($dt,1, 2, 0,1,'fill','fill',0,0);
   
   
   
   $table->attach_defaults( $notebook, 0, 2, 1,2);

	$window->add($table);
	$window->set_resizable (1);
	$window->show_all();		
}			


sub open_page{
	my ( $notebook,$noteref,$table,$page_name)=@_;
	$notebook->destroy;
	($notebook,$noteref) = generate_main_notebook($page_name);
	$table->attach_defaults( $notebook, 0, 2, 1,2);	
	$table->show_all;

}


sub user_help{ 
    my $dir = Cwd::getcwd();
    my $help="$dir/../../doc/ProNoC_User_manual.pdf";	
    system qq (xdg-open $help);
    return;
}

sub overview{
    my $dir = Cwd::getcwd();
    my $help="$dir/../../doc/ProNoC_System_Overview.pdf";	
    system qq (xdg-open $help);
    return;
}

sub setting{
	my $reset=shift;
	my $project_dir	  = get_project_dir(); #mpsoc dir addr
	my $paths_file= "$project_dir/mpsoc/perl_gui/lib/Paths";

	__PACKAGE__->mk_accessors(qw{
	PRONOC_WORK
	});
	my $self;
	if (-f 	$paths_file ){
		$self= do $paths_file;
	}else{
		$self = __PACKAGE__->new();
		
	}
	
	
	my $old_pronoc_work = $self->object_get_attribute("PATH","PRONOC_WORK");
	my $old_quartus = $self->object_get_attribute("PATH","QUARTUS_BIN");
	my $old_modelsim = $self->object_get_attribute("PATH","MODELSIM_BIN");
	make_undef_as_string(\$old_pronoc_work,\$old_quartus,\$old_modelsim);
	
	my $table=def_table(10,10,FALSE);	
	my $set_win=def_popwin_size(50,80,"Configuration setting",'percent');
	my $scrolled_win = new Gtk2::ScrolledWindow (undef, undef);
	$scrolled_win->set_policy( "automatic", "automatic" );
	$scrolled_win->add_with_viewport($table);
	my $row=0; my $col=0;
	
	#title1		
	my $title1=gen_label_in_center("Path setting");
	$table->attach ($title1 , 0, 10,  $row, $row+1,'expand','shrink',2,2); $row++;
	my $separator = Gtk2::HSeparator->new;	
	$table->attach ($separator , 0, 10 , $row, $row+1,'fill','fill',2,2);	$row++;
    $table->attach_defaults (get_path_envirement_gui($self,$set_win,$reset) , 0, 10 , $row, $row+1);	$row++;
   
  

	#title2		
	my $title2=gen_label_in_center("Toolchain");
	$table->attach ($title2 , 0, 10,  $row, $row+1,'expand','shrink',2,2); $row++;
	my $separator2 = Gtk2::HSeparator->new;	
	$table->attach ($separator2 , 0, 10 , $row, $row+1,'fill','fill',2,2);	$row++;

	#check which toolchain is available in the system
	$table->attach_defaults (check_toolchains($self,$set_win,$reset) , 0, 10 , $row, $row+1);	$row++;
	
	
	
		
	#title3
	$table->attach (gen_label_in_center("Tools") , 0, 10,  $row, $row+1,'expand','shrink',2,2); $row++;
	$table->attach ( Gtk2::HSeparator->new , 0, 10 , $row, $row+1,'fill','fill',2,2);	$row++;

	#check which toolchain is available in the system
	$table->attach_defaults (check_tools($self,$set_win,$reset) , 0, 10 , $row, $row+1);$row++;
	
	
	my $ok = def_image_button('icons/select.png','OK');
	my $mtable = def_table(10, 1, FALSE);

	$mtable->attach_defaults($scrolled_win,0,1,0,9);
	$mtable-> attach ($ok , 0, 1,  9, 10,'expand','shrink',2,2); 
	
	$set_win->add ($mtable);
	$set_win->show_all();
	
	
	
	$ok->signal_connect("clicked"=> sub{
		#save setting
		open(FILE,  ">$paths_file") || die "Can not open: $!";
		print FILE perl_file_header("Paths");
		print FILE Data::Dumper->Dump([\%$self],['setting']);
		close(FILE) || die "Error closing file: $!";
		my $pronoc_work = $self->object_get_attribute("PATH","PRONOC_WORK");
		my $quartus = $self->object_get_attribute("PATH","QUARTUS_BIN");
		my $modelsim = $self->object_get_attribute("PATH","MODELSIM_BIN");
		make_undef_as_string(\$pronoc_work,\$quartus,\$modelsim);
			
		if(($old_pronoc_work ne $pronoc_work) || !defined $ENV{PRONOC_WORK}){
			mkpath("$pronoc_work/emulate",1,01777) unless -d "$pronoc_work/emulate";
			mkpath("$pronoc_work/simulate",1,01777) unless -d "$pronoc_work/simulate";	
			mkpath("$pronoc_work/tmp",1,01777) unless -d "$pronoc_work/tmp";
			mkpath("$pronoc_work/toolchain",1,01777) unless -d "$pronoc_work/toolchain";
						
		}
		
	
		set_path_env();
		if($old_pronoc_work ne $pronoc_work ){
			update_bashrc_file($self,$old_pronoc_work,$old_quartus,$old_modelsim);			
		}

		my  ($file_path,$text)=@_;
		$set_win->destroy;
		main_window() if($reset);

	});
	
}

sub get_path_envirement_gui {
	my($self,$set_win,$reset)=@_;
	my $table = def_table(10, 1, FALSE);
	my $row=0;
	my $col=0;
	my $project_dir	  = get_project_dir(); #mpsoc dir addr
	my $paths_file= "$project_dir/mpsoc/perl_gui/lib/Paths";
	my $old_pronoc_work = $self->object_get_attribute("PATH","PRONOC_WORK");
	my $old_quartus = $self->object_get_attribute("PATH","QUARTUS_BIN");
	my $old_modelsim = $self->object_get_attribute("PATH","MODELSIM_BIN");
	make_undef_as_string(\$old_pronoc_work,\$old_quartus,\$old_modelsim);
	
	
	
	my $pronoc_w_row=0;
	my @paths = (
	{ label=>"PRONOC_WORK", param_name=>"PRONOC_WORK", type=>"DIR_path", default_val=>"$project_dir/mpsoc_work", content=>undef, info=>"Define the working directory where the projects' files will be created", param_parent=>'PATH',ref_delay=>undef },
	{ label=>"QUARTUS_BIN", param_name=>"QUARTUS_BIN", type=>"DIR_path", default_val=>undef, content=>undef, info=>"Define the path to QuartusII compiler bin directory.  Setting of this variable is optional and is needed if you are going to use Altera FPGAs for implementation or emulation", param_parent=>'PATH',ref_delay=>undef },
	{ label=>"VIVADO_BIN", 	param_name=>"VIVADO_BIN", type=>"DIR_path", default_val=>undef, content=>undef, info=>"Define the path to Xilinx/Vivado compiler bin directory.  Setting of this variable is optional and is needed if you are going to use Xilinx FPGAs for implementation or emulation", param_parent=>'PATH',ref_delay=>undef },
	{ label=>"SDK_BIN"	,	param_name=>"SDK_BIN", type=>"DIR_path", default_val=>undef, content=>undef, info=>"Define the path to Xilinx/SDK/bin directory. Setting of this variable is optional and is needed if you are going to use Xilinx FPGAs for implementation or emulation", param_parent=>'PATH',ref_delay=>undef },
	{ label=>"MODELSIM_BIN",param_name=>"MODELSIM_BIN", type=>"DIR_path", default_val=>undef, content=>undef, info=>"Define the path to Modelsim simulator bin directory.  Setting of this variable is optional and is needed if you have installed Modelsim simulator and you want ProNoC to auto-generate the
simulation models using Modelsim software", param_parent=>'PATH',ref_delay=>undef },
		);	

	foreach my $d (@paths) {
		#$mpsoc,$name,$param, $default,$type,$content,$info, $table,$row,$column,$show,$attribut1,$ref_delay,$new_status,$loc
		my $widget;
		($row,$col)=add_param_widget ($self, $d->{label}, $d->{param_name}, $d->{default_val}, $d->{type}, $d->{content}, $d->{info}, $table,$row,$col,1, $d->{param_parent}, $d->{ref_delay},undef,"vertical");
		
	}
	#add apply buton for work dir
	my $apply=def_image_button("icons/enter.png",'Apply');
	$table->attach ($apply , 4, 5,  $pronoc_w_row, $pronoc_w_row+1,'fill','shrink',2,2); $row++;
	$apply->signal_connect("clicked"=> sub{
			my $pronoc_work = $self->object_get_attribute("PATH","PRONOC_WORK");
			make_undef_as_string(\$pronoc_work);
			if(($old_pronoc_work ne $pronoc_work)){
				open(FILE,  ">$paths_file") || die "Can not open: $!";
				print FILE perl_file_header("Paths");
				print FILE Data::Dumper->Dump([\%$self],['setting']);
				close(FILE) || die "Error closing file: $!";
				mkpath("$pronoc_work/emulate",1,01777) unless -d "$pronoc_work/emulate";
				mkpath("$pronoc_work/simulate",1,01777) unless -d "$pronoc_work/simulate";	
				mkpath("$pronoc_work/tmp",1,01777) unless -d "$pronoc_work/tmp";
				mkpath("$pronoc_work/toolchain",1,01777) unless -d "$pronoc_work/toolchain";
				update_bashrc_file($self,$old_pronoc_work,$old_quartus,$old_modelsim);	
					
			}
			set_path_env();		
		    $set_win->destroy;
			setting($reset);
	});
	return $table;	
}


sub update_bashrc_file {
	my ($self,$old_pronoc_work,$old_quartus,$old_modelsim)=@_;
	my $pronoc_work = $self->object_get_attribute("PATH","PRONOC_WORK");
	my $quartus = $self->object_get_attribute("PATH","QUARTUS_BIN");
	my $modelsim = $self->object_get_attribute("PATH","MODELSIM_BIN");
	my $dialog = Gtk2::MessageDialog->new (my $window,
                                      'destroy-with-parent',
                                      'question', # message type
                                      'yes-no', # which set of buttons?
                                      "ProNoC variable has been changed. Do you want to update ~/.bashrc file with new ones?");
	my $response = $dialog->run;
  	if ($response eq 'yes') {
     			make_undef_as_string(\$pronoc_work,\$quartus,\$modelsim);
				append_text_to_file ("$ENV{HOME}/.bashrc", "\nexport PRONOC_WORK=$pronoc_work\n") if(($old_pronoc_work ne $pronoc_work) || !defined $ENV{PRONOC_WORK}); 
				#append_text_to_file ("$ENV{HOME}/.bashrc", "export QUARTUS_BIN=$quartus\n") if($old_quartus ne $quartus) ;
				#append_text_to_file ("$ENV{HOME}/.bashrc", "export MODELSIM_BIN=$modelsim\n") if($old_modelsim ne $modelsim) ;
  	
  	
  	
  	}
  	$dialog->destroy;	
}




sub check_toolchains{
	my ($self,$set_win,$reset)=@_;
	my $table = def_table(10, 1, FALSE);
	
	my @f1=("/bin/mb-g++","/bin/mb-objcopy");
	my @f2=("/bin/lm32-elf-gcc","/bin/lm32-elf-ld","/bin/lm32-elf-objcopy","/bin/lm32-elf-objdump","/lm32-elf/lib","/lib/gcc/lm32-elf/4.5.3");
	my @f3=("/bin/or1k-elf-gcc","/bin/or1k-elf-ld","/bin/or1k-elf-objcopy","/bin/or1k-elf-objdump","/lib/gcc/or1k-elf/5.2.0");
	
	my @tool = (
	{ label=>"aeMB", tooldir=>"aemb", files=>\@f1, size=>'21 MB', path=>'https://drive.google.com/file/d/0B3E23UPNn7CRWWZMN2pUSTM1MFE/view?usp=sharing' },
	{ label=>"lm32", tooldir=>"lm32", files=>\@f2, size=>'57 MB', path=>'https://drive.google.com/file/d/0B3E23UPNn7CRaTVRbFhwWGlvTFk/view?usp=sharing' },
	{ label=>"or1k-elf", tooldir=>"or1k-elf", files=>\@f3, size=>'219 MB', path=>'https://drive.google.com/file/d/0B3E23UPNn7CRRUY3UmZBOHpXNUE/view?usp=sharing' },
	);
	
	my $row =0;
	my $download_st=0;
	my $i=0;
	foreach my $d (@tool) {
		my $index=$i;
		$i++;
		my $exist=1;
		my $miss="";
		my $pronoc_work = $self->object_get_attribute("PATH","PRONOC_WORK");
		my $tooldir=$d->{tooldir};
		my @files=@{$d->{files}};
		my $tool_path="$pronoc_work/toolchain/$tooldir";
		unless (-d $tool_path){
			$exist=0;
			$miss=$miss." $tool_path is missing\n";
		}else{
			foreach my $f (@files){
				
				my $file_path= "$tool_path/$f";
				unless ( -f $file_path || -d $file_path){
					$exist=0;
					$miss=$miss." $file_path file is missing\n";
				}
			}
		}
		if ($exist==0){
			my $col=0;
			my $w=def_image_button("icons/warning.png",$d->{label});
			$w->signal_connect("clicked" => sub {message_dialog($miss);});	
			$table->attach ($w , $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
			$table->attach (gen_label_in_center("Size: $d->{size}") , $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++; 	
			my $dowload=def_image_button("icons/download.png",'Download Now');
			$table->attach ($dowload , $col, $col+1,  $row, $row+1,'shrink','shrink',2,2);  $col++;
			my $srow=	$row;
			$dowload ->signal_connect("clicked" => sub {
				$dowload ->set_sensitive (FALSE);
				$download_st = $download_st | (1<<$index);
				my $load= show_gif("icons/load.gif");
				$table->attach ($load, $col, $col+1, $srow,$srow+ 1,'shrink','shrink',0,0);  $col++;
				$load->show_all;
				my $filename="$pronoc_work/toolchain/$d->{label}.zip";
				my $target="$pronoc_work/toolchain/$d->{label}";
				#download the file from google drive
				download_from_google_drive("$d->{path}" ,"$filename"  );
				#unzip the file
				my $cmd= "unzip $pronoc_work/toolchain/$d->{label}.zip -d $pronoc_work/toolchain/";
				return if(run_cmd_message_dialog_errors($cmd));
				$load->destroy;
				#remove zip file
				unlink "$pronoc_work/toolchain/$d->{label}.zip";
				$download_st = $download_st & ~(1<<$index);
				
				if ($download_st==0){
					$cmd = "chmod +x -Rf $pronoc_work/toolchain/";
					return if(run_cmd_message_dialog_errors($cmd));
					$set_win->destroy;
					setting($reset);
				}				
			});		
								
			$row++;			
		}else{
			my $w=def_image_label("icons/button_ok.png",$d->{label});
			$table->attach ($w , 0, 1,  $row, $row+1,'shrink','shrink',2,2); $row++;			
		}
			
	}			
	return $table;	
}

sub Dir_isEmpty {
    return 0 unless -d $_[0];
    opendir my $dh, $_[0] or die $!;
    my $count = () = readdir $dh;    # gets count thru ()
    return $count - 2;     #maybe not the best way of removing . and .
}


sub check_tools{
	my ($self,$set_win,$reset)=@_;
	my $table = def_table(10, 1, FALSE);
	my $row=0;
	my $pronoc_work = $self->object_get_attribute("PATH","PRONOC_WORK");
	my $lable1;
	if (Dir_isEmpty("$pronoc_work/toolchain/bin") == 0){
		$lable1=def_image_label("icons/warning.png","The tools directory is empty! You need to run the Make tools first.");	
		
	}else{
		$lable1=gen_label_in_left("Regenerate the tools    ");
		
	}
	$table->attach ($lable1 , 0, 1,  $row, $row+1,'shrink','shrink',2,2); 
	
	my $make=def_image_button('icons/setting2.png','Make tools');
	$table->attach ($make , 1, 2,  $row, $row+1,'shrink','shrink',2,2); $row++;
	my $srow = $row;
	$make ->signal_connect("clicked" => sub {
		#unzip the file
		$make ->set_sensitive (FALSE);
		my $load= show_gif("icons/load.gif");
		$table->attach ($load, 2, 3, $srow,$srow+ 1,'shrink','shrink',0,0);  		
				my $project_dir	  = get_project_dir(); #mpsoc dir addr
				my $cmd= "xterm -hold -e bash -c \' cd $project_dir/mpsoc/src_c; make; echo \"\n\nPlease close this window to continue .....\n\n\"\'";
				return if(run_cmd_message_dialog_errors($cmd));
				$load->destroy;
				$set_win->destroy;
				setting($reset);
		
	});	
	
	
	return $table;

}

sub uart {
	uart_main();	
}

sub source_probe{
	source_probe_main();	
}


sub generate_main_notebook {
	my $mode =shift;
	
	my $notebook = Gtk2::Notebook->new;
	$notebook->show_all;
	if($mode eq 'Generator'){
		my $intfc_gen=  intfc_main();
		my $lable1=def_image_label("icons/intfc.png"," _Interface generator ",1);
		$notebook->append_page ($intfc_gen,$lable1);#Gtk2::Label->new_with_mnemonic ("  _Interface generator  "));
		$lable1->show_all;

		my $ipgen=ipgen_main();
		my $lable2=def_image_label("icons/ip.png"," I_P generator ",1);
		$notebook->append_page ($ipgen,$lable2);#Gtk2::Label->new_with_mnemonic ("  _IP generator  "));
		$lable2->show_all;

		my $socgen=socgen_main();
		my $lable3=def_image_label("icons/tile.png"," P_rocessing tile generator ",1);			
		$notebook->append_page ($socgen,$lable3 );#,Gtk2::Label->new_with_mnemonic ("  _Processing tile generator  "));
		$lable3->show_all;		

		my $mpsocgen =mpsocgen_main();
		my $lable4=def_image_label("icons/noc.png"," _NoC based MPSoC generator ",1);	
		$notebook->append_page ($mpsocgen,$lable4);#Gtk2::Label->new_with_mnemonic ("  _NoC based MPSoC generator  "));	
		$lable4->show_all;	
		
	
	} elsif($mode eq 'Networkgen'){
	
		my $networkgen = network_maker_main();
		my $lable5=def_image_label("icons/trace.png"," Network Maker ");	
		$notebook->append_page ($networkgen,$lable5);#Gtk2::Label->new_with_mnemonic ("  _NoC based MPSoC generator  "));	
		$lable5->show_all;	
	
	
	}else{
			
		
		my $trace_gen= trace_gen_main('task');
		my $lable1=def_image_label("icons/trace.png"," _Trace generator ",1);
		#my $lb=Gtk2::Label->new_with_mnemonic (" _Trace generator   ");
		set_tip($lable1, "Generate trace file from application task graph");
		
		$notebook->append_page ($trace_gen,$lable1);		
		$lable1->show_all;
		$trace_gen->show_all;
		
		my $simulator =simulator_main();
		my $lable2=def_image_label("icons/sim.png"," _NoC simulator ",1);
		
		
		$notebook->append_page ($simulator,$lable2);#Gtk2::Label->new_with_mnemonic (" _NoC simulator   "));		
		$lable2->show_all;
		$simulator->show_all;		

		my $emulator =emulator_main();
		my $lable3=def_image_label("icons/emul.png"," _NoC emulator ",1);
		$notebook->append_page ($emulator,$lable3);#Gtk2::Label->new_with_mnemonic (" _NoC emulator"));				
		$lable3->show_all;
		$emulator->show_all;	

	}		
		my $scrolled_win = add_widget_to_scrolled_win($notebook);			

		return ($scrolled_win,$notebook);	
}




Gtk2->init;
main;
Gtk2->main();
