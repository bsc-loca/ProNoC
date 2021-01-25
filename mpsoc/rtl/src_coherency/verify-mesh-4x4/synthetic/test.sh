#!/bin/bash

filename='tmp'
maxsize=5


filesize=$(stat -c%s "$filename")
echo "Size of $filename = $filesize bytes."

if (( filesize > maxsize )); then
    echo "print it"
else
    echo "fine"
fi
