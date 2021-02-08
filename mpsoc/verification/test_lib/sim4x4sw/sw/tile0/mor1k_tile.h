#ifndef MOR1K_TILE_SYSTEM_H
	#define MOR1K_TILE_SYSTEM_H
 
 
 /*  ss   */ 
 
 
 /*  uart   */ 
 #include "define_printf.h" // This file must be available in processor folder which define the printf function

#define uart_DATA_REG					(*((volatile unsigned int *) (0X90000000)))
#define uart_CONTROL_REG				(*((volatile unsigned int *) (0X90000000+4)))
#define uart_CONTROL_WSPACE_MSK	0xFFFF0000
#define uart_DATA_RVALID_MSK			0x00008000
#define uart_DATA_DATA_MSK			0x000000FF

//////////////////////////////*basic function for jtag_uart*////////////////////////////////////////
void jtag_putchar(char ch);
char jtag_getchar(void);
void outbyte(char c){jtag_putchar(c);} //called in printf();
char inbyte(){return jtag_getchar();}

void jtag_putchar(char ch){ //print one char from jtag_uart
	while((uart_CONTROL_REG&uart_CONTROL_WSPACE_MSK)==0);
	uart_DATA_REG=ch;
}

char jtag_getchar(void){ //get one char from jtag_uart
	unsigned int data;
	data=uart_DATA_REG;
	while(!(data & uart_DATA_RVALID_MSK)) //wait for terminal input
		data=uart_DATA_REG;
	return (data & uart_DATA_DATA_MSK);
}	

int jtag_scanstr(char* buf){ //scan string until <ENTER> to buf, return str length 
	char ch; unsigned int i=0;
	while(1){
		ch=jtag_getchar();
		if(ch=='\n') { buf[i]=0; jtag_putchar(ch); i++; break; } //ENTER
		else if(ch==127) { printf("\b \b"); if(i>0) i--; } //backspace
		else { jtag_putchar(ch); buf[i]=ch; i++; } //valid
	}
	return i;
}

int jtag_scanint(int *num){ //return the scanned integer
	unsigned int curr_num,strlen,i=0;
	char str[11];
	strlen=jtag_scanstr(str); //scan str
	if(strlen>11) { printf("overflows 32-bit integer value\n");return 1; } //check overflow
	*num=0;
	for(i=0;i<strlen;i++){ //str2int
		curr_num=(unsigned int)str[i]-'0';
		if(curr_num>9); //not integer: do nothing
		else *num=*num*10+curr_num;  //is integer
	}
	return 0;
}



/////////////////////////////*END: basic function for jtag_uart*////////////////////////////////////
 
 
 /*  cpu   */ 
  #include "mor1kx/system.h" 

 inline void nop (){
	__asm__("l.nop 1");
 }
/*********************
//Interrupt template: check mor1kx/int.c for more information
// interrupt function
void hw_isr(void){
	//place your interrupt code here


	HW_ISR=HW_ISR; //ack the interrupt at the end of isr function
	return;
}

int main(){
		
	int_init();
	//assume hw interrupt pin is connected to 10th cpu intrrupt pin 
	int_add(10, hw_isr, 0);
	// Enable this interrupt 
	int_enable(10);
	cpu_enable_user_interrupts();
	hw_init ( ); // hw interrupt enable function
	while(1){
	//place rest of the code

	}
}
*******************************/
 
 
 /*  ni   */ 
 //intrrupt flag location
  #define ni_INT (1<<0)
 #include <stdint.h>
#include "../phy_addr.h"
 
/*	    NI wb registers addresses
	    0   :   STATUS1_WB_ADDR           // status1:  {send_vc_is_busy,receive_vc_is_busy,receive_vc_packet_is_saved,receive_vc_got_packet};
	    1   :   STATUS2_WB_ADDR           // status2:  {send_enable_binary,receive_enable_binary,vc_got_error,aT2_error_isr,got_pck_isr, save_done_isr,send_done_isr,aT2_error_int_en,got_pck_int_en, save_done_int_en,send_done_int_en};   
            2   :   BURST_SIZE_WB_ADDR       // The busrt size in words 
            
            3   :   SEND_DATA_SIZE_WB_ADDR,  // The size of data to be sent in byte  
            4   :   SEND_STRT_WB_ADDR,       // The address of data to be sent   in byte       
            5   :   SEND_DEST_WB_ADDR        // The destination router address
            6   :   SEND_CTRL_WB_ADDR
            
            7   :   RECEIVE_DATA_SIZE_WB_ADDR // The size of recieved data in byte  
            8   :   RECEIVE_STRT_WB_ADDR      // The address pointer of reciever memory in byte
            9   :   RECEIVE_SRC_WB_ADDR       // The source router (the router which is sent this packet). 
            10  :   RECEIVE_CTRL_WB_ADDR      // The NI reciever control register 
            11  :   RECEIVE_MAX_BUFF_SIZ      // The receiver's  allocated buffer size in words. If the packet size is bigger tha the buffer size the rest of will be discarred
            12  :   ERROR_FLAGS	// errors:  {crc_miss_match,burst_size_error,send_data_size_error,rcive_buff_ovrflw_err};  	
            
*/
#define COREID	0
#define CORE_PHY_ADDR   PHY_ADDR_ENDP_0


