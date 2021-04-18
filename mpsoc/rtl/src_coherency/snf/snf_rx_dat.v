/**************************************
* Module: snf_rx_dat
* Date:2019-06-25  
* Author: alireza     
*
* Description: 
***************************************/
module  snf_rx_dat #(
    parameter MAX_HNFs_ASSIGND_TO_A_SN=2,
    parameter B=4
   // parameter src_id=0
)(
    
    src_id,
    
    //chi
    noc_chi_rxdatflitpend, 
    noc_chi_rxdatflitv, 
    noc_chi_rxdatflit, 
    chi_noc_rxdatlcrdv,      
    
    //mem_wr
    rxdat_to_mem_wr_data,
    rxdat_to_mem_wr_addr,    
    rxdat_to_mem_wr_en,
    mem_to_rxdat_wr_ready,
    mem_to_rxdat_wr_done,
    
    
    
    //lkpt
    rxdat_to_txnlkpt_txnid,
    rxdat_to_txnlkpt_rd_valid,
    txnlkpt_to_rxdat_txndat, 
    
    //general
    assign_hnfs,
    reset, 
    clk 


);


   `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
   
    
     function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
        endfunction // log2 
    
    localparam TXN_IDw = (MAX_HNFs_ASSIGND_TO_A_SN>1)? TXNID_REQ + log2(MAX_HNFs_ASSIGND_TO_A_SN): TXNID_REQ;
    
    input [31 : 0] src_id;    
    
    // Clock and Reset
    input [SRCID_REQ*MAX_HNFs_ASSIGND_TO_A_SN-1 : 0] assign_hnfs;
    input clk,reset;

    //chi
    input    noc_chi_rxdatflitpend ;
    input    noc_chi_rxdatflitv ;
    input   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit ;
    output  reg chi_noc_rxdatlcrdv ; 

    //mem wr
    output [DATA_DAT-1 : 0] rxdat_to_mem_wr_data;
    output [ADDR_REQ-1 : 0] rxdat_to_mem_wr_addr;    
    output reg rxdat_to_mem_wr_en;
    input mem_to_rxdat_wr_ready;
    input mem_to_rxdat_wr_done;
    
    //txnlkpt
    output [TXN_IDw-1 : 0] rxdat_to_txnlkpt_txnid;
    output rxdat_to_txnlkpt_rd_valid;
    input [SNF_TXN_DATAw-1 : 0]txnlkpt_to_rxdat_txndat; 
    
   
    
    
    wire [QOS_DAT-1:0]             qos; // not supported
    wire [TGTID_DAT-1:0]           tgtid;
    wire [SRCID_DAT-1:0]           srcid;
    wire [TXNID_DAT-1:0]           txnid;
    wire [HOMENID_DAT-1:0]         homenid; 
    wire [OPCODE_DAT-1:0]          opcode;
    wire [RESPERR_DAT-1:0]         resperr;   // not supported  
    wire [RESP_DAT-1:0]            resp;
    wire [FWD_DATAPULL_DAT-1:0]    fwd_datapull; // not supported
    wire [DBID_DAT-1:0]            dbid;
    wire [CCID_DAT-1:0]            ccid; // not supported
    wire [DATAID_DAT-1:0]          dataid; // not supported
    wire                           tracetag; // not supported
    wire [BE_DAT-1:0]              be; // not supported
    wire [DATA_DAT-1:0]            data;
    wire [DATACHECK_DAT-1:0]       datacheck;// not supported
    wire [POISON_DAT-1:0]          poison; // not supported
    
    wire [DAT_FLIT_SIZE-1:0]  current_rxdatflit;
    reg read_fifo_en;
    wire flit_fifo_empty;
    
    assign {qos,tgtid,srcid ,txnid ,homenid ,opcode ,resperr, resp ,fwd_datapull ,dbid ,ccid ,dataid ,tracetag ,be ,data ,datacheck  ,poison}=current_rxdatflit;
    assign rxdat_to_txnlkpt_rd_valid =read_fifo_en;

    fifo #(
        .Dw(DAT_FLIT_SIZE),
        .B(B)
    )
    flit_fifo
    (
        .din(noc_chi_rxdatflit),
        .wr_en(noc_chi_rxdatflitv),
        .rd_en(read_fifo_en ),
        .dout(current_rxdatflit),
        .full(),
        .nearly_full(),
        .empty(flit_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
   
   //Read txn_id one cycle before reading the actual flit  
  wire [TXNID_DAT-1:0]  rxdat_txnid_in = noc_chi_rxdatflit[DAT_FLIT_SIZE-1-(QOS_DAT+TGTID_DAT+SRCID_DAT) :    DAT_FLIT_SIZE-(QOS_DAT+TGTID_DAT+SRCID_DAT)-TXNID_DAT];
  wire [HOMENID_DAT-1:0] homenid_next = noc_chi_rxdatflit[DAT_FLIT_SIZE-(QOS_DAT+TGTID_DAT+SRCID_DAT+TXNID_DAT)-1 : DAT_FLIT_SIZE-(QOS_DAT+TGTID_DAT+SRCID_DAT+TXNID_DAT+HOMENID_DAT)];
  wire [TXN_IDw-1 : 0 ]rxdat_txnid_addr;
  wire [ADDR_REQ-1:0] req_addr;
  wire [OPCODE_REQ-1:0] req_opcode; 
  
   generate
        if(MAX_HNFs_ASSIGND_TO_A_SN>1) begin :if1
            
            localparam  Nw= log2(MAX_HNFs_ASSIGND_TO_A_SN);
            wire [Nw-1 : 0] srcnum;
            
            get_srcid_num #(
               .SRCID_REQ(SRCID_REQ),
               .MAX_HNFs_ASSIGND_TO_A_SN(MAX_HNFs_ASSIGND_TO_A_SN)
            )
            conv
            (
               .assign_hnfs(assign_hnfs),
               .srcid(homenid_next),
               .srcnum(srcnum)               
            );
            
              assign  rxdat_txnid_addr = {srcnum, rxdat_txnid_in}; 
            
        end else begin : if2
              assign  rxdat_txnid_addr =  rxdat_txnid_in;         
        end
    endgenerate
  
  

  
  
  
  fwft_fifo #(
    .DATA_WIDTH(TXN_IDw),
    .MAX_DEPTH(B),
    .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
   )
   rxdat_txnid_fifo
   (
    .din(rxdat_txnid_addr),
    .wr_en(noc_chi_rxdatflitv),
    .rd_en(read_fifo_en),
    .dout(rxdat_to_txnlkpt_txnid),
    .full(),
    .nearly_full(),
    .recieve_more_than_0(),
    .recieve_more_than_1(),
    .reset(reset),
    .clk(clk)
   );  
    
    
   
    assign  {req_opcode,req_addr} = txnlkpt_to_rxdat_txndat;
    assign rxdat_to_mem_wr_addr = req_addr;
    assign rxdat_to_mem_wr_data =data;
   
    localparam IDEAL=1;
    localparam PROCESS_REQ=2;
    localparam READ_RD_DAT=4;
    reg [2:0] pst;
    reg [2:0] nst;
    
    reg unsupported_upcode;
    
    
    always @(*)begin 
        unsupported_upcode=1'b0;         
        read_fifo_en=1'b0;     
        nst=pst; 
        rxdat_to_mem_wr_en=1'b0;
    
        case(pst)
        IDEAL: begin 
            if(~flit_fifo_empty  )begin 
                nst=PROCESS_REQ;
                read_fifo_en=1'b1;            
            end        
        end //IDEAL
        PROCESS_REQ: begin 
            case(opcode)
            OPCODE_DAT_NonCopyBackWrData,OPCODE_DAT_CopyBackWrData:begin
                if( mem_to_rxdat_wr_ready) begin 
                    rxdat_to_mem_wr_en=1'b1;
                    if(~flit_fifo_empty)begin  read_fifo_en=1'b1;    end else  nst=IDEAL;
                
                end                        
               
            end // REQ_OPCODE_ReadNoSnp
            default unsupported_upcode=1'b1;
        endcase
       end
       endcase
    end
           
    
    
      always @(posedge clk) begin
            if(reset) begin          
                chi_noc_rxdatlcrdv<=1'b0;
                pst <= IDEAL;               
            end  else begin 
                chi_noc_rxdatlcrdv<=read_fifo_en;
                pst<=nst;                 
            end
        end 
    
    
    
    
    //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk)begin 
        if( unsupported_upcode>0)begin 
            $display("%t: snf ( %d ) txn ( %d ) Error: rxdat got an unsupported upcode ( %d )",$time,src_id, txnid,opcode );
            $stop;
        end
    end
     //synthesis translate_on 
    //synopsys  translate_on
    

endmodule

