/**************************************
* Module: hnf_rx_dat
* Date:2019-06-03  
* Author: alireza     
*
* Description: 
***************************************/

`timescale   1ns/1ns

module  hnf_rx_data #(
   //  parameter src_id=0,
     parameter B=4
     )(
     src_id,
     reset,
     clk,  
     
     //chi channel
     noc_chi_rxdatflitpend,
     noc_chi_rxdatflitv,
     noc_chi_rxdatflit,
     chi_noc_rxdatlcrdv,    
        
     
     //rx_rsp
     rxdat_rxrsp_txnid, 
     rxdat_rxrsp_opcode,
     rxdat_rxrsp_resp,
     rxdat_rxrsp_srcid,
     rxdat_rxrsp_valid,  
     rxrsp_rxdat_ready,     
    
     
     //datlkpt
     rxdat_to_datlkpt_txnid,
     rxdat_to_datlkpt_txndat,
     rxdat_to_datlkpt_valid     
    );
    
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
   
    
    input [31 : 0] src_id;    
    
        
    input reset,clk;
    
    //CHI channel
    input    noc_chi_rxdatflitpend;
    input    noc_chi_rxdatflitv ;
    input   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit ;
    output   reg chi_noc_rxdatlcrdv ; 
    
     //rx_rsp  
    output reg [TXNID_REQ-1:0] rxdat_rxrsp_txnid; 
    output [OPCODE_DAT-1:0] rxdat_rxrsp_opcode; 
    output [SRCID_DAT-1:0]  rxdat_rxrsp_srcid;
    output [RESP_DAT-1:0] rxdat_rxrsp_resp ;
    output reg rxdat_rxrsp_valid; 
    input rxrsp_rxdat_ready;      
          
     //datlkpt
    output [TXNID_REQ-1 : 0] rxdat_to_datlkpt_txnid;
    output [DATA_DAT-1  : 0] rxdat_to_datlkpt_txndat;
    output rxdat_to_datlkpt_valid;
          
    wire [DAT_FLIT_SIZE-1 : 0] current_rxdatflit;        
          
     //data fileds
    wire [QOS_DAT-1:0]             qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_DAT-1:0]           tgtid  ;
    wire [SRCID_DAT-1:0]           srcid  ;
    wire [TXNID_DAT-1:0]           txnid  ;
    wire [HOMENID_DAT-1:0]         homenid; // 
    wire [OPCODE_DAT-1:0]          opcode ;
    wire [RESPERR_DAT-1:0]         resperr;     
    wire [RESP_DAT-1:0]            resp;
    wire [FWD_DATAPULL_DAT-1:0]    fwd_datapull;
    wire [DBID_DAT-1:0]            dbid;
    wire [CCID_DAT-1:0]            ccid;
    wire [DATAID_DAT-1:0]          dataid;
    wire                           tracetag; // = 1'b0;
    wire [BE_DAT-1:0]              be;
    wire [DATA_DAT-1:0]            data;
    wire [DATACHECK_DAT-1:0]       datacheck;
    wire [POISON_DAT-1:0]          poison;
    
    reg read_fifo_en;
    
    
    
    wire fifo_empty; 
    wire fifo_not_empty = ~ fifo_empty;
   
   fifo #(
    .Dw(DAT_FLIT_SIZE),
    .B(B)
   )
   the_fifo
   (
    .din(noc_chi_rxdatflit),
        .wr_en(noc_chi_rxdatflitv),
        .rd_en(read_fifo_en ),
        .dout(current_rxdatflit),
        .full( ),
        .nearly_full( ),
        .empty(fifo_empty ),
        .reset(reset),
        .clk(clk)
   ); 
    
    
   
 //Read txn_id one cycle before reading the actual flit  
  wire [TXNID_DAT-1:0]  txnid_in = noc_chi_rxdatflit[DAT_FLIT_SIZE-1-(QOS_DAT+TGTID_DAT+SRCID_DAT) :    DAT_FLIT_SIZE-(QOS_DAT+TGTID_DAT+SRCID_DAT)-TXNID_DAT];
  wire [DATA_DAT-1 :0]  data_in = noc_chi_rxdatflit[DATA_DAT+ DATACHECK_DAT + POISON_DAT-1 :  DATACHECK_DAT + POISON_DAT ];
  
  // save the recived data in lkpt 
  assign rxdat_to_datlkpt_valid = noc_chi_rxdatflitv ;    
  assign rxdat_to_datlkpt_txnid =txnid_in;
  assign rxdat_to_datlkpt_txndat = data_in;
  assign rxdat_rxrsp_opcode = opcode;
  assign rxdat_rxrsp_resp = resp;
  assign rxdat_rxrsp_srcid = srcid;
    
  assign {qos,tgtid,srcid ,txnid ,homenid ,opcode ,resperr, resp ,fwd_datapull ,dbid ,ccid ,dataid ,tracetag ,be ,data ,datacheck  ,poison} = current_rxdatflit; 
    
    
    localparam IDEAL=1;
    localparam PROCESS_REQ=2;
    reg [1:0] pst;
    reg [1:0] nst;
    
    
   
         
   
                                        
    
   reg rx_dat_busy;
    
    
   //will change to state machin 
    always @(*)begin 
        read_fifo_en=1'b0;
        nst=pst;
        rx_dat_busy=1'b0;
       
        
        rxdat_rxrsp_txnid= txnid;
        rxdat_rxrsp_valid=1'b0; 
         
        case(pst)
        IDEAL: begin 
            if(fifo_not_empty )begin 
                nst=PROCESS_REQ;
                read_fifo_en=1'b1;            
            end        
        end 
        PROCESS_REQ: begin 
            rx_dat_busy=1'b1;
            if(rxrsp_rxdat_ready) begin
                rxdat_rxrsp_valid=1'b1;   
                if(fifo_not_empty)begin read_fifo_en=1'b1;  end else begin  nst=IDEAL;  end
            end
        end//   PROCESS_REQ  
        endcase        
    end
    
    
    
    always @(posedge clk) begin
        if(reset) begin          
            chi_noc_rxdatlcrdv<=0;
            pst<=IDEAL;
        end  else begin 
            chi_noc_rxdatlcrdv<=read_fifo_en;
            pst<=nst;            
        end
    end
      
    
    
  //assign rxdat_to_cache_wr_state = lkpt_to_rxdat_cache_state; 
   
      
    
    

endmodule






