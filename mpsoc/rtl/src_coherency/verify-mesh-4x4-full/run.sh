#!/bin/bash



my_array=( \
	"./excl160 "
	"./norm16 "
       	"./tread "	
	
)

rm out;

for i in "${my_array[@]}"; do
 echo "run $i"
 echo "
*******$i***************
" >>out; 

cd $i; ./run.sh >>../out; cd ..;
 
done
