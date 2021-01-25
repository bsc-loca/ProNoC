#!/bin/bash

my_array=( \

	"./no_cache_wr_rd"	 
	"./rd "
	"./rd_same_addr "
	"./rd_snpf_evict "
	"./wr_hazard "
	"./wr_rd_hazard "
	"./wr_rd_rd_clnu "
	"./wr_rd_rd_rd_rd(rnd) "
	"./wr_rd_rd_rd_rd "
	"./wr_rd_rd_rd "
	"./wr_rd_rd_rdu "
	"./wr_rd "
	"./wr "
	"./rd_nosnp "
	"./exlusive1 "
	"./exlusive2 "
	"./atomic_ld_add_accum "
)

rm out;
for i in "${my_array[@]}"; do
 echo "run $i"
 echo "
*******$i***************
" >>out; 
  cd $i; ./run.sh >>../out;  cd ..;
 
done

