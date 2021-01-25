/**************************************
* Module: hnf_rx_req
* Date:2019-05-27  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  snf_rx_req#(
    parameter MAX_HNFs_ASSIGND_TO_A_SN=2,
    parameter VERBOSITY=3,
    parameter B=4
   //parameter src_id=1
    
)(

    src_id,
    // CHI RXREQ
    noc_chi_rxreqflitpend,
    noc_chi_rxreqflitv,
    noc_chi_rxreqflit,          
    chi_noc_rxreqlcrdv, 
    
    // txdat
    rxreq_to_txdat_wr,
    rxreq_to_txdat_dat,
    rxreq_to_txdat_tgtid,        
    rxreq_to_txdat_txnid,        
    rxreq_to_txdat_dbid,
    rxreq_to_txdat_homenid,
    rxreq_to_txdat_resp,
    rxreq_to_txopcode_dat,
    txdat_to_rxreq_ready,
    
    
    // txrsp
    txrsp_to_rxreq_ready,
    rxreq_to_txrsp_wr_en,
    rxreq_to_txrsp_txnid,
    rxreq_to_txrsp_tgtid,
    rxreq_to_txrsp_opcode,
    rxreq_to_txrsp_resp,
    rxreq_txsnp_dbid,
    
    //txnlkpt   
    txreq_to_txnlkpt_txnid, 
    txreq_to_txnlkpt_txndat, 
    txreq_to_txnlkpt_valid,  
    
    
    //main memory rd
    mem_to_rxreq_rd_data,
    rxreq_to_mem_rd_addr,   
    rxreq_to_mem_rd_en,
    mem_to_rxreq_rd_ready,
    mem_to_rxreq_rd_done, 
    mem_to_rxreq_wr_credit_incr,

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

     //CHI RXREQ
    input   noc_chi_rxreqflitpend ;
    input   noc_chi_rxreqflitv;
    input  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit;          
    output  chi_noc_rxreqlcrdv;  
    
    // rxreq
    output reg rxreq_to_txdat_wr;
    output reg [DATA_DAT-1 : 0] rxreq_to_txdat_dat;
    output reg [TGTID_DAT-1:0]  rxreq_to_txdat_tgtid;        
    output reg [TXNID_DAT-1:0]  rxreq_to_txdat_txnid;        
    output reg [TXNID_DAT-1:0]  rxreq_to_txdat_dbid;
    output reg [SRCID_DAT-1:0]  rxreq_to_txdat_homenid;
    output reg [RESP_DAT-1:0]   rxreq_to_txdat_resp;
    output reg [OPCODE_DAT-1:0] rxreq_to_txopcode_dat;
    input txdat_to_rxreq_ready;
    
    
    //main memory 
    input [DATA_DAT-1 : 0] mem_to_rxreq_rd_data;
    output [ADDR_REQ-1 : 0] rxreq_to_mem_rd_addr;
    output rxreq_to_mem_rd_en;
    input mem_to_rxreq_rd_ready;
    input mem_to_rxreq_rd_done;   
    input mem_to_rxreq_wr_credit_incr;
   

    
    //txrsp
    input  txrsp_to_rxreq_ready;
    output reg  rxreq_to_txrsp_wr_en;
    output reg  [TXNID_RSP-1:0] rxreq_to_txrsp_txnid;
    output reg  [TGTID_RSP-1:0] rxreq_to_txrsp_tgtid;
    output reg  [OPCODE_RSP-1:0] rxreq_to_txrsp_opcode;
    output reg  [RESP_RSP-1:0] rxreq_to_txrsp_resp;
    output reg  [TXNID_RSP-1:0] rxreq_txsnp_dbid;
    
    //txnlkpt
    output [TXN_IDw-1 : 0] txreq_to_txnlkpt_txnid;
    output [SNF_TXN_DATAw-1 : 0] txreq_to_txnlkpt_txndat;
    output reg txreq_to_txnlkpt_valid;
    
    
    
    //general
    input [SRCID_REQ*MAX_HNFs_ASSIGND_TO_A_SN-1 : 0] assign_hnfs;
    input reset,clk;


     // txreqflit
    wire [QOS_REQ-1:0]         qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_REQ-1:0]       tgtid;
    wire [SRCID_REQ-1:0]       srcid;
    wire [TXNID_REQ-1:0]       txnid;
    wire [RETURNNID_REQ-1:0]       returnnid; // = {RETURNNID_REQ{1'b0}};
    wire               endian; // = 1'b1;
    wire [RETURNTXNID_REQ-1:0]     returntxnid;
    wire [OPCODE_REQ-1:0]      opcode;
    wire [SIZE_REQ-1:0]        flitsize; // = 3'b110 ;
    wire [ADDR_REQ-1:0]        addr;
    wire               ns; // = 1'b1;
    wire               likelyshared; // = 1'b0;
    wire               allowretry; // = 1'b1;
    wire [ORDER_REQ-1:0]       order; // = 2'b11;
    wire [PCRDTYPE_REQ-1:0]    pcrdtype; // = 4'b0000;
    wire [MEMATTR_REQ-1:0]     memattr;// = 4'b0111;
    wire               snpattr; // = 1'b1;
    wire [LPID_REQ-1:0]        lpid; // = 5'b00000;
    wire               excl_snoopme; // = 1'b1;
    wire               expcompack;
    wire                           tracetag; // = 1'b0;
        
    //fifo 
    wire flit_fifo_empty;
    reg read_fifo_en;
    wire [REQ_FLIT_SIZE-1:0] current_rxreqflit;
    
    wire [DATA_DAT-1 : 0] current_mem_dout;
    wire rd_data_fifo_empty;
    
    
    assign  txreq_to_txnlkpt_txndat = {opcode,addr};// save the addr and reqopcode so after reciving the data we can update the main mem    
  
    
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
               .srcid(srcid),
               .srcnum(srcnum)               
            );
            
              assign  txreq_to_txnlkpt_txnid = {srcnum, txnid}; 
            
        end else begin : if2
              assign  txreq_to_txnlkpt_txnid =  txnid;         
        end
    endgenerate
    
    
    send_main_mem_rd_en_command mem_rd(
        .reqflit(noc_chi_rxreqflit),
        .req_flit_wr(noc_chi_rxreqflitv),
        .reset(reset),
        .clk(clk),
        .mem_rd_en(rxreq_to_mem_rd_en),
        .rd_addr(rxreq_to_mem_rd_addr)    
    );
    
     
 
       
   /* 
    fifo #(
        .Dw(REQ_FLIT_SIZE),
        .B(B)
    )
    flit_fifo
    (
        .din(noc_chi_rxreqflit),
        .wr_en(noc_chi_rxreqflitv),
        .rd_en(read_fifo_en ),
        .dout(current_rxreqflit),
        .full(),
        .nearly_full(),
        .empty(flit_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
    
    
    
    
    */
    
    fifo_depth_extended #(
    	.Dw(REQ_FLIT_SIZE),
        .B(B),
    	.EXTND_B(100)
    )
    flit_fifo
    (
    	.din(noc_chi_rxreqflit),
        .wr_en(noc_chi_rxreqflitv),
        .rd_en(read_fifo_en ),
        .dout(current_rxreqflit),
        .full(),
        .nearly_full(),
        .empty(flit_fifo_empty),
        .reset(reset),
        .clk(clk),
        .credit_out(chi_noc_rxreqlcrdv)
    );
    
    
    
    
    
   
   reg rd_dat_fifo_en;
    fifo #(
        .Dw(DATA_DAT),
        .B(100)
    )
    rd_data_fifo
    (
        .din(mem_to_rxreq_rd_data),
        .wr_en(mem_to_rxreq_rd_done),
        .rd_en(rd_dat_fifo_en),
        .dout(current_mem_dout),
        .full( ),
        .nearly_full( ),
        .empty(rd_data_fifo_empty),
        .reset(reset),
        .clk(clk)
    );
    
   
    
    assign {qos, tgtid,srcid,txnid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared,allowretry
     ,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag} = current_rxreqflit; 
    
    
    localparam 
        IDEAL=1,
        PROCESS_REQ=2,
        SEND_COMP_DATA_I=4,
        SEND_COMP_DATA_UC=8;
    reg [3:0] pst;
    reg [3:0] nst;
    reg rx_req_busy;
    
    
    
    reg [1: 0 ] txrsp_action;
    localparam [1:0 ]
        TXRSP_IDEAL=0,
        TXRSP_CompDBIDResp=1;
    
    reg [1: 0 ] txdat_action;
    localparam [1:0 ]
        TXDAT_IDEAL=0,
        TXDAT_CompData_UC=1,
        TXDAT_CompData_I=2;
    
     reg unsupported_upcode;
     reg snf_wr_buff_credit_dec;
     wire snf_wr_buff_not_full;
     
     reg [6:0] counter;
     always @(posedge clk or posedge reset) begin
             if(reset)begin 
                counter<=100;
             end else begin 
                if(mem_to_rxreq_wr_credit_incr && ~snf_wr_buff_credit_dec)  counter<=counter+1'b1;
                else if(~mem_to_rxreq_wr_credit_incr && snf_wr_buff_credit_dec)  counter<=counter-1'b1;
             end        
     end//always
     
     assign snf_wr_buff_not_full = (counter > 0);
    
     always @(*)begin 
        unsupported_upcode=1'b0;      
        rx_req_busy=1'b0;
        read_fifo_en=1'b0;
        rd_dat_fifo_en=1'b0;
        nst=pst;        
        txrsp_action = TXRSP_IDEAL;
        txdat_action = TXDAT_IDEAL;
        snf_wr_buff_credit_dec=1'b0;
               
    
        case(pst)
        IDEAL: begin 
            if(~flit_fifo_empty  )begin 
                nst=PROCESS_REQ;
                read_fifo_en=1'b1;            
            end        
        end //IDEAL
        PROCESS_REQ: begin 
            rx_req_busy=1'b1;
            case(opcode)
            REQ_OPCODE_ReadNoSnp:begin
                if(~rd_data_fifo_empty) begin 
                    rd_dat_fifo_en=1'b1; 
                    // In  IDMT both returnnid and srcid are the same. we have to return COMP_DATA_I to home node
                    if( returnnid == srcid) nst = SEND_COMP_DATA_I;
                    //else its DMT. we need to send comdata UC to RN
                    else nst = SEND_COMP_DATA_UC;
                                                     
                end 
            end // REQ_OPCODE_ReadNoSnp
            
            REQ_OPCODE_WriteNoSnpFull:begin 
                if(txrsp_to_rxreq_ready & snf_wr_buff_not_full) begin 
                    snf_wr_buff_credit_dec=1'b1;
                    txrsp_action=  TXRSP_CompDBIDResp;
                    //this req is procceeded check for the next req
                    if(~flit_fifo_empty )begin     read_fifo_en=1'b1; end  else nst=IDEAL;                                    
                end
            end// REQ_OPCODE_WriteNoSnpFull  
            
            
            default :  unsupported_upcode=1'b1;
            endcase // opcode
        end//PROCESS_REQ
        
        SEND_COMP_DATA_I: begin
            if(txdat_to_rxreq_ready ) begin 
                txdat_action = TXDAT_CompData_I;
                //this req is procceeded check for the next req
                if(~flit_fifo_empty )begin    read_fifo_en=1'b1; nst =  PROCESS_REQ; end  else nst=IDEAL;   
            end
        end
	SEND_COMP_DATA_UC: begin 
	    if(txdat_to_rxreq_ready ) begin 
                txdat_action = TXDAT_CompData_UC;
                //this req is procceeded check for the next req
                if(~flit_fifo_empty )begin    read_fifo_en=1'b1; nst =  PROCESS_REQ; end  else nst=IDEAL;   
            end

	end


        endcase // pst
    end // always
    
    
        
    // txdat    
    always @(*) begin
        rxreq_to_txdat_wr = 1'b0;             
        // default for read_snoop
        rxreq_to_txdat_dat = current_mem_dout;
        rxreq_to_txdat_tgtid = returnnid;        
        rxreq_to_txdat_txnid = returntxnid;        
        rxreq_to_txdat_dbid = txnid;
        rxreq_to_txdat_homenid = srcid;
        rxreq_to_txdat_resp =   CompData_UC;
        rxreq_to_txopcode_dat = OPCODE_DAT_CompData;
        case(txdat_action) 
        TXDAT_CompData_UC:begin
             rxreq_to_txdat_wr = 1'b1;
        end
        TXDAT_CompData_I:begin 
            rxreq_to_txdat_resp =   CompData_I;
            rxreq_to_txdat_wr = 1'b1;
        end
        default : begin 
            rxreq_to_txdat_wr = 1'b0;             
            // default for read_snoop
            rxreq_to_txdat_dat = current_mem_dout;
            rxreq_to_txdat_tgtid = returnnid;        
            rxreq_to_txdat_txnid = returntxnid;        
            rxreq_to_txdat_dbid = txnid;
            rxreq_to_txdat_homenid = srcid;
            rxreq_to_txdat_resp =   CompData_UC;
            rxreq_to_txopcode_dat = OPCODE_DAT_CompData;        
        end
        endcase
    end
    
   //txrsp;
   always @(*) begin
    rxreq_to_txrsp_wr_en=1'b0;
    //defalt for TXRSP_CompDBIDResp
    rxreq_to_txrsp_txnid =txnid;
    rxreq_to_txrsp_tgtid = srcid;
    rxreq_to_txrsp_opcode = RSP_OPCODE_CompDBIDResp; 
    rxreq_to_txrsp_resp=0 ;
    rxreq_txsnp_dbid= 0;
   
    case(txrsp_action)
    TXRSP_CompDBIDResp:begin
         rxreq_to_txrsp_wr_en=1'b1;
    
    end
    default : begin 
        rxreq_to_txrsp_wr_en=1'b0;
        //defalt for TXRSP_CompDBIDResp
        rxreq_to_txrsp_txnid =txnid;
        rxreq_to_txrsp_tgtid = srcid;
        rxreq_to_txrsp_opcode = RSP_OPCODE_CompDBIDResp; 
        rxreq_to_txrsp_resp=0 ;
        rxreq_txsnp_dbid= 0;
    end
    endcase
   end
           
           
      
    
        always @(posedge clk) begin
            if(reset) begin          
               // chi_noc_rxreqlcrdv<=0;
                pst <= IDEAL;
                txreq_to_txnlkpt_valid<=1'b0;
            end  else begin 
               // chi_noc_rxreqlcrdv<=read_fifo_en;
                pst<=nst;
                txreq_to_txnlkpt_valid<= read_fifo_en;
            end
        end



   //synthesis translate_off 
    //synopsys  translate_off
    always @(posedge clk)begin 
        if((VERBOSITY & MONITORE_REQ_TYPE) > 0)begin
            if(pst == PROCESS_REQ && opcode == REQ_OPCODE_ReadNoSnp && rd_dat_fifo_en) $display("%t: snf ( %d ) txn ( %d ) got ReadnoSnoop req on addr ( %d )",$time,src_id, txnid,addr );
            if(pst == PROCESS_REQ && opcode == REQ_OPCODE_WriteNoSnpFull && rd_dat_fifo_en) $display("%t: snf ( %d ) txn ( %d ) got WriteNoSnpFull req on addr ( %d )",$time,src_id, txnid,addr );
        end
        if((VERBOSITY & MONITORE_TXN_CMD) > 0 )begin
            if(txdat_action ==  TXDAT_CompData_I)  $display("%t: snf ( %d ) txn ( %d ) sends CompData_I ( %h )",$time,src_id,txnid,rxreq_to_txdat_dat);
            if(txdat_action ==  TXDAT_CompData_UC)  $display("%t: snf ( %d ) txn ( %d ) sends CompData_UC ( %h )",$time,src_id,txnid,rxreq_to_txdat_dat);
            if(txrsp_action ==  TXRSP_CompDBIDResp) $display("%t: snf ( %d ) txn ( %d ) sends CompDBIDResp ",$time,src_id,txnid);
        end
        if(unsupported_upcode) begin 
            $display("%t: Error: snf ( %d ) txn ( %d ) has received an unsupported request opcode: %h",$time,src_id, txnid, opcode);
            $stop;    
        end
    end
     //synthesis translate_on 
    //synopsys  translate_on






