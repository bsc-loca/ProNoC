#define MAX_ACTORS 1024


typedef signed char i8;
typedef short i16;
typedef int i32;
typedef long long int i64;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long int u64;

///////////////////////////////////////////////////

#ifndef CACHELINE_SIZE
#define CACHELINE_SIZE 64 // Standard size for x86 processors
#endif

// Declare the FIFO structure with a size equal to (size)
#define DECLARE_FIFO(type, size, count, readersnb) static type array_##count[(size)]; \
static unsigned int read_inds_##count[readersnb] = {0}; \
static FIFO_T(type) fifo_##count = {{0}, read_inds_##count, {0}, 0, {0}, array_##count};

#define FIFO_T(T) FIFO_T_EXPAND(T)
#define FIFO_T_EXPAND(T) fifo_##T##_t

#define FIFO_GET_ROOM(T) FIFO_GET_ROOM_EXPAND(T)
#define FIFO_GET_ROOM_EXPAND(T) fifo_ ## T ## _get_room

#define FIFO_GET_NUM_TOKENS(T) FIFO_GET_NUM_TOKENS_EXPAND(T)
#define FIFO_GET_NUM_TOKENS_EXPAND(T) fifo_ ## T ## _get_num_tokens

/* Define structure and methods for all types thanks to macro expansion */

#define T i8
#include "generic_fifo.h"
#undef T

#define T i16
#include "generic_fifo.h"
#undef T

#define T i32
#include "generic_fifo.h"
#undef T

#define T i64
#include "generic_fifo.h"
#undef T

#define T u8
#include "generic_fifo.h"
#undef T

#define T u16
#include "generic_fifo.h"
#undef T

#define T u32
#include "generic_fifo.h"
#undef T

#define T u64
#include "generic_fifo.h"
#undef T

#define T float
#include "generic_fifo.h"
#undef T

//#endif  /* _ORCC_FIFO_H_ */

///////////////////////////////////////////////////


typedef int boolean;
#define TRUE  1
#define FALSE 0

/* Scheduling strategy codes */
typedef enum {
    ORCC_SS_ROUND_ROBIN,
    ORCC_SS_DD_DRIVEN, /* data-driven & demand-driven */
    ORCC_SS_SIZE /* only used for string tab declaration */
} schedstrategy_et;

/* Mapping strategy codes */
typedef enum {
#ifdef METIS_ENABLE
    ORCC_MS_METIS_REC,
    ORCC_MS_METIS_KWAY_CV,
    ORCC_MS_METIS_KWAY_EC,
#endif /* METIS_ENABLE */
    ORCC_MS_ROUND_ROBIN,
    ORCC_MS_QM,
    ORCC_MS_WLB,
    ORCC_MS_COWLB,
    ORCC_MS_KRWLB,
    ORCC_MS_SIZE /* only used for string tab declaration */
} mappingstrategy_et;

typedef enum reasons {
    starved,
    full
} reasons_t;

typedef struct actor_s actor_t;
typedef struct waiting_s waiting_t;
typedef struct agent_s agent_t;
typedef struct action_s action_t;
typedef struct local_scheduler_s local_scheduler_t;
typedef struct schedinfo_s schedinfo_t;
typedef struct options_s options_t;
typedef struct global_scheduler_s global_scheduler_t;
typedef struct mapping_s mapping_t;
typedef struct network_s network_t;
typedef struct connection_s connection_t;

/*
 * Actors are the vertices of orcc Networks
 */
struct actor_s {
    char *name;
    void (*init_func)();
    void (*sched_func)(schedinfo_t *);
    int num_inputs; /** number of input ports */
    int num_outputs; /** number of output ports */
    int in_list; /** set to 1 when the actor is in the schedulable list. Used by add_schedulable to do the membership test in O(1). */
    int in_waiting; /** idem with the waiting list. */
    local_scheduler_t *sched; /** scheduler which execute this actor. */
    int processor_id; /** id of the processor core mapped to this actor. */
    int id;
    int commCost;  /** Used by Quick Mapping algo */
    int triedProcId;  /** Used by Quick Mapping algo */
    int evaluated;  /** Used by KL algo */
    int workload; /** actor's workload */
    double ticks; /** elapsed ticks obtained by profiling */
    action_t **actions;
    int nb_actions;
    double scheduler_workload;
    char *class_name;
    int firings; /** nb of firings for profiling */
    int switches; /** nb of switches for profiling */
    int misses; /** nb of misses for profiling */
};


