#!/bin/sh

# run the following line in terminal to install the necessary packages
#    sudo sh install.sh 

LIST_OF_APPS="build-essential libgtk2.0-dev libglib2.0-dev libpango1.0-dev clang lib32z1 libgd-graph-perl libgtk2-perl libglib-perl cpanminus libusb-1.0 graphviz libgtksourceview2.0-dev libcanberra-gtk-module unzip xterm verilator wget" 

PERL_LIBS="ExtUtils::Depends ExtUtils::PkgConfig Glib Pango Gtk2 String::Similarity Gtk2::Ex::Graph::GD GD::Graph::bars3d IO::CaptureOutput Proc::Background List::MoreUtils File::Find::Rule Gtk2::SourceView2 Verilog::EditFiles IPC::Run File::Which Class::Accessor String::Scanf File::Copy::Recursive" 

apt-get install -y $LIST_OF_APPS

cpanm $PERL_LIBS
