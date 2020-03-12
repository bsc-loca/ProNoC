`timescale 1ns / 1ps
/**********************************************************************
**  File:  xilinx_jtag_wb.v 
**  
**    
**  Copyright (C) 2020  Alireza Monemi
**    
**  This file is part of ProNoC 
**
**  ProNoC ( stands for Prototype Network-on-chip)  is free software: 
**  you can redistribute it and/or modify it under the terms of the GNU
**  Lesser General Public License as published by the Free Software Foundation,
**  either version 2 of the License, or (at your option) any later version.
**
**  ProNoC is distributed in the hope that it will be useful, but WITHOUT
**  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
**  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
**  Public License for more details.
**
**  You should have received a copy of the GNU Lesser General Public
**  License along with ProNoC. If not, see <http:**www.gnu.org/licenses/>.
**
**
**  Description: 
**  xilinx bscan chain to wishbon bus interface. It prvide simple read/write on 
**  whishbone bus. Does not support burst transaction.
**
*******************************************************************/
`timescale 1 ps / 1 ps

module xilinx_jtag_to_wb #(
    parameter JWB_NUM=1,
    parameter Dw=32,
    parameter Aw=32,
    parameter INDEXw=8,
    parameter CTRL_REG_INDEX =127

)(
    clk,
    reset,
    cpu_en,
    system_reset,
    wb_to_jtag_all,
    jtag_to_wb_all
);

     function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

    localparam  J2WBw= 1+1+Dw+Aw;
    localparam  WB2Jw=8+8+1+Dw;
    
    input reset,clk;
    output cpu_en, system_reset;
    
    input [JWB_NUM*WB2Jw-1  : 0] wb_to_jtag_all;
    output[JWB_NUM*J2WBw-1 : 0] jtag_to_wb_all; 
    
    wire  [J2WBw-1  : 0] jtag_to_wb [JWB_NUM-1 : 0];
    wire  [WB2Jw-1  : 0] wb_to_jtag [JWB_NUM-1 : 0];   
    wire  [INDEXw-1 : 0] wb_to_jtag_index[JWB_NUM-1 : 0];
    wire  [INDEXw-1 : 0] jtag_to_wb_index;
    wire  [JWB_NUM-1: 0] jtag_sel_onehot;
    wire  [WB2Jw-1  : 0] wb_to_jtag_mux;
    wire  [JWB_NUM-1: 0] stb_all;    

    wire [7    : 0] wb_to_jtag_status;
    wire [Dw-1 : 0] wb_to_jtag_dat; 
    wire wb_to_jtag_ack;
    
    wire [Dw-1 : 0] jtag_to_wb_dat;
    wire [Aw-1 : 0] jtag_to_wb_addr;
    wire jtag_to_wb_stb;
    wire jtag_to_wb_we;
    
    
    genvar i;
    generate
        for (i = 0; i < JWB_NUM ; i = i + 1) begin : block
            assign  wb_to_jtag[i]  = wb_to_jtag_all [(i+1)*WB2Jw-1 : i*WB2Jw];
            assign  wb_to_jtag_index [i]  = wb_to_jtag[i][7:0];
            assign  jtag_sel_onehot[i] = (wb_to_jtag_index [i] == jtag_to_wb_index);
            assign  stb_all[i] = jtag_to_wb_stb & jtag_sel_onehot[i];            
            
            assign  jtag_to_wb_all[(i+1)*J2WBw-1 : i*J2WBw] =jtag_to_wb[i];
            assign  jtag_to_wb[i] = {stb_all[i],jtag_to_wb_we,jtag_to_wb_dat,jtag_to_wb_addr};
        end
    endgenerate
    
    
    localparam BIN_WIDTH     =  (JWB_NUM>1)? log2(JWB_NUM):1;
    wire [BIN_WIDTH-1 : 0] jtag_sel_bin;

  
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(JWB_NUM),
        .BIN_WIDTH()
    )
    convert
    (
        .one_hot_code(jtag_sel_onehot),
        .bin_code(jtag_sel_bin)
    );
    assign wb_to_jtag_mux= wb_to_jtag[jtag_sel_bin];    
    assign {wb_to_jtag_status,wb_to_jtag_ack,wb_to_jtag_dat} = wb_to_jtag_mux[WB2Jw-1 : INDEXw]; 
   
    xilinx_jtag_mem_ctrl #(
        .Dw(Dw),
        .Aw(Aw),
        .INDEXw(INDEXw)
    )
    mem_ctrl
    (   
       
        .wb_to_jtag_status(wb_to_jtag_status ),
        .wb_to_jtag_dat   (wb_to_jtag_dat    ),
        .wb_to_jtag_ack   (wb_to_jtag_ack    ),
                         
        .jtag_to_wb_index (jtag_to_wb_index  ),
        .jtag_to_wb_dat   (jtag_to_wb_dat    ),
        .jtag_to_wb_addr  (jtag_to_wb_addr   ),
        .jtag_to_wb_stb   (jtag_to_wb_stb    ),
        .jtag_to_wb_we    (jtag_to_wb_we     ),
        
        .reset (reset),
        .clk(clk)
        
   );
   
    reg [1:0]ctrl_reg;   
    always @(posedge clk or posedge reset)begin    
       if(reset)  ctrl_reg <=2'b00;
       else if(jtag_to_wb_index ==   CTRL_REG_INDEX)begin 
            if(jtag_to_wb_we & jtag_to_wb_stb) begin 
                ctrl_reg <= jtag_to_wb_dat[1:0];
            end
       end  
    end 

    assign  {cpu_en, system_reset} =ctrl_reg;
