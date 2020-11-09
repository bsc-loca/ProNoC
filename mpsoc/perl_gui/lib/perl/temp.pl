#!/usr/bin/perl
 
use strict;
use Gtk3 -init;
use Glib ('TRUE','FALSE');
use Gtk3::SourceView;
 
# Variables to save a Gtk3::TextIter for the start and end position
# of the current search result
my $start;
my $end;
 
# a window
my $window = Gtk3::Window->new('toplevel');
$window->set_title ('SourceView Example');
$window->set_default_size(700, 450);
$window->set_border_width(5);
$window->signal_connect('delete_event' => sub {Gtk3->main_quit()});
 
# two buttons for the search and replace functions
my $button_search = Gtk3::Button->new();
$button_search->set_label("Suchen");
$button_search->signal_connect("clicked" => \&search_cb);
 
my $button_replace = Gtk3::Button->new();
$button_replace->set_label("Ersetzen");
$button_replace->signal_connect("clicked" => \&replace_cb);
 
# a text buffer (stores text)
my $buffer = Gtk3::SourceView::Buffer->new();
$buffer->set_text("searchstring \n searchstring \n searchstring \n searchstring \n searchstring \n");
 
# For the search and replace function we need first a search context
# associated with the buffer $buffer
my $search_context = Gtk3::SourceView::SearchContext->new($buffer);
 
# a textview
my $textview = Gtk3::SourceView::View->new();
# displays the buffer
$textview->set_buffer($buffer);
$textview->set_wrap_mode("word");
$textview->set_hexpand(TRUE);
$textview->set_vexpand(TRUE);
 
# a grid to attach the widgets
my $grid = Gtk3::Grid->new();
$grid->set_column_spacing(20);
$grid->set_row_spacing(20);
$grid->attach($button_search, 0, 0, 1, 1);
$grid->attach($button_replace, 1, 0, 1, 1);
$grid->attach($textview, 0, 1, 2, 1);
 
# add the grid to the window, 
# show the window and run the Application
$window->add($grid);
$window -> show_all();
Gtk3->main();
 
sub search_cb {
        # First we need a Gtk3::SourceView::SearchSettings object
        # This element represents the settings of a search and can be associated
        # with one or several Gtk3::SourceView::SearchContexts
        my $search_settings = Gtk3::SourceView::SearchSettings->new();
        # here we just want to set the text to search as 'searchstring'
        # Usually (if the search text is given by an entry or the like)
        # you may be interested to call Gtk3::SourceView::Utils::unescape_search_text
        # before this function. Here this is not necessary.
        $search_settings->set_search_text('searchstring');
        # Last we associate the $search_settings with the $search_context
        $search_context->set_settings($search_settings);
 
        # The single search run
        # We need a Gtk3::TextIter for the first search run,
        # because there $end is not defined
        my $startiter = $buffer->get_start_iter();
        # The Gtk3::SourceView::SearchContext::forward
        # function returns an array with one Gtk3::Textiter
        # each start and end position of the search result
        my @treffer;
        # If one search run is already passed, wen want to start the 
        # current search run after the previous search result
        if ($end) {
                # Note: To avoid warning, we first check,
                # whether there is a further result
                if ($search_context->forward($end)) {
                        # perform the search and save 
                        # the Gtk3::Iters to @treffer
                        @treffer = $search_context->forward($end);
                        # Save the Gtk3::TextIter for 
                        # the start position of the result
                        # in the variable $start
                        $start = @treffer[0];
                        # Save the Gtk3::TextIter for 
                        # the end position of the result
                        # in the variable $end
                        $end = @treffer[1];
                        # Note: The concept of "current match" 
                        # doesn't exist yet. 
                        # A way to highlight differently 
                        # the current match is to select it.
                        $buffer->select_range($start, $end);
                }
                # If no further result exists, we start searching 
                # from the beginning
                else {
                        $end = $buffer->get_start_iter();
                        @treffer = $search_context->forward($end);
                        $start = @treffer[0];
                        $end = @treffer[1];
                        $buffer->select_range($start, $end);
                }
        }
        # In the first search run $end is not defined
        # Therefore we start the first run at the Gtk3::TextIter
        # $startiter which points to the beginning of the buffer
        else {
                if ($search_context->forward($startiter)) {
                @treffer = $search_context->forward($startiter);
                $start = @treffer[0];
                $end = @treffer[1];
                $buffer->select_range($start, $end);
        }
}
}
 
sub replace_cb {
# Replacement is only possible, if there is a current search
# result. This is the case, if $end is defined (see above)
if ($end) {
        # Before replacement we need the offset of the 
        # $start Iterator to create a new Gtk3::TextIter after
        # Replacement
        my $offset_start = $start->get_offset();
 
        # Replace the current search result
        my $replace=$search_context->replace($start, $end, "replaced", -1);
 
        # IMPORTANT: Because the TextBuffer is changed, we need a 
        # new Gtk3::TextIter! otherwise we would get an error!
        # Therefore initialize the TextIter $end at position $offset_start!
        $end = $buffer->get_iter_at_offset($offset_start);
         
        # After the replacement it will be usually jumped to the
        # next search result
        search_cb();
        }
}