endmodule

/*************************
 * 
 * 
 * ************************/



module  send_main_mem_rd_en_command (
    reqflit,
    req_flit_wr,
    reset,
    clk,
    mem_rd_en,
    rd_addr    
);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
  
    
     input  [REQ_FLIT_SIZE-1:0]    reqflit;
     input req_flit_wr;
     
     input reset, clk;
     output reg mem_rd_en;
     
     output reg [ADDR_REQ-1 : 0] rd_addr;    
     
     
      // txreqflit
    wire [QOS_REQ-1:0]         qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_REQ-1:0]       tgtid;
    wire [SRCID_REQ-1:0]       srcid;
    wire [TXNID_REQ-1:0]       txnid;
    wire [RETURNNID_REQ-1:0]       returnnid; // = {RETURNNID_REQ{1'b0}};
    wire               endian; // = 1'b1;
    wire [RETURNTXNID_REQ-1:0]     returntxnid;
    wire [OPCODE_REQ-1:0]      opcode;
    wire [SIZE_REQ-1:0]        flitsize; // = 3'b110 ;
    wire [ADDR_REQ-1:0]        addr;
    wire               ns; // = 1'b1;
    wire               likelyshared; // = 1'b0;
    wire               allowretry; // = 1'b1;
    wire [ORDER_REQ-1:0]       order; // = 2'b11;
    wire [PCRDTYPE_REQ-1:0]    pcrdtype; // = 4'b0000;
    wire [MEMATTR_REQ-1:0]     memattr;// = 4'b0111;
    wire               snpattr; // = 1'b1;
    wire [LPID_REQ-1:0]        lpid; // = 5'b00000;
    wire               excl_snoopme; // = 1'b1;
    wire               expcompack;
    wire                           tracetag; // = 1'b0;
     
     assign {qos, tgtid,srcid,txnid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared,allowretry
     ,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag} =  reqflit; 
    
    reg read_opcode;
    always @(*) begin
        read_opcode = 1'b0;
         case(opcode)
            REQ_OPCODE_ReadNoSnp:begin
                read_opcode = 1'b1;
            end // REQ_OPCODE_ReadNoSnp
            default: begin 
                 read_opcode = 1'b0;
            end
         endcase
    end
    
    
     
     always @(posedge clk  ) begin
        if(req_flit_wr) rd_addr<= addr;         
     end      
     
     always @(posedge clk or posedge reset ) begin
        if(reset) mem_rd_en <= 1'b0;
        mem_rd_en <= read_opcode & req_flit_wr;        
     end       
      