struct waiting_s {
    actor_t *waiting_actors[MAX_ACTORS];
    volatile unsigned int next_entry;
    unsigned int next_waiting;
};



struct agent_s {
    options_t *options; /** Mapping options */
    global_scheduler_t *scheduler;
    network_t *network;
    mapping_t *mapping;
    int nb_threads;
#ifdef THREADS_ENABLE
    orcc_semaphore_t sem_agent;
#endif
};


/*
 * Actions
 */
struct action_s {
    char *name;
    double workload; /** action's workload */
    double ticks; /** elapsed ticks obtained by profiling */
    double min_ticks; /** elapsed min clockcycles obtained by profiling */
    double avg_ticks; /** elapsed average clockcycles obtained by profiling */
    double max_ticks; /** elapsed max clockcycles obtained by profiling */
    double variance_ticks; /** elapsed clockcycles variance obtained by profiling */
    int firings; /** nb of firings for profiling */
};



struct schedinfo_s {
    int num_firings;
    reasons_t reason;
    int ports; /** contains a mask that indicate the ports affected */
};

struct options_s
{
    /* Video specific options */
    char *input_file;
    char *input_directory;               // Directory for input files.

    /* Video specific options */
    char display_flags;                  // Display flags
    int nbLoops;                         // (Deprecated) Number of times the input file is read
    int nbFrames;                        // Number of frames to display before closing application
    char *yuv_file;                      // Reference YUV file

    /* Runtime options */
    schedstrategy_et sched_strategy;     // Strategy for the actor scheduling
    char *mapping_input_file;            // Predefined mapping configuration
    char *mapping_output_file;           //
    int nb_processors;
    boolean enable_dynamic_mapping;
    mappingstrategy_et mapping_strategy; // Strategy for the actor mapping
    int nbProfiledFrames;                // Number of frames to display before remapping application
    int mapping_repetition;              // Repetition of the actor remapping

    char *profiling_file; // profiling file
    char *write_file; // write file

    /* Debugging options */
    boolean print_firings;
};



struct global_scheduler_s {
    local_scheduler_t **schedulers;
    int nb_schedulers;
    agent_t *agent;
};

/*
 * Mapping structure store the mapping result
 */
struct mapping_s {
    int number_of_threads;
    int *threads_affinities;
    actor_t ***partitions_of_actors;
    int *partitions_size;
};

/*
 * Orcc Networks are directed graphs
 */
struct network_s {
    char *name;
    actor_t **actors;
    connection_t **connections;
    int nb_actors;
    int nb_connections;
};

/*
 * Connections are the edges of orcc Networks
 */
struct connection_s {
    actor_t *src;
    actor_t *dst;
    int workload; /** connections's workload */
    long rate; /** communication rate obtained by profiling */
};





struct local_scheduler_s {
    int id; /** Unique ID of this scheduler */
    int nb_schedulers;
    schedstrategy_et strategy; /** Scheduling strategy */

    /* Round robin */
    int num_actors; /** number of actors managed by this scheduler */
    actor_t **actors; /** static list of actors managed by this scheduler */
    int rr_next_schedulable; /** index of the next actor to schedule in last list */

    /* Data demand/driven scheduler */
    actor_t *schedulable[MAX_ACTORS]; /** dynamic list of the next actors to schedule */
    unsigned int ddd_next_entry; /** index of the next actor to schedule in last list */
    unsigned int ddd_next_schedulable; /** index of next actor added in the list */

    /* Multicore with data demand/driven scheduler */
    int round_robin; /** set to 1 when last scheduled actor is a result of round robin scheduling */
    waiting_t **waiting_schedulable; /** receiving lists from other schedulers of some actors to schedule */

