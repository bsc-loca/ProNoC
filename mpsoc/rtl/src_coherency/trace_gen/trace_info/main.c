#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <byteswap.h>
#include <string.h>
#include <unistd.h>
#include <ctype.h>
#include <dirent.h> 



#define  CACHE_BLK_SIZ 64 



char opcode_str [10][10]= {"MISS","MISS","EVICT"," ", "WAIT_FOR", "WAIT"};
char CACHE_str  [6][10] = {"D","I"};
char miss_str   [2][3]  = {"LD","ST"};


unsigned int rnf_num=1;
char * pattern;
char * path;





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


char * trace_in;
char * path;
unsigned int total_trace_in_dr;



unsigned int trace_num=0;



struct trace_info_struct {
		unsigned int total_trace_num;
		unsigned int total_MissD;
		unsigned int total_MissI;
		unsigned int total_EvictDirty;
		unsigned int total_WFIE;
		unsigned int total_Wait_For;
		unsigned int total_Wait;
		unsigned int total_Atomic;

		//miss D/I type
		unsigned int total_LD_XC; //load exclusive
		unsigned int total_LD_NXC;//load non-exclusive
		unsigned int total_ST_XC; //store exclusive
		unsigned int total_ST_NXC; //store non-exclusive

		unsigned int total_LD;
		unsigned int total_ST;
		unsigned int total_XC;
		unsigned int total_NXC;

		int64_t total_wait_cycles;
		int64_t total_wait_cycles_4bit;
		int64_t total_wait_cycles_6bit;
		int64_t total_wait_cycles_8bit;
};


void usage (void)
{
	printf("Usage: ./tracegen  <options>  \n");
	printf("\nOptions: \n");
	printf("         -f <trace_file>: input trace file to be analyzed.\n");
	printf("         -p <trace_folder>: path to directory contains input trace files to be analyzed.\n");
	exit(1);
}