endmodule



module  xilinx_jtag_mem_ctrl #(
    parameter Dw=32,
    parameter Aw=32,
    parameter INDEXw=8
)(
   
    wb_to_jtag_status,
    wb_to_jtag_dat,
    wb_to_jtag_ack,
    
    jtag_to_wb_index,
    jtag_to_wb_dat,
    jtag_to_wb_addr,
    jtag_to_wb_stb,
    jtag_to_wb_we,
        
    reset,
    clk
);

    
    input [7    : 0] wb_to_jtag_status;
    input [Dw-1 : 0] wb_to_jtag_dat; 
    input wb_to_jtag_ack;
    
    output [INDEXw-1  : 0] jtag_to_wb_index;
    output [Dw-1 : 0] jtag_to_wb_dat;
    output [Aw-1 : 0] jtag_to_wb_addr;
    output jtag_to_wb_stb;
    output jtag_to_wb_we;

    input reset,clk;

     localparam 
        STATE_NUM=3,
        IDEAL =1,
        WB_WR_DATA=2,
        WB_RD_DATA=4;
    
   
    
    reg [STATE_NUM-1    :   0] ps,ns;
      
    wire  wb_wr_addr_en,  wb_wr_data_en,    wb_rd_data_en;
    reg wr_mem_en,  rd_mem_en,  wb_cap_rd;
    
    reg [Aw-1   :   0]  wb_addr,wb_addr_next;
    reg [Dw-1   :   0]  wb_wr_data,wb_rd_data;
    reg wb_addr_inc;    
    
   
    assign  jtag_to_wb_stb    = wr_mem_en |  rd_mem_en;
    assign  jtag_to_wb_we     = wr_mem_en;
    assign  jtag_to_wb_dat    = wb_wr_data;
    assign  jtag_to_wb_addr   = wb_addr;
   

    localparam 
        JDw= (Dw > Aw)? Dw : Aw;
    
    wire [JDw-1  :0] data_out;
    wire [JDw-1   :0] data_in;
    
    assign  data_in    = wb_rd_data;
    localparam Iw=2;
   
    
    xilinx_jtag_ctrl #(
        .Dw(JDw),
        .Iw(Iw),
        .INDEXw(INDEXw)
    )
    vjtag_ctrl_inst
    (
        .ir(  ),
        .index(jtag_to_wb_index),
        .clk(clk),
        .reset(reset),
        .data_out(data_out),
        .data_in(data_in),
        .wb_wr_addr_en(wb_wr_addr_en),
        .wb_wr_data_en(wb_wr_data_en),
        .wb_rd_data_en(wb_rd_data_en)
    );
        
    
    always @(posedge clk or posedge reset) begin 
        if(reset) begin 
            wb_addr <= {Aw{1'b0}};
            wb_wr_data  <= {Dw{1'b0}};  
            ps <= IDEAL;
        end else begin
            wb_addr <= wb_addr_next;
            ps <= ns;
            if(wb_wr_data_en) wb_wr_data  <= data_out;  
            if(wb_cap_rd) wb_rd_data <= wb_to_jtag_dat;
        end
    end
    
    
    always @(*)begin 
        wb_addr_next= wb_addr;
        if(wb_wr_addr_en) wb_addr_next = data_out [Aw-1 :   0];
        else if (wb_addr_inc)  wb_addr_next = wb_addr +1'b1;    
    end
    
    
    
    always @(*)begin 
        ns=ps;
        wr_mem_en =1'b0;
        rd_mem_en =1'b0;
        wb_addr_inc=1'b0;
        wb_cap_rd=1'b0;
        case(ps)
        IDEAL : begin 
            if(wb_wr_data_en) ns= WB_WR_DATA;   
            if(wb_rd_data_en) ns= WB_RD_DATA;   
        end 
        WB_WR_DATA: begin 
            wr_mem_en =1'b1;
            if(wb_to_jtag_ack) begin 
                ns=IDEAL;
                wb_addr_inc=1'b1;           
            end
        end 
        WB_RD_DATA: begin 
            rd_mem_en =1'b1;
            if(wb_to_jtag_ack) begin 
                wb_cap_rd=1'b1;
                ns=IDEAL;
                //wb_addr_inc=1'b1;         
            end     
        end     
        endcase 
    end 
        
endmodule










/*
module xilinx_jtag_wb #(
    parameter INDEXw = 8, //Index width of target master wishbone bus.   
    parameter DW=32,
    parameter AW=32,
      
    //wishbone port parameters
    parameter S_Aw          =   7,
    parameter M_Aw          =   32,
    parameter TAGw          =   3,
    parameter SELw          =   4    
)(
    clk,
    reset,
    index, 
    ir,
    //data_out,
   
    //wishbone master interface signals
    m_sel_o,
    m_dat_o,
    m_addr_o,
    m_cti_o,
    m_stb_o,
    m_cyc_o,
    m_we_o,
    m_dat_i,
    m_ack_i    
);

    //IO declaration
    input reset,clk;
    output [INDEXw-1 :0] index;
    
    //wishbone master interface signals
    output  [SELw-1          :   0] m_sel_o;
    output  [DW-1            :   0] m_dat_o;
    output  [M_Aw-1          :   0] m_addr_o;
    output  [TAGw-1          :   0] m_cti_o;
    output                          m_stb_o;
    output                          m_cyc_o;
    output                          m_we_o;
    input   [DW-1           :  0]   m_dat_i;
    input                           m_ack_i;    
    output  [1:0] ir;
    //output  [DW-1  :0] data_out; 
    
  
    
    
    localparam 
        STATE_NUM=3,
        IDEAL =1,
        WB_WR_DATA=2,
        WB_RD_DATA=4;
    
    reg [STATE_NUM-1    :   0] ps,ns;
      
    wire  wb_wr_addr_en,  wb_wr_data_en,    wb_rd_data_en;
    reg wr_mem_en,  rd_mem_en,  wb_cap_rd;
    
    reg [AW-1   :   0]  wb_addr,wb_addr_next;
    reg [DW-1   :   0]  wb_wr_data,wb_rd_data;
    reg wb_addr_inc;    
    
    assign  m_cti_o    = 3'b000;
    assign  m_sel_o    = 4'b1111;
    assign  m_cyc_o    = m_stb_o;
    assign  m_stb_o    = wr_mem_en |  rd_mem_en;
    assign  m_we_o     = wr_mem_en;
    assign  m_dat_o    = wb_wr_data;
    assign  m_addr_o   = wb_addr;
   

    localparam 
        JDw= (DW > AW)? DW : AW;
    
    wire [JDw-1  :0] data_out;
    wire [JDw-1   :0] data_in;
    
    assign  data_in    = wb_rd_data;
    localparam Iw=2;
    xilinx_jtag_ctrl #(
        .Dw(JDw),
        .Iw(Iw),
        .INDEXw(INDEXw)
    )
    vjtag_ctrl_inst
    (
        .ir(ir ),
        .index(index),
        .clk(clk),
        .reset(reset),
        .data_out(data_out),
        .data_in(data_in),
        .wb_wr_addr_en(wb_wr_addr_en),
        .wb_wr_data_en(wb_wr_data_en),
        .wb_rd_data_en(wb_rd_data_en)
    );
        
    
    always @(posedge clk or posedge reset) begin 
        if(reset) begin 
            wb_addr <= {AW{1'b0}};
            wb_wr_data  <= {DW{1'b0}};  
            ps <= IDEAL;
        end else begin
            wb_addr <= wb_addr_next;
            ps <= ns;
            if(wb_wr_data_en) wb_wr_data  <= data_out;  
            if(wb_cap_rd) wb_rd_data <= m_dat_i;
        end
    end
    
    
    always @(*)begin 
        wb_addr_next= wb_addr;
        if(wb_wr_addr_en) wb_addr_next = data_out [AW-1 :   0];
        else if (wb_addr_inc)  wb_addr_next = wb_addr +1'b1;    
    end
    
    
    
    always @(*)begin 
        ns=ps;
        wr_mem_en =1'b0;
        rd_mem_en =1'b0;
        wb_addr_inc=1'b0;
        wb_cap_rd=1'b0;
        case(ps)
        IDEAL : begin 
            if(wb_wr_data_en) ns= WB_WR_DATA;   
            if(wb_rd_data_en) ns= WB_RD_DATA;   
        end 
        WB_WR_DATA: begin 
            wr_mem_en =1'b1;
            if(m_ack_i) begin 
                ns=IDEAL;
                wb_addr_inc=1'b1;           
            end
        end 
        WB_RD_DATA: begin 
            rd_mem_en =1'b1;
            if(m_ack_i) begin 
                wb_cap_rd=1'b1;
                ns=IDEAL;
                //wb_addr_inc=1'b1;         
            end     
        end     
        endcase 
    end 
        
endmodule

*/


module xilinx_jtag_ctrl #(
    parameter Dw=32,
    parameter Iw=2,
    parameter INDEXw=7
)(
    clk,
    reset,
    data_out,
    data_in,
    wb_wr_addr_en,
    wb_wr_data_en,
    wb_rd_data_en,
    ir,
    index
);

    

    localparam 
        BUFFw= Dw+Iw+INDEXw;
        
     // IR states
    localparam [Iw-1:0]
        DONT_CAPTURE     = 2'b00,
        UPDATE_WB_ADDR   = 2'b01,
        UPDATE_WB_WR_DATA= 2'b10,
        UPDATE_WB_RD_DATA= 2'b11;
        
        

//IO declaration
    input reset,clk;
    output [Dw-1    :0] data_out;
    input [Dw-1 :0] data_in;
    output wb_wr_addr_en, wb_wr_data_en,    wb_rd_data_en;
    output  reg [Iw-1:0] ir;
    output  reg [INDEXw-1:0] index;
    

    wire      tdo, tck,   tdi;  
    wire      cdr ,sdr,udr;
    wire tlr;
    
    xilinx_jtag_bscan      vjtag_inst (
    
    .tdo ( tdo ),   
    .tck ( tck ),
    .tdi ( tdi ),
    
    .tlr ( tlr ),
    .cdr ( cdr ),
    .sdr ( sdr ),
    .udr ( udr )
    
    );
      
    // internal registers 
  // (* KEEP = "TRUE" *)  wire [Iw-1:0] ir;
   (* KEEP = "TRUE" *)  reg [BUFFw-1   :   0] jtag_shift_buffer,jtag_shift_buffer_next;
 
      
  
    assign tdo =  jtag_shift_buffer[0];
    assign data_out = jtag_shift_buffer[Dw-1 : 0];
    
    
    always @ (*)begin 
        jtag_shift_buffer_next=jtag_shift_buffer;
        if( sdr ) jtag_shift_buffer_next={tdi,jtag_shift_buffer[BUFFw-1:1]};// shift buffer
        if( cdr ) jtag_shift_buffer_next = {data_in,index,ir}; 
        
    end
        
    always @(posedge tck or posedge tlr)    begin
        if (tlr)begin 
            // jtag_shift_buffer<={BUFFw{1'b0}};
            // ir<= {Iw{1'b0}};            
        end else begin 
            jtag_shift_buffer<=jtag_shift_buffer_next;  
            if( udr & (jtag_shift_buffer_next[Iw-1:0]!=DONT_CAPTURE) )begin 
                {index,ir} <= jtag_shift_buffer_next[INDEXw+Iw-1 : 0];
            end    
        end
    end   
    
   /* 
    always @(posedge tck ) begin       
           if( sdr ) jtag_shift_buffer<={tdi,jtag_shift_buffer[BUFFw-1:1]};// shift buffer
           if( cdr ) jtag_shift_buffer<={data_in,ir};
           if( udr ) ir <= jtag_shift_buffer_next[Iw-1:0];
    end   
    */
    
    
    reg wb_wr_addr1,    wb_wr_data1,    wb_rd_data1;
    //always @(posedge tck or posedge reset)
    always @(*)
    begin
        //if( reset )   begin
        //  wb_wr_addr1<=1'b0;
        //  wb_wr_data1<=1'b0;
        //end else begin
            wb_wr_addr1=(ir== UPDATE_WB_ADDR || ir== UPDATE_WB_RD_DATA) &  udr;
            wb_wr_data1=(ir== UPDATE_WB_WR_DATA &&  udr );  
            wb_rd_data1=(ir== UPDATE_WB_RD_DATA && cdr);
        //end   
    end
    
    reg wb_wr_addr2,    wb_wr_data2,    wb_rd_data2;
    reg wb_wr_addr3,    wb_wr_data3,    wb_rd_data3;
    
    always @(posedge clk or posedge reset)
    begin
        if( reset ) begin
            wb_wr_addr2<=1'b0;
            wb_wr_data2<=1'b0;
            wb_wr_addr3<=1'b0;
            wb_wr_data3<=1'b0;
            wb_rd_data2<=1'b0;
            wb_rd_data3<=1'b0;
        end else begin
            wb_wr_addr2<=wb_wr_addr1;
            wb_wr_data2<=wb_wr_data1;   
            wb_wr_addr3<=wb_wr_addr2;
            wb_wr_data3<=wb_wr_data2;   
            wb_rd_data2<=wb_rd_data1;
            wb_rd_data3<=wb_rd_data2;
        end 
    end

    assign wb_wr_addr_en =(wb_wr_addr2 & ~wb_wr_addr3);
    assign wb_wr_data_en =(wb_wr_data2 & ~wb_wr_data3);     
    assign wb_rd_data_en =(wb_rd_data2 & ~wb_rd_data3);
endmodule



module xilinx_jtag_bscan (
    tck,
    tdo,
    tdi,
    
    tlr,
    sdr,
    cdr,
    udr
);

// May be 1, 2, 3, or 4
// Only used for Virtex 4/5 devices
parameter jtag_chain = 4;

input  tdo;
output tck;
output tdi;

output tlr;
output sdr;
output cdr;
output udr;



wire sel;
wire shift,update,capture;
assign sdr = shift & sel;
assign udr = update & sel;
assign cdr = capture & sel;


    BSCANE2 #(
        .JTAG_CHAIN( jtag_chain) // Value for USER command.
    )
    bse2_inst
    (
        .CAPTURE(capture), // 1-bit output: CAPTURE output from TAP controller.
        .DRCK( ), // 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or SHIFT are asserted.
        .RESET(tlr), // 1-bit output: Reset output for TAP controller.
        .RUNTEST(), // 1-bit output: Output asserted when TAP controller is in Run Test/Idle state.
        .SEL(sel), // 1-bit output: USER instruction active output.
        .SHIFT(shift), // 1-bit output: SHIFT output from TAP controller.
        .TCK(tck), // 1-bit output: Test Clock output. Fabric connection to TAP Clock pin.
        .TDI(tdi), // 1-bit output: Test Data Input (TDI) output from TAP controller.
        .TMS( ), // 1-bit output: Test Mode Select output. Fabric connection to TAP.
        .UPDATE(update), // 1-bit output: UPDATE output from TAP controller
        .TDO(tdo) // 1-bit input: Test Data Output (TDO) input for USER function.
    );

  
endmodule
