#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <limits.h>
#include <ctype.h>
#include <stdint.h>
#include <inttypes.h>
#include <verilated.h>          // Defines common routines

#include "Vtraffic.h"


#define IS_SELF_LOOP_EN (strcmp(SELF_LOOP_EN ,"YES")==0)

#define CHAN_SIZE   sizeof(traffic[0]->chan_in)

#define conect_r2r(T1,r1,p1,T2,r2,p2)  \
	memcpy(&router##T1 [r1]->chan_in[p1] , &router##T2 [r2]->chan_out[p2], CHAN_SIZE )

#define connect_r2gnd(T,r,p)\
	memset(&router##T [r]->chan_in [p],0x00,CHAN_SIZE)

#define connect_r2e(T,r,p,e) \
	memcpy(&router##T [r]->chan_in[p], &traffic[e]->chan_out, CHAN_SIZE );\
	memcpy(&traffic[e]->chan_in, &router##T [r]->chan_out[p], CHAN_SIZE )

#include "parameter.h"
Vtraffic		*traffic[NE];

#include "topology_top.h"
#include "traffic_task_graph.h"
#include "traffic_synthetic.h"


#define RATIO_INIT		2
#define DISABLE -1
#define MY_VL_SETBIT_W(data,bit) (data[VL_BITWORD_I(bit)] |= (VL_UL(1) << VL_BITBIT_I(bit)))
#define STND_DEV_EN 1
#define SYNTHETIC 0
#define CUSTOM 1 
#define RANDOM_RANGE 1
#define RANDOM_discrete 2


int reset,clk;
int TRAFFIC_TYPE=SYNTHETIC;
int AVG_PACKET_SIZE=5;
int MIN_PACKET_SIZE=5;
int MAX_PACKET_SIZE=5;
int end_sim_pck_num;
int sim_end_clk_num;
int HOTSPOT_NUM;
int C0_p=100, C1_p=0, C2_p=0, C3_p=0;
char * TRAFFIC;
unsigned char FIXED_SRC_DST_PAIR;
unsigned char  NEw=0;
unsigned long int main_time = 0;     // Current simulation time
unsigned int saved_time = 0; 
unsigned int total_rsv_pck_num=0;
unsigned int total_sent_pck_num=0;
unsigned int sum_clk_h2h,sum_clk_h2t;
double 		 sum_clk_per_hop=0;
const int  CC=(C==0)? 1 : C;
unsigned int total_rsv_pck_num_per_class[CC]={0};
unsigned int sum_clk_h2h_per_class[CC]={0};
unsigned int sum_clk_h2t_per_class[CC]={0};
double 		 sum_clk_per_hop_per_class[CC]={0};
unsigned int rsvd_core_total_pck_num[NE]= {0};
unsigned int rsvd_core_worst_delay[NE] =  {0};
unsigned int sent_core_total_pck_num[NE]= {0};
unsigned int sent_core_worst_delay[NE] =  {0};
unsigned int random_var[NE] = {100};
unsigned int clk_counter,ideal_rsv_cnt;
unsigned int count_en;
unsigned int total_active_endp;
char all_done=0;
unsigned int total_sent_flit_number =0;
unsigned int total_rsv_flit_number =0;
unsigned int total_rsv_flit_number_old=0;
int ratio=RATIO_INIT;
double first_avg_latency_flit,current_avg_latency_flit;
double sc_time_stamp ();
int pow2( int );
char inject_done=0;
char simulation_done=0;
char pck_size_sel=RANDOM_RANGE;
int  * discrete_size;
int  * discrete_prob;
unsigned int * rsv_size_array;

#if (STND_DEV_EN)
	//#include <math.h>
	double sqroot (double s){
		int i;	
		double root = s/3;
		if (s<=0) return 0;
		for(i=0;i<32;i++) root = (root +s/root)/2;
		return root;
	}
	
	double 	     sum_clk_pow2=0;
	double 	     sum_clk_pow2_per_class[C];
	double standard_dev( double , unsigned int, double);
#endif

void update_noc_statistic (	int);
unsigned char pck_class_in_gen(unsigned int);
unsigned int pck_dst_gen_task_graph ( unsigned int);
void print_statistic (void);
void print_parameter();
void reset_all_register();
void sim_eval_all (void);
void sim_final_all (void);
void clk_negedge_event(void);
void clk_posedge_event(void);
void connect_clk_reset_start_all(void);
unsigned int rnd_between (unsigned int, unsigned int );



void  usage(){
	printf(" ./simulator -f [Traffic Pattern file]\n\nor\n");
	printf(" ./simulator -t [Traffic Pattern]   -m [Packet size info] -n  [end_sim_pck_num]  c	[MAX SIM CLKs]   -i [INJECTION RATIO] -p [class traffic ratios (%%)]  -h[HOTSPOT info] -H[custom traffic pattern]\n");
	printf("      Traffic Pattern: \"HOTSPOT\" \"RANDOM\" \"TORNADO\" \"BIT_REVERSE\"  \"BIT_COMPLEMENT\"  \"TRANSPOSE1\"   \"TRANSPOSE2\"\n");
	printf("      end_sim_pck_num: total number of sent packets. Simulation will stop when total of sent packet by all nodes reach this number\n");
	printf("      sim_end_clk_num: simulation clock limit. Simulation will stop when simulation clock number reach this value \n");
	printf("      INJECTION_RATIO: packet injection ratio\n");
	printf("      class traffic ratios %%: The percentage of traffic injected for each class. represented in string whit each class ratio is separated by comma. \"n0,n1,n2..\" \n");
	printf("      hotspot traffic info: represented in a string with following format:  \"HOTSPOT PERCENTAGE,HOTSPOT NUM,HOTSPOT CORE 1,HOTSPOT CORE 2,HOTSPOT CORE 3,HOTSPOT CORE 4,HOTSPOT CORE 5, ENABLE HOTSPOT CORES SEND \"   \n");
	printf("      Packet size info:represented in a string with following format:");
	printf("      \t\"R,MIN,MAX\" : The injected packets' size in flits are randomly selected in range MIN<= PCK_size <=MAX (Random-Range)\n");
	printf("      \t\"D,S1,S2,..Sn,P,P1,P2,P3,...Pn\" : Si are the discrete set of numbers representing packet size. The injected packet size is randomly selected among these discrete values according to associated probability values.\n");
	printf("	  \t\t The probabilities pi must satisfy two requirements: every probability pi is a number between 0 and 100, and the sum of all the probabilities is 100\n");
	printf("      custom traffic pattern: represented in a string with following format:  \"SRC1,DEST1, SRC2,DEST2, .., SRCn, DESTn\"   \n");

}


int parse_string ( char * str, int * array)
{
    int i=0; 
    char *pt;
    pt = strtok (str,",");
    while (pt != NULL) {
        int a = atoi(pt);
        array[i]=a;
        i++;
        pt = strtok (NULL, ",");
    }
   return i; 
}



unsigned int pck_dst_gen ( 	unsigned int core_num) {
	if(TRAFFIC_TYPE==CUSTOM)	return  	pck_dst_gen_task_graph ( core_num);
	if((strcmp (TOPOLOGY,"MESH")==0)||(strcmp (TOPOLOGY,"TORUS")==0))	return  pck_dst_gen_2D (core_num);
	return pck_dst_gen_1D (core_num);
}



void update_hotspot(char * str){
	 int i;
	 int array[1000];
	 int p;
	 int acuum=0;
	 hotspot_st * new_node;
	 p= parse_string (str, array);
	 if (p<4){
		    fprintf(stderr,"Error in hotspot traffic parameters. 4 value should be given as hotspot parameter\n");
			exit(1);
	 }
	 HOTSPOT_NUM=array[0];
	 if (p<1+HOTSPOT_NUM*3){
		    fprintf(stderr,"Error in hotspot traffic parameters \n");
			exit(1);
	 }
	 new_node =  (hotspot_st *) malloc( HOTSPOT_NUM * sizeof(hotspot_st));
	 if( new_node == NULL){
		 fprintf(stderr,"Error: cannot allocate memory for hotspot traffic\n");
   	    exit(1);
   	 }
	 for (i=1;i<3*HOTSPOT_NUM; i+=3){
		new_node[i/3]. ip_num = array[i];
	    new_node[i/3]. send_enable=array[i+1];
	    new_node[i/3]. percentage =  acuum + array[i+2];
	    acuum= new_node[i/3]. percentage;									
		 
	 }	 
	 if(acuum> 1000){
		 	printf("Warning: The hotspot traffic summation %f exceed than 100 percent.  \n", (float) acuum /10);
   	   
	 } 	
	 hotspots=new_node;
}

void update_custom(char * str){
	int i;
	int array[10000];
	int p;
	p= parse_string (str, array);
	for (i=0;i<p; i+=2){
		custom_traffic_table[array[i]] = array[i+1];
	}
}

void update_pck_size(char *str){
	int i;
	int array[1000];
	char substring[1000];
	int p;
	char *pt,*pt2;
	MIN_PACKET_SIZE=100000;
	MAX_PACKET_SIZE=1;


	pt = strtok (str,",");
	if(*pt=='R'){//random range
		p= parse_string (str+2, array);
		if(p<2){
			fprintf(stderr,"ERROR: Wrong Packet size format %s. It should be \"R,min,max\" : \n",str);
			exit(1);
		}

		MIN_PACKET_SIZE=array[0];
		MAX_PACKET_SIZE=array[1];
		AVG_PACKET_SIZE=(MIN_PACKET_SIZE+MAX_PACKET_SIZE)/2;// average packet size
	}else if(*pt=='D'){//random discrete
		pck_size_sel =  RANDOM_discrete;
		pt = strtok (str+2,"P");
		pt2 = strtok (NULL,"P");
		if (pt == NULL || pt2==NULL) {
			fprintf(stderr,"ERROR: Wrong Packet size format %s. It should be \"D,s1,s2..sn,P,p1,p2..pn\". missing letter \"P\" in format  \n",str);
			exit(1);
		}
		p= parse_string (pt, array);
		if (p==0){
			fprintf(stderr,"ERROR: Wrong Packet size format %s. It should be \"D,s1,s2..sn,P,p1,p2..pn\". missing si values after letter \"D\" \"P\" in format  \n",str);
			exit(1);
		}
		int in=p;
		//alocate mmeory for pck size
		discrete_size = (int*)malloc((p) * sizeof(int));
		discrete_prob = (int*)malloc((p) * sizeof(int));
		// Check if the memory has been successfully allocated
		if (discrete_size == NULL || discrete_prob==NULL) {
			printf("ERROR: Memory not allocated.\n");
			exit(1);
		}

		for (i=0; i<p; i++){

			//printf("I[%u]=%u,\n",i,array[i]);
			discrete_size[i] = array[i];
			if(MIN_PACKET_SIZE > array[i]) MIN_PACKET_SIZE = array[i];
			if(MAX_PACKET_SIZE < array[i]) MAX_PACKET_SIZE = array[i];
		}

		p= parse_string (pt2+1, array);
		int sum=0;
		AVG_PACKET_SIZE=0;
		for (i=0; i<p; i++){
			//printf("P[%u]=%u,\n",i,array[i]);
			if(i<in){
				 sum+=array[i];
				 discrete_prob[i]=sum;
				 AVG_PACKET_SIZE+=discrete_size[i] * array[i];

			}
		}
		AVG_PACKET_SIZE/=100;

		if(sum!=100){
			fprintf(stderr,"ERROR: The accumulatio of the first %u probebility values is %u which is not equal to 100\n",in,sum);
			exit(1);
		}

	}else {
		fprintf(stderr,"ERROR: Wrong Packet size format %s. It should start with one of \"D\" or \"R\" letter\n",str);
		exit(1);
	}
	p=(MAX_PACKET_SIZE-MIN_PACKET_SIZE)+1;
	rsv_size_array = (unsigned int*) calloc ( p , sizeof(int));
	if (rsv_size_array==NULL){
		 fprintf(stderr,"Error: cannot allocate memory for rsv_size_array\n");
		 exit(1);
	}

}

void processArgs (int argc, char **argv )
{
   char c;
   int p;
   int array[10];
   float f;

   /* don't want getopt to moan - I can do that just fine thanks! */
   opterr = 0;
   if (argc < 2)  usage();	
   while ((c = getopt (argc, argv, "t:m:n:c:i:p:h:H:f:")) != -1)
      {
	 switch (c)
	    {
	 	case 'f':
	 		TRAFFIC_TYPE=CUSTOM;
	 		TRAFFIC=(char *) "CUSTOM from file";
	 		load_traffic_file(optarg,task_graph_data,task_graph_abstract);
	 		end_sim_pck_num=task_graph_total_pck_num;
	 		break;
	    case 't':  
			TRAFFIC=optarg;
			total_active_routers=-1;
			break;
		case 's':
			MIN_PACKET_SIZE=atoi(optarg);
			break;
		case 'n':
			 end_sim_pck_num=atoi(optarg);
			 break;
		case 'c':
			 sim_end_clk_num=atoi(optarg);
			 break;
		case 'i':
			 f=atof(optarg);
			 f*=(MAX_RATIO/100);
			 ratio= (int) f;
			 break;
		case 'p':
			p= parse_string (optarg, array);
		    C0_p=array[0];
		    C1_p=array[1];
		    C2_p=array[2];
		    C3_p=array[3];
			break;
		case 'm':
			update_pck_size(optarg);

			break;
		case 'H':
			update_custom(optarg);
			break;
		case 'h':		
			update_hotspot(optarg);
			break; 			 
	    case '?':
	       if (isprint (optopt))
		  fprintf (stderr, "Unknown option `-%c'.\n", optopt);
	       else
		  fprintf (stderr,
			   "Unknown option character `\\x%x'.\n",
			   optopt);
	    default:
	       usage();
	       exit(1);
	    }
      }

}




int get_new_pck_size(){
		if(pck_size_sel ==  RANDOM_discrete){
				int rnd = rand() % 100; // 0~99
				int i=0;
				while( rnd > discrete_prob[i] ) i++;
				return discrete_size [i];
		}
		//random range
		return rnd_between(MIN_PACKET_SIZE,MAX_PACKET_SIZE);
}


int main(int argc, char** argv) {
	char change_injection_ratio=0;
	int i,j,x,y;//,report_delay_counter=0;
	char file_name[100];
	char deafult_out[] = {"result"};

	unsigned int dest_e_addr;

	while((0x1<<NEw) < NE)NEw++;
	

	Verilated::commandArgs(argc, argv);   // Remember args
	Vrouter_new();
	//noc								= new Vnoc;
	for(i=0;i<NE;i++)	traffic[i]  = new Vtraffic;
	for(i=0;i<NE;i++)   custom_traffic_table[i]=INJECT_OFF; //off
	processArgs ( argc,  argv );
	
	
	FIXED_SRC_DST_PAIR = strcmp (TRAFFIC,"RANDOM") &  strcmp(TRAFFIC,"HOTSPOT") & strcmp(TRAFFIC,"random") & strcmp(TRAFFIC,"hot spot") & strcmp(TRAFFIC,"CUSTOM from file");
	

	/********************
	*	initialize input
	*********************/

	reset=1;
	reset_all_register();
	start_i=0; 
	topology_init();

    for (i=0;i<NE;i++){
    	random_var[i] = 100;
    	traffic[i]->current_e_addr		= endp_addr_encoder(i);
    	traffic[i]->start=0;
    	traffic[i]->pck_class_in=  pck_class_in_gen( i);
    	traffic[i]->pck_size_in=get_new_pck_size();
    	dest_e_addr=pck_dst_gen (i);
    	traffic[i]->dest_e_addr= dest_e_addr;
    	if(dest_e_addr == INJECT_OFF) traffic[i]->stop=1;
    	//printf("src=%u, des_eaddr=%x, dest=%x\n", i,dest_e_addr, endp_addr_decoder(dest_e_addr));
    	if(inject_done) traffic[i]->stop=1;
    	traffic[i]->start_delay=rnd_between(1,4*NE-2);
    	if(TRAFFIC_TYPE==SYNTHETIC){
    		//traffic[i]->avg_pck_size_in=AVG_PACKET_SIZE;
    		traffic[i]->ratio=ratio;
    		traffic[i]->init_weight=1;
    	}
	}

	main_time=0;
	print_parameter();
	if(strcmp(TRAFFIC,"CUSTOM from file")) printf("\n\n\n Flit injection ratio per router is =%f \n",(float)ratio*100/MAX_RATIO);
	//printf("\n\n\n delay= %u clk",router->delay);
	while (!Verilated::gotFinish()) {
	   
		if (main_time-saved_time >= 10 ) {
			reset = 0;
		}

		if(main_time == saved_time+21){ count_en=1; start_i=1;}//for(i=0;i<NC;i++) traffic[i]->start=1;}
		if(main_time == saved_time+23) start_i=0;// for(i=0;i<NC;i++) traffic[i]->start=0;
		  
		clk_posedge_event( );
		//The valus of all registers and input ports valuse change @ posedge of the clock. Once clk is deasserted,  as multiple modules are connected inside the testbench we need several eval for propogating combinational logic values 
		//between modules when the clock . 
		for (i=0;i<2*(SBP_MAX+1);i++) clk_negedge_event( );
				
		if(simulation_done){
				for (i=0;i<NE;i++) if(traffic[i]->pck_number>0) total_active_endp   	= 	total_active_endp +1;

				printf(" simulation clock cycles:%d\n",clk_counter);
				printf(" total received flits:%d\n",total_rsv_flit_number);
				printf(" total sent flits:%d\n",total_sent_flit_number);
				print_statistic( );
				change_injection_ratio = 1;
				sim_final_all();
				return 0;
		}
		

		main_time++;  
		//getchar();   

		
	}// Done simulating
	
	sim_final_all();
	return 0;

}




/*************
 * sc_time_stamp 
 * 
 * **********/
double sc_time_stamp () {       // Called by $time in Verilog
	return main_time;
}

int pow2( int num){
	int pw;
	pw= (0x1 << num);
	return pw;
}

void sim_eval_all (void){
	int i;
	//noc->eval(); 
	routers_eval();
	for(i=0;i<NE;i++) traffic[i]->eval();
}	

void sim_final_all (void){
	int i;
	routers_final();
	for(i=0;i<NE;i++) traffic[i]->final();
	//noc->final(); 
}	

void connect_clk_reset_start_all(void){
	int i;
	//noc-> clk = clk; 
	//noc-> reset = reset;
		 
	for(i=0;i<NE;i++)	{
		start_o[i]=start_i;//TO DO fix it
		traffic[i]->start= start_o[i];
		traffic[i]->reset= reset;
		traffic[i]->clk	= clk;
	}
	connect_routers_reset_clk();
}


void clk_negedge_event(void){
	int i,j;
	
	clk = 0;

	
	topology_connect_all_nodes ();
			

	for (i=0;i<NE;i++){
				if(inject_done) traffic[i]->stop=1;
				traffic[i]->current_r_addr		= er_addr[i];

	}

			

				

	
	connect_clk_reset_start_all();
	sim_eval_all();
	
}	




void clk_posedge_event(void) {
	int i;
	unsigned int dest_e_addr;
	clk = 1;       // Toggle clock
	if(count_en) clk_counter++;
		inject_done= ((total_sent_pck_num >= end_sim_pck_num) || (clk_counter>= sim_end_clk_num) || total_active_routers == 0);
		//if(inject_done) printf("clk_counter=========%d\n",clk_counter);
		total_rsv_flit_number_old=total_rsv_flit_number;
		for (i=0;i<NE;i++){

			// a packet has been received
			if(traffic[i]->update & ~reset){
				update_noc_statistic (i) ;
			}
			// the header flit has been sent out
			if(traffic[i]->hdr_flit_sent ){
				traffic[i]->pck_class_in=  pck_class_in_gen( i);
				sent_core_total_pck_num[i]++;
				traffic[i]->pck_size_in=get_new_pck_size();
				if(!FIXED_SRC_DST_PAIR){
					dest_e_addr=pck_dst_gen (i);
					traffic[i]->dest_e_addr= dest_e_addr;
					if(dest_e_addr == INJECT_OFF) traffic[i]->stop=1;
					//printf("src=%u, dest=%x\n", i,endp_addr_decoder(dest_e_addr));
				}
			}

				if(traffic[i]->flit_out_wr==1) total_sent_flit_number++;
				if(traffic[i]->flit_in_wr==1)  total_rsv_flit_number++;
				if(traffic[i]->hdr_flit_sent==1)total_sent_pck_num++;

			}//for


			if(inject_done){
				if(total_rsv_flit_number_old == total_rsv_flit_number){
						ideal_rsv_cnt++;
						if(ideal_rsv_cnt >= 100){
							print_statistic( );
							fprintf(stderr,"ERROR: The number of sent (%u) & received flits (%u) were not equal at the end of simulation\n",total_sent_flit_number, total_rsv_flit_number);
							exit(1);
						}
				}
				if(total_sent_flit_number == total_rsv_flit_number ) simulation_done=1;
			}
	connect_clk_reset_start_all();
	sim_eval_all();
			
}			


/**********************************
 *
 * 	update_noc_statistic
 *
 *
 *********************************/

void update_noc_statistic (	int	core_num){
	unsigned int   	clk_num_h2h =traffic[core_num]->time_stamp_h2h;
	unsigned int    clk_num_h2t =traffic[core_num]->time_stamp_h2t;
    unsigned int    distance=traffic[core_num]->distance;
    unsigned int  	class_num=traffic[core_num]->pck_class_out;
    unsigned int    src_e_addr=traffic[core_num]->src_e_addr;
    unsigned int 	src = endp_addr_decoder (src_e_addr);						
	total_rsv_pck_num+=1;
	if((total_rsv_pck_num & 0Xffff )==0 ) printf(" packet sent total=%d\n",total_rsv_pck_num);
	sum_clk_h2h+=clk_num_h2h;
	sum_clk_h2t+=clk_num_h2t;
#if (STND_DEV_EN)
	sum_clk_pow2+=(double)clk_num_h2h * (double) clk_num_h2h;
	sum_clk_pow2_per_class[class_num]+=(double)clk_num_h2h * (double) clk_num_h2h;
#endif			        		
	sum_clk_per_hop+= ((double)clk_num_h2h/(double)distance);
	//printf("sum_clk_per_hop(%f)+= clk_num_h2h(%u)/distance(%u)\n",sum_clk_per_hop,clk_num_h2h,distance);
	total_rsv_pck_num_per_class[class_num]+=1;
	sum_clk_h2h_per_class[class_num]+=clk_num_h2h ;
	sum_clk_h2t_per_class[class_num]+=clk_num_h2t ;
	sum_clk_per_hop_per_class[class_num]+= ((double)clk_num_h2h/(double)distance);
	rsvd_core_total_pck_num[core_num]=rsvd_core_total_pck_num[core_num]+1;
	if (rsvd_core_worst_delay[core_num] < clk_num_h2t) rsvd_core_worst_delay[core_num] = (strcmp (AVG_LATENCY_METRIC,"HEAD_2_TAIL")==0)?  clk_num_h2t :  clk_num_h2h;
    if (sent_core_worst_delay[src] < clk_num_h2t) sent_core_worst_delay[src] = (strcmp (AVG_LATENCY_METRIC,"HEAD_2_TAIL")==0)?  clk_num_h2t :  clk_num_h2h;
    if( traffic[core_num]->pck_size_o >= MIN_PACKET_SIZE && traffic[core_num]->pck_size_o <=MAX_PACKET_SIZE){
       	rsv_size_array[traffic[core_num]->pck_size_o-MIN_PACKET_SIZE]++;
    }
}



void print_statistic (void){
	double avg_latency_per_hop,  avg_latency_flit, avg_latency_pck, avg_throughput,min_avg_latency_per_class;
	int i;
#if (STND_DEV_EN)
	double	std_dev;
#endif
	char file_name[100];
	avg_throughput= ((double)(total_sent_flit_number*100)/total_active_endp )/clk_counter;
	printf(" Total active Endpoint: %d \n",total_active_endp);
	printf(" Avg throughput is: %f (flits/clk/Total active Endpoint %%)\n",    avg_throughput);
	avg_latency_flit   = (double)sum_clk_h2h/total_rsv_pck_num;
	avg_latency_pck	   = (double)sum_clk_h2t/total_rsv_pck_num;
	if(ratio==RATIO_INIT) first_avg_latency_flit=avg_latency_flit;
#if (STND_DEV_EN)
	std_dev= standard_dev( sum_clk_pow2,total_rsv_pck_num, avg_latency_flit);
	printf(" standard_dev = %f\n",std_dev);
#endif
    avg_latency_per_hop    = (double)sum_clk_per_hop/total_rsv_pck_num;
    printf("\nall : \n");
  	printf(" Total number of packet = %d \n average latency per hop = %f \n",total_rsv_pck_num,avg_latency_per_hop);
  	printf(" average packet latency = %f \n average flit latency = %f \n",avg_latency_pck, avg_latency_flit);
    min_avg_latency_per_class=1000000;
    printf(" Total injected packet in different size:\n");
    for (i=0;i<=(MAX_PACKET_SIZE - MIN_PACKET_SIZE);i++){
    	if(rsv_size_array[i]>0) printf("\t %u flit_sized pck = %u\n",i+ MIN_PACKET_SIZE, rsv_size_array[i]);
    }
    printf("\n");

    for(i=0;i<C;i++){
           	avg_throughput		 = (total_rsv_pck_num_per_class[i]>0)? ((double)(total_rsv_pck_num_per_class[i]*AVG_PACKET_SIZE*100)/total_active_endp )/clk_counter:0;
			avg_latency_flit 	 = (total_rsv_pck_num_per_class[i]>0)? (double)sum_clk_h2h_per_class[i]/total_rsv_pck_num_per_class[i]:0;
			avg_latency_pck	   	 = (total_rsv_pck_num_per_class[i]>0)? (double)sum_clk_h2t_per_class[i]/total_rsv_pck_num_per_class[i]:0;
			avg_latency_per_hop  = (total_rsv_pck_num_per_class[i]>0)? (double)sum_clk_per_hop_per_class[i]/total_rsv_pck_num_per_class[i]:0;
			printf ("\nclass : %d  \n",i);
	        printf (" Total number of packet = %d \n avg_throughput = %f \n average latency per hop = %f \n ",total_rsv_pck_num_per_class[i],avg_throughput,avg_latency_per_hop);
            printf (" average packet latency = %f \n average flit latency = %f \n",avg_latency_pck,avg_latency_flit);
            if(min_avg_latency_per_class > avg_latency_flit) min_avg_latency_per_class=avg_latency_flit;

#if (STND_DEV_EN)
            std_dev= (total_rsv_pck_num_per_class[i]>0)?  standard_dev( sum_clk_pow2_per_class[i],total_rsv_pck_num_per_class[i], avg_latency_flit):0;
            printf(" standard_dev = %f\n",std_dev);
#endif
	}//for
	current_avg_latency_flit=min_avg_latency_per_class;
	for (i=0;i<NE;i++) {
		printf	 ("\n\nEnd_point %d\n",i);
		printf	 ("\n\ttotal number of received packets: %u\n",rsvd_core_total_pck_num[i]);
		printf	 ("\n\tworst-case-delay of received packets (clks): %u\n",rsvd_core_worst_delay[i] );
		printf	 ("\n\ttotal number of sent packets: %u\n",traffic[i]->pck_number);
		printf	 ("\n\tworst-case-delay of sent packets (clks): %u\n",sent_core_worst_delay[i] );
	}
}


void print_parameter (){
		printf ("Router parameters: \n");
		printf ("\tTopology: %s\n",TOPOLOGY);
		printf ("\tRouting algorithm: %s\n",ROUTE_NAME);
	 	printf ("\tVC_per port: %d\n", V);
		printf ("\tBuffer_width: %d\n", B);
if((strcmp (TOPOLOGY,"MESH")==0)||(strcmp (TOPOLOGY,"TORUS")==0)){
	    printf ("\tRouter num in row: %d \n",T1);
	    printf ("\tRouter num in column: %d \n",T2);
}else if ((strcmp (TOPOLOGY,"RING")==0)||(strcmp (TOPOLOGY,"LINE")==0)){
		printf ("\t Total Router num: %d \n",T1);
}
else if ((strcmp (TOPOLOGY,"TREE")==0)||(strcmp (TOPOLOGY,"FATTREE")==0)){
		printf ("\tK: %d \n",T1);
		printf ("\tL: %d \n",T2);
} else{ //CUSTOM
	    printf ("\tTotal Endpoints number: %d \n",T1);
		printf ("\tTotal Routers number: %d \n",T2);
}
	    printf ("\tNumber of Class: %d\n", C);
	    printf ("\tFlit data width: %d \n", Fpay);
	    printf ("\tVC reallocation mechanism: %s \n",  VC_REALLOCATION_TYPE);
	    printf ("\tVC/sw combination mechanism: %s \n", COMBINATION_TYPE);
	    printf ("\tAVC_ATOMIC_EN:%d \n", AVC_ATOMIC_EN);
	    printf ("\tCongestion Index:%d \n",CONGESTION_INDEX);
	    printf ("\tADD_PIPREG_AFTER_CROSSBAR:%d\n",ADD_PIPREG_AFTER_CROSSBAR);
	    printf ("\tSSA_EN enabled:%s \n",SSA_EN);
	    printf ("\tSwitch allocator arbitration type:%s \n",SWA_ARBITER_TYPE);
	    printf ("\tMinimum supported packet size:%d flit(s) \n",MIN_PCK_SIZE);


	printf ("\nSimulation parameters\n");
#if(DEBUG_EN)
    printf ("\tDebuging is enabled\n");
#else
    printf ("\tDebuging is disabled\n");
#endif
	//if(strcmp (AVG_LATENCY_METRIC,"HEAD_2_TAIL")==0)printf ("\tOutput is the average latency on sending the packet header until receiving tail\n");
	//else printf ("\tOutput is the average latency on sending the packet header until receiving header flit at destination node\n");
	printf ("\tTraffic pattern:%s\n",TRAFFIC);
	if(C>0) printf ("\ttraffic percentage of class 0 is : %d\n", C0_p);
	if(C>1) printf ("\ttraffic percentage of class 1 is : %d\n", C1_p);
	if(C>2) printf ("\ttraffic percentage of class 2 is : %d\n", C2_p);
	if(C>3) printf ("\ttraffic percentage of class 3 is : %d\n", C3_p);
	if(strcmp (TRAFFIC,"HOTSPOT")==0){
		//printf ("\tHot spot percentage: %u\n", HOTSPOT_PERCENTAGE);
	    printf ("\tNumber of hot spot cores: %d\n", HOTSPOT_NUM);

	}
	    //printf ("\tTotal packets sent by one router: %u\n", TOTAL_PKT_PER_ROUTER);
		printf ("\tSimulation timeout =%d\n", sim_end_clk_num);
		printf ("\tSimulation ends on total packet num of =%d\n", end_sim_pck_num);
	    printf ("\tPacket size (min,max,average) in flits: (%u,%u,%u)\n",MIN_PACKET_SIZE,MAX_PACKET_SIZE,AVG_PACKET_SIZE);
	    printf ("\tPacket injector FIFO width in flit:%u \n",TIMSTMP_FIFO_NUM);
}





/************************
 *
 * 	reset system
 *
 *
 * *******************/

void reset_all_register (void){
	int i;
	 total_active_endp=0;
	 total_rsv_pck_num=0;
	 total_sent_pck_num=0;
	 sum_clk_h2h=0;
	 sum_clk_h2t=0;
	 ideal_rsv_cnt=0;
#if (STND_DEV_EN)
	 sum_clk_pow2=0;
#endif

	 sum_clk_per_hop=0;
	 count_en=0;
	 clk_counter=0;

	 for(i=0;i<C;i++)
	 {
		 total_rsv_pck_num_per_class[i]=0;
	     sum_clk_h2h_per_class[i]=0;
	     sum_clk_h2t_per_class[i]=0;
	 	 sum_clk_per_hop_per_class[i]=0;
#if (STND_DEV_EN)
	 	 sum_clk_pow2_per_class[i]=0;
#endif

	 }  //for
	 total_sent_flit_number=0;
}


 

/***********************
 *
 * 	standard_dev
 *
 * ******************/

#if (STND_DEV_EN)
/************************
 * std_dev = sqrt[(B-A^2/N)/N]  = sqrt [(B/N)- (A/N)^2] = sqrt [B/N - mean^2]
 * A = sum of the values
 * B = sum of the squarded values 
 * *************/

double standard_dev( double sum_pow2, unsigned int  total_num, double average){
	double std_dev;
	
	/*
	double  A, B, N;
	N= total_num;
	A= average * N;
	B= sum_pow2;

	A=(A*A)/N;
	std_dev = (B-A)/N;
	std_dev = sqrt(std_dev);
*/	

	std_dev = sum_pow2/(double)total_num; //B/N
	std_dev -= (average*average);// (B/N) - mean^2
	std_dev = sqroot(std_dev);// sqrt [B/N - mean^2]

	return std_dev;

}

#endif



/**********************
 *
 *	pck_class_in_gen
 *
 * *****************/

unsigned char  pck_class_in_gen(
	 unsigned int  core_num

) {
	unsigned char pck_class_in;
	unsigned char  rnd=rand()%100;
	pck_class_in= 	  ( rnd <    C0_p		)?  0:
    				  ( rnd <   (C0_p+C1_p)	)?	1:
    				  ( rnd <   (C0_p+C1_p+C2_p))?2:3;
    return pck_class_in;
}




void update_injct_var(unsigned int src,  unsigned int injct_var){
	//printf("before%u=%u\n",src,random_var[src]);
	random_var[src]= rnd_between(100-injct_var, 100+injct_var);
	//printf("after=%u\n",random_var[src]);
}

unsigned int pck_dst_gen_task_graph ( unsigned int src){
	 task_t  task;
	float f,v;

	int index = task_graph_abstract[src].active_index;

	if(index == DISABLE){
		traffic[src]->ratio=0;
		traffic[src]->stop=1;
		 return INJECT_OFF; //disable sending
	}

	if(	read(task_graph_data[src],index,&task)==0){
		traffic[src]->ratio=0;
		traffic[src]->stop=1;
		 return INJECT_OFF; //disable sending

	}

	if(sent_core_total_pck_num[src] & 0xFF){//sent 255 packets
			//printf("uu=%u\n",task.jnjct_var);
			update_injct_var(src, task.jnjct_var);

		}

	task_graph_total_pck_num++;
	task.pck_sent = task.pck_sent +1;
	task.burst_sent= task.burst_sent+1;
	task.byte_sent = task.byte_sent + (task.avg_pck_size * (Fpay/8) );

	traffic[src]->pck_class_in=  pck_class_in_gen(src);
	//traffic[src]->avg_pck_size_in=task.avg_pck_size;
	traffic[src]->pck_size_in=rnd_between(task.min_pck_size,task.max_pck_size);

	f=  task.injection_rate;
	v= random_var[src];
	f*= (v /100);
	if(f>100) f= 100;
	f=  f * MAX_RATIO / 100;

	traffic[src]->ratio=(unsigned int)f;
	traffic[src]->init_weight=task.initial_weight;

	if (task.burst_sent >= task.burst_size){
		task.burst_sent=0;
		task_graph_abstract[src].active_index=task_graph_abstract[src].active_index+1;
		if(task_graph_abstract[src].active_index>=task_graph_abstract[src].total_index) task_graph_abstract[src].active_index=0;

	}

	update_by_index(task_graph_data[src],index,task);

	if (task.byte_sent  >= task.bytes){ // This task is done remove it from the queue
				remove_by_index(&task_graph_data[src],index);
				task_graph_abstract[src].total_index = task_graph_abstract[src].total_index-1;
				if(task_graph_abstract[src].total_index==0){ //all tasks are done turned off the core
					task_graph_abstract[src].active_index=-1;
					traffic[src]->ratio=0;
					traffic[src]->stop=1;
					if(total_active_routers!=0) total_active_routers--;
					return INJECT_OFF;
				}
				if(task_graph_abstract[src].active_index>=task_graph_abstract[src].total_index) task_graph_abstract[src].active_index=0;
	}

	return endp_addr_encoder(task.dst);
}






