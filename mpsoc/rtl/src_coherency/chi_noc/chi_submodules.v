`timescale   1ns/1ns


module txnid_gen #(
    //parameter src_id=0,
    parameter VERBOSITY=3,
    parameter TAGw=8
    //parameter INIT_ID=src_id*20
)(
    src_id,   
    reset,
    clk,
    txnid_in,
    add,
    txnid_out,
    read,
    empty
);


  `define INCLUDE_CHI_LOCALPARAM
  `include "../chi_localparam.v"
  
  input [31 : 0] src_id;  
    
  input reset, clk;
  input [TAGw-1 : 0] txnid_in;
  input add;
  output [TAGw-1 : 0]  txnid_out;
  input  read;
  output  empty;
  
  txnid_genfifo #(
  	.Dw(TAGw),
  	.B(2**TAGw)
  	//.INIT_ID(INIT_ID)
  )
  fifo
  (
  	.din(txnid_in),
  	.wr_en(add),
  	.rd_en(read),
  	.dout(txnid_out),
  	.full(),
  	.nearly_full(),
  	.empty(empty),
  	.reset(reset),
  	.clk(clk)
  );
  
  
   //synthesis translate_off 
   //synopsys  translate_off
    always @(posedge clk)begin 
        if( (VERBOSITY & MONITORE_TXNID_GEN) !=0)begin 
            if(add ) $display("%t: gen ( %d ) txn ( %d ) is released",$time,src_id,txnid_in);
            if(read) $display("%t: gen ( %d ) txn ( %d ) is generated",$time,src_id,txnid_out);
        end            
    end
    //synthesis translate_on 
    //synopsys  translate_on
  
  
  

endmodule




module txnid_genfifo  #(
    parameter Dw = 72,//data_width
    parameter B  = 10,// buffer num
    parameter INIT_ID=0
)(
    din,   
    wr_en, 
    rd_en, 
    dout,  
    full,
    nearly_full,
    empty,
    reset,
    clk
);

 
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

    localparam  B_1 = B-1,
                Bw = log2(B),
                DEPTHw=log2(B+1);
    localparam  [Bw-1   :   0] Bint =   B_1[Bw-1    :   0];

    input [Dw-1:0] din;     // Data in
    input          wr_en;   // Write enable
    input          rd_en;   // Read the next word

    output  [Dw-1:0]  dout;    // Data out
    output         full;
    output         nearly_full;
    output         empty;

    input          reset;
    input          clk;

reg [Dw-1:0]  ramout;    // Data out

reg [Dw-1       :   0] queue [B-1 : 0] /* synthesis ramstyle = "no_rw_check" */;
reg [Bw- 1      :   0] rd_ptr;
reg [Bw- 1      :   0] wr_ptr;
reg [DEPTHw-1   :   0] depth;

// Sample the data
always @(posedge clk)
begin
   if (wr_en)
      queue[wr_ptr] <= din;
   if (rd_en)
      ramout <=  queue[rd_ptr];
end

reg first_round;

localparam [Bw-1: 0] INIT = INIT_ID[Bw-1 : 0];
//localparam [Bw-1: 0] LAST = (INIT=={Bw{1'b0}})?  (B-1)  :  INIT-1;

reg start;

always @(posedge clk)
begin
   if (reset) begin
      rd_ptr <= INIT+1;
      wr_ptr <= INIT;
      depth  <= B-1;
      start<=1'b0;
      first_round<=1'b1;
   end
   else begin
      if(rd_en) start <= 1'b1;
      if ((rd_ptr == INIT) & rd_en & start) first_round<=1'b0;
      if (wr_en) wr_ptr <= (wr_ptr==Bint)? {Bw{1'b0}} : wr_ptr + 1'b1;
      if (rd_en) rd_ptr <= (rd_ptr==Bint)? {Bw{1'b0}} : rd_ptr + 1'b1;
      if (wr_en & ~rd_en) depth <= depth + 1'b1;
      else if (~wr_en & rd_en) depth <= depth - 1'b1;
   end
end

//assign dout = queue[rd_ptr];
assign full = depth == B;
assign nearly_full = depth >= B-1;
assign empty = depth == {DEPTHw{1'b0}};

//synthesis translate_off
//synopsys  translate_off
always @(posedge clk)
begin
    if(~reset)begin
       if (wr_en && depth == B && !rd_en)begin
          $display(" %t: ERROR: Attempt to write to full FIFO: %m",$time);
          $stop;
       end if (rd_en && depth == {DEPTHw{1'b0}}) begin
          $display("%t: ERROR: Attempt to read an empty FIFO: %m",$time);
          $stop;
        end
    end//~reset
end
//synopsys  translate_on
//synthesis translate_on


assign dout =(first_round)? rd_ptr-1  :   ramout;

endmodule // fifo



module fake_sam_old #(
    parameter NUM_OF_RNs=4,
    parameter NUM_OF_HNs=4, // must be power  of 2
    parameter CACHE_BLK_SIZ=64, 
    
    
    parameter RAW_ADDR_SIZ =10,
    parameter TRGT_ADDR_SIZ = 10,
    parameter EAw=2
)(
    raw_addr,
    target_hnf_id, // destination endpoint number
    target_addr // address in destination endpoint
);

   input [RAW_ADDR_SIZ-1 : 0] raw_addr;
   output [EAw-1 : 0] target_hnf_id;
   output [TRGT_ADDR_SIZ-1: 0] target_addr;


    
    // set target home node acording to mb2020 
    // consequatve cache blocks are mapped in different HNFs 
    // No odd even yet supported in ache/snoop filter
     function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 



    localparam 
        LOW_OFFSETw = log2(CACHE_BLK_SIZ),        // The address range in cache block
      //  BLK_ADDRw = RAW_ADDR_SIZ - OFFSETw,
        HNF_ADDRw = log2(NUM_OF_HNs),
        HIGH_OFFSETw = RAW_ADDR_SIZ - HNF_ADDRw - LOW_OFFSETw;
    
  
  
    generate
    if(NUM_OF_HNs==1)begin  :hn1
         assign target_hnf_id = NUM_OF_RNs;
         assign target_addr = raw_addr;
    end// NUM_OF_HNs=1
    else begin :hns
        wire [LOW_OFFSETw-1 : 0] low_offset_addr;
       // wire [BLK_ADDRw-1 : 0] block_addr = raw_addr [RAW_ADDR_SIZ-1 : OFFSETw];
        wire [HNF_ADDRw-1 : 0] hnf_num;
        wire [HIGH_OFFSETw-1 : 0] high_offset_addr;
       
        assign {high_offset_addr,hnf_num,low_offset_addr} = raw_addr;
       
        assign target_hnf_id = NUM_OF_RNs + hnf_num;
      //  assign target_addr = {high_offset_addr,low_offset_addr};
         assign target_addr = raw_addr;
    end
    endgenerate  
    
    
    


endmodule



























module credict_ckeck #(
    parameter B=4
)(
    have_cridit,
    nearly_full,
    chi_noc_flitv,
    noc_chi_lcrdv,
    reset,
    clk
);

    input  chi_noc_flitv,    noc_chi_lcrdv;    
    output have_cridit, nearly_full;
    input reset,clk;
    
      function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 
    
    localparam Bw = log2(B+1);

    reg [Bw-1 : 0] credit_counter;
    
     always@(posedge clk or posedge reset)begin
        if(reset)begin
            credit_counter <={Bw{1'b0}};           
        end else begin
            if(  chi_noc_flitv   & ~ noc_chi_lcrdv)   credit_counter <= credit_counter+1'b1;
            if( ~chi_noc_flitv   &   noc_chi_lcrdv)   credit_counter <= credit_counter-1'b1;           
        end //reset
     end//always

    assign  have_cridit = (credit_counter != B);
    assign  nearly_full = (credit_counter == B-1);
endmodule








module many_to_one_intfc #(
    parameter Dw=20,
    parameter IN_NUM=2,
    parameter B=4
    
)(
    qin_data_in,
    qin_we,
    qin_is_ready,    
  
    qout_data_o,
    qout_we_o,
    qout_is_ready,
    qout_winner,
    
    
    reset,clk
    
);

    localparam DATA_ARRAYw = Dw * IN_NUM;
    
    

    input [DATA_ARRAYw-1 : 0] qin_data_in;
    input [IN_NUM-1 : 0] qin_we;
    output[IN_NUM-1 : 0] qin_is_ready;
    
    output [Dw-1 : 0] qout_data_o;
    output qout_we_o;
    input  qout_is_ready;
    output [IN_NUM-1 : 0 ] qout_winner;
    
    input reset,clk;
    
    

   
    wire [DATA_ARRAYw-1 : 0] qin_data_o;
    wire [IN_NUM-1 : 0] q_full;
    wire [IN_NUM-1 : 0] not_empty;
    wire  [IN_NUM-1 : 0] qin_rd_en;
   
    wire [IN_NUM-1 : 0] request;
    wire [IN_NUM-1 : 0] grant;
    wire any_grant;
    
    genvar i;
    generate 
    for (i=0; i<IN_NUM; i=i+1 ) begin : in
        //seperte input array
      
        fwft_fifo #(
            .DATA_WIDTH(Dw),
            .MAX_DEPTH(B),
            .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
        )
        q_fifo
        (
            .din(qin_data_in[(i+1)*Dw-1 : i*Dw ]),
            .wr_en(qin_we[i]),
            .rd_en(qin_rd_en[i]),
            .dout(qin_data_o[(i+1)*Dw-1 : i*Dw ]),
            .full(q_full[i]),
            .nearly_full( ),
            .recieve_more_than_0(not_empty[i]),
            .recieve_more_than_1( ),
            .reset(reset),
            .clk(clk)
        );
               
        
    end
    endgenerate
     
  
    
    assign qin_is_ready = ~ q_full;
    assign request = (qout_is_ready)? not_empty : {IN_NUM{1'b0}};
    assign qin_rd_en = grant;
    assign qout_we_o = any_grant;
    assign qout_winner = grant;
    
    
    arbiter #(
    	.ARBITER_WIDTH(IN_NUM)
    )
    arbiter
    (
    	.request(request),
    	.grant(grant),
    	.any_grant(any_grant),
    	.clk(clk),
    	.reset(reset)
    );
    
    one_hot_mux #(
    	.IN_WIDTH(DATA_ARRAYw),
    	.SEL_WIDTH(IN_NUM),
    	.OUT_WIDTH(Dw)
    )
    mux
    (
    	.mux_in(qin_data_o),
    	.mux_out(qout_data_o),
    	.sel(grant)
    );
      

endmodule



module get_req_flit_excl_info (
     reqflit,
     addr,
     srcid,
     lpid, 
     opcode,
     excl_snoopme // = 1'b1;
);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

      input  [REQ_FLIT_SIZE-1:0]       reqflit;
      output [ADDR_REQ-1:0]            addr;
      output [SRCID_REQ-1:0]           srcid;
      output [LPID_REQ-1:0]            lpid; 
      output [OPCODE_REQ-1:0]          opcode;
      output                           excl_snoopme; // = 1'b1;
      

    
       

// txreqflit
        wire [QOS_REQ-1:0]             qos; // = {QOS_REQ{1'b0}};
        wire [TGTID_REQ-1:0]           tgtid;

        wire [TXNID_REQ-1:0]           txnid;
        wire [RETURNNID_REQ-1:0]       returnnid; // = {RETURNNID_REQ{1'b0}};
        wire                           endian; // = 1'b1;
        wire [RETURNTXNID_REQ-1:0]     returntxnid;

        wire [SIZE_REQ-1:0]            flitsize; // = 3'b110 ;
       
        wire                           ns; // = 1'b1;
        wire                           likelyshared; // = 1'b0;
        wire                           allowretry; // = 1'b1;
        wire [ORDER_REQ-1:0]           order; // = 2'b11;
        wire [PCRDTYPE_REQ-1:0]        pcrdtype; // = 4'b0000;
        wire [MEMATTR_REQ-1:0]         memattr;// = 4'b0111;
        wire                           snpattr; // = 1'b1;


        wire                           expcompack;
        wire                           tracetag; // = 1'b0;

 assign {qos, tgtid,srcid,txnid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared,allowretry
     ,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag} = reqflit; 

endmodule



module get_rsp_flit_txnid (
     rspflit,
     txnid

);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

     input  [RSP_FLIT_SIZE-1:0]    rspflit;
    

    wire [QOS_RSP-1:0]             qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_RSP-1:0]           tgtid  ;
    wire [SRCID_RSP-1:0]           srcid  ;
    output  [TXNID_RSP-1:0]        txnid  ;
    wire [OPCODE_RSP-1:0]          opcode ;
    wire [RESPERR_RSP-1:0]         resperr;     
    wire [RESP_RSP-1:0]            resp;
    wire [FWD_DATAPULL_RSP-1:0]    fwd_datapull;
    wire [DBID_RSP-1:0]            dbid;
    wire [PCRDTYPE_RSP-1:0]        pcrdtype; // = 4'b0000;
    wire                           tracetag; // = 1'b0;

    assign {qos, tgtid,   srcid,   txnid,   opcode,  resperr,    resp,  fwd_datapull,  dbid,   pcrdtype,  tracetag} = rspflit;

endmodule




 module get_snp_flit_addr (
    snpflit,
    addr
   );

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

    input  [SNP_FLIT_SIZE-1:0]    snpflit;

    wire [QOS_SNP-1:0]             qos; // = {QOS_REQ{1'b0}};
    wire [SRCID_SNP-1:0]           srcid;
    wire [TXNID_SNP-1:0]           txnid;
    wire [FWDNID_SNP-1:0]          fwdnid;
    wire [FWDTXNID_SNP-1:0]        fwdtxnid;
    wire [OPCODE_SNP-1:0]          opcode;
    output [ADDR_SNP-1:0]            addr;
    wire                           ns;
    wire                           donotgotosd_datapull;
    wire                           rettosrc;
    wire                           tracetag; // = 1'b0;
   
    assign { qos, srcid, txnid, fwdnid, fwdtxnid, opcode, addr, ns, donotgotosd_datapull , rettosrc, tracetag} = snpflit;



endmodule

/**************************
 * 
 * ***********************/
module one_pipereg #(
    parameter Dw=20,
    parameter IGNORE_SAME_LOC_RD_WR_WARNING = "NO"
)(
    qin_data_in,
    qin_we,
    qin_is_ready,    
   
   
    qin_valid_o,    
    qout_data_o,
    qout_we_o,
    qout_is_ready,
   
    
    
    reset,clk
    
);

   
    
    

    input [Dw-1 : 0] qin_data_in;
    input   qin_we;
    output  qin_is_ready;
    
    output [Dw-1 : 0] qout_data_o;
    output  qin_valid_o;
    output qout_we_o;
    input  qout_is_ready;
    
    
    input reset,clk;
    
    
   
   
    
    wire   q_full;
    wire   not_empty;
    wire   qin_rd_en;
   
    wire   request;
  
   
    
    reg [Dw-1 : 0 ] pipereg  ;
    reg [Dw-1 : 0 ] pipereg_next  ;
    reg   pipereg_valid;
    
    assign qin_valid_o= pipereg_valid;
     
    

    reg   pipereg_valid_next;
      


    
     
        //seperte input array
        always @(*) begin               
            pipereg_next = pipereg;
            if (qin_we ) pipereg_next = qin_data_in;
            pipereg_valid_next = pipereg_valid;
            if (qin_we & ~qin_rd_en) pipereg_valid_next=1'b1;
            else if (~qin_we & qin_rd_en) pipereg_valid_next=1'b0;
       end
        
        always @(posedge clk or posedge reset) begin
            if(reset) begin 
                pipereg <= {Dw{1'b0}};
                pipereg_valid <= 1'b0;
            end 
            else begin 
                pipereg <= pipereg_next;
                pipereg_valid <= pipereg_valid_next;
            end            
        end
        
        
 //synthesis translate_off
//synopsys  translate_off
        always @(posedge clk)
        begin
            if(~reset)begin
                if (qin_we  && ~qin_rd_en  && q_full) begin
                    $display("%t: ERROR: Attempt to write to full pipereg. %m",$time);
                    $stop;
                end
                /* verilator lint_off WIDTH */
                if (qin_rd_en && !not_empty  && IGNORE_SAME_LOC_RD_WR_WARNING == "NO") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                    $stop;
                end
                if (qin_rd_en  && ~qin_we  && !not_empty  && IGNORE_SAME_LOC_RD_WR_WARNING == "YES") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                    $stop;
                end
                /* verilator lint_on WIDTH */
            end //~reset
        end // always @ (posedge clk)
    
//synopsys  translate_on
//synthesis translate_on  
        
        assign q_full  =  pipereg_valid ;
        assign not_empty  = pipereg_valid ;
      
    
   
   
     
  
    
    assign qin_is_ready = ~ q_full | request;
    assign request = (qout_is_ready)? not_empty : 1'b0;
    assign qin_rd_en = request;
    assign qout_we_o = request;
   
  
    assign qout_data_o =pipereg;
     
    
  
      

endmodule 






/**************************
 * 
 * ***********************/
module pipereg_ctrl #(
    parameter IGNORE_SAME_LOC_RD_WR_WARNING = "NO"
)(
    
    qin_we,
    qin_is_ready,   
    qin_valid_o,  
    
    qin_rd_en,
   
    
    reset,clk
    
);

   
    input   qin_we;
    output  qin_is_ready;  
    output  qin_valid_o;    
    input qin_rd_en;
    input reset,clk;
    
   
   
    
    wire   q_full;
    wire   not_empty;
    reg   pipereg_valid,  pipereg_valid_next;
       
    
    always @(*) begin            
        pipereg_valid_next = pipereg_valid;
        if (qin_we & ~qin_rd_en) pipereg_valid_next=1'b1;
        else if (~qin_we & qin_rd_en) pipereg_valid_next=1'b0;
    end
        
    always @(posedge clk or posedge reset) begin
        if(reset) begin 
            pipereg_valid <= 1'b0;
        end 
        else begin 
            pipereg_valid <= pipereg_valid_next;
        end            
    end
         
    assign q_full  =  pipereg_valid ;
    assign not_empty  = pipereg_valid ;
    assign qin_is_ready = ~ pipereg_valid | qin_rd_en;
    assign qin_valid_o= pipereg_valid;
        
        
        
 //synthesis translate_off
//synopsys  translate_off
        always @(posedge clk)
        begin
            if(~reset)begin
                if (qin_we  && ~qin_rd_en  && q_full) begin
                    $display("%t: ERROR: Attempt to write to full pipereg. %m",$time);
                    $stop;
                end
                /* verilator lint_off WIDTH */
                if (qin_rd_en && !not_empty  && IGNORE_SAME_LOC_RD_WR_WARNING == "NO") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                    $stop;
                end
                if (qin_rd_en  && ~qin_we  && !not_empty  && IGNORE_SAME_LOC_RD_WR_WARNING == "YES") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                    $stop;
                end
                /* verilator lint_on WIDTH */
            end //~reset
        end // always @ (posedge clk)
    
//synopsys  translate_on
//synthesis translate_on  
 
      

endmodule 
 




 
module many_to_one_pipereg #(
    parameter Dw=20,
    parameter IN_NUM=2,
    parameter IGNORE_SAME_LOC_RD_WR_WARNING = "NO"
)(
    src_id, 
    qin_data_in,
    qin_we,
    qin_is_ready,    
   
    qin_data_o,
    qin_valid_o,
    
    
    
    qout_data_o,
    qout_we_o,
    qout_is_ready,
    qout_winner,
    
    
    reset,clk
    
);

    localparam DATA_ARRAYw = Dw * IN_NUM;
    
    
    input [31 : 0] src_id;   
     
    input [DATA_ARRAYw-1 : 0] qin_data_in;
    input [IN_NUM-1 : 0] qin_we;
    output[IN_NUM-1 : 0] qin_is_ready;
    
    output [Dw-1 : 0] qout_data_o;
    output [IN_NUM-1 : 0] qin_valid_o;
    output qout_we_o;
    input  qout_is_ready;
    output [IN_NUM-1 : 0 ] qout_winner;
    
    input reset,clk;
    
    output [DATA_ARRAYw-1 : 0] qin_data_o;
    wire [IN_NUM-1 : 0] q_full;
    wire [IN_NUM-1 : 0] not_empty;
    wire  [IN_NUM-1 : 0] qin_rd_en;
   
    wire [IN_NUM-1 : 0] request;
    wire [IN_NUM-1 : 0] grant;
    wire any_grant;
    
    
    reg [Dw-1 : 0 ] pipereg_array [IN_NUM-1 : 0];
    reg [Dw-1 : 0 ] pipereg_array_next [IN_NUM-1 : 0];
    reg [IN_NUM-1 : 0] pipereg_valid;
    
    assign qin_valid_o= pipereg_valid;
     
    genvar i;

    reg [IN_NUM-1 : 0] pipereg_valid_next;
      


    generate 
    for (i=0; i<IN_NUM; i=i+1 ) begin : in
        //seperte input array
        always @(*) begin       		
    		pipereg_array_next[i] = pipereg_array[i];
            if (qin_we[i]) pipereg_array_next[i] = qin_data_in[(i+1)*Dw-1 : i*Dw ];
    
    		pipereg_valid_next[i] = pipereg_valid[i];
           	if (qin_we[i] & ~qin_rd_en[i]) pipereg_valid_next[i]=1'b1;
      		else if (~qin_we[i] & qin_rd_en[i]) pipereg_valid_next[i]=1'b0;
        end      
        
        always @(posedge clk or posedge reset) begin
            if(reset) begin 
                pipereg_array[i] <= {Dw{1'b0}};
                pipereg_valid[i] <= 1'b0;
            end 
            else begin 
                pipereg_array[i] <= pipereg_array_next[i];
                pipereg_valid[i] <= pipereg_valid_next[i];
            end            
        end
         
 
        
        assign q_full[i] =  pipereg_valid[i];
        assign not_empty[i] = pipereg_valid[i];
        assign qin_data_o[(i+1)*Dw-1 : i*Dw]  = pipereg_array[i];
      
 
      
        
    end
    endgenerate
     
 
    
   
    assign request = (qout_is_ready)? not_empty : {IN_NUM{1'b0}};
  
  
  
  
    
    
    arbiter #(
        .ARBITER_WIDTH(IN_NUM)
    )
    arbiter
    (
        .request(request),
        .grant(grant),
        .any_grant(any_grant),
        .clk(clk),
        .reset(reset)
    );
    
    assign qin_is_ready = ~ q_full | grant;
    assign qin_rd_en = grant;
    assign qout_we_o = any_grant;
    assign qout_winner = grant;
  
       
    
    
    one_hot_mux #(
        .IN_WIDTH(DATA_ARRAYw),
        .SEL_WIDTH(IN_NUM),
        .OUT_WIDTH(Dw)
    )
    mux
    (
        .mux_in(qin_data_o),
        .mux_out(qout_data_o),
        .sel(grant)
    );
    
     //synthesis translate_off
    //synopsys  translate_off
    
    generate 
    for (i=0; i<IN_NUM; i=i+1 ) begin : sim
        always @(posedge clk)
        begin
            if(~reset)begin
                if (qin_we[i] & ~qin_is_ready[i]) begin
                    $display("ERROR: %t src_id(%d) Attempt to write to full pipereg %d. %m",$time,src_id,i);
                    $stop;
                 end
                            
                /* verilator lint_off WIDTH */
                if (qin_rd_en[i] & ~not_empty[i] & (IGNORE_SAME_LOC_RD_WR_WARNING == "NO")) begin
                    $display("ERROR: %t  src_id(%d) Attempt to read an empty FIFO: %d. %m", $time,src_id,i);
                    $stop;
                end
                
                if (qin_rd_en[i] & ~qin_we[i] & ~not_empty[i] & (IGNORE_SAME_LOC_RD_WR_WARNING == "YES")) begin
                    $display("ERROR: %t src_id(%d) Attempt to read an empty FIFO: %d. %m", $time,src_id,i);
                    $stop;
                end
                /* verilator lint_on WIDTH */
            end //~reset
        end // always @ (posedge clk)
        
    end
    endgenerate    
   
    //synthesis translate_on
    //synopsys  translate_on
        
     
      

endmodule


 
 module many_to_one_pipe_fifo #(
    parameter B=4,
    parameter Dw=20,
    parameter IN_NUM=2,
    parameter IGNORE_SAME_LOC_RD_WR_WARNING = "NO"
)(
    qin_data_in,
    qin_we,
    qin_is_ready,    
   
    qin_data_o,
    qin_valid_o,  
    
    qout_data_o,
    qout_we_o,
    qout_is_ready,
    qout_winner,    
    reset,clk
    
);

    localparam DATA_ARRAYw = Dw * IN_NUM;
    
    

    input [DATA_ARRAYw-1 : 0] qin_data_in;
    input [IN_NUM-1 : 0] qin_we;
    output[IN_NUM-1 : 0] qin_is_ready;
    
    output [Dw-1 : 0] qout_data_o;
    output [IN_NUM-1 : 0] qin_valid_o;
    output qout_we_o;
    input  qout_is_ready;
    output [IN_NUM-1 : 0 ] qout_winner;
    
    input reset,clk;
    
    
   
   
    output [DATA_ARRAYw-1 : 0] qin_data_o;
    wire [IN_NUM-1 : 0] q_full;
    wire [IN_NUM-1 : 0] not_empty;
    wire  [IN_NUM-1 : 0] qin_rd_en;
   
    wire [IN_NUM-1 : 0] request;
    wire [IN_NUM-1 : 0] grant;
    wire any_grant;
    
    assign qin_valid_o = not_empty;
    
  
  
    genvar i;


      


    generate 
    for (i=0; i<IN_NUM; i=i+1 ) begin : in
       
        
        
//synthesis translate_off
//synopsys  translate_off
        always @(posedge clk)
        begin
            if(~reset)begin
                if (qin_we[i] && ~qin_rd_en[i] && q_full[i]) begin
                    $display("%t: ERROR: Attempt to write to full pipereg %d. %m",$time,i);
                    $stop;
                end
                /* verilator lint_off WIDTH */
                if (qin_rd_en[i] && !not_empty[i] && IGNORE_SAME_LOC_RD_WR_WARNING == "NO") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                    $stop;
                end
                if (qin_rd_en[i] && ~qin_we[i] && !not_empty[i] && IGNORE_SAME_LOC_RD_WR_WARNING == "YES") begin
                    $display("%t ERROR: Attempt to read an empty FIFO: %m", $time);
                    $stop;
                end
                /* verilator lint_on WIDTH */
            end //~reset
        end // always @ (posedge clk)
    
//synopsys  translate_on
//synthesis translate_on  
        
         
       
        fwft_fifo #(
            .DATA_WIDTH(Dw),
            .MAX_DEPTH(B),
            .IGNORE_SAME_LOC_RD_WR_WARNING("YES")
        )
        q_fifo
        (
            .din(qin_data_in[(i+1)*Dw-1 : i*Dw ]),
            .wr_en(qin_we[i]),
            .rd_en(qin_rd_en[i]),
            .dout(qin_data_o[(i+1)*Dw-1 : i*Dw ]),
            .full(q_full[i]),
            .nearly_full( ),
            .recieve_more_than_0(not_empty[i]),
            .recieve_more_than_1( ),
            .reset(reset),
            .clk(clk)
        );
               
        
    end
    endgenerate
     
  
    
    assign qin_is_ready = ~ q_full | grant;
    assign request = (qout_is_ready)? not_empty : {IN_NUM{1'b0}};
    assign qin_rd_en = grant;
    assign qout_we_o = any_grant;
    assign qout_winner = grant;
    
    
    arbiter #(
        .ARBITER_WIDTH(IN_NUM)
    )
    arbiter
    (
        .request(request),
        .grant(grant),
        .any_grant(any_grant),
        .clk(clk),
        .reset(reset)
    );
    
    one_hot_mux #(
        .IN_WIDTH(DATA_ARRAYw),
        .SEL_WIDTH(IN_NUM),
        .OUT_WIDTH(Dw)
    )
    mux
    (
        .mux_in(qin_data_o),
        .mux_out(qout_data_o),
        .sel(grant)
    );
      

endmodule

































 
 
module check_num_asseted_bits #(
   parameter Dw=5 // the input number width in bits 
)(
    n, // input number
    has_no_bit_asserted,
    has_one_bit_asserted,
    has_more_than_one_bit_asserted
);

    input [Dw-1 : 0] n;
    output  has_no_bit_asserted,
    has_one_bit_asserted,
    has_more_than_one_bit_asserted;

    wire [Dw-1: 0] n_1 =  n -1'b1;
    
    assign  has_more_than_one_bit_asserted = |(n & n_1);
    assign  has_no_bit_asserted = (n=={Dw{1'b0}});
    assign  has_one_bit_asserted = ~(has_more_than_one_bit_asserted | has_no_bit_asserted);

endmodule


module monitor_req_flit #(
    parameter AGENT_NAME="snf",
   // parameter src_id=0,
    parameter TYPE="RX"

)
(
    src_id,
    req_flit,
    monitor,
    clk

);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
  
    input clk;
    input monitor;
    input [REQ_FLIT_SIZE-1:0] req_flit;
    input [31 : 0] src_id;


    wire [QOS_REQ-1:0]             qos; 
    wire [TGTID_REQ-1:0]           tgtid;
    wire [SRCID_REQ-1:0]           srcid;
    wire [TXNID_REQ-1:0]           txnid;
    wire [RETURNNID_REQ-1:0]       returnnid;
    wire               endian;
    wire [RETURNTXNID_REQ-1:0]     returntxnid;
    wire [OPCODE_REQ-1:0]      opcode;
    wire [SIZE_REQ-1:0]        flitsize;
    wire [ADDR_REQ-1:0]        addr;
    
    wire               ns;
    wire               likelyshared;
    wire               allowretry;
    wire [ORDER_REQ-1:0]       order;
    wire [PCRDTYPE_REQ-1:0]    pcrdtype;
    wire [MEMATTR_REQ-1:0]     memattr;
    wire               snpattr;
    wire [LPID_REQ-1:0]        lpid;
    wire               excl_snoopme;
    wire               expcompack;
    wire               tracetag;

 assign {qos, tgtid,srcid,txnid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared,allowretry
     ,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag} =req_flit;

 wire [31 : 0] str;
 assign str = (TYPE=="RX")? "got" : "sent";
                    

always @(posedge clk) begin
  
        if(monitor) begin 
        $display("%t: %s ( %d ) txn ( %d ) %s req flit: qos ( %d ) tgtid ( %d ) srcid ( %d ) returnnid ( %d ) endian ( %d ) returntxnid ( %d ) opcode ( %d ) flitsize ( %d ) addr ( %d ) ns ( %d ) likelyshared ( %d ).", $time, AGENT_NAME,src_id,txnid, str,qos, tgtid,srcid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared);
        $display("%t: %s ( %d ) txn ( %d ) %s req flit: allowretry ( %d ) order ( %d ) pcrdtype ( %d ) memattr ( %d ) snpattr ( %d ) lpid ( %d ) excl_snoopme ( %d ) expcompack ( %d ) tracetag ( %d )", $time, AGENT_NAME,src_id,txnid, str, allowretry,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag);
        end
  
end



endmodule



module monitor_rsp_flit #(
    parameter AGENT_NAME="snf",
   // parameter src_id=0,
    parameter TYPE="RX"

)
(
    src_id,   
    rsp_flit,
    monitor,
    clk

);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
     input [31 : 0] src_id;    

    input clk;
    input monitor;
    input [RSP_FLIT_SIZE-1:0] rsp_flit;


    
    wire [QOS_RSP-1:0]             qos; // = {QOS_REQ{1'b0}};
    wire [TGTID_RSP-1:0]           tgtid  ;
    wire [SRCID_RSP-1:0]           srcid  ;
    wire [TXNID_RSP-1:0]           txnid  ;
    wire [OPCODE_RSP-1:0]          opcode ;
    wire [RESPERR_RSP-1:0]         resperr;     
    wire [RESP_RSP-1:0]            resp;
    wire [FWD_DATAPULL_RSP-1:0]    fwd_datapull;
    wire [DBID_RSP-1:0]            dbid;
    wire [PCRDTYPE_RSP-1:0]        pcrdtype; // = 4'b0000;
    wire                           tracetag; // = 1'b0;

    assign {qos, tgtid, srcid,   txnid,   opcode,  resperr,    resp,  fwd_datapull,  dbid,   pcrdtype,  tracetag} = rsp_flit;
    
   wire [31 : 0] str;
 assign str = (TYPE=="RX")? "got" : "sent";
                    

always @(posedge clk) begin
  
        if(monitor) begin 
        $display("%t: %s ( %d ) txn ( %d ) %s rsp flit: qos( %d ), tgtid( %d ), srcid( %d ), txnid( %d ), opcode( %d ), resperr( %d ), resp( %d ), fwd_datapull( %d ), dbid( %d ), pcrdtype( %d ), tracetag( %d ).", $time, AGENT_NAME, src_id,txnid, str, qos, tgtid, srcid,   txnid,   opcode,  resperr,    resp,  fwd_datapull,  dbid,   pcrdtype,  tracetag);
        end
  
end




endmodule



module monitor_dat_flit #(
    parameter AGENT_NAME="snf",
   // parameter src_id=0,
    parameter TYPE="RX"

)
(
    src_id,
    dat_flit,
    monitor,
    clk

);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
     input [31 : 0] src_id;    

    input clk;
    input monitor;
    input [DAT_FLIT_SIZE-1:0] dat_flit;

    wire [QOS_DAT-1:0]             qos;  //= {QOS_REQ{1'b0}}; // not supported
    wire [TGTID_DAT-1:0]           tgtid;  //= rxreq_to_txdat_tgtid;
    wire [SRCID_DAT-1:0]           srcid;  //= src_id;
    wire [TXNID_DAT-1:0]           txnid; //= rxreq_to_txdat_txnid;
    wire [HOMENID_DAT-1:0]         homenid; //=  rxreq_to_txdat_homenid; 
    wire [OPCODE_DAT-1:0]          opcode; //= rxreq_to_txopcode_dat;
    wire [RESPERR_DAT-1:0]         resperr;// = {RESPERR_DAT{1'b0}};   // not supported  
    wire [RESP_DAT-1:0]            resp; //=rxreq_to_txdat_resp ;
    wire [FWD_DATAPULL_DAT-1:0]    fwd_datapull;// = {FWD_DATAPULL_DAT{1'b0}}; // not supported
    wire [DBID_DAT-1:0]            dbid; //= rxreq_to_txdat_dbid ;
    wire [CCID_DAT-1:0]            ccid; //= {CCID_DAT{1'b0}}; // not supported
    wire [DATAID_DAT-1:0]          dataid;// = {DATAID_DAT{1'b0}}; // not supported
    wire                           tracetag;//  = 1'b0; // not supported
    wire [BE_DAT-1:0]              be;// ={BE_DAT{1'b1}}; // not supported
    wire [DATA_DAT-1:0]            data;// = rxreq_to_txdat_dat;
    wire [DATACHECK_DAT-1:0]       datacheck;// = {DATACHECK_DAT{1'b0}} ;// not supported
    wire [POISON_DAT-1:0]          poison;// = {POISON_DAT{1'b0}}; // not supported
    
    
    

    assign {qos,tgtid,srcid ,txnid ,homenid ,opcode ,resperr, resp ,fwd_datapull ,dbid ,ccid ,dataid ,tracetag ,be ,data ,datacheck  ,poison} = dat_flit;
    
   wire [31 : 0] str;
   assign str = (TYPE=="RX")? "got" : "sent";
                    

    always @(posedge clk) begin
      
            if(monitor) begin 
            $display("%t: %s ( %d ) txn ( %d ) %s dat flit: qos ( %d ), tgtid ( %d ), srcid ( %d ), homenid ( %d ), opcode ( %d ), resperr ( %d ), resp ( %d ), fwd_datapull ( %d )",
            $time,AGENT_NAME,src_id, txnid, str, qos, tgtid, srcid, homenid ,opcode, resperr, resp, fwd_datapull);
            $display("%t: %s ( %d ) txn ( %d ) %s dat flit: dbid ( %d ), ccid ( %d ), dataid ( %d ), tracetag ( %d ), be ( %d ), data ( %h ), datacheck ( %d ), poison ( %d )",
            $time,AGENT_NAME,src_id, txnid, str, dbid, ccid, dataid, tracetag, be, data, datacheck, poison);
            end
      
    end




endmodule





module monitor_snp_flit #(
    parameter AGENT_NAME="hnf",
    parameter TYPE="RX",
    parameter EAw=3

)
(
    src_id,
    snp_flit,
    monitor,
    snp_target_id,   
    clk

);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
     input [31 : 0] src_id;    

    input clk;
    input monitor;
    input [SNP_FLIT_SIZE-1:0] snp_flit;
    input [EAw-1 : 0]  snp_target_id;   

    wire [QOS_SNP-1:0]             qos;  
    wire [SRCID_SNP-1:0]           srcid  ;
    wire [TXNID_SNP-1:0]           txnid  ;
    wire [FWDNID_SNP-1:0]          fwdnid  ;
    wire [FWDTXNID_SNP-1:0]        fwdtxnid  ;
    wire [OPCODE_SNP-1:0]          opcode ;
    wire [ADDR_SNP-1:0]            addr ;
    wire                           ns ;
    wire                           donotgotosd_datapull ;
    wire                           rettosrc ;
    wire                           tracetag;  
    wire reset_rettosrc;
    
 
    assign  {qos, srcid, txnid, fwdnid, fwdtxnid, opcode, addr, ns, donotgotosd_datapull , rettosrc, tracetag}=
    snp_flit;

    wire [31 : 0] str;
    assign str = (TYPE=="RX")? "got" : "sent";
                    

    always @(posedge clk) begin
      
            if(monitor) begin 
            $display("%t: %s ( %d ) txn ( %d ) %s snp flit: qos ( %d ), srcid ( %d ), tgtid ( %d ), fwdnid ( %d ), fwdtxnid ( %d ), opcode ( %d ), addr  ( %d ),ns ( %d ), donotgotosd_datapull ( %d ), rettosrc  ( %d ), tracetag  ( %d )",
            $time,AGENT_NAME,src_id, txnid, str, qos, srcid,snp_target_id, fwdnid, fwdtxnid ,opcode, addr, ns, donotgotosd_datapull, rettosrc, tracetag);
           
            end
      
    end


endmodule








module fifo_two_rd_port #(
    parameter Dw = 72,//data_width
    parameter B  = 10// buffer num
)(
    din,   
    wr_en, 
    full,
    
    rd_en1, 
    dout1,  
    empty1,
  
    rd_en2, 
    dout2,  
    empty2,
  
    reset,
    clk
);

 
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

    localparam  B_1 = B-1,
                Bw = log2(B),
                DEPTHw=log2(B+1);
    localparam  [Bw-1   :   0] Bint =   B_1[Bw-1    :   0];

    input [Dw-1:0] din;     // Data in
    input          wr_en;   // Write enable
    output         full;

    input          rd_en1;   // Read the next word
    output  [Dw-1:0]  dout1;    // Data out
    output         empty1;
    
    input          rd_en2;   // Read the next word
    output  [Dw-1:0]  dout2;    // Data out
    output         empty2;
  

    input          reset;
    input          clk;



reg [Dw-1       :   0] queue [B-1 : 0]; 
reg [Bw- 1      :   0] rd_ptr1,rd_ptr2;
reg [Bw- 1      :   0] wr_ptr;
reg [DEPTHw-1   :   0] depth1,depth2;

// Sample the data
always @(posedge clk)
begin
   if (wr_en)
      queue[wr_ptr] <= din;  
end


 assign  dout1 =  queue[rd_ptr1];
 assign  dout2 =  queue[rd_ptr2];




always @(posedge clk)
begin
   if (reset) begin
      wr_ptr <= {Bw{1'b0}};
      rd_ptr1 <= {Bw{1'b0}};
      depth1  <= {DEPTHw{1'b0}};
      rd_ptr2 <= {Bw{1'b0}};
      depth2  <= {DEPTHw{1'b0}};
   end
   else begin
      if (wr_en) wr_ptr <= (wr_ptr==Bint)? {Bw{1'b0}} : wr_ptr + 1'b1;
      if (rd_en1) rd_ptr1 <= (rd_ptr1==Bint)? {Bw{1'b0}} : rd_ptr1 + 1'b1;
      if (rd_en2) rd_ptr2 <= (rd_ptr2==Bint)? {Bw{1'b0}} : rd_ptr2 + 1'b1;
     
      if (wr_en & ~rd_en1) depth1 <= depth1 + 1'b1;
      else if (~wr_en & rd_en1) depth1 <= depth1 - 1'b1;

      if (wr_en & ~rd_en2) depth2 <= depth2 + 1'b1;
      else if (~wr_en & rd_en2) depth2 <= depth2 - 1'b1;


   end
end

//assign dout = queue[rd_ptr];
assign full = (depth1 == B) | (depth2==B);
assign empty1 = depth1 == {DEPTHw{1'b0}};
assign empty2 = depth2 == {DEPTHw{1'b0}};

//synthesis translate_off
//synopsys  translate_off
always @(posedge clk)
begin
    if(~reset)begin
       if (wr_en && (depth1 == B && !rd_en1))  $display(" %t: ERROR: Attempt to write to full FIFO port 1: %m",$time);
       if (wr_en && (depth2 == B && !rd_en2))  $display(" %t: ERROR: Attempt to write to full FIFO port 2: %m",$time);
       if (rd_en1 && depth1 == {DEPTHw{1'b0}}) $display(" %t: ERROR: Attempt to read an empty FIFO port 1: %m",$time);
       if (rd_en2 && depth2 == {DEPTHw{1'b0}}) $display(" %t: ERROR: Attempt to read an empty FIFO port 2: %m",$time);
    end//~reset
end
//synopsys  translate_on
//synthesis translate_on

endmodule // fifo



// if two concurrent write to both chanels happens,
// first chanel is written in wr pointer and seond chanel writes in wr pointer+1
module fifo_two_wr_port #(
    parameter Dw = 72,//data_width
    parameter SDw = 5, //if bigger than 0 then the first SDw are sent to sdout like  fwft_fifo 
    parameter B  = 10// buffer num
)(
    
    din1,   
    wr_en1, 
       
    din2,   
    wr_en2, 
   
    full,
    nearly_full,// nearly full should be used to perevent wr if both chanel atempt to wr at the same time
    
    rd_en, 
    dout, 
    sdout,
    empty,
      
    reset,
    clk
);



 
    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

    localparam  B_1 = B-1,
                Bw = log2(B),
                DEPTHw=log2(B+1);
    localparam  [Bw-1   :   0] Bint =   B_1[Bw-1    :   0];
    localparam  [Bw-1   :   0] B_2  =   Bint-1'b1;

    input [Dw-1:0] din1;     // Data in
    input          wr_en1;   // Write enable
  
    input [Dw-1:0] din2;     // Data in
    input          wr_en2;   // Write enable
    
    output         full;
    output         nearly_full;

    input          rd_en;   // Read the next word
    output reg [Dw-1:0]  dout;    // Data out
    output         empty;
  

    input          reset;
    input          clk;

    localparam SDw1= (SDw> 0)? SDw : 1;

    output [SDw1-1 : 0 ] sdout;


    reg [Dw-1       :   0] queue [B-1 : 0]; 
    reg [Bw- 1      :   0] rd_ptr;
    reg [Bw- 1      :   0] wr_ptr;
    reg [DEPTHw-1   :   0] depth;





// Sample the data

wire [Bw- 1      :   0] wr_ptr_next = (wr_ptr==Bint)? {Bw{1'b0}} : wr_ptr + 1'b1 ;

always @(posedge clk)
begin
   if      ( wr_en1 & ~wr_en2)      queue[wr_ptr] <= din1;
   else if (~wr_en1 &  wr_en2)      queue[wr_ptr] <= din2; 
   else if ( wr_en1 &  wr_en2)begin 
     queue[wr_ptr ] <= din1; 
     queue[wr_ptr_next] <= din2; 
   end
   
   if (rd_en )       dout <=  queue[rd_ptr];
end


 generate 
 if(SDw> 0)begin 
     assign sdout =  queue[rd_ptr][SDw-1 : 0]; 
 end else begin 
     assign sdout =  1'hx;
 end 
 endgenerate



always @(posedge clk)
begin
   if (reset) begin
      wr_ptr <= {Bw{1'b0}};
      depth  <= {DEPTHw{1'b0}};
      rd_ptr <= {Bw{1'b0}};      
    end
    else begin
        case({wr_en1,wr_en2})
        2'b10,2'b01: begin 
            wr_ptr <= (wr_ptr==Bint)? {Bw{1'b0}} : wr_ptr + 1'b1; //+1
            if (~rd_en) depth <= depth + 2'd1;            
        end    
        2'b11: begin 
            wr_ptr <=   //+2
                (wr_ptr==B_2)? {Bw{1'b0}} :
                (wr_ptr==Bint)? 1 :
                wr_ptr + 2'd2;
            if (~rd_en) depth <= depth + 2'd2;  
            else depth <= depth + 2'd1;  
                
        end
        2'b00: begin 
            if (rd_en) depth <= depth - 2'd1;  
        end
        endcase
        
        if (rd_en) rd_ptr <= (rd_ptr==Bint)? {Bw{1'b0}} : rd_ptr + 1'b1;
    end
end

//assign dout = queue[rd_ptr];
assign full = (depth == B);
assign nearly_full = (depth >= Bint);
assign empty = depth == {DEPTHw{1'b0}};


//synthesis translate_off
//synopsys  translate_off
always @(posedge clk)
begin
    if(~reset)begin
     case({wr_en1,wr_en2})
        2'b10: begin
            if (full && !rd_en) begin 
                $display(" %t: ERROR: Attempt to write to full FIFO port 1: %m",$time);
                $stop;
            end
        end
        2'b01: begin 
            if (full && !rd_en) begin 
                $display(" %t: ERROR: Attempt to write to full FIFO port 2: %m",$time);
                $stop;
            end    
        end
        2'b11: begin 
            if(full | (nearly_full & ~rd_en)) begin 
                $display(" %t: ERROR: Attempt to write to full FIFO port 1&2: %m",$time);
                $stop;
            end    
        
        end        
        endcase
        
        if (rd_en & empty) begin 
            $display(" %t: ERROR: Attempt to read an empty FIFO %m",$time);
            $stop;
        end              
      
    end//~reset
end
//synopsys  translate_on
//synthesis translate_on

endmodule // fifo


/******************
 *  extractors
 * ****************/


module extract_req_flit_fileds (
    req_flit,
  
    qos,
    tgtid,
    srcid,
    txnid,
    returnnid,
    endian,
    returntxnid,
    opcode,
    flitsize,
    addr,
    ns, 
    likelyshared,
    allowretry,
    order,
    pcrdtype,
    memattr,
    snpattr,
    lpid,
    excl_snoopme,
    expcompack,
    tracetag

);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
  
 
    input [REQ_FLIT_SIZE-1:0] req_flit;
 

    output [QOS_REQ-1:0]             qos; 
    output [TGTID_REQ-1:0]           tgtid;
    output [SRCID_REQ-1:0]           srcid;
    output [TXNID_REQ-1:0]           txnid;
    output [RETURNNID_REQ-1:0]       returnnid;
    output               endian;
    output [RETURNTXNID_REQ-1:0]     returntxnid;
    output [OPCODE_REQ-1:0]      opcode;
    output [SIZE_REQ-1:0]        flitsize;
    output [ADDR_REQ-1:0]        addr;

    output               ns;
    output               likelyshared;
    output               allowretry;
    output [ORDER_REQ-1:0]       order;
    output [PCRDTYPE_REQ-1:0]    pcrdtype;
    output [MEMATTR_REQ-1:0]     memattr;
    output               snpattr;
    output [LPID_REQ-1:0]        lpid;
    output               excl_snoopme;
    output               expcompack;
    output               tracetag;

 assign {qos, tgtid,srcid,txnid,returnnid,endian,returntxnid,opcode,flitsize,addr,ns,likelyshared,allowretry
     ,order,pcrdtype,memattr,snpattr,lpid,excl_snoopme,expcompack,tracetag} =req_flit;
 

endmodule



module extract_rsp_flit_fileds (
    rsp_flit,
    
    qos,
    tgtid,
    srcid,
    txnid,
    opcode,
    resperr,     
    resp,
    fwd_datapull,
    dbid,
    pcrdtype, // = 4'b0000;
    tracetag // = 1'b0;

);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
    
    input [RSP_FLIT_SIZE-1:0] rsp_flit;


    
    output [QOS_RSP-1:0]             qos; // = {QOS_REQ{1'b0}};
    output [TGTID_RSP-1:0]           tgtid  ;
    output [SRCID_RSP-1:0]           srcid  ;
    output [TXNID_RSP-1:0]           txnid  ;
    output [OPCODE_RSP-1:0]          opcode ;
    output [RESPERR_RSP-1:0]         resperr;     
    output [RESP_RSP-1:0]            resp;
    output [FWD_DATAPULL_RSP-1:0]    fwd_datapull;
    output [DBID_RSP-1:0]            dbid;
    output [PCRDTYPE_RSP-1:0]        pcrdtype; // = 4'b0000;
    output                           tracetag; // = 1'b0;

    assign {qos, tgtid, srcid,   txnid,   opcode,  resperr,    resp,  fwd_datapull,  dbid,   pcrdtype,  tracetag} = rsp_flit;
    
   
endmodule



module extract_dat_flit_fileds (
    dat_flit,
  
    qos,  //= {QOS_REQ{1'b0}}; // not supported
    tgtid,  //= rxreq_to_txdat_tgtid;
    srcid,  //= src_id;
    txnid, //= rxreq_to_txdat_txnid;
    homenid, //=  rxreq_to_txdat_homenid; 
    opcode, //= rxreq_to_txopcode_dat;
    resperr,// = {RESPERR_DAT{1'b0}};   // not supported  
    resp, //=rxreq_to_txdat_resp ;
    fwd_datapull,// = {FWD_DATAPULL_DAT{1'b0}}; // not supported
    dbid, //= rxreq_to_txdat_dbid ;
    ccid, //= {CCID_DAT{1'b0}}; // not supported
    dataid,// = {DATAID_DAT{1'b0}}; // not supported
    tracetag,//  = 1'b0; // not supported
    be,// ={BE_DAT{1'b1}}; // not supported
    data,// = rxreq_to_txdat_dat;
    datacheck,// = {DATACHECK_DAT{1'b0}} ;// not supported
    poison// = {POISON_DAT{1'b0}}; // not supported


);

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"
    
   
    input [DAT_FLIT_SIZE-1:0] dat_flit;

    output  [QOS_DAT-1:0]             qos;  //= {QOS_REQ{1'b0}}; // not supported
    output  [TGTID_DAT-1:0]           tgtid;  //= rxreq_to_txdat_tgtid;
    output  [SRCID_DAT-1:0]           srcid;  //= src_id;
    output  [TXNID_DAT-1:0]           txnid; //= rxreq_to_txdat_txnid;
    output  [HOMENID_DAT-1:0]         homenid; //=  rxreq_to_txdat_homenid; 
    output  [OPCODE_DAT-1:0]          opcode; //= rxreq_to_txopcode_dat;
    output  [RESPERR_DAT-1:0]         resperr;// = {RESPERR_DAT{1'b0}};   // not supported  
    output  [RESP_DAT-1:0]            resp; //=rxreq_to_txdat_resp ;
    output  [FWD_DATAPULL_DAT-1:0]    fwd_datapull;// = {FWD_DATAPULL_DAT{1'b0}}; // not supported
    output  [DBID_DAT-1:0]            dbid; //= rxreq_to_txdat_dbid ;
    output  [CCID_DAT-1:0]            ccid; //= {CCID_DAT{1'b0}}; // not supported
    output  [DATAID_DAT-1:0]          dataid;// = {DATAID_DAT{1'b0}}; // not supported
    output                            tracetag;//  = 1'b0; // not supported
    output  [BE_DAT-1:0]              be;// ={BE_DAT{1'b1}}; // not supported
    output  [DATA_DAT-1:0]            data;// = rxreq_to_txdat_dat;
    output  [DATACHECK_DAT-1:0]       datacheck;// = {DATACHECK_DAT{1'b0}} ;// not supported
    output  [POISON_DAT-1:0]          poison;// = {POISON_DAT{1'b0}}; // not supported
    
    
    

    assign {qos,tgtid,srcid ,txnid ,homenid ,opcode ,resperr, resp ,fwd_datapull ,dbid ,ccid ,dataid ,tracetag ,be ,data ,datacheck  ,poison} = dat_flit;
 
 

 
 
endmodule


