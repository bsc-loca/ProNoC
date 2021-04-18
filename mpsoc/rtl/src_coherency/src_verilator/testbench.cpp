#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <verilated.h>          // Defines common routines
#include <inttypes.h>
#include <byteswap.h>

#include "Vinject.h"
//#include "Vrnf.h"
#include "Vhnf.h"
#include "Vsnf.h"
#include "Vdatrouter.h"
#include "Vreqrouter.h"
#include "Vrsprouter.h"
#include "Vsnprouter.h"

#include "parameter.h"
#include "topology.h"


Vinject        *inject[NUM_OF_RNs];
//Vrnf           *rnf        ;
Vhnf           *hnf [NUM_OF_HNs];
Vsnf           *snf [NUM_OF_SNs];
Vdatrouter     *datrouter [NR];
Vreqrouter     *reqrouter [NR];
Vrsprouter     *rsprouter [NR];
Vsnprouter     *snprouter [NR];

FILE * file[NUM_OF_RNs];
FILE *e; //error file

int reset,clk;
unsigned int main_time = 0; // Current simulation time


unsigned int done_counter;
unsigned int clk_counter,last_counter;
unsigned int start_time=0;


struct rnf_counters_struct {
		unsigned int min_txn_period_time;
		unsigned int max_txn_period_time;
		unsigned int total_txn_num;
		unsigned long int accum_txn_time;
		unsigned int txn_start_time[256];	
};	

struct flit_counters_struct {
		unsigned int req_snt;
		unsigned int dat_snt;
		unsigned int rsp_snt;
		unsigned int snp_snt;
		
		unsigned int req_rsv;
		unsigned int dat_rsv;
		unsigned int rsp_rsv;
		unsigned int snp_rsv;		
};	


struct rnf_counters_struct rnf_counters [NUM_OF_RNs];
struct flit_counters_struct rnf_flits [NUM_OF_RNs];
struct flit_counters_struct hnf_flits [NUM_OF_HNs];
struct flit_counters_struct snf_flits [NUM_OF_SNs];

void report_performance(void);
void update_error_file (FILE *, const char * , unsigned int , unsigned int );

unsigned int trace_line[NUM_OF_RNs];
unsigned int injct_done=0;

void open_trace_files(void);

void initial_noc_param(){

	open_trace_files();
	

	while((0x1<<nxw) < T1){nxw++;maskx<<=1; maskx|=1;}
	while((0x1<<nyw) < T2){nyw++;masky<<=1; masky|=1;}

	unsigned int i,SN_NUM,HN_NUM_IN_SN,snf_id,j;
		
    int tmp=0;

     //initial inputs
	for (i=0;i<NUM_OF_RNs;i++){
		inject[i]->wrapreq = 0;
		inject[i]->wrapreqvalid=0;
		trace_line[i]=0;
		if(file[i]==NULL) 		injct_done|= (1<<i);
		memset(&rnf_counters [i], tmp, sizeof(rnf_counters [i]));
		rnf_counters [i].min_txn_period_time=-1;
		for (j=0;j<256;j++) rnf_counters [i].txn_start_time[j]=0;
		rnf_flits [i].dat_snt=0;
		rnf_flits [i].rsp_snt=0;
		rnf_flits [i].req_snt=0;
		rnf_flits [i].snp_snt=0;
		rnf_flits [i].dat_rsv=0;
		rnf_flits [i].rsp_rsv=0;
		rnf_flits [i].req_rsv=0;
		rnf_flits [i].snp_rsv=0;
	}
	
	for (i=0;i<NUM_OF_HNs;i++){
		hnf_flits [i].dat_snt=0;
		hnf_flits [i].rsp_snt=0;
		hnf_flits [i].req_snt=0;
		hnf_flits [i].snp_snt=0;
		hnf_flits [i].dat_rsv=0;
		hnf_flits [i].rsp_rsv=0;
		hnf_flits [i].req_rsv=0;
		hnf_flits [i].snp_rsv=0;
	}
	
	for (i=0;i<NUM_OF_SNs;i++){
		snf_flits [i].dat_snt=0;
		snf_flits [i].rsp_snt=0;
		snf_flits [i].req_snt=0;
		snf_flits [i].snp_snt=0;
		snf_flits [i].dat_rsv=0;
		snf_flits [i].rsp_rsv=0;
		snf_flits [i].req_rsv=0;
		snf_flits [i].snp_rsv=0;
	}		

}

