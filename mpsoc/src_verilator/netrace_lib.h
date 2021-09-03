#ifndef NETRACE_LIB_H
#define NETRACE_LIB_H


#include "netrace-1.0/queue.h"
#include "netrace-1.0/netrace.h"
#include "netrace-1.0/queue.c"
#include "netrace-1.0/netrace.c"


extern int reset,clk;
extern char simulation_done;
extern void connect_clk_reset_start_all(void);
extern void sim_eval_all (void);
extern void topology_connect_all_nodes (void);
extern Vpck_inj        *pck_inj[NE];
extern unsigned int  count_en;
extern unsigned long int main_time;     // Current simulation time

#define L2_LATENCY 8


int ignore_dependencies = 0;
int start_region = 0;
int reader_throttling = 0;
unsigned long long int nt_cycle=0;
nt_header_t* header;
queue_t** waiting;
queue_t** inject;
queue_t** traverse;
nt_packet_t* trace_packet = NULL;
nt_packet_t* packet = NULL;
int nt_packets_left = 0;

int netrace_to_pronoc_map [64];
int pronoc_to_netrace_map [NE];
int pck_injct_in_pck_wr[NE];



typedef struct queue_node queue_node_t;
struct queue_node {
	nt_packet_t* packet;
	unsigned long long int cycle;
};


unsigned long long int calc_packet_timing( nt_packet_t* packet ) {
	
	int n_hops = abs( packet->src -  packet->dst );
	if( n_hops <= 0 ) n_hops = 1;
	return 3*n_hops;
}



void netrace_init( char * tracefile){
    int i=0;
	nt_open_trfile( tracefile );
	if( ignore_dependencies ) {
		nt_disable_dependencies();
		printf("\tDependencies is turned off in tracking cleared packets list\n");
	}
	nt_print_trheader();
	header = nt_get_trheader();
	nt_seek_region( &header->regions[start_region] );
	for(i = 0; i < start_region; i++ ) {
		nt_cycle += header->regions[i].num_cycles;
	}
	if(nt_cycle) printf("\tThe simulation start at region %u and %llu cycle\n",start_region,nt_cycle);

	waiting  = (queue_t**) malloc( header->num_nodes * sizeof(queue_t*) );
	inject   = (queue_t**) malloc( header->num_nodes * sizeof(queue_t*) );
	traverse = (queue_t**) malloc( header->num_nodes * sizeof(queue_t*) );
	if( (waiting == NULL) || (inject == NULL) || (traverse == NULL) ) {
		printf( "ERROR: malloc fail queues\n" );
		exit(0);
	}
	for( i = 0; i < header->num_nodes; ++i ) {
		waiting[i]  = queue_new();
		inject[i]   = queue_new();
		traverse[i] = queue_new();
	}

	if( !reader_throttling ) {
		trace_packet = nt_read_packet();
	} else if( !ignore_dependencies ) {
		nt_init_self_throttling();
	}

}




