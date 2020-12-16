use strict;
use Glib ':constants';
use Gtk2 -init;

my $window = Gtk2::Window->new;
my $scroll = Gtk2::ScrolledWindow->new;
my $textview = Gtk2::TextView->new;
my $button = Gtk2::Button->new ("scroll me, baby");
my $vbox = Gtk2::VBox->new;

$window->add ($vbox);
$vbox->add ($scroll);
$vbox->pack_start ($button, FALSE, FALSE, 0);
$scroll->add ($textview);

my $buffer = $textview->get_buffer;

{
local $/ = undef;
open IN, $0;
$buffer->insert ($buffer->get_start_iter, scalar <IN>);
close IN;
}

$window->show_all;

texview_scrol_end($textview);



my $going_up = TRUE;

$window->signal_connect (destroy => sub {Gtk2->main_quit});

sub texview_scrol_end{
	my $textview=shift;
	my $buffer =  $textview->get_buffer;
    my $end_mark = $buffer->create_mark( 'end', $buffer->get_end_iter, 0 );

$textview->scroll_to_mark( $end_mark, 0.0,0, 0.0, 1.0 );
   # $buffer->place_cursor( $buffer->get_end_iter);
}


$buffer->insert ($buffer->get_end_iter, "l
l
l
l
l

l
l
l
l
l
l
l
l

l
l
l
l
l
l
l");


Gtk2->main;






















####