#define ni_STATUS1_REG   (*((volatile unsigned int *) (0Xb8000000)))   //0
#define ni_STATUS2_REG   (*((volatile unsigned int *) (0Xb8000000+4)))   //1
#define ni_BURST_SIZE_REG  (*((volatile unsigned int *) (0Xb8000000+8))) //2


#define ni_NUM_VCs	2

#define ni_SEND_DATA_SIZE_REG(v)  (*((volatile unsigned int *) (0Xb8000000+12+(v<<6))))  //3
#define ni_SEND_START_ADDR_REG(v)   (*((volatile unsigned int *) (0Xb8000000+16+(v<<6))))  //4
#define ni_SEND_DEST_REG(v)   (*((volatile unsigned int *) (0Xb8000000+20+(v<<6)))) //5
#define ni_SEND_CTRL_REG(v)    (*((volatile unsigned int *) (0Xb8000000+24+(v<<6)))) //6

#define ni_RECEIVE_DATA_SIZE_REG(v)  (*((volatile unsigned int *) (0Xb8000000+28+(v<<6)))) //7
#define ni_RECEIVE_STRT_ADDR_REG(v)   (*((volatile unsigned int *) (0Xb8000000+32+(v<<6)))) //8
#define ni_RECEIVE_SRC_REG(v)    (*((volatile unsigned int *) (0Xb8000000+36+(v<<6))))  //9
#define ni_RECEIVE_CTRL_REG(v)    (*((volatile unsigned int *) (0Xb8000000+40+(v<<6)))) //10
#define ni_RECEIVE_MAX_BUFF_SIZ_REG(v)    (*((volatile unsigned int *) (0Xb8000000+44+(v<<6)))) //11
#define ni_ERROR_FLAGS_REG(v)    (*((volatile unsigned int *) (0Xb8000000+48+(v<<6)))) //12



// assign status1= {send_vc_is_busy,receive_vc_is_busy,receive_vc_packet_is_saved,receive_vc_got_packet};
// assign status2= {send_enable_binary,receive_enable_binary,vc_got_error,aT2_error_isr,got_pck_isr, save_done_isr,send_done_isr,aT2_error_int_en,got_pck_int_en, save_done_int_en,send_done_int_en};
    

#define ni_got_packet(v) 	((ni_STATUS1_REG >> (v)) & 0x1)
#define ni_packet_is_saved(v) ((ni_STATUS1_REG >> (2+v)) & 0x1)
#define ni_receive_is_busy(v)	((ni_STATUS1_REG >> (2*2+v)) & 0x1)
#define ni_send_is_busy(v)	((ni_STATUS1_REG >> (3*2+v)) & 0x1)
#define ni_got_aT2_error(v)  ((ni_STATUS2_REG >> (8+v)) & 0x1)

#define SEND_DONE_INT_EN  (1<<0) 
#define SAVE_DONE_INT_EN  (1<<1) 
#define GOT_PCK_INT_EN  (1<<2)
#define ERRORS_INT_EN  (1<<3)  
#define ALL_INT_EN  (SEND_DONE_INT_EN | SAVE_DONE_INT_EN | GOT_PCK_INT_EN  | ERRORS_INT_EN) 

#define SEND_DONE_ISR (1<<4) 
#define SAVE_DONE_ISR (1<<5) 
#define GOT_PCK_ISR (1<<6) 
#define ERRORS_ISR (1<<7)



//errors = {crc_miss_match,illegal_send_req,burst_size_error,send_data_size_error,rcive_buff_ovrflw_err};  
#define BUFF_OVER_FLOW_ERR  (1<<0)  // This error happens when the receiver allocated buffer size is smaller than the received packet size 
#define SEND_DATA_SIZE_ERR  (1<<1)  // This error happens when the send data size is not set  
#define BURST_SIZE_ERR	    (1<<2)  // This error happens when the burst size is not set
#define ILLEGAL_SEND_REQ    (1<<3)  // This error happens when a new send request is received while the DMA is still busy sending previous packet
#define CRC_MISS_MATCH	    (1<<4)  // This error happens when the received packet CRC miss match