void netrace_posedge_event(){
	int i;
	clk = 1;       // Toggle clock
	if(reset | (count_en==0)){
		connect_clk_reset_start_all();
		sim_eval_all();
		return;
	}
	if(( nt_cycle > header->num_cycles ) && nt_packets_left==0 )  simulation_done=1;
	// Reset packets remaining check
	nt_packets_left = 0;

	// Get packets for this cycle
	if( reader_throttling ) {
		nt_packet_list_t* list;
		for( list = nt_get_cleared_packets_list(); list != NULL; list = list->next ) {
			if( list->node_packet != NULL ) {
				trace_packet = list->node_packet;
				queue_node_t* new_node = (queue_node_t*) nt_checked_malloc( sizeof(queue_node_t) );
				new_node->packet = trace_packet;
				new_node->cycle = (trace_packet->cycle > nt_cycle) ? trace_packet->cycle : nt_cycle;
				queue_push( inject[trace_packet->src], new_node, new_node->cycle );
			} else {
				printf( "ERROR: Malformed packet list" );
				exit(-1);
			}
		}
		nt_empty_cleared_packets_list();
	} else {
		while( (trace_packet != NULL) && (trace_packet->cycle == nt_cycle) ) {
			// Place in appropriate queue
			queue_node_t* new_node = (queue_node_t*) nt_checked_malloc( sizeof(queue_node_t) );
			new_node->packet = trace_packet;
			new_node->cycle = (trace_packet->cycle > nt_cycle) ? trace_packet->cycle : nt_cycle;
			if( ignore_dependencies || nt_dependencies_cleared( trace_packet ) ) {
				// Add to inject queue
				queue_push( inject[trace_packet->src], new_node, new_node->cycle );
			} else {
				// Add to waiting queue
				queue_push( waiting[trace_packet->src], new_node, new_node->cycle );
			}
			// Get another packet from trace
			trace_packet = nt_read_packet();
		}
		if( (trace_packet != NULL) && (trace_packet->cycle < nt_cycle) ) {
			// Error check: Crash and burn
			printf( "ERROR: Invalid trace_packet cycle time: %llu, current cycle: %llu\n", trace_packet->cycle, nt_cycle );
			exit(-1);
		}
	}

	// Inject where possible (max one per node)
	for( i = 0; i < header->num_nodes; ++i ) {
		nt_packets_left |= !queue_empty( inject[i] );
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

		queue_node_t* temp_node = (queue_node_t*) queue_peek_front( inject[i] );
		if( temp_node != NULL ) {
			packet = temp_node->packet;
			if( (packet != NULL) && (temp_node->cycle <= nt_cycle) ) {


				printf( "Inject: %llu ", nt_cycle );
				nt_print_packet( packet );

				temp_node = (queue_node_t*) queue_pop_front( inject[i] );
				temp_node->cycle = nt_cycle + calc_packet_timing( packet );
				queue_push( traverse[packet->dst], temp_node, temp_node->cycle );
				//Inject this packet to ProNoC
				printf("\tInject packet to ProNoC:\n");
				printf ("\t\tsize=%u\n", nt_get_packet_size(packet));
				printf ("\t\tdst=%u\n", packet->dst);
				printf ("\t\tsrc=%u, i=%u\n", packet->src,i);
				long int ptr_addr = reinterpret_cast<long int> (temp_node);
				printf ("\t\tpacket pointer addr: %lx\n" ,ptr_addr);


				int flit_num = (nt_get_packet_size(packet)* 8) / Fpay;
				int pronoc_dst =  netrace_to_pronoc_map[packet->dst];

				pck_inj[pronoc_src]->pck_injct_in_data         = ptr_addr;
				pck_inj[pronoc_src]->pck_injct_in_size         = flit_num;
				pck_inj[pronoc_src]->pck_injct_in_endp_addr    = endp_addr_encoder(pronoc_dst);
				pck_inj[pronoc_src]->pck_injct_in_class_num    = 0;
				pck_inj[pronoc_src]->pck_injct_in_init_weight  = 1;
				pck_inj[pronoc_src]->pck_injct_in_vc           = 0x1<<sent_vc;
				pck_inj[pronoc_src]->pck_injct_in_pck_wr  	   = 1;

			}
		}
	}

/*
	// Step all network components, Eject where possible
		for( i = 0; i < header->num_nodes; ++i ) {
			nt_packets_left |= !queue_empty( traverse[i] );
			queue_node_t* temp_node = (queue_node_t*) queue_peek_front( traverse[i] );
			if( temp_node != NULL ) {
				packet = temp_node->packet;
				if( (packet != NULL) && (temp_node->cycle <= nt_cycle) ) {
					printf( "Eject: %llu ", nt_cycle );
					nt_print_packet( packet );
					nt_clear_dependencies_free_packet( packet );
					temp_node = (queue_node_t*) queue_pop_front( traverse[i] );
					free( temp_node );
				}
			}
		}
*/

	// Step all network components, Eject where possible
	for( i = 0; i < NE; ++i ) {
		nt_packets_left |= !queue_empty( traverse[i] );
		//check which pck injector got a packet
		if(pck_inj[i]->pck_injct_out_pck_wr==0) continue;
		//we have got a packet
		printf( "data=%lx\n",pck_inj[i]->pck_injct_out_data);

		queue_node_t* temp_node = (queue_node_t*)  pck_inj[i]->pck_injct_out_data;
		if( temp_node != NULL ) {
			packet = temp_node->packet;
			if( packet != NULL){
				printf( "ProNoC Eject: %llu ", nt_cycle );
				nt_print_packet( packet );
				// remove from traverse
				nt_clear_dependencies_free_packet( packet );
				queue_remove( traverse[packet->src], temp_node );
				free( temp_node );
			}
		}
	}
		// Check for cleared dependences... or not
		if( !reader_throttling ) {
		for( i = 0; i < header->num_nodes; ++i ) {
			nt_packets_left |= !queue_empty( waiting[i] );
			node_t* temp = waiting[i]->head;
			while( temp != NULL ) {
				queue_node_t* temp_node = (queue_node_t*) temp->elem;
				packet = temp_node->packet;
				temp = temp->next;
				if( nt_dependencies_cleared( packet ) ) {
					// remove from waiting
					queue_remove( waiting[i], temp_node );
					// add to inject
					queue_node_t* new_node = (queue_node_t*) nt_checked_malloc( sizeof(queue_node_t) );
					new_node->packet = packet;
					new_node->cycle = nt_cycle + L2_LATENCY;
					queue_push( inject[i], new_node, new_node->cycle );
					free( temp_node );
				}
			}
		}
	}
		nt_cycle++;

	connect_clk_reset_start_all();
	sim_eval_all();

}


void netrace_clk_negedge_event( ){
	int i;
	clk = 0;
	topology_connect_all_nodes ();
	connect_clk_reset_start_all();
	sim_eval_all();

}


#endif
