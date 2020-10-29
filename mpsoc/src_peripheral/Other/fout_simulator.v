/**************************************
* Module: simulator_UART
* Date:2017-06-13  
* Author: alireza     
*
* Description: A simple uart that display input characters on simulator terminal using $write command.
*              This module start wrting on terminal when the buffer becomes full or wait counter reach its limit. 
*              The buffer  perevents the conflict between multiple simulation UART messages 
*              Wait counter reset by each individual write on buffer
***************************************/
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on



module  fout_simulator #(
    parameter BUFFER_SIZE   =255  // for getting fle name

)(
    reset,
    clk,
    s_dat_i,
    s_sel_i,
    s_addr_i,  
    s_cti_i,
    s_stb_i,
    s_cyc_i,
    s_we_i,    
    s_dat_o,
    s_ack_o    

);

   localparam 
	Dw            =   32,
	M_Aw          =   32,
    TAGw          =   3,
    SELw          =   4;
  


    input reset,clk;
	//wishbone slave interface signals
    input   [Dw-1       :   0]      s_dat_i;
    input   [SELw-1     :   0]      s_sel_i;
    input   [2:0]    			    s_addr_i;  
    input   [TAGw-1     :   0]      s_cti_i;
    input                           s_stb_i;
    input                           s_cyc_i;
    input                           s_we_i;
    
    output  reg [Dw-1       :   0]  s_dat_o;
    output  reg                     s_ack_o;


  

     wire s_ack_o_next    =   s_stb_i & (~s_ack_o);
     
    always @(posedge clk)begin 
        if( reset   )s_ack_o<=1'b0;
       else s_ack_o<=s_ack_o_next;
    end
     
     
//synthesis translate_off
//synopsys  translate_off


   
	function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 
   
    
    localparam Bw = log2(BUFFER_SIZE+1);
    
   
    reg [7  : 0 ]  buffer [ 0  : BUFFER_SIZE-1];
    wire [ BUFFER_SIZE*8-1 : 0] buff_string;
    genvar i;
    generate
    for (i=0;i<BUFFER_SIZE;i=i+1)begin 
    	assign  buff_string [(i+1)*8-1 : i*8] = buffer [BUFFER_SIZE-i-1];
     end
     endgenerate


   
    reg [Bw-1   :   0] ptr,ptr_next;
   
    always @(posedge clk)begin 
        if( reset   )s_ack_o<=1'b0;
       else s_ack_o<=s_ack_o_next;
    end
            
  
	reg buff_en;

		

	reg [7: 0 ]  file_ptr,file_ptr_next;
	integer file [0:126];

	
	
localparam //WB address registers
	GET_FLE_PTR   = 0,
	GET_FILE_NAME	= 1,
	GET_FILE_CONTENT = 2;

reg [3: 0] counter_next,counter;

   always @(*)begin 
        counter_next=counter;
        ptr_next = ptr;
        buff_en=0;
        file_ptr_next=file_ptr;
		if( s_stb_i &  s_cyc_i &  s_we_i & ~s_ack_o) begin // get a write command from WB interface
			case(s_addr_i)
			GET_FLE_PTR:begin
					file_ptr_next=s_dat_i[7:0];			
			end
			GET_FILE_NAME:begin 
				if(s_dat_i[7:0]==0)begin //end of file name. Open the file to write
					
					file[file_ptr] = $fopen(buff_string, "w");
					
					$display("create %s\n",buff_string);					
				end else begin 				
					buff_en=1;
					if( ptr < BUFFER_SIZE)begin 
						ptr_next  =  ptr+1;
						counter_next=counter+1'b1;
					end    
				end 
			end
			GET_FILE_CONTENT:begin
				$fwrite (file[file_ptr], "%c", s_dat_i[7:0]);
				
			end
			endcase
		end
    end
  
 
   generate 
   for (i=0;i<BUFFER_SIZE;i=i+1)begin 
    	always @ (posedge clk)begin 
			if(reset)begin 
				file[i]<=0;
			end
			if(counter==4'hF) if(file[i]!=0) $fflush (file[i]);
		end
   end
   endgenerate
  
  
    
    always @(posedge clk)begin 
        if(reset) begin 
           
            ptr<=0;
            buffer[0]<=0;
			file_ptr<=0; 
			counter<=0;
        end else begin
			file_ptr<=file_ptr_next;
            counter<=counter_next;
            ptr <= ptr_next;
            if( buff_en )begin 
                buffer[ptr]<=s_dat_i[7:0];
                if(ptr<BUFFER_SIZE-1) buffer[ptr+1]<=0;         
            end 
        end
    end

	


  
 //synopsys  translate_on
//synthesis translate_on 

endmodule




