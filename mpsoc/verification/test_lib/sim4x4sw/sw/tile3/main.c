//This code just recives packets and shows the packet contents
#include "mor1k_tile.h"
#define TOTAL_CORE  (MAX_X_ADDR	* MAX_Y_ADDR)
//if there is a data chach make sure the snoop protocol is supported by CPU to invalidate the 
// the local copy of the recive_buffer once the NI update the main memory
volatile unsigned char  recive_buffer[2][16];

// a simple delay function
void delay ( unsigned int num ){	
	while (num>0){ 
		num--;
		nop(); // asm volatile ("nop");
	}
	return;
}

void error_handling_function(){
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

unsigned int reseived_counter=0;
void got_packet_function(){
//this function sends packet saving command to the NI. It doese not wait until the packet saving is finished. Once the packet is completely saved, the  software will be notified using SAVE_DONE_ISR intrrupt or it can check by using ni_packet_is_saved(v) function.
	unsigned int i;
	for (i=0;i<ni_NUM_VCs;i++){
		if(ni_got_packet(i)) {
			ni_receive (i, (unsigned int)(&recive_buffer[i][0]), 4);
      			reseived_counter++;
		}
	}
}

void check_packet_function(){// in this example we just print the packet content
	unsigned int i,size,j;
	struct SRC_INFOS  src_info;
	for (i=0;i<ni_NUM_VCs;i++){
		if(ni_packet_is_saved(i)) {
			src_info=get_src_info(i);
			size=ni_RECEIVE_DATA_SIZE_REG(i); 
			printf("A message of %u words is recived from core (%x) in vc%u:", size,src_info.addr,i);
			 for (j=0;j<size*4;j++){
					 printf("%c", recive_buffer[i][j]);
			}
				printf("\n");
		}
	}
}

// NI interrupt function
void ni_isr(void){
	//place your interrupt code here 
	if( ni_STATUS2_REG & ERRORS_ISR ){
	// An error ocures 
		error_handling_function();
		ni_ack_errors_isr();
	}
	if( ni_STATUS2_REG & SAVE_DONE_ISR ){
	//check which VC has finished saving the packet. This function must be called before got_packet_function
		check_packet_function();
		ni_ack_save_done_isr(); 
	}
	if( ni_STATUS2_REG & GOT_PCK_ISR ){
	//check which VC got a packet and send the save command to NI to start saving the packet. 
		got_packet_function();
	//Please note that the whole of the packet may not yet be in the memory when the code reaches here. Once the packet is completely saved the  software will be notified using SAVE_DONE_ISR flag  
		ni_ack_got_pck_isr();
	}
	return;
}

int main(){
	int i,j;
	unsigned int send_counter=0;
	printf("Hi from core %u \n",COREID);
	int_init();
	int_add(0, ni_isr, 0);
	// Enable ni interrupt (its connected to inttruupt pin 0)
	int_enable(0);
	cpu_enable_user_interrupts();
	// hw interrupt enable function:
	// ni_initial (burst_size,  errors_int_en,  send_int_en,  save_int_en,  got_pck_int_en)
	ni_initial (16,1,0,1,1); //enable the intrrupt when a packet is recived, saved or got any error
	delay(2000+COREID);
	printf("total received packets by core%u is %u\n",COREID, reseived_counter);
	while(1){

	}
	return 0;
}