#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <byteswap.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>

#define  CACHE_BLK_SIZ 64 



char opcode_str [10][10]= {"MISS","MISS","EVICT"," ", "WAIT_FOR", "WAIT"};
char CACHE_str  [6][10] = {"D","I"};
char miss_str   [2][3]  = {"LD","ST"};


unsigned int rnf_num=1;
char * pattern;
char * path;

unsigned int min_delay=0;
unsigned int max_delay=0;
unsigned int load_percentage =50;
unsigned int store_percentage=50;
unsigned int trace_num=100;
unsigned int min_rnd=0;
unsigned int max_rnd=0xFFFFFFFF;



 #define OpCode_L1MissData   0x0 //000
 #define OpCode_L1MissInst   0x1 //001
 #define OpCode_EvictDirty   0x2 //010
 #define OpCode_WFI   		 0x3 //011
 #define OpCode_WFE          0x3 //011
 #define OpCode_Wait_For     0x4 //100
 #define OpCode_Wait         5   //101
 #define OpCode_AtomicLd     6   //110
 #define OpCode_AtomicSt     6   //110

 #define LD  0
 #define ST  1


  

FILE *fptr, *fp;

unsigned int line_num=0;


void gen_cache_miss_trace (uint64_t ReqId,uint64_t addr, uint64_t OpC, uint64_t Excl, uint64_t Ld_St, 	uint64_t OpCode ){
//(addr/=4);
	uint64_t trace=0xDEADBEEFDEADBEEF;
	trace =ReqId;
	trace <<=((41-8)+1);// addr size
	trace |=(addr);
	trace <<=3; // OpC size
	trace |= OpC;
	trace <<=1; // OpC Excl
	trace |= Excl;
	trace <<=1; // OpC Ld_St
	trace |= Ld_St;
	trace <<=3; // OpC Ld_St
	trace |= OpCode;
	trace = __bswap_64 (trace);
	fwrite(&trace, 8, 1, fptr);
    char Ex = (Excl)? 'X' : ' ';
    char Evict = (OpCode==OpCode_EvictDirty)? 'E' : ' ';
    fprintf(fp,"%u: 0 0 %s %lu 0x%lx %s %s %c %c\n",line_num, opcode_str[OpCode],ReqId, addr,CACHE_str[OpCode],miss_str[Ld_St],Evict,Ex);
    line_num++;
}


void gen_wait_trace ( uint64_t Cycles, uint64_t Instructions ){
//(addr/=4);
	uint64_t trace= Instructions;
	trace <<=((41-8)+1);// Cycles size
	trace |=(Cycles);
	trace <<=3; // OpC size
	//trace |= OpC;
	trace <<=1; // OpC Excl
	//trace |= Excl;
	trace <<=1; // OpC Ld_St
	//trace |= Ld_St;
	trace <<=3; // OpC Ld_St
	trace |= OpCode_Wait;
	trace = __bswap_64 (trace);
	fwrite(&trace, 8, 1, fptr);
   // char Ex = (Excl)? 'X' : ' ';
   // char Evict = (OpCode==OpCode_EvictDirty)? 'E' : ' ';
   fprintf(fp,"%u: 0 0 %s %lu %lu \n",line_num, opcode_str[OpCode_Wait], Cycles, Instructions);
   
    line_num++;
}

#define GEN_READ_SHD  gen_cache_miss_trace(reqid++,addr,0,0,LD,OpCode_L1MissData);gen_wait_trace ( 2, 0);
#define GEN_READ_UNIQUE         gen_cache_miss_trace(reqid++,addr,0,0,ST,OpCode_L1MissData);gen_wait_trace ( 2, 0);




void usage (void)
{
	printf("Usage: ./tracegen  <options>  \n");
	printf("\nOptions: \n");
	printf("         -p <path>: path where the generatd trace files will be saved there.\n");
	printf("         -r <rn num>: number of request nodes.\n");
	printf("         -t <pattern>: traffic pattern: \"RANDON\", \"HOTSPOT\" .\n");
	printf("         -l <lower bound delay>: minimum delay between two instructions.\n");	
	printf("         -u <upper bound delay>: maximum delay between two instructions.\n");
	printf("         -L <Load miss percentage>.\n");
	printf("         -S <Store miss percentage>.\n");
	printf("         -a <Minimum Random Address in hex>.\n");
	printf("         -b <Maximum Random Address in hex>.\n");
	printf("         -n <trace num>. number of trace lines in each trace file\n");
	exit(1);	
}

 char default_path [] = "./out";
 char default_pattern [] =  "RANDOM";

