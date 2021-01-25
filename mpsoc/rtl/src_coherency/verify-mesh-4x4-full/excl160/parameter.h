
#ifndef PARAM_H
	#define PARAM_H

	#define NUM_OF_RNs  4
	#define NUM_OF_HNs  4
	#define NUM_OF_SNs  1

    FILE * file[NUM_OF_RNs];


	void open_trace_files(){
		int i;
		file[0] = fopen("sample/validation_llsc-scalar_trace_0.bin","rb");
		file[1] = fopen("sample/validation_llsc-scalar_trace_0.bin","rb");
		file[2] = NULL;//fopen("sample/validation_llsc-scalar_trace_0.bin","rb");
		file[3] = NULL;//fopen("sample/validation_llsc-scalar_trace_0.bin","rb");

		for (i=0;i<2;i++){

			if (file[i] == NULL)
			{
				printf("Error while opening the trace file %u.\n",i);
				exit(EXIT_FAILURE);
			}
		}

	}

	#define REPEAT_NUM 10000000 

	#define DEBUG_EN 1
      	
      	//NoC param
	#define T1    3  
	#define T2    3  
	#define T3    1  
	#define T4    1  
	#define B     15
	#define TOPOLOGY  "MESH"
	#define ROUTE_NAME  "XY"


	//agent nums
	#define SYS_CACHE_EN  1


	#define SRCID_REQ 7

	const char RN_ID[] = {0,1,2,3};
	const char HN_ID[] = {4,5,6,7};
	const char SN_ID[] = {8};
	char HN_SN_ID[NUM_OF_HNs]; //assigned snf id to each home node. filled in initial function
    unsigned long int SN_HN_ID[NUM_OF_SNs]; //assigned hnf id to each snf. filled in initial function
       
	//snf param
	#define SNPF_WAY_NUM    8  
	#define SNPF_ADDRw      44  
	#define SNPF_INDEXw     10  
	#define CACHE_WAY_NUM   8  
	#define CACHE_INDEXw   10  

	//pck-injector 	
	#define WRAP_REQ_W  64  

	//snf param 
	#define MEM_RD_PIPE_LATENCY   50  
	#define MEM_WR_PIPE_LATENCY   500   

	#define  NE	(T1*T2*T3) 
	

#endif