    /* Mapping synchronization */
    agent_t *agent;
#ifdef THREADS_ENABLE
    orcc_semaphore_t sem_thread;
#endif
};


/////////////////////////////////////////////////////////
void error_handelling_function(){
	unsigned int i;
	for (i=0;i<ni_NUM_VCs;i++){
			if(ni_ERROR_FLAGS_REG(i)){
				printf ("Error in vc %u\n",i);
				if(ni_ERROR_FLAGS_REG(i) & BUFF_OVER_FLOW_ERR) printf ("The receiver allocated buffer size is smaller than the received packet size in core%u\n",COREID);
				if(ni_ERROR_FLAGS_REG(i) & SEND_DATA_SIZE_ERR)  printf ("the send data size is not set in core%u\n",COREID);
				if(ni_ERROR_FLAGS_REG(i) & BURST_SIZE_ERR)	 printf (" the burst size is not set in core%u\n",COREID);
				if(ni_ERROR_FLAGS_REG(i) & ILLEGAL_SEND_REQ)  printf( "A new send request is received while the DMA is still busy sending previous packet in core%u\n",COREID);
				if(ni_ERROR_FLAGS_REG(i) & CRC_MISS_MATCH)	    printf( "CRC missmatch in core%u\n",COREID);

		 } 
	}
}


/*
transfer_manage
	w: initial weight
	v: Virtual channel number
	class_num: message class number
	dest_port: destination queue number
	queue_pointer: address in byte
	queue_size: queue size in byte
	start_index: start index byte number
	end_index:  end index byte number
	dest_phy_addr
	credit: Number of byte available in destination queue
*/



unsigned int  transfer_manage (unsigned int w, unsigned int v, unsigned int class_num, unsigned char dest_port, unsigned int queue_pointer,unsigned int queue_size, unsigned int start_index,  unsigned int end_index, unsigned int dest_phy_addr,unsigned int credit){
    
//printf ( "core:%u transfer_manage (w=%u, v=%u, c=%u, dest_port=%u, queue_pointer=%u, queue_size=%u,  start_index=%u, end_index=%u,dest_phy_addr=%u, credit=%u", COREID,
// w,  v,  class_num,  dest_port,  queue_pointer, queue_size,  start_index,  end_index,  dest_phy_addr, credit);
   

	unsigned int start_addr_pointer;
	unsigned int data_size;
    if (ni_send_is_busy(v)) return 0 ; // if VC is busy sending previous packet do nothing

    unsigned int start_addr_in_Q = start_index % queue_size;
    start_addr_pointer = queue_pointer + start_addr_in_Q;

// printf("start_addr_pointer(%u) = queue_pointer(%u) + start_addr_in_Q(%u)\n)", start_addr_pointer , queue_pointer , start_addr_in_Q);

    data_size =  end_index-start_index;

    if(data_size> credit) data_size =  credit; // we dont want to send more data than the receiver credit

    if((start_addr_in_Q + data_size)> queue_size) data_size =  queue_size-start_addr_in_Q; // we only send data until end of the queque. The rest will be sent in next round starting from begining of the queue   

	if(data_size>0) ni_transfer (w, v, class_num, dest_port , start_addr_pointer, data_size, dest_phy_addr);

    return data_size;   
}




// a simple delay function
void delay ( unsigned int num ){
	
	while (num>0){ 
		num--;
		nop(); // asm volatile ("nop");
	}
	return;

}


#ifndef RANDOM_H
	#define RANDOM_H

// KISS is one random number generator according to three numbers.
static unsigned int x=123456789,y=234567891,z=345678912,w=456789123,c=0; 

unsigned int JKISS32() { 
    unsigned int t; 

    y ^= (y<<5); y ^= (y>>7); y ^= (y<<22); 

    t = z+w+c; z = w; c = t < 0; w = t&2147483647; 

    x += 1411392427; 

    return x + y + w; 
}

unsigned int rand(void){
	return JKISS32();
}

void srand(unsigned int seed){
	x^=seed; y+=seed; z^=seed; w-=seed;
}



#endif
