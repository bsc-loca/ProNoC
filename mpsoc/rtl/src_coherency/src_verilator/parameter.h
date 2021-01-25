#ifndef PARAM_H
		#define PARAM_H

	#define	REPEAT_NUM	10000000
	#define	DEBUG_EN	1
	#define	T1	 4
	#define	T2	 4
	#define	T3	 2
	#define	T4	 1
	#define	B	 15
	#define	TOPOLOGY	"MESH"
	#define	ROUTE_NAME	"XY"
	#define	SYS_CACHE_EN	1
	#define	NUM_OF_RNs	15
	#define	NUM_OF_HNs	15
	#define	NUM_OF_SNs	2
	#define	SNPF_WAY_NUM	 8
	#define	SNPF_ADDRw	 44
	#define	SNPF_INDEXw	 10
	#define	CACHE_WAY_NUM	 8
	#define	CACHE_INDEXw	10
	#define	WRAP_REQ_W	64
	#define	MEM_RD_PIPE_LATENCY	50
	#define	MEM_WR_PIPE_LATENCY	500

	const char RN_ID[] ={1,3,5,7,9,11,13,15,17,19,21,23,25,27,29};
	const char HN_ID[] ={0,2,4,8,10,12,14,16,18,20,22,24,26,28,30};
	const char SN_ID[] ={6,31};
	//assigned snf id to each home node.
	const char HN_SN_ID[] ={0,1,0,1,0,1,0,1,0,1,0,1,0,1,0};
	const char HN_LOC_SN[] ={0,0,1,1,2,2,3,3,4,4,5,5,6,6,7};

#endif