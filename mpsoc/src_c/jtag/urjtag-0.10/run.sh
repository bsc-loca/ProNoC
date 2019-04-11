#!/bin/sh
./configure
wait
make
wait
# copy all generated library files in lib dir
find  . -name \*.a -exec cp '{}' ../my/lib/ \;
find  . -name \*.h -exec cp '{}' ../my/include/ \;