endmodule


/********************
 *  get_srcid_num 
 * ****************/
 
 module get_srcid_num #(
    parameter SRCID_REQ=7,
    parameter MAX_HNFs_ASSIGND_TO_A_SN=2
 )
 (
    
    srcid,  // srcid read from flit buffer
    srcnum,
    assign_hnfs
  
  );

    
     function integer log2;
          input integer number; begin   
             log2=(number <=1) ? 1: 0;    
             while(2**log2<number) begin    
                log2=log2+1;    
             end       
          end   
    endfunction // log2 
    localparam  Nw= log2(MAX_HNFs_ASSIGND_TO_A_SN);

   
    input [SRCID_REQ-1 : 0] srcid;
    output [Nw-1 : 0] srcnum;
    input [SRCID_REQ*MAX_HNFs_ASSIGND_TO_A_SN-1 : 0] assign_hnfs;
    
    
    wire [SRCID_REQ-1 : 0]  assign_hnf [MAX_HNFs_ASSIGND_TO_A_SN-1 : 0];
    wire [MAX_HNFs_ASSIGND_TO_A_SN-1 : 0] match;
     
    
  
    genvar i;
    generate
        for (i = 0; i < MAX_HNFs_ASSIGND_TO_A_SN; i = i + 1) begin : block
            assign assign_hnf [i] = assign_hnfs [(i+1)*SRCID_REQ-1 : i*SRCID_REQ];
            assign match[i] =  (assign_hnf [i] == srcid);
        end
       
        
    endgenerate
    
   
     one_hot_to_bin #(
            .ONE_HOT_WIDTH(MAX_HNFs_ASSIGND_TO_A_SN),
            .BIN_WIDTH(Nw)
        )
        conv(
            .one_hot_code(match),
            .bin_code(srcnum)
        );
    
endmodule
