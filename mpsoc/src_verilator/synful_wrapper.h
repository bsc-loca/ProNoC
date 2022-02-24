#ifndef _SYNFUL_WRAPPER_H
	#define  _SYNFUL_WRAPPER_H


#include <iostream>

#include "synful/synful.h"

bool synful_SSExit;
int  synful_random_seed=53432145;








void synful_eval( ){
	int i;

	if((reset==1) || (count_en==0))	return;

	if((( synful_cycle > sim_end_clk_num) || (read_done==1 )) && nt_packets_left==0 )  simulation_done=1;

	synful_run_one_cycle ();

	std::cout << synful_cycle << std::endl;

}














void synful_negedge_event( ){
	int i;
	clk = 0;
	topology_connect_all_nodes ();
	connect_clk_reset_start_all();
	sim_eval_all();
}

void synful_posedge_event(){
	unsigned int i;
	clk = 1;       // Toggle clock
	synful_eval();
	connect_clk_reset_start_all();
	sim_eval_all();
	//print total sent packet each 1024 clock cycles
	if(verbosity==1) if(nt_cycle&0x3FF) printf("\rTotal sent packet: %9d", total_sent_pck_num);
}





#endif
