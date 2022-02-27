#ifndef _SYNFUL_WRAPPER_H
	#define  _SYNFUL_WRAPPER_H


#include <iostream>

#include "synful/synful.h"

bool synful_SSExit;
int  synful_random_seed=53432145;
int  synful_packets_left = 0;

extern queue_t** synful_inject;
       queue_t** synful_traverse;





void synful_init(char * fname, bool ss_exit, int seed){
	std::cout << "Initiating synful with: " << fname << "random seed:" << seed << std::endl;
    synful_model_init(fname, ss_exit,seed);

 	synful_inject   = (queue_t**) malloc( SYNFUL_ENDP_NUM * sizeof(queue_t*) );
 	synful_traverse = (queue_t**) malloc( SYNFUL_ENDP_NUM * sizeof(queue_t*) );

 	if(synful_inject == NULL || synful_traverse == NULL ) {
		printf( "ERROR: malloc fail queues\n" );
		exit(0);
	}
	for(int i = 0; i <  SYNFUL_ENDP_NUM; ++i ) {
		synful_inject[i]     = queue_new();
		synful_traverse[i]   = queue_new();
	}
}


void synful_final_report(){
	int i;

	if(verbosity==1) 	printf("\e[?25h");//To re-enable the cursor:
	printf("\nSynful simulation results-------------------\n"
			"\tSynful  end clock cycles: %llu\n"
	,synful_cycle);
	print_statistic_new (synful_cycle);
}



void synful_eval( ){
	int i;

	if((reset==1) || (count_en==0))	return;

	if((( synful_cycle > sim_end_clk_num) || (read_done==1 )) && synful_packets_left==0 )  simulation_done=1;

	// Reset packets remaining check
	synful_packets_left = 0;

	synful_run_one_cycle ();


	// Inject where possible (max one per node)
	for( i = 0; i < SYNFUL_ENDP_NUM; ++i ) {
		synful_packets_left |= !queue_empty( synful_inject[i] );
		//TODO define RRA if multiple netrace sources are mapped to one node. only one can sent packt at each cycle
		int pronoc_src =  netrace_to_pronoc_map[i];
		//TODO define sent vc policy
		int sent_vc = 0;

		if(pck_inj[pronoc_src]->pck_injct_in_pck_wr){
			//the wr_pck should be asserted only for single cycle
			pck_inj[pronoc_src]->pck_injct_in_pck_wr  	   = 0;
			continue;
		}

		pck_inj[pronoc_src]->pck_injct_in_pck_wr  	   = 0;
		if((pck_inj[pronoc_src]->pck_injct_out_ready & (0x1<<sent_vc)) == 0){
			//This pck injector is not ready yet
			continue;
		}

		pronoc_pck_t* temp_node = (pronoc_pck_t*) queue_peek_front( synful_inject[i] );
		if( temp_node != NULL ) {
			if(verbosity>1) {
				printf( "Inject: %llu ", synful_cycle );
				synful_print_packet( temp_node );
			}
			temp_node = (pronoc_pck_t*) queue_pop_front( synful_inject[i] );
			queue_push( synful_traverse[temp_node->dest], temp_node, synful_cycle );
			int flit_num = temp_node->packetSize; //TODO set according to Fpay size
			int pronoc_dst =  netrace_to_pronoc_map[temp_node->dest];
			if(flit_num< pck_inj[pronoc_src]->min_pck_size) flit_num = pck_inj[pronoc_src]->min_pck_size;
			if(IS_SELF_LOOP_EN ==0){
				if(temp_node->dest == pronoc_src ){
					 fprintf(stderr,"ERROR: ProNoC is not configured with self-loop enable and Netrace aims to inject\n a "
							 "packet with identical source and destination address. Enable the SELF_LOOP parameter\n"
							 "in ProNoC and rebuild the simulation model\n");
					 exit(1);
				}
			}

			unsigned int sent_class =0;
			long int ptr_addr = reinterpret_cast<long int> (temp_node);
			pck_inj[pronoc_src]->pck_injct_in_data         = ptr_addr;
			pck_inj[pronoc_src]->pck_injct_in_size         = temp_node->packetSize;
			pck_inj[pronoc_src]->pck_injct_in_endp_addr    = endp_addr_encoder(pronoc_dst);
			pck_inj[pronoc_src]->pck_injct_in_class_num    = sent_class;
			pck_inj[pronoc_src]->pck_injct_in_init_weight  = 1;
			pck_inj[pronoc_src]->pck_injct_in_vc           = 0x1<<sent_vc;
			pck_inj[pronoc_src]->pck_injct_in_pck_wr  	   = 1;
			total_sent_pck_num++;

			#if (C>1)
				sent_stat[pronoc_src][sent_class].pck_num ++;
				sent_stat[pronoc_src][sent_class].flit_num +=flit_num;
			#else
				sent_stat[pronoc_src].pck_num ++;
				sent_stat[pronoc_src].flit_num +=flit_num;
			#endif
		}//temp!=NULL
	}//inject



	// Step all network components, Eject where possible
	for( i = 0; i < NE; ++i ) {
		synful_packets_left |= !queue_empty( synful_traverse[i] );
		//check which pck injector got a packet
		if(pck_inj[i]->pck_injct_out_pck_wr==0) continue;
		//we have got a packet
		//printf( "data=%lx\n",pck_inj[i]->pck_injct_out_data);

		pronoc_pck_t* temp_node = (pronoc_pck_t*)  pck_inj[i]->pck_injct_out_data;
		if( temp_node != NULL ) {
			if(verbosity>1) {
				printf( "Eject: %llu ", synful_cycle );
				synful_print_packet(temp_node);
			}
			//send it to synful
			synful_Eject (temp_node);

			// remove from traverse

			queue_remove( synful_traverse[i], temp_node );
			unsigned long long int    clk_num_h2t= (synful_cycle - temp_node->cycle);
			unsigned int    clk_num_h2h= clk_num_h2t - pck_inj[i]->pck_injct_out_h2t_delay;
			/*
				printf("clk_num_h2t (%llu) h2t_delay(%u)\n", clk_num_h2t , pck_inj[i]->pck_injct_out_h2t_delay);
				if(clk_num_h2t < pck_inj[i]->pck_injct_out_h2t_delay){
					fprintf(stderr, "ERROR:clk_num_h2t (%llu) is smaller than  injector h2t_delay(%u)\n", clk_num_h2t , pck_inj[i]->pck_injct_out_h2t_delay);
					exit(1);
				}
			*/
			update_statistic_at_ejection (
					i,//	core_num
					clk_num_h2h, // clk_num_h2h,
					(unsigned int) clk_num_h2t, // clk_num_h2t,
					pck_inj[i]->pck_injct_out_distance, //    distance,
					pck_inj[i]->pck_injct_out_class_num,//  	class_num,
					temp_node->source//		unsigned int 	src
			);
			#if(C>1)
				rsvd_stat[i][pck_inj[i]->pck_injct_out_class_num].flit_num +=pck_inj[i]->pck_injct_out_size;
	   		#else
				rsvd_stat[i].flit_num+=pck_inj[i]->pck_injct_out_size;
			#endif
				free( temp_node );

		}//emp_node != NULL
	}//for

	synful_cycle++;

	//std::cout << synful_cycle << std::endl;

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
	update_all_router_stat();
	synful_eval();
	connect_clk_reset_start_all();
	sim_eval_all();
	//print total sent packet each 1024 clock cycles
	if(verbosity==1) if(synful_cycle&0x3FF) printf("\rTotal sent packet: %9d", total_sent_pck_num);
}





#endif
