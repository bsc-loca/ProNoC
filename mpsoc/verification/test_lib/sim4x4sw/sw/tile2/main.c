//This code send packets to tile 3 (1,1) 
#include "mor1k_tile.h"
#define TOTAL_CORE  (MAX_X_ADDR	* MAX_Y_ADDR)

unsigned char pck1[10]={"first data"}; 
unsigned char pck2[11]={"second data"}; 
unsigned char pck3[6]={"123456"}; 
unsigned char recive_buffer[15];

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
	unsigned int i;
	for (i=0;i<ni_NUM_VCs;i++){
		if(ni_got_packet(i)) {
			ni_receive (i, (unsigned int)recive_buffer, 4);
			reseived_counter++;
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
	
	return;
}

int main(){
	int i;
	//void ni_initial (unsigned int burst_size,unsigned char send_int_en,unsigned char save_int_en,unsigned char got_pck_int_en)
	printf("Hi from core %u\n",COREID);
	int_init();
	int_add(0, ni_isr, 0);
	// Enable ni interrupt (its connected to inttruupt pin 0)
	int_enable(0);
	cpu_enable_user_interrupts();
	// hw interrupt enable function:
	// ni_initial ( burst_size,  errors_int_en, send_int_en,  save_int_en, got_pck_int_en)
	ni_initial (16,1,0,0,1); //enable the  intrrupt when a packet is recived or when there is an error
	//ni_transfer (w, v,  class_num,  data_start_addr,   data_size,  dest_x, dest_y){
	ni_transfer (1,0, 0, (unsigned int)&pck1[0],  3, PHY_ADDR_ENDP_3);
	ni_transfer (1,1, 1, (unsigned int)&pck2[0],  3, PHY_ADDR_ENDP_3);
	ni_transfer (1,0, 0, (unsigned int)&pck3[0],  2, PHY_ADDR_ENDP_3);
	//printf("core %u sent packet to (%u,%u)",CORID,rnd_dest_x[i],rnd_dest_y[i]);
	printf("total sent packets by core%u is %u\n",COREID,3);
	
	while(1){

	}
	return 0;
}