void processArgs (int argc, char **argv )
{
   char c;  
   opterr = 0;

   while ((c = getopt (argc, argv, "f:p:h")) != -1)
      {
	 switch (c)
	    {
	 	
		case 'f':	
			trace_in= optarg;
			break;
		
		case 'p':
			path = optarg;
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
     if(trace_in == NULL && path == NULL){
	 fprintf (stderr, "The trace file name or the path to the folder containg all application traces are need\n ");
	 usage(); 
      }
      

	     
}


struct trace_info_struct info[64];

void update_miss_type (int64_t trace, unsigned int n) {
	unsigned int  type = (trace >>3) & 0x3; // Excl[4] Ld/St[3]

	if(type == 0) info[n].total_LD_NXC++;//load non-exclusive
	if(type == 1) info[n].total_ST_NXC++; //store non-exclusive
	if(type == 2) info[n].total_LD_XC++; //load exclusive
	if(type == 3) info[n].total_ST_XC++; //store exclusive

	if(type ==0 || type ==2 )info[n].total_LD  ++;
	if(type ==1 || type ==3 )info[n].total_ST  ++;
	if(type ==2 || type ==3 )info[n].total_XC  ++;
	if(type ==0 || type ==1 )info[n].total_NXC ++;


}


void process_the_trace(int64_t trace, unsigned int n){
	int64_t OpCode; //bit loc [2:0]
	int64_t Cycles; //Cycles/@[41:8]
	info[n].total_trace_num++;
	trace = __bswap_64 (trace);
	OpCode = trace & 0x00000007;
	switch (OpCode){
		case(OpCode_L1MissData):
				info[n].total_MissD++;
		 	 	 update_miss_type (trace,n);
		break;
		case (OpCode_L1MissInst ):
				info[n].total_MissI++;
		 	 	update_miss_type (trace,n);
		break;
		case (OpCode_EvictDirty ):
				info[n].total_EvictDirty++;
		break;
		case (OpCode_WFI   		):
				info[n].total_WFIE++;
		break;
		//case (OpCode_WFE        ):

		//break;
		case (OpCode_Wait_For   ):
				info[n].total_Wait_For++;
		break;
		case (OpCode_Wait       ):
				info[n].total_Wait++;
		        Cycles= (trace >>8) & 0xFFFFFFFF;
		        info[n].total_wait_cycles+= Cycles;
		        Cycles &=  0xFF;
		        if (Cycles==0) Cycles=1;
		        info[n].total_wait_cycles_8bit+=Cycles;
		        Cycles &=  0x3F;
		        if (Cycles==0) Cycles=1;
		        info[n].total_wait_cycles_6bit+=Cycles;
		        Cycles &=  0xF;
		        if (Cycles==0) Cycles=1;
		        info[n].total_wait_cycles_4bit+=Cycles;

		break;
		//case (OpCode_AtomicLd   ):

		//break;
		case (OpCode_AtomicSt   ):
				info[n].total_Atomic++;

		break;
		default:
			fprintf (stderr,"Error! Got an undefined OpCode (%lu) in trace line %u",OpCode,info[n].total_trace_num);


	}






}

void display_results(unsigned int n){
	printf("total number of trace_num=  %u\n",     info[n].total_trace_num   );
	printf("total number of MissD=      %u\n",     info[n].total_MissD       );
	printf("total number of MissI=      %u\n",     info[n].total_MissI       );
	printf("total number of EvictDirty= %u\n",     info[n].total_EvictDirty  );
	printf("total number of WFIE=       %u\n",     info[n].total_WFIE        );
	printf("total number of Wait_For=   %u\n",     info[n].total_Wait_For    );
	printf("total number of Wait=       %u\n",     info[n].total_Wait        );
	printf("total number of Atomic=     %u\n",     info[n].total_Atomic      );
	printf("total number of Wait Cycles      =%lu\n",     info[n].total_wait_cycles );
	printf("total number of Wait Cycles 8 bit=%lu\n",     info[n].total_wait_cycles_8bit );
	printf("total number of Wait Cycles 6 bit=%lu\n",     info[n].total_wait_cycles_6bit );
	printf("total number of Wait Cycles 4 bit=%lu\n",     info[n].total_wait_cycles_4bit );

	printf("total number of  missed load exclusive = %u\n", info[n].total_LD_XC);//load exclusive
	printf("total number of  missed load non-exclusive= %u\n", info[n].total_LD_NXC);//load non-exclusive
	printf("total number of  missed store exclusive= %u\n", info[n].total_ST_XC);//store exclusive
	printf("total number of  missed store non-exclusive= %u\n", info[n].total_ST_NXC);//store non-exclusive

	printf("total number of  miss load= %u\n", info[n].total_LD);
	printf("total number of  miss store= %u\n", info[n].total_ST);
	printf("total number of  exclusive= %u\n", info[n].total_XC);
	printf("total number of  non-exclusive= %u\n", info[n].total_NXC);
}


void process_trace_file(char * file_name , unsigned int n){
	int64_t trace;	
	int c;
	FILE *fptr;
	printf("Analyze file:%s\n",file_name);
	fptr = fopen(file_name,"rb");
	if(fptr == NULL)
	{
		fprintf (stderr,"Error! could not open %s file",file_name);
		exit(1);
	}
	
	c=fread(&trace,sizeof(trace),1, fptr);
	do{
		process_the_trace(trace,n);
		//read next trace
		c=fread(&trace,sizeof(trace),1, fptr);
	}while (c==1);

	fclose(fptr);

}




void process_all_traces_in( char * path) {
	struct dirent *de;  // Pointer for directory entry 
  	char * ext;
	int n=0;
	// opendir() returns a pointer of DIR type.  
	DIR *dr = opendir(path); 
  	char fname [500];
	if (dr == NULL)  // opendir returns NULL if couldn't open directory 
	{ 
       		fprintf (stderr,"Could not open %s directory",path ); 
        	exit(1);
	} 
  
        while ((de = readdir(dr)) != NULL) {
		ext = strrchr(de->d_name, '.');
		if (!ext) {
		    /* no extension */
		} else {
		    //printf("extension is %s\n", ext + 1);
		    if (strcmp(ext +1, "bin")==0){
			sprintf (fname, "%s/%s",path,de->d_name);
			process_trace_file( fname, n); 
                        //display_results(n);
			n++;
		    }

  		}


         	
  	}

	
	total_trace_in_dr=n; 
    	closedir(dr);     
	
}

char str [100];
char * convert_metric (int64_t in){

	float f;
	if(in <1000){
		sprintf(str,"%lu",in);

	}else if (in<1000000){
		f=(float)in/1000;
		sprintf(str,"%.2f k",f);
    }else {
    	f=(float)in/1000000;
    	sprintf(str,"%.2f M",f);
    }
    return &str[0];
}


void get_max_wait_cycle() {

	int64_t max_wait_cycles=0;
	int64_t max_wait_cycles_4bit=0;
	int64_t max_wait_cycles_6bit=0;
	int64_t max_wait_cycles_8bit=0;
	
	int64_t total_trace_num=0;
	int64_t total_MissD=0;
	int64_t total_MissI=0;
	int64_t total_EvictDirty=0;
	int64_t total_WFIE=0;
	int64_t total_Wait_For=0;
	int64_t total_Atomic=0;

	//miss D/I type
	int64_t total_LD_XC=0; //load exclusive
	int64_t total_LD_NXC=0;//load non-exclusive
	int64_t total_ST_XC=0; //store exclusive
	int64_t total_ST_NXC=0; //store non-exclusive

	int64_t total_LD=0;
	int64_t total_ST=0;
	int64_t total_XC=0;
	int64_t total_NXC=0;

	int n;

	for (n=0; n<total_trace_in_dr; n++){
		if(max_wait_cycles     < info[n].total_wait_cycles     ) max_wait_cycles      = info[n].total_wait_cycles  ;
		if(max_wait_cycles_4bit< info[n].total_wait_cycles_4bit) max_wait_cycles_4bit = info[n].total_wait_cycles_4bit;
		if(max_wait_cycles_6bit< info[n].total_wait_cycles_6bit) max_wait_cycles_6bit = info[n].total_wait_cycles_6bit;
		if(max_wait_cycles_8bit< info[n].total_wait_cycles_8bit) max_wait_cycles_8bit = info[n].total_wait_cycles_8bit;

		//accumulators
		total_trace_num += info[n].total_trace_num;
		total_MissD     += info[n].total_MissD;
		total_MissI     += info[n].total_MissI;
		total_EvictDirty+= info[n].total_EvictDirty;
		total_WFIE      += info[n].total_WFIE;
		total_Wait_For  += info[n].total_Wait_For;
		total_Atomic    += info[n].total_Atomic;

		//miss D/I type
		total_LD_XC     += info[n].total_LD_XC;
		total_LD_NXC    += info[n].total_LD_NXC;
		total_ST_XC     += info[n].total_ST_XC;
		total_ST_NXC    += info[n].total_ST_NXC;

		total_LD        += info[n].total_LD;
		total_ST        += info[n].total_ST;
		total_XC        += info[n].total_XC;
		total_NXC       += info[n].total_NXC;
	}

	printf(" max_wait_cycles        = %lu (%s)\n",	max_wait_cycles     ,convert_metric(max_wait_cycles)      );
	printf(" max_wait_cycles_4bit   = %lu (%s)\n",	max_wait_cycles_4bit,convert_metric(max_wait_cycles_4bit) );
	printf(" max_wait_cycles_6bit   = %lu (%s)\n",	max_wait_cycles_6bit,convert_metric(max_wait_cycles_6bit) );
	printf(" max_wait_cycles_8bit   = %lu (%s)\n",	max_wait_cycles_8bit,convert_metric(max_wait_cycles_8bit) );

	//accumulators
	printf("total_trace_num  = %lu (%s)\n" , total_trace_num ,convert_metric(total_trace_num ));
	printf("total_MissD      = %lu (%s)\n" , total_MissD     ,convert_metric(total_MissD     ));
	printf("total_MissI      = %lu (%s)\n" , total_MissI     ,convert_metric(total_MissI     ));
	printf("total_EvictDirty = %lu (%s)\n" , total_EvictDirty,convert_metric(total_EvictDirty));
	printf("total_WFIE       = %lu (%s)\n" , total_WFIE      ,convert_metric(total_WFIE      ));
	printf("total_Wait_For   = %lu (%s)\n" , total_Wait_For  ,convert_metric(total_Wait_For  ));
	printf("total_Atomic     = %lu (%s)\n" , total_Atomic    ,convert_metric(total_Atomic    ));

	printf("total_LD_XC      = %lu (%s)\n" , total_LD_XC     ,convert_metric(total_LD_XC     ));
	printf("total_LD_NXC     = %lu (%s)\n" , total_LD_NXC    ,convert_metric(total_LD_NXC    ));
	printf("total_ST_XC      = %lu (%s)\n" , total_ST_XC     ,convert_metric(total_ST_XC     ));
	printf("total_ST_NXC     = %lu (%s)\n" , total_ST_NXC    ,convert_metric(total_ST_NXC    ));

	printf("total_LD         = %lu (%s)\n" , total_LD        ,convert_metric(total_LD        ));
	printf("total_ST         = %lu (%s)\n" , total_ST        ,convert_metric(total_ST        ));
	printf("total_XC         = %lu (%s)\n" , total_XC        ,convert_metric(total_XC        ));
	printf("total_NXC        = %lu (%s)\n" , total_NXC       ,convert_metric(total_NXC       ));

}






int main ( int argc, char **argv ){
	
	int n;

	processArgs (argc,argv );



 	for (n=0; n<32; n++){

		info[n].total_trace_num=0;
		info[n].total_MissD=0;
		info[n].total_MissI=0;
		info[n].total_EvictDirty=0;
		info[n].total_WFIE=0;
		info[n].total_Wait_For=0;
		info[n].total_Wait=0;
		info[n].total_Atomic=0;
		info[n].total_wait_cycles=0;
		info[n].total_wait_cycles_8bit=0;
		info[n].total_wait_cycles_6bit=0;
		info[n].total_wait_cycles_4bit=0;
		info[n].total_LD_XC=0;//load exclusive
		info[n].total_LD_NXC=0;//load non-exclusive
		info[n].total_ST_XC=0;//store exclusive
		info[n].total_ST_NXC=0;//store non-exclusive

		info[n].total_LD=0;
		info[n].total_ST=0;
		info[n].total_XC=0;
		info[n].total_NXC=0;
	}

	if(trace_in != NULL){
		process_trace_file(trace_in,0);
		display_results(0);
	}


	if (path != NULL ){
		process_all_traces_in(path);
		get_max_wait_cycle();

	}


	
	return 0;
}
