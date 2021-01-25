#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <byteswap.h>

#define  CACHE_BLK_SIZ 64 



char opcode_str [10][10]= {"MISS","MISS","EVICT"," ", "WAIT_FOR", "WAIT"};
char CACHE_str  [6][10]= {"D","I"};
char miss_str  [2][3]= {"LD","ST"};



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


    #define REPEAT 10

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


int main(){
	uint64_t reqid=0;
	
	printf("generate file\n");

		
	fptr = fopen("trace.bin","wb");
    fp = fopen("trace.txt","w");
	if(fptr == NULL)
	{
	     printf("Error! coudnot creat trace.bin file");
	     exit(1);
	}
	if(fp == NULL)
	{
	     printf("Error! Coudnot creat trace.txt file");
	     exit(1);
	}

	int i;
	uint64_t addr;
	
	

	addr = 0;
	for (i=0;i<REPEAT;i++) {
		addr=addr+ (CACHE_BLK_SIZ);
		GEN_READ_SHD
		//GEN_READ_UNIQUE
		
		
		//addr=addr+ 64;//(1024*CACHE_BLK_SIZ);
		//addr=addr+ (1024*CACHE_BLK_SIZ);	

	}


    fclose(fptr);
    fclose(fp);
	return 0;
}