void display_exe_path(char** argv){
	char cwd[1024];
	getcwd(cwd, sizeof(cwd));
	printf("Exe file path is: %s\%s\n", cwd,&argv[0][1]);
}


inline void eval_all(){
	int i;
	for (i=0;i<NUM_OF_RNs;i++) 	inject[i]->eval();
	for (i=0;i<NUM_OF_HNs;i++)  hnf[i]->eval();
	for (i=0;i<NUM_OF_SNs;i++)  snf[i]->eval();
	for (i=0;i<NR;i++){
		datrouter[i]->eval();
		reqrouter[i]->eval();
		rsprouter[i]->eval();
		snprouter[i]->eval();
	}
}

inline void final_all(){
	int i;
	for (i=0;i<NUM_OF_RNs;i++) 	inject[i]->final();
	for (i=0;i<NUM_OF_HNs;i++)  hnf[i]->final();
	for (i=0;i<NUM_OF_SNs;i++)  snf[i]->final();
	for (i=0;i<NR;i++){
		datrouter[i]->final();
		reqrouter[i]->final();
		rsprouter[i]->final();
		snprouter[i]->final();
	}
	report_performance();	
	
}




#define connectr(r,i,p,dst_id,dst_p)   r[i]->router_flit_in_wr[p] = r[dst_id]->router_flit_out_wr[dst_p];\
r[i]->router_credit_in[p] = r[dst_id]->router_credit_out[dst_p];\
r[i]->router_congestion_in[p] = r[dst_id]->router_congestion_out[dst_p] ;\
memcpy(r[i]->router_flit_in[p], r[dst_id]->router_flit_out[dst_p],sizeof(r[i]->router_flit_in[p]))


#define connect_gnd(r,i,p)   r[i]->router_flit_in_wr[p] = 0;\
r[i]->router_credit_in[p] = 0;\
r[i]->router_congestion_in[p] = 0

#define connect_clk(r,i,p) r[i]->clk=clk; r[i]->reset=reset; r[i]->CURRENT_ADDR =router_addr_encoder(i)

void connect_all_r2r() {
	// connect routers
	unsigned int i,j,pp;
	unsigned int  dst_id;
	unsigned int  dst_p;
	
	
	
	unsigned int R2R_chanelS_MESH_TORI =  (IS_RING || IS_LINE)? 2 : 4;
	
	for (i=0;i<NR;i++){
		connect_clk(datrouter,i,pp);
		connect_clk(rsprouter,i,pp);
		connect_clk(reqrouter,i,pp);
		connect_clk(snprouter,i,pp);

		for (pp=0;pp<R2R_chanelS_MESH_TORI;pp++){

			get_connected_router_mesh (i , pp, &dst_id, &dst_p);

			if(dst_id==-1 || dst_p==-1 ){

				connect_gnd(datrouter,i,pp);
				connect_gnd(rsprouter,i,pp);
				connect_gnd(reqrouter,i,pp);
				connect_gnd(snprouter,i,pp);


			}else{
				//printf ("connected_router_mesh (%u , %u, %u, %u);\n",i , pp, dst_id, dst_p);

				connectr(datrouter,i,pp,dst_id,dst_p);
				connectr(rsprouter,i,pp,dst_id,dst_p);
				connectr(reqrouter,i,pp,dst_id,dst_p);
				connectr(snprouter,i,pp,dst_id,dst_p);


			}


		}
	}

}

