/**************************************
* Module: hnf_ibuffer_manager
* Date:2019-06-26  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ps




module  hnf_req_buffer #(
   parameter B  = 10// buffer num
)(
    req_din, 
    wr_en, 
    credit_out,
    req_dout,
    
    // These infos are read one cyle before actual flit is read  so they can be used by snoop filter, cache. exclusive monitore to make decision before getting actual flit
    next_addr_out,
    next_srcid_out, 
    next_lpid_out,  
    next_opcode_out,
    next_excl_snoopme_out,    
    
    
    rd_en, 
    re_try, 
    add_credit,
   /*
    add_rd_to_end,
    new_req_full,
    retry_full,
    */
    
    
    
    nearly_full,
    full,
    
    empty,
    reset,
    clk
);

     `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

     localparam Dw = REQ_FLIT_SIZE;

 
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

    localparam  Bw = log2(B),
                DEPTHw=log2(B+1);
    

    input [Dw-1:0] req_din;     // Data in
    input          wr_en;   // Write enable
    input          rd_en;   // Read the next word
    input re_try;
    output reg credit_out;
    input add_credit;
    

    output reg [Dw-1:0]  req_dout;    // Data out
    output         full;
    output         nearly_full;
    output         empty;
    
    
    
    output [ADDR_REQ-1 : 0]  next_addr_out;
    output [SRCID_REQ-1:0]           next_srcid_out;
    output [LPID_REQ-1:0]            next_lpid_out; 
    output [OPCODE_REQ-1:0]          next_opcode_out;
    output next_excl_snoopme_out;
    
    

    input          reset;
    input          clk;

    wire [Bw- 1      :   0] rd_ptr;
    wire [Bw- 1      :   0] wr_ptr;
    
    reg  [B-1 : 0] is_valid,rd_ptr_onehot_reg;
    wire [B-1 : 0] wr_ptr_onehot, rd_ptr_onehot, is_empty;
    genvar i;
    generate 
    for (i=0;i<B;i=i+1)begin : v
    always @(posedge clk or posedge reset) begin
        if(reset) is_valid[i] <= 1'b0;
        else if((wr_en & wr_ptr_onehot[i])|(re_try & rd_ptr_onehot_reg[i] )  ) is_valid[i] <= 1'b1;
        else if(rd_en & rd_ptr_onehot[i]) is_valid[i] <= 1'b0;        
    end
    end
    endgenerate
    
    
    //save rd_ptr_onehot value. So if we revives retry signal, we can add it the list of valid data again
    always @(posedge clk or posedge reset) begin
        if(reset) rd_ptr_onehot_reg<={B{1'b0}};
        else if(rd_en) rd_ptr_onehot_reg<=rd_ptr_onehot;
    end
    
    
    
    assign is_empty = ~ is_valid;
   
    // we are not allowed to write data in the last read position. As It may get retry signal
    wire [B-1 : 0] ready_for_write = is_empty & (~rd_ptr_onehot_reg) ;
    arbiter_priority_en #(
        .ARBITER_WIDTH(B)
    )
    wr_arbiter
    (
        .request(ready_for_write),
        .grant(wr_ptr_onehot),
        .any_grant( ),
        .clk(clk),
        .reset(reset),
        .priority_en(wr_en)
    );
    
   
    arbiter_priority_en #(
        .ARBITER_WIDTH(B)
    )
    rd_arbiter
    (
        .request(is_valid),
        .grant(rd_ptr_onehot),
        .any_grant( ),
        .clk(clk),
        .reset(reset),
        .priority_en(rd_en)
    );
    
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(B)
    )
    wr_conv(
        .one_hot_code(wr_ptr_onehot),
        .bin_code(wr_ptr)
    );
    
    
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(B)
    )
    rd_conv(
        .one_hot_code(rd_ptr_onehot),
        .bin_code(rd_ptr)
    );
    
    
    


reg [Dw-1       :   0] queue [B-1 : 0] /* synthesis ramstyle = "no_rw_check" */;

reg [DEPTHw-1   :   0] depth;

// Sample the data
always @(posedge clk)
begin
   if (wr_en)
      queue[wr_ptr] <= req_din;
   if (rd_en)
      req_dout <=
//synthesis translate_off
//synopsys  translate_off
          #1
//synopsys  translate_on
//synthesis translate_on  
          queue[rd_ptr];
end

always @(posedge clk)
begin
   if (reset) begin    
      depth  <= {DEPTHw{1'b0}};
   end
   else begin     
      if (wr_en & ~rd_en & ~re_try) depth <= depth + 1'b1;
      else if (~wr_en & rd_en & ~re_try) depth <= depth - 1'b1;     
      else if (wr_en & ~rd_en & re_try) depth <= depth + 2'd2;
      else if (wr_en & rd_en & re_try) depth <= depth + 1'b1;
      else if (~wr_en & ~rd_en & re_try) depth <= depth + 1'b1;
     // else if (~wr_en & rd_en & re_try) depth <= depth ;
   end
end

//assign req_dout = queue[rd_ptr];
assign full = depth == B;
assign nearly_full = depth >= B-1;
assign empty = depth == {DEPTHw{1'b0}};






get_req_flit_excl_info  next_excl_info(
        .reqflit(queue[rd_ptr]),
        .addr(next_addr_out),
        .srcid(next_srcid_out),
        .lpid(next_lpid_out), 
        .opcode(next_opcode_out),
        .excl_snoopme(next_excl_snoopme_out)
   );

    always @(posedge clk or posedge reset) begin
            if(reset)begin 
                credit_out<=1'b0;
            end else begin 
                credit_out<=add_credit;
            end        
    end//always






//synthesis translate_off
//synopsys  translate_off
always @(posedge clk)
begin
    if(~reset)begin
       if (wr_en && depth == B && !rd_en)begin
          $display(" %t: ERROR: Attempt to write to full FIFO: %m",$time);
          $stop;
       end 
       if (rd_en && depth == {DEPTHw{1'b0}})begin 
          $display("%t: ERROR: Attempt to read an empty FIFO: %m",$time);
          $stop;
       end
       
       if(wr_ptr_onehot=={B{1'b0}} & wr_en) begin 
          $display(" %t: ERROR: Attempt to write when there was no candidate write location: %m",$time);
          $stop;
       end
       
       
    end//~reset
end
//synopsys  translate_on
//synthesis translate_on

   
    


endmodule





















// currently we dont use retry only make a large buffer


module  hnf_req_retry_manager #(
    parameter B=4,
    parameter EXTND_B=8

   )(
   
    // CHI RXREQ
    noc_chi_rxreqflitpend,
    noc_chi_rxreqflitv,
    noc_chi_rxreqflit,          
    chi_noc_rxreqlcrdv,      
    
    // to buffer
    rxreqflitpend,
    rxreqflitv,
    rxreqflit,          
    rxreqlcrdv,      
 
    reset,
    clk
);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

       // RXREQ
    input   noc_chi_rxreqflitpend ;
    input   noc_chi_rxreqflitv;
    input  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit;          
    output reg chi_noc_rxreqlcrdv;   

   
    output   rxreqflitpend ;
    output  reg rxreqflitv;
    output  [REQ_FLIT_SIZE-1:0]    rxreqflit;          
    input  rxreqlcrdv;   

    assign rxreqflitpend=1'b1;
    
    input reset,clk;
    
    
    reg read_fifo_en ;
    wire fifo_empty;
    localparam IDEAL=1;
    localparam PROCESS_REQ=2;
    reg [1:0] pst;
    reg [1:0] nst;
   
    bram_based_fifo #(
        .Dw(REQ_FLIT_SIZE),
        .B(EXTND_B)
    )
    flit_fifo
    (
        .din(noc_chi_rxreqflit),
        .wr_en(noc_chi_rxreqflitv),
        .rd_en(read_fifo_en ),
        .dout(rxreqflit),
        .full(),
        .nearly_full(),
        .empty(fifo_empty),
        .reset(reset),
        .clk(clk)
    ); 
    
    wire buff_ready;
    
     credict_ckeck #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(rxreqflitv),
        .noc_chi_lcrdv(rxreqlcrdv),
        .have_cridit(buff_ready),
        .nearly_full(),
        .reset(reset),
        .clk(clk)
     );
    
    
    
 always @(*)begin 
        read_fifo_en=1'b0;
        nst=pst;
        rxreqflitv=1'b0;
  
        
  
         
        case(pst)
        IDEAL: begin 
            if(~fifo_empty  )begin 
                nst=PROCESS_REQ;
                read_fifo_en=1'b1;            
            end        
        end 
        PROCESS_REQ: begin 
            if(buff_ready) begin         
                rxreqflitv=1'b1;   
                if(~fifo_empty )begin read_fifo_en=1'b1;  end else begin nst=IDEAL;
                end
            end
        end//   PROCESS_REQ  
        endcase        
    end
    
    
     always @(posedge clk) begin
        if(reset) begin          
          
            pst<=IDEAL;
        end  else begin 
            
            pst<=nst;            
        end
    end
    
    
      function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 
        
    localparam  EBw = log2(EXTND_B+1);
    
    reg [EBw-1 : 0] credit_counter;
        
        
    
    always@(posedge clk or posedge reset)begin
        if(reset)begin
            credit_counter <={EBw{1'b0}};           
        end else begin
            if(  noc_chi_rxreqflitv   & ~ read_fifo_en)   credit_counter <= credit_counter+1'b1;
            if( ~noc_chi_rxreqflitv   &   read_fifo_en)   credit_counter <= credit_counter-1'b1;           
        end //reset
     end//always


    always @(posedge clk or posedge reset) begin
        if (reset) chi_noc_rxreqlcrdv<=1'b0;
        else begin 
            if(credit_counter < (EXTND_B-B))begin 
                chi_noc_rxreqlcrdv<=noc_chi_rxreqflitv;              
            
            end else if (credit_counter == (EXTND_B-B) ) begin 
                 chi_noc_rxreqlcrdv<=noc_chi_rxreqflitv &read_fifo_en ;  
            
            end else begin    
                 chi_noc_rxreqlcrdv<=read_fifo_en; 
                                        
            end
        end
    end
    
    
    
    
    
    
    
    

endmodule

