void processArgs (int argc, char **argv )
{
   char c;  
   opterr = 0;

   while ((c = getopt (argc, argv, "r:t:l:u:a:b:L:S:p:n:h")) != -1)
      {
	 switch (c)
	    {
	 	
		case 'r':	
			sscanf(optarg, "%u", &rnf_num);
			break;
		case 't':
			pattern =  optarg;
			if (strcmp(pattern,"RANDOM")!=0 &&  strcmp(pattern,"HOTSPOT")!=0){
					fprintf (stderr, "Error unsupported %s pattern\n",pattern);
					usage();
			}	
			break;
		case 'p':
			path =  optarg;
			break;	
		case 'l':
	      	sscanf(optarg, "%u", &min_delay);
			break;
		case 'u':
	      	sscanf(optarg, "%u", &max_delay);
			break;
		case 'L':
			sscanf(optarg, "%u", &load_percentage);			
			break;
		case 'S':
			sscanf(optarg, "%u", &store_percentage);
			break;	
		case 'n':
			sscanf(optarg, "%u", &trace_num);
			break;		
		
		case 'a':
			sscanf(optarg, "%x", &min_rnd);
			break;
		case 'b':
                        sscanf(optarg, "%x", &max_rnd);
			break;

		case 'h':
			usage();
     		break;
		case '?':
	     	  if (isprint (optopt))
			  fprintf (stderr, "Unknown option `-%c'.\n", optopt);
	     	  else
			  fprintf (stderr,   "Unknown option character `\\x%x'.\n",   optopt);
		default:
		      usage();
	    }
      }
      if(max_delay < min_delay) {
		  fprintf (stderr, "max_delay of %u is smaller than min_delay of %u.\n",max_delay, min_delay );
		  usage();
	  }	
	  if((load_percentage + store_percentage)!=100){
		  fprintf (stderr, "load_percentage + store_percentage = %u. The sumation should be 100.\n",load_percentage + store_percentage );
		  usage();
		  
	  }	
	 
	  if(path == NULL) path= default_path;  
	  if(pattern==NULL) pattern = default_pattern;      
}

unsigned int gen_Randoms (int lower, int upper) 
{ 
   return  ((rand() % (upper - lower + 1)) + lower);  
} 


int main ( int argc, char **argv ){
	
	processArgs (argc,argv );
	
	uint64_t reqid;
	uint64_t addr;
	int i,j;
	char file_name1[256];
	char file_name2[256];
	unsigned int delay,tmp;
	
	for (i=0;i<rnf_num; i++){
		
		sprintf (file_name1,"%s/trace%u.bin",path,i);
		sprintf (file_name2,"%s/trace%u.txt",path,i);
		printf("generate file:%s\n",file_name1);
	
		fptr = fopen(file_name1,"wb");
		fp   = fopen(file_name2,"w");
		if(fptr == NULL)
		{
			fprintf (stderr,"Error! coudnot creat trace.bin file");
			exit(1);
		}
		if(fp == NULL)
		{
			fprintf (stderr,"Error! Coudnot creat trace.txt file");
			exit(1);
		}
		addr = 0;
		reqid=0;
		line_num=0;
		for (j=0;j<trace_num;j++) {
			tmp=gen_Randoms(0,100);
			delay=gen_Randoms(min_delay,max_delay);
			if(strcmp(pattern,"RANDOM")==0){
					addr=gen_Randoms(min_rnd,max_rnd);
					addr *=CACHE_BLK_SIZ;
			}else{
				//TODO  add hotspot
				
				
			}		
			if(tmp<load_percentage){
				gen_cache_miss_trace(reqid++,addr,0,0,LD,OpCode_L1MissData);
			}else{
				gen_cache_miss_trace(reqid++,addr,0,0,ST,OpCode_L1MissData);
			}		
			gen_wait_trace ( delay, 0);
			
			
		}
		fclose(fptr);
		fclose(fp);
		
	}
	
		
	
	return 0;
}
