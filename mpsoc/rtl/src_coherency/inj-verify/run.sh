#!/bin/bash



my_array=( \
	"./norm160000 "
	"./excl160 "
	"./norm16000 "
	"./norm1600 "
	"./norm16 "
        "./rd_snpf_evict "
	"./rd_snpf_evict "
	"./wr_rd_rd_clean1 "
	"./wr_rd_rd_clean2 "	
	
)

rm out;

for i in "${my_array[@]}"; do
 echo "run $i"
 echo "
*******$i***************
" >>out; 

cd $i; ./run.sh >>../out; cd ..;
 
done
