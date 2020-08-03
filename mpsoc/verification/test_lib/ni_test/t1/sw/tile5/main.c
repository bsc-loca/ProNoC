//This code just recives packets and shows the packet contents
#include "mor1k_tile.h"

//if there is a data chach make sure the snoop protocol is supported by CPU to invalidate the 
// the local copy of the recive_buffer once the NI update the main memory
volatile unsigned char  recive_buffer[3][30];

volatile unsigned int reseived_counter=0;

// a simple delay function
void delay ( unsigned int num ){	
	while (num>0){ 
		num--;
		nop(); // asm volatile ("nop");
	}
	return;
}

/////////////////////////////////////////////////////////
void error_handling_function(){
	unsigned int i;
	for (i=0;i<ni_NUM_VCs;i++){
			if(ni_ERROR_FLAGS_REG(i)){
				printf ("Error in vc %u\n",i);
				if(ni_ERROR_FLAGS_REG(i) & BUFF_OVER_FLOW_ERR) printf ("The receiver allocated buffer size is smaller than the received packet size in core%u\n",COREID);
				if(ni_ERROR_FLAGS_REG(i) & SEND_DATA_SIZE_ERR)  printf ("the send data size is not set in core%u\n",COREID);
				if(ni_ERROR_FLAGS_REG(i) & BURST_SIZE_ERR)	 printf (" the burst size is not set in core%u\n",COREID);
				if(ni_ERROR_FLAGS_REG(i) & ILLEGAL_SEND_REQ)  printf( "A new send request is received while the DMA is still busy sending previous packet in core%u\n",COREID);
				if(ni_ERROR_FLAGS_REG(i) & CRC_MISS_MATCH)	    printf( "CRC miss-matched in core%u\n",COREID);

		 } 
	}
}

unsigned char iport_array[ni_NUM_VCs];

void got_packet_function(){
	unsigned int i ;
	unsigned char iport;
	for (i=0;i<ni_NUM_VCs;i++){
		if(ni_got_packet(i)) {
			iport =ni_RECEIVE_PRECAP_DATA_REG(i); 	
			ni_receive (i, recive_buffer[iport] , 30, 0);		
		  iport_array[i]=iport;
		}//If ni got packet
	}//for	
}
	  
    
void check_packet_function(){
		unsigned char iport;
		unsigned int i ,j,size ;
		unsigned int credit_value,credit_port;
		struct SRC_INFOS  src_info;
		for (i=0;i<ni_NUM_VCs;i++){
			if(ni_packet_is_saved(i)) {
				src_info=get_src_info(i);
				size=ni_RECEIVE_DATA_SIZE_REG(i); 
				iport= iport_array[i];
				
				printf("A message of %u bytes is recived from core (%x) vc%u port%u:", size,src_info.addr,i,iport);
				for (j=0;j<size*4;j++){
					 printf("%c", recive_buffer[iport][j]);
				}//for
				printf("\n");
		}// end if packet is saved
	}//for
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
	//printf("total received packets by core%u is %u\n",COREID, reseived_counter);
	while(1){

	}
	return 0;
}