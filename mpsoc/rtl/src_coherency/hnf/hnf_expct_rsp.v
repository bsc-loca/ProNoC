/**************************************
* Module: hnf_comp_notifier
* Date:2019-06-14  
* Author: alireza     
*
* Description: 
***************************************/
module  hnf_expct_rsp  #(
    parameter VERBOSITY=0,
   // parameter src_id=0,
    parameter EXPCT_RSP_Dw = 6    

)(
   
    src_id,   
    //txreq wr
    rxreq_to_expct_rsp_txnid_wr,
    rxreq_to_expct_rsp_dat_wr, 
    rxreq_to_expct_rsp_valid_wr, 
    expct_rsp_to_rxreq_ready_wr, 
    
    //rxrsp wr
    rxrsp_to_expct_rsp_txnid_wr, 
    rxrsp_to_expct_rsp_dat_wr, 
    rxrsp_to_expct_rsp_valid_wr, 
    expct_rsp_to_rxrsp_ready_wr, 
    
    
    //rxrsp rd
    rxrsp_to_expct_rsp_txnid_rd, 
    expct_rsp_to_rxrsp_dat_rd, 
    rxrsp_to_expct_rsp_valid_rd, 
    expct_rsp_to_rxrsp_ready_rd,    
    
    
    //general 
    reset,
    clk


);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"             

    input [31 : 0] src_id;   
     
    input reset,clk;
     
    
    //txreq wr
    input [TXNID_REQ-1 : 0] rxreq_to_expct_rsp_txnid_wr;
    input [EXPCT_RSP_Dw-1 : 0] rxreq_to_expct_rsp_dat_wr;
    input rxreq_to_expct_rsp_valid_wr;
    output expct_rsp_to_rxreq_ready_wr;
    
    //rxrsp wr
    input [TXNID_REQ-1 : 0] rxrsp_to_expct_rsp_txnid_wr;
    input [EXPCT_RSP_Dw-1 : 0] rxrsp_to_expct_rsp_dat_wr;
    input rxrsp_to_expct_rsp_valid_wr;
    output expct_rsp_to_rxrsp_ready_wr;
    
    
    //rxrsp rd
    input [TXNID_REQ-1 : 0] rxrsp_to_expct_rsp_txnid_rd;
    output [EXPCT_RSP_Dw-1 : 0] expct_rsp_to_rxrsp_dat_rd;
    input rxrsp_to_expct_rsp_valid_rd;
    output expct_rsp_to_rxrsp_ready_rd;   
    
    assign expct_rsp_to_rxrsp_ready_rd=1'b1;    
    
    wire [TXNID_REQ-1 : 0] lkpt_txnid_wr;
    wire [EXPCT_RSP_Dw-1 : 0] lkpt_txndat_wr;
    wire lkpt_valid_wr;
        
    wire  [TXNID_REQ-1 : 0] lkpt_txnid_rd = rxrsp_to_expct_rsp_txnid_rd;
   // wire  [EXPCT_RSP_Dw-1 : 0] lkpt_txndat_rd ;
    wire lkpt_valid_rd = rxrsp_to_expct_rsp_valid_rd;
   // wire rxrsp_full,txreq_full; 
        
  
    assign expct_rsp_to_rxrsp_ready_rd = 1'b1;
   // assign expct_rsp_to_rxrsp_ready_wr = ~rxrsp_full;
   // assign expct_rsp_to_rxreq_ready_wr = ~txreq_full;
    
    
 //   localparam REGDw = TXNID_REQ + EXPCT_RSP_Dw;
    
 /*
    wire txreq_rd_en, rxrsp_rd_en;
    wire [REGDw-1 : 0] rxrsp_dout, txreq_dout;
    wire rxrsp_valid, txreq_valid;
   */ 
    
    localparam 
        PNUM=2,
        Dw = TXNID_REQ + EXPCT_RSP_Dw,
        ARRAYw= PNUM * Dw;
    
    wire [ARRAYw-1 : 0] qin_data_in = {rxreq_to_expct_rsp_txnid_wr,rxreq_to_expct_rsp_dat_wr,rxrsp_to_expct_rsp_txnid_wr,rxrsp_to_expct_rsp_dat_wr};
    wire [PNUM-1 : 0 ] qin_we = {rxreq_to_expct_rsp_valid_wr,rxrsp_to_expct_rsp_valid_wr};
    wire [PNUM-1 : 0 ] qin_is_ready;
    wire [Dw-1 : 0] rxrsp_dout, txreq_dout;
    wire rxrsp_valid, txreq_valid;
   // wire txreq_rd_en, rxrsp_rd_en;
    assign {expct_rsp_to_rxreq_ready_wr,expct_rsp_to_rxrsp_ready_wr}= qin_is_ready;
    
   // wire req_wone,rsp_wone;
    
    many_to_one_pipereg #(
       	.Dw(Dw),
    	.IN_NUM(PNUM),
    	.IGNORE_SAME_LOC_RD_WR_WARNING("YES")
    )
    wr_pipereg
    (
    	.src_id(src_id),
    	.qin_data_in(qin_data_in),
    	.qin_we(qin_we),
    	.qin_is_ready(qin_is_ready),
    	.qin_valid_o({txreq_valid,rxrsp_valid}),
    	.qin_data_o({txreq_dout,rxrsp_dout} ),
    	
    	.qout_data_o({lkpt_txnid_wr,lkpt_txndat_wr}),    	
    	.qout_we_o(lkpt_valid_wr),
    	.qout_is_ready(1'b1),
    	.qout_winner(  ),
    	.reset(reset),
    	.clk(clk)
    	
    );
    
    
    
  
    wire [TXNID_REQ-1 : 0] rxrsp_txnid_wr;
    wire [EXPCT_RSP_Dw-1 : 0] rxrsp_txndat_wr; 
    wire rd_during_wr = ((rxrsp_to_expct_rsp_txnid_wr == rxrsp_to_expct_rsp_txnid_rd) & rxrsp_to_expct_rsp_valid_wr );
    
    /*
    reg bypass;   
    
    always @(posedge clk ) begin
               if (rxrsp_to_expct_rsp_valid_rd) begin 
                        bypass<=rd_during_wr;                       
               end
     end
    */
   
   
   
   wire [EXPCT_RSP_Dw-1 : 0 ] lkpt_mem_rd;
   
    transaction_lookup_table #(
        .TXN_DATAw(EXPCT_RSP_Dw),
        .TXN_IDw(TXNID_REQ),
        .RD_DURING_WR("OLD_DAT")
    )
    lkpt
    (
        .txn_wr_addr(lkpt_txnid_wr),
        .txn_wr_dat(lkpt_txndat_wr),
        .txn_wr_en(lkpt_valid_wr),
        
        .txn_rd_addr(lkpt_txnid_rd),
        .txn_rd_dat(lkpt_mem_rd),
        .txn_rd_en(lkpt_valid_rd),
        .clk(clk)
    ); 
    
    // if rd_during_wr is asserted the dat_rd must be current cycle rxrsp_txndat_wr in next clock cycle
    // wr Data req does not need to be checked in pipeline 
    // The rxrsp_to_expct_rsp_dat_wr is the latest data which is goinig to be wr so has highest priority
    // rxrsp_dout is the data saved in pipereg has the lowest priotrity to be bypassed
   
    assign {rxrsp_txnid_wr,rxrsp_txndat_wr} =  rxrsp_dout;
   
    atomic_mem_rd #(
    	.PIPE_NUM(2),
    	.Dw(EXPCT_RSP_Dw),
    	.Aw(TXNID_REQ)
    )
    atomic
    (
    	.rd_addr(lkpt_txnid_rd),
    	.rd_en(lkpt_valid_rd),
    	.mem_rd_dat(lkpt_mem_rd),
    	    	
    	.wr_addr_pipe({rxrsp_to_expct_rsp_txnid_wr,rxrsp_txnid_wr}),
    	.wr_en_pipe({rxrsp_to_expct_rsp_valid_wr,rxrsp_valid}),
    	.wr_dat_pipe({rxrsp_to_expct_rsp_dat_wr,rxrsp_txndat_wr}),// 
    	.clk(clk),
    	.reset(reset),
    	
    	.rd_dat(expct_rsp_to_rxrsp_dat_rd)
    );
   
   
    
   
   //assign expct_rsp_to_rxrsp_dat_rd = (bypass)? rxrsp_txndat_wr :lkpt_txndat_rd; 
  // assign expct_rsp_to_rxrsp_dat_rd = lkpt_txndat_rd;
         

 //synthesis translate_off 
    //synopsys  translate_off
      
    
    always @(posedge clk) begin
        if((VERBOSITY &  MONITORE_WAIT_LIST) > 0)begin 
            if(rxreq_to_expct_rsp_valid_wr) $display("%t: hnf ( %d ) txn ( %d ) rspsnp will wait for ( %b ) Nodes to response to the request",$time,src_id,rxreq_to_expct_rsp_txnid_wr,rxreq_to_expct_rsp_dat_wr[EXPCT_RSP_Dw-2 : 0]);
            if(lkpt_valid_wr)begin 
                if(lkpt_txndat_wr[EXPCT_RSP_Dw-1] )   $display("%t: hnf ( %d ) txn ( %d ) rspsnp  wait list changed ( %b ). Data is gotton",$time,src_id, lkpt_txnid_wr, lkpt_txndat_wr[EXPCT_RSP_Dw-2 : 0]);
                else $display("%t: hnf ( %d ) txn ( %d ) rspsnp wait list changed ( %b ). No data is gotton",$time,src_id, lkpt_txnid_wr, lkpt_txndat_wr[EXPCT_RSP_Dw-2 : 0]);
                
            end
           // if(rxrsp_to_expct_rsp_valid_rd & rd_during_wr) $display("bypassed");
        end
    end
    
 //synthesis translate_on
    //synopsys  translate_on

endmodule