#define connect_agent(T,r,rid,eid,a,aid) \
	r[rid]->chi_noc_tx##T##flitpend[eid] = a[aid]->chi_noc_tx##T##flitpend;\
	r[rid]->chi_noc_tx##T##flitv[eid]    = a[aid]->chi_noc_tx##T##flitv;\
	memcpy(&r[rid]->chi_noc_tx##T##flit[eid], a[aid]->chi_noc_tx##T##flit, sizeof(  r[rid]->chi_noc_tx##T##flit[eid]) );\
	a[aid]->noc_chi_tx##T##lcrdv =   r[rid]->noc_chi_tx##T##lcrdv[eid];\
	a[aid]->noc_chi_rx##T##flitpend=  r[rid]->noc_chi_rx##T##flitpend[eid];\
	a[aid]->noc_chi_rx##T##flitv=  r[rid]->noc_chi_rx##T##flitv[eid];\
	memcpy(&a[aid]->noc_chi_rx##T##flit,  r[rid]->noc_chi_rx##T##flit[eid],sizeof(a[aid]->noc_chi_rx##T##flit));\
	r[rid]->chi_noc_rx##T##lcrdv[eid] =a[aid]->chi_noc_rx##T##lcrdv


#define connect_agent_small(T,r,rid,eid,a,aid) \
	r[rid]->chi_noc_tx##T##flitpend[eid] = a[aid]->chi_noc_tx##T##flitpend;\
	r[rid]->chi_noc_tx##T##flitv[eid]    = a[aid]->chi_noc_tx##T##flitv;\
	r[rid]->chi_noc_tx##T##flit[eid]     = a[aid]->chi_noc_tx##T##flit;\
	a[aid]->noc_chi_tx##T##lcrdv =   r[rid]->noc_chi_tx##T##lcrdv[eid];\
	a[aid]->noc_chi_rx##T##flitpend=  r[rid]->noc_chi_rx##T##flitpend[eid];\
	a[aid]->noc_chi_rx##T##flitv=  r[rid]->noc_chi_rx##T##flitv[eid];\
	a[aid]->noc_chi_rx##T##flit=  r[rid]->noc_chi_rx##T##flit[eid];\
	r[rid]->chi_noc_rx##T##lcrdv[eid] =a[aid]->chi_noc_rx##T##lcrdv


 void connect_agents_2r (){
	int i,j;
	int endp_num_in_router,router_id;
	for (i=0;i<NUM_OF_RNs;i++){
		endp_num_in_router = RN_ID[i] % NL;//valid for mesh tori line ring
		router_id = RN_ID[i] / NL;
		//printf("router_id =%u\n",router_id );
		connect_agent(dat,datrouter,router_id,endp_num_in_router,inject,i);
		connect_agent(req,reqrouter,router_id,endp_num_in_router,inject,i);
		connect_agent(snp,snprouter,router_id,endp_num_in_router,inject,i);
		//printf ("r%u\n",i);
		connect_agent_small(rsp,rsprouter,router_id,endp_num_in_router,inject,i);


		inject[i]->clk=clk;
		inject[i]->reset=reset;
		inject[i]->src_id=RN_ID[i];
		inject[i]->RN_NUM=i;
		//printf("inject[%u]->src_id=%u",i,RN_ID[i]);
	}
		
	for (i=0;i<NUM_OF_HNs;i++){
		endp_num_in_router = HN_ID[i] % NL;//valid for mesh tori line ring
		router_id = HN_ID[i] / NL;
		
		
		snprouter[router_id]->snp_target_id[endp_num_in_router] = hnf[i]->snp_target_id;
		connect_agent(dat,datrouter,router_id,endp_num_in_router,hnf,i);
		connect_agent_small(rsp,rsprouter,router_id,endp_num_in_router,hnf,i);
		connect_agent(req,reqrouter,router_id,endp_num_in_router,hnf,i);
		connect_agent(snp,snprouter,router_id,endp_num_in_router,hnf,i);
		hnf[i]->clk=clk;
		hnf[i]->reset=reset;
		hnf[i]->src_id=HN_ID[i];
		hnf[i]->snf_id=SN_ID[HN_SN_ID[i]];
		
		// SNF_ID =HN_SN_ID[i],
        // ASSIGNED_SNF_ENDP_ID = SN_ID[SNF_ID],
        // HNF_END_ID = HN_ID[i],
        // HN_NUM_IN_SN = HN_LOC_SN[i];
        // assign assign_hnfs [SNF_ID ][(HN_NUM_IN_SN+1)*SRCID_REQ-1 : HN_NUM_IN_SN*SRCID_REQ]  =  HNF_END_ID[SRCID_REQ-1 :0];  
        snf[HN_SN_ID[i]]->assign_hnfs [HN_LOC_SN[i]] = HN_ID[i];
	}
	for (i=0;i<NUM_OF_SNs;i++){
		endp_num_in_router = SN_ID[i] % NL;//valid for mesh tori line ring
		router_id = SN_ID[i] / NL;
		
		connect_agent(dat,datrouter,router_id,endp_num_in_router,snf,i);
		connect_agent_small(rsp,rsprouter,router_id,endp_num_in_router,snf,i);
		connect_agent(req,reqrouter,router_id,endp_num_in_router,snf,i);
		connect_agent(snp,snprouter,router_id,endp_num_in_router,snf,i);
		snf[i]->clk=clk;
		snf[i]->reset=reset;
		snf[i]->src_id=SN_ID[i];
		//snf[i]->assign_hnfs= SN_HN_ID[i];
	}
}





void open_trace_files(){
		int i;
		for (i=0;i<NUM_OF_RNs;i++){
			if( strcmp("OFF", TRACE_FILES[i])){
				file[i] = fopen(TRACE_FILES[i],"rb");
				if (file[i] == NULL)
				{
					printf("Error while opening the trace file %u.\n",i);
					exit(EXIT_FAILURE);
				}
			}else{
				file[i] == NULL;
			}	
		
		
		}
		
}





unsigned int active=0;

unsigned int wait_counter [NUM_OF_RNs ] = {0};
unsigned int  deactive_counter [NUM_OF_RNs ] = {0};

//$display("***************start feeding traces to packet injector %d************",in);
void pck_inject_rd_trace (FILE * file_pt, unsigned int in, unsigned int  max_trace_num, char** argv){
	int64_t trace;
	int c;
	if(injct_done & (1<<in)) return;

	active=1;
	
	if(inject[in]->tim_wrap_strobereq==0){
		 deactive_counter[in]++;
		 return;
		 
	}	 
	
	//if((trace_line[in] & 0x7FF) ==0) if(inject[in]->wrapreqvalid) printf ("%u: RN[%u] read trace num %u: %" PRIX64 " \n",clk_counter,in,trace_line[in],inject[in]->wrapreq);
	
	 deactive_counter[in]=0;
	
	if(wait_counter[in]>0){
			wait_counter[in]=wait_counter[in]-1;
			return;
	}	
	
	
	
	
	c=fread(&trace,sizeof(trace),1, file_pt);
	if( c!=1 ||   trace_line[in] >=max_trace_num){
		injct_done|= (1<<in);
		inject[in]->wrapreqvalid=0;
		if(c!=1) {
			printf("%u: End of trace file %d at trace_line=%d: ",clk_counter,in,trace_line[in]);
			display_exe_path(argv);
		}	
		else {
			printf("%u: inject %u Reached max trace num %d: ",clk_counter,in,trace_line[in]);
			display_exe_path(argv);
		}
		return;
	} //read a trace
	trace = __bswap_64 (trace);
	inject[in]->wrapreq= trace & 0x000000ffffffffffLL;
	inject[in]->wrapreqvalid=1;
	//printf ("RN[%u] read trace num %u: %" PRIX64 "\n",in,trace_line[in],trace);
	//if((trace_line[in] & 0x7FF) ==0)
	// printf ("%u: RN[%u] read trace num %u: %" PRIX64 " \n",clk_counter,in,trace_line[in]+1,inject[in]->wrapreq);
	trace_line[in]++;
	//wait_counter[in]=1;
}


void update_txn_end_counters (unsigned int srcid, unsigned int txnid){
	int txn_period;
	if (rnf_counters[srcid].txn_start_time[txnid]==0){
		 // It was probebly eviction
		update_error_file (e,"A new ack is sent  while no req has been sent",srcid,txnid);
		return;
	}
	txn_period = clk_counter - rnf_counters[srcid].txn_start_time[txnid];
	rnf_counters[srcid].txn_start_time[txnid]=0;
		    
	//min delay
	if(rnf_counters [srcid].min_txn_period_time > txn_period)  rnf_counters [srcid].min_txn_period_time= txn_period;
	//max delay
	if(rnf_counters [srcid].max_txn_period_time < txn_period)  rnf_counters [srcid].max_txn_period_time= txn_period; 
	// total
	rnf_counters [srcid].total_txn_num = rnf_counters [srcid].total_txn_num + 1;
	rnf_counters [srcid].accum_txn_time = rnf_counters [srcid].accum_txn_time + txn_period;	
	
}	



void update_performance_counters (){
	int i;
	int txnid;
	//check for requests from injectors 
    for (i=0;i<NUM_OF_RNs;i++){
		//check request flit
		if( inject[i]->chi_noc_txreqflitv){
			txnid= inject[i]->req_txnid;
			
			if(rnf_counters[i].txn_start_time[txnid] != 0) {
				update_error_file (e,"Warning: A new request is sent to a not yet ended txn",i,txnid);
				
			}
			rnf_counters[i].txn_start_time[txnid]=clk_counter;			
		}	
		//check rsp flit for Comp response
		if( inject[i]->noc_chi_rxrspflitv & inject[i]->rsp_Comp){
			update_txn_end_counters (i, inject[i]->rsp_txnid);	
			last_counter = 	clk_counter;	
		}	
		//check dat flit for CompDat
		if( inject[i]->noc_chi_rxdatflitv & inject[i]->dat_Comp){
			update_txn_end_counters (i, inject[i]->dat_txnid);
			last_counter = 	clk_counter;	
			
		}	
		
		if( inject[i]->chi_noc_txreqflitv) rnf_flits [i].req_snt++;
		if( inject[i]->chi_noc_txrspflitv) rnf_flits [i].rsp_snt++;	
		if( inject[i]->chi_noc_txdatflitv) rnf_flits [i].dat_snt++;
		if( inject[i]->chi_noc_txsnpflitv) rnf_flits [i].snp_snt++;	
		
		if( inject[i]->noc_chi_rxreqflitv) rnf_flits [i].req_rsv++;			
		if( inject[i]->noc_chi_rxrspflitv) rnf_flits [i].rsp_rsv++;	
		if( inject[i]->noc_chi_rxdatflitv) rnf_flits [i].dat_rsv++;			
		if( inject[i]->noc_chi_rxsnpflitv) rnf_flits [i].snp_rsv++;	
			
		
	}//for RNs
		
	for (i=0;i<NUM_OF_HNs;i++){
		if( hnf[i]->chi_noc_txreqflitv) hnf_flits [i].req_snt++;
		if( hnf[i]->chi_noc_txrspflitv) hnf_flits [i].rsp_snt++;	
		if( hnf[i]->chi_noc_txdatflitv) hnf_flits [i].dat_snt++;
		if( hnf[i]->chi_noc_txsnpflitv) hnf_flits [i].snp_snt++;	
		
		if( hnf[i]->noc_chi_rxreqflitv) hnf_flits [i].req_rsv++;			
		if( hnf[i]->noc_chi_rxrspflitv) hnf_flits [i].rsp_rsv++;	
		if( hnf[i]->noc_chi_rxdatflitv) hnf_flits [i].dat_rsv++;			
		if( hnf[i]->noc_chi_rxsnpflitv) hnf_flits [i].snp_rsv++;	
	}
	
	for (i=0;i<NUM_OF_SNs;i++){
		if( snf[i]->chi_noc_txreqflitv) snf_flits [i].req_snt++;
		if( snf[i]->chi_noc_txrspflitv) snf_flits [i].rsp_snt++;	
		if( snf[i]->chi_noc_txdatflitv) snf_flits [i].dat_snt++;
		if( snf[i]->chi_noc_txsnpflitv) snf_flits [i].snp_snt++;	
		
		if( snf[i]->noc_chi_rxreqflitv) snf_flits [i].req_rsv++;			
		if( snf[i]->noc_chi_rxrspflitv) snf_flits [i].rsp_rsv++;	
		if( snf[i]->noc_chi_rxdatflitv) snf_flits [i].dat_rsv++;			
		if( snf[i]->noc_chi_rxsnpflitv) snf_flits [i].snp_rsv++;	
	}
	
	
}	




void report_performance(void){
	unsigned long int average;
	unsigned long int average_acum=0;
	unsigned int active_rnf_number=0;
	unsigned int max=0,min=-1;
	unsigned int i;
	
	FILE * f;
	FILE * t;
	f = fopen("performance_result_num.txt","w");
	t = fopen("performance_result_name.txt","w");
	if (f==NULL){
		printf("Unable to create file to record performance!\n");
		exit (1);
	}	
	for (i=0;i<NUM_OF_RNs;i++){
		
		average=0;
		if(rnf_counters [i].total_txn_num !=0){
				average =  (rnf_counters [i].accum_txn_time/rnf_counters [i].total_txn_num);
				active_rnf_number++;
				average_acum+=average;
				if(max <rnf_counters [i].max_txn_period_time) max= rnf_counters [i].max_txn_period_time;
				if(min>rnf_counters [i].min_txn_period_time ) min= rnf_counters [i].min_txn_period_time;
		}		
		
		fprintf(t,"RNF[%u] Num Txn:\n",	i); 
		fprintf(f,"%u\n",	rnf_counters [i].total_txn_num); 
		
		fprintf(t,"RNF[%u] Min Txn delay:\n",	i); 
		fprintf(f,"%u\n",	rnf_counters [i].min_txn_period_time); 
		
		fprintf(t,"RNF[%u] Max Txn delay:\n",	i); 
		fprintf(f,"%u\n",	rnf_counters [i].max_txn_period_time); 
		
		fprintf(t,"RNF[%u] Avg Txn delay:\n",	i); 
		fprintf(f,"%lu\n",	average); 
		
   
	}
	
	for (i=0;i<NUM_OF_RNs;i++){
		fprintf(t,"RNF[%u] snt_req:\n",	i);   fprintf(f,"%u\n",	 rnf_flits [i].req_snt);
		fprintf(t,"RNF[%u] snt_rsp:\n",	i);   fprintf(f,"%u\n",  rnf_flits [i].rsp_snt);
		fprintf(t,"RNF[%u] snt_dat:\n",	i);   fprintf(f,"%u\n",  rnf_flits [i].dat_snt);
		fprintf(t,"RNF[%u] snt_snp:\n",	i);   fprintf(f,"%u\n",  rnf_flits [i].snp_snt);

		fprintf(t,"RNF[%u] rsv_req:\n",	i);   fprintf(f,"%u\n",  rnf_flits [i].req_rsv);
		fprintf(t,"RNF[%u] rsv_rsp:\n",	i);   fprintf(f,"%u\n",  rnf_flits [i].rsp_rsv);
		fprintf(t,"RNF[%u] rsv_dat:\n",	i);   fprintf(f,"%u\n",  rnf_flits [i].dat_rsv);
		fprintf(t,"RNF[%u] rsv_snp:\n",	i);   fprintf(f,"%u\n",  rnf_flits [i].snp_rsv);
			
		
	}//for RNs
		
	for (i=0;i<NUM_OF_HNs;i++){
		fprintf(t,"HNF[%u] snt_req:\n",	i);   fprintf(f,"%u\n",	 hnf_flits [i].req_snt);
		fprintf(t,"HNF[%u] snt_rsp:\n",	i);   fprintf(f,"%u\n",  hnf_flits [i].rsp_snt);
		fprintf(t,"HNF[%u] snt_dat:\n",	i);   fprintf(f,"%u\n",  hnf_flits [i].dat_snt);
		fprintf(t,"HNF[%u] snt_snp:\n",	i);   fprintf(f,"%u\n",  hnf_flits [i].snp_snt);

		fprintf(t,"HNF[%u] rsv_req:\n",	i);   fprintf(f,"%u\n",  hnf_flits [i].req_rsv);
		fprintf(t,"HNF[%u] rsv_rsp:\n",	i);   fprintf(f,"%u\n",  hnf_flits [i].rsp_rsv);
		fprintf(t,"HNF[%u] rsv_dat:\n",	i);   fprintf(f,"%u\n",  hnf_flits [i].dat_rsv);
		fprintf(t,"HNF[%u] rsv_snp:\n",	i);   fprintf(f,"%u\n",  hnf_flits [i].snp_rsv);

		
	}
	
	for (i=0;i<NUM_OF_SNs;i++){
		fprintf(t,"SNF[%u] snt_req:\n",	i);   fprintf(f,"%u\n",	 snf_flits [i].req_snt);
		fprintf(t,"SNF[%u] snt_rsp:\n",	i);   fprintf(f,"%u\n",  snf_flits [i].rsp_snt);
		fprintf(t,"SNF[%u] snt_dat:\n",	i);   fprintf(f,"%u\n",  snf_flits [i].dat_snt);
		fprintf(t,"SNF[%u] snt_snp:\n",	i);   fprintf(f,"%u\n",  snf_flits [i].snp_snt);

		fprintf(t,"SNF[%u] rsv_req:\n",	i);   fprintf(f,"%u\n",  snf_flits [i].req_rsv);
		fprintf(t,"SNF[%u] rsv_rsp:\n",	i);   fprintf(f,"%u\n",  snf_flits [i].rsp_rsv);
		fprintf(t,"SNF[%u] rsv_dat:\n",	i);   fprintf(f,"%u\n",  snf_flits [i].dat_rsv);
		fprintf(t,"SNF[%u] rsv_snp:\n",	i);   fprintf(f,"%u\n",  snf_flits [i].snp_rsv);
		
	}
	
	
	
	
	average=average_acum/(unsigned long int) active_rnf_number;
	
	fprintf(t,"Total average delay:\n");
	fprintf(f,"%u\n",average);
	
	fprintf(t,"The min delay:\n");
	fprintf(f,"%u\n",min);
	
	fprintf(t,"The max delay:\n");
	fprintf(f,"%u\n",max);
	
	fprintf(t,"Execution time:\n");
	fprintf(f,"%u\n",last_counter-start_time);

	fclose(t);
	fclose(f);
	
}




void update_error_file (FILE *e, const char * message, unsigned int srcid, unsigned int xnid){
		fprintf(e,"%s:\n",message);
		fprintf(e,"RNF[%u]TXN[%u] : txn num = %u, start_time=%u, current time =%u  \n",srcid,xnid, rnf_counters [srcid].total_txn_num, rnf_counters [srcid].txn_start_time[ xnid],clk_counter);	
}	



int main(int argc, char** argv) {
	int i;
	
	e = fopen("error_result.txt","w");
	//while((0x1<<NEw) < NE)NEw++;	

	Verilated::commandArgs(argc, argv);   // Remember args
	
	//rnf        new  Vrnf        ;
	for (i=0;i<NUM_OF_RNs;i++) 	inject[i] =  new  Vinject;
	for (i=0;i<NUM_OF_HNs;i++)  hnf[i] = new  Vhnf;
	for (i=0;i<NUM_OF_SNs;i++)  snf[i] = new  Vsnf;
	for (i=0;i<NR;i++){
		datrouter[i]  =new  Vdatrouter;
		reqrouter[i]  =new  Vreqrouter;
		rsprouter[i]  =new  Vrsprouter;
		snprouter[i]  =new  Vsnprouter;
	}
	
	/********************
	*	initialize input
	*********************/
	main_time=0;
	clk_counter=0;
	reset=1;
	clk = 0;
	initial_noc_param();
	printf("Start Simulation...\n");
	done_counter = 5000;// wait 5000 clock cycle after the last packet is injected. then stop the simulation
	display_exe_path(argv);
	while (!Verilated::gotFinish()) {
		
		
		if ((main_time % 3) == 0) {
			clk = 1;       // Toggle clock
		}else if  ((main_time % 3) == 1) {

			if (main_time >= 10 ) 	reset=0;
						
			
			if(!reset){
				clk_counter++;
				if((clk_counter & 0xfffff)==0) {
					printf ("info: sim clk reaches %u. injectdone:%X :  ",clk_counter ,injct_done );
					display_exe_path(argv);
				}
			}
				
			// you can change the inputs and read the outputs here in case they are captured at posedge of clock
			if(clk_counter> 2000){
				//printf ("main_time=%u\n",main_time);
				if( start_time ==0) start_time=clk_counter;
				active=0;
				for (i=0;i<NUM_OF_RNs;i++){
					pck_inject_rd_trace(file[i],i,2*REPEAT_NUM,argv);
					if (deactive_counter [i]> 100000){
						printf ("%u :******Possible Error: RN[%u] is hanged at line %u for  %u clk cycle *****",clk_counter,i,trace_line[i],deactive_counter [i]  );
						display_exe_path(argv);
						final_all();
						return 1;
					}	
					
					
				}
				if(active==0) {
					done_counter--;
					if(done_counter==0){
						final_all();
						printf("%u:*********simulation finished successfully!**:",clk_counter);
						display_exe_path(argv);
						return 0;
					}	
				}
				
				
				
			}
			update_performance_counters();
		}
		else{
			clk = 0;       // Toggle clock

		}


		//connections	//clk,reset,enable
		connect_all_r2r();
		connect_agents_2r();

		//eval instances
		eval_all();
		main_time++;



	}//while

	// Simulation is done
	final_all();
	printf("%u:*********Possible Error: simulation finished unexpectedly!**:",clk_counter);
	display_exe_path(argv);
	return 0;
	
}


double sc_time_stamp () {       // Called by $time in Verilog
	return clk_counter;
}
