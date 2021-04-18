#!/bin/bash


desktop=$(xdotool get_num_desktops)
if [ "$desktop" -lt 2 ]; then
	xdotool set_num_desktops 2
	echo "There is only one desktop. Another desktop is added to run ProNoC inside that"
fi

xdotool set_desktop --relative 1


echo "done!"
