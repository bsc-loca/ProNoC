/**************************************
* Module: pronoc_jtag_uart
* Date:2020-04-11  
* Author: alireza     
*
* Description: 
***************************************/
module  pronoc_jtag_uart #(
    //wb parameter 
    parameter Aw           =   1,
    parameter SELw         =   4,
    parameter TAGw         =   3,
    parameter Dw           =   32,
    //uart parameter    
    parameter BUFF_Aw      =   10,
    //jtag parameter
    parameter JTAG_INDEX= 126,
    parameter JDw = 32,
    parameter JAw=32,
    parameter JINDEXw=8,
    parameter JSTATUSw=8

)(
 //wb
  clk,
  reset,
  wb_irq,
  wb_dat_o,
  wb_ack_o,
  wb_adr_i,
  wb_stb_i,
  wb_cyc_i,
  wb_we_i,
  wb_dat_i,
  dataavailable,
  readyfordata,  
  
  //jtag 
  wb_to_jtag,
  jtag_to_wb
  

);

    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 
    
    
     //wb interface
    localparam 
        DATA_REG = 1'b0,            
        CONTROL_REG  = 1'b1 ,  
        CONTROL_WSPACE_MSK = 32'hFFFF0000,
        DATA_RVALID_MSK = 32'h00008000,
        DATA_DATA_MSK = 32'h000000FF,
        B = 2 ^ (BUFF_Aw-1),
        B_1 = B-1,
        Bw = log2(B),
        DEPTHw=log2(B+1),
        J2WBw= 1+1+JDw+JAw,
        WB2Jw=1+JSTATUSw+JINDEXw+1+JDw;
        
    localparam  [Bw-1   :   0] Bint =   B_1[Bw-1    :   0];
    
    //wb
    input            clk;
    input            reset;
    output           wb_irq;
    output  reg[ Dw-1: 0] wb_dat_o;
    output    reg       wb_ack_o;
    input            wb_adr_i;
    input            wb_stb_i;
    input            wb_cyc_i;
    input            wb_we_i;
    input   [ Dw-1: 0] wb_dat_i;
    output           dataavailable;
    output           readyfordata; //jtag
  
    //jtag
    output [WB2Jw-1  : 0] wb_to_jtag;
    input  [J2WBw-1 : 0] jtag_to_wb; 


    wire [7:0]  wb_to_fifo_dat,fifo_to_wb_dat,jtag_to_fifo_dat,fifo_to_jtag_dat;
    wire [BUFF_Aw-1: 0] wb_to_fifo_addr,jtag_to_fifo_addr;
  
      
    //wb_wr_jtag_rd
    reg [BUFF_Aw- 2      :   0] jtag_rd_ptr;
    reg [BUFF_Aw- 2      :   0] wb_wr_ptr;
    reg [BUFF_Aw -1      :   0] wb_to_jtag_depth;
    reg wb_to_fifo_we,fifo_to_wb_re;
    wire wb_fifo_full, wb_fifo_nearly_full, wb_fifo_empty;
    
    //jtag_wr_wb_rd
    reg [BUFF_Aw- 2      :   0] wb_rd_ptr;
    reg [BUFF_Aw- 2      :   0] jtag_wr_ptr;
    reg [BUFF_Aw -1      :   0] jtag_to_wb_depth;
    reg jtag_to_fifo_we,fifo_to_jtag_re;
    wire jtag_fifo_full, jtag_fifo_nearly_full, jtag_fifo_empty;

    
    
    wire [JSTATUSw-1 : 0] jtag_status_o;
    wire [JINDEXw-1 : 0] jtag_index_o;
    wire jtag_stb_i,jtag_we_i;
    wire [JDw-1 : 0] jtag_dat_i,jtag_dat_o;
    wire [JAw-1 : 0] jtag_addr_i;    
    reg jtag_ack_o;    
 
    assign jtag_status_o=0;
    assign jtag_index_o = JTAG_INDEX; 
    
    assign wb_to_jtag = {jtag_status_o,jtag_ack_o,jtag_dat_o,jtag_index_o,clk};
    assign {jtag_addr_i,jtag_stb_i,jtag_we_i,jtag_dat_i} = jtag_to_wb;
     
    assign jtag_to_fifo_dat = jtag_addr_i[7:0]; //The data written to jtag is passed as address.
    assign jtag_dat_o[8+BUFF_Aw-2 : 0] = (~jtag_fifo_empty)? {jtag_wr_ptr,fifo_to_jtag_dat} : {jtag_wr_ptr,8'd0};

    reg wb_ack_o_next,jtag_ack_o_next;


    always @ (*) begin
        wb_ack_o_next =1'b0;
        wb_to_fifo_we =1'b0;
        fifo_to_jtag_re=1'b0;
        wb_dat_o[7:0]=fifo_to_wb_dat;
        if(wb_stb_i & wb_we_i ) begin 
                case(wb_adr_i)
                DATA_REG:begin
                    if(~wb_fifo_full)begin 
                        wb_to_fifo_we=1'b1;
                        wb_ack_o_next =1'b1;
                    end                
                end
                CONTROL_REG:begin                
                    // set the bits of control reg
                
                end
                endcase
        end //sa_stb_i && sa_we_i
        if(wb_stb_i & ~wb_we_i ) begin 
                case(wb_adr_i)
                DATA_REG:begin
                    wb_dat_o[7:0]=fifo_to_wb_dat;
                    if(~jtag_fifo_empty)begin
                        fifo_to_jtag_re=1'b1;
                        wb_ack_o_next =1'b1;
                     
                    end
                
                end
                CONTROL_REG:begin                
                    // read control reg
                
                end
                endcase
        end
    end//always
  reg jtag_to_fifo_we_next;
  
  
  always @(*) begin
        jtag_to_fifo_we_next=1'b0;
        jtag_ack_o_next =1'b0;
        fifo_to_wb_re=1'b0;
        if(jtag_stb_i) begin 
            if(~wb_fifo_empty) fifo_to_wb_re=1'b1;//make one cycle delay for wr enable
            jtag_ack_o_next =1'b1;       
            if( ~jtag_fifo_full && jtag_to_fifo_dat!=0) jtag_to_fifo_we_next=1'b1;
        end     
    end
    
    
    
    always @ (posedge clk or posedge reset)begin
        if (reset) begin 
            wb_ack_o<=1'b0;
            jtag_ack_o<=1'b0;
            jtag_to_fifo_we<=1'b0;
        end else begin
            wb_ack_o<= wb_ack_o_next;
            jtag_ack_o<=jtag_ack_o_next;
            jtag_to_fifo_we<=jtag_to_fifo_we_next;
        end
    end
    
    assign wb_to_fifo_dat = wb_dat_i [7:0];

    uart_dual_port_ram #(
    	.Dw(8),
    	.Aw(BUFF_Aw)
    )
    uart_ram
    (
    	//wb_to_jtag
    	.data_a(wb_to_fifo_dat),    	
    	.addr_a(wb_to_fifo_addr),
    	.we_a  (wb_to_fifo_we),
    	.q_a   (fifo_to_wb_dat),
    	
    	//jtag_to_wb
    	.data_b(jtag_to_fifo_dat),
    	.addr_b(jtag_to_fifo_addr),    	
    	.we_b  (jtag_to_fifo_we),
    	.q_b   (fifo_to_jtag_dat),
    	
    	.clk   (clk)    	
    );

    assign wb_to_fifo_addr = (wb_to_fifo_we) ? {1'b0,wb_wr_ptr} : {1'b1,wb_rd_ptr};
    assign jtag_to_fifo_addr = (jtag_to_fifo_we) ? {1'b1,jtag_wr_ptr} : {1'b0,jtag_rd_ptr};
    

    //pointers update wb_wr_jtag_rd
    always @(posedge clk)
    begin
       if (reset) begin
          jtag_rd_ptr <= {Bw{1'b0}};
          wb_wr_ptr <= {Bw{1'b0}};
          wb_to_jtag_depth  <= {DEPTHw{1'b0}};
       end
       else begin
          if (wb_to_fifo_we) wb_wr_ptr <= (wb_wr_ptr==Bint)?   {Bw{1'b0}} : wb_wr_ptr + 1'b1;
          if (fifo_to_wb_re) jtag_rd_ptr <= (jtag_rd_ptr==Bint)?   {Bw{1'b0}} : jtag_rd_ptr + 1'b1;
          if (wb_to_fifo_we & ~fifo_to_wb_re) wb_to_jtag_depth <=  wb_to_jtag_depth + 1'b1;
          else if (~wb_to_fifo_we & fifo_to_wb_re) jtag_to_wb_depth <=    wb_to_jtag_depth - 1'b1;
       end
    end
    
    assign wb_fifo_full = wb_to_jtag_depth == B;
    assign wb_fifo_nearly_full = wb_to_jtag_depth >= B-1;
    assign wb_fifo_empty = wb_to_jtag_depth == {DEPTHw{1'b0}};
    
    
    
    
    //pointers update wb_rd_jtag_wr
    always @(posedge clk)
    begin
       if (reset) begin
          wb_rd_ptr <= {Bw{1'b0}};
          jtag_wr_ptr <= {Bw{1'b0}};
          jtag_to_wb_depth  <= {DEPTHw{1'b0}};
       end
       else begin
          if (jtag_to_fifo_we) jtag_wr_ptr <= (jtag_wr_ptr==Bint)?   {Bw{1'b0}} : jtag_wr_ptr + 1'b1;
          if (fifo_to_jtag_re) wb_rd_ptr <= (wb_rd_ptr==Bint)?   {Bw{1'b0}} : wb_rd_ptr + 1'b1;
          if (jtag_to_fifo_we & ~fifo_to_jtag_re) jtag_to_wb_depth <=  jtag_to_wb_depth + 1'b1;
          else if (~jtag_to_fifo_we & fifo_to_jtag_re) jtag_to_wb_depth <=    jtag_to_wb_depth - 1'b1;
       end
    end
    
    assign jtag_fifo_full = jtag_to_wb_depth == B;
    assign jtag_fifo_nearly_full = jtag_to_wb_depth >= B-1;
    assign jtag_fifo_empty = jtag_to_wb_depth == {DEPTHw{1'b0}};



endmodule




// Quartus II Verilog Template
// True Dual Port RAM with single clock


module uart_dual_port_ram
#(
    parameter Dw=8, 
    parameter Aw=6   
)
(
   data_a,
   data_b,
   addr_a,
   addr_b,
   we_a,
   we_b,
   clk,
   q_a,
   q_b
);


    input [(Dw-1):0] data_a, data_b;
    input [(Aw-1):0] addr_a, addr_b;
    input we_a, we_b, clk;
    output  reg [(Dw-1):0] q_a, q_b;

    // Declare the RAM variable
    reg [Dw-1:0] ram[2**Aw-1:0];

       // Port A 
    always @ (posedge clk)
    begin
        if (we_a) 
        begin
            ram[addr_a] <= data_a;
            q_a <= data_a;
        end
        else 
        begin
            q_a <= ram[addr_a];
        end 
    end 

    // Port B 
    always @ (posedge clk)
    begin
        if (we_b) 
        begin
            ram[addr_b] <= data_b;
            q_b <= data_b;
        end
        else 
        begin
            q_b <= ram[addr_b];
        end 
    end

 
   
endmodule