//ack intrrupts functions
#define ni_ack_send_done_isr()  (ni_STATUS2_REG &= (ALL_INT_EN |SEND_DONE_ISR))
#define ni_ack_save_done_isr()  (ni_STATUS2_REG &= (ALL_INT_EN | SAVE_DONE_ISR))
#define ni_ack_got_pck_isr()    (ni_STATUS2_REG &= (ALL_INT_EN | GOT_PCK_ISR))
#define ni_ack_errors_isr()    (ni_STATUS2_REG &= (ALL_INT_EN | ERRORS_ISR))

#define ni_ack_all_isr()  (ni_STATUS2_REG = ni_STATUS2_REG)


struct SRC_INFOS{
	unsigned char r; // reserved
	unsigned char c;  // message  class
	int16_t addr; // phy_addr
} ;

inline struct SRC_INFOS get_src_info(unsigned char v){
	struct SRC_INFOS  src_info =*(struct SRC_INFOS *) (&ni_RECEIVE_SRC_REG(v));
	return  src_info;
} 

/*
	The NI initializing function. 
	The burst_size must be  <= 16
	send_int_en :1: enable the intrrupt when a packet is sent 0 : This intrrupt is disabled
	save_int_en : 1: enable the intrrupt when a recived packet is saved on internal buffer  0 : This intrrupt is disabled
	got_pck_int_en : 1: enable the intrrupt when a packet is recived in NI. 0 : This intrrupt is disabled

*/
void ni_initial (unsigned int burst_size, unsigned char errors_int_en, unsigned char send_int_en, unsigned char save_int_en, unsigned char got_pck_int_en) {
	ni_BURST_SIZE_REG  =  burst_size;
	if(errors_int_en) ni_STATUS2_REG |= ERRORS_INT_EN;
	if(send_int_en) ni_STATUS2_REG |= SEND_DONE_INT_EN;
	if(save_int_en) ni_STATUS2_REG |= SAVE_DONE_INT_EN;
	if(got_pck_int_en) ni_STATUS2_REG |= GOT_PCK_INT_EN;
}

/*
	The NI message sent function:
	v: virtual chanel number which this packet should be sent to
	class_num: message class number. Diffrent message classes can be sent via isolated network resources to avoid protocol deadlock
 	data_start_addr : The address pointer to the start location of the packet to be sent in the memory
	data_size: the message data size in words
	dest_phy_addr: the destination endpoint physical address. check phy_adr.h file for knowing each endpoint physical address

*/

void ni_transfer (unsigned int init_weight, unsigned int v, unsigned int class_num, unsigned int data_start_addr,  unsigned int data_size, unsigned int dest_phy_addr){
	 while (ni_send_is_busy(v)); // wait until VC is busy sending previous packet

	ni_SEND_DATA_SIZE_REG(v)  = data_size;
	ni_SEND_START_ADDR_REG(v)  = data_start_addr;
	ni_SEND_DEST_REG(v)   = dest_phy_addr | (class_num<<16) | (init_weight<<24);
	 
}

/*
	The NI message receiver function:
	v: virtual chanel number of the received packet
	data_start_addr : The address pointer to the start location of the memory where the newly arrived packet must be stored by NI in.
	max_buffer_size : The allocated receive-memory buffer size in words.
*/

void ni_receive (unsigned int v, unsigned int data_start_addr,  unsigned int max_buffer_size){
	 while (ni_receive_is_busy(v)); // wait until VC is busy saving previous packet

	ni_RECEIVE_STRT_ADDR_REG(v)  = data_start_addr;
	ni_RECEIVE_MAX_BUFF_SIZ_REG(v) = max_buffer_size;
	ni_RECEIVE_CTRL_REG(v)   = 1;

	 
}
 
 
 /*  ram   */ 
 
 
 /*  timer   */ 
 //intrrupt flag location
  #define timer_INT (1<<1)
 #define timer_TCSR	   			(*((volatile unsigned int *) (0X96000000	)))
		
/*
//timer control register
TCSR
bit
PRESCALER WIDTH+3:4	:	clk_dev_ctrl
3		:	timer_isr
2		:	rst_on_cmp_value
1		:	int_enble_on_cmp_value
0		:	timer enable 
*/	
	#define timer_TLR	   			(*((volatile unsigned int *) (0X96000000+4	)))
	#define timer_TCMR	   			(*((volatile unsigned int *) (0X96000000+8	)))
	#define timer_EN				(1 << 0)
	#define timer_INT_EN				(1 << 1)
	#define timer_RST_ON_CMP			(1 << 2)
//Initialize the timer. Enable the timer, reset on compare value, and interrupt
	void timer_int_init ( unsigned int compare ){
		timer_TCMR	=	compare;
		timer_TCSR   =	( timer_EN | timer_INT_EN | timer_RST_ON_CMP);
	}

#define timer_start()  timer_TCSR|=timer_EN
#define timer_stop()  timer_TCSR&=~timer_EN
#define timer_reset() timer_TLR=0
#define timer_read() timer_TLR
 
 
 /*  bus   */ 
 #endif
