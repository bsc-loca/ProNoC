module injct_top (
    RN_NUM,
    src_id,
    reset,
    clk,
    
    wrapreq,
    wrapreqvalid,
    tim_wrap_strobereq,  
    
        
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    chi_noc_txreqflitpend,
    chi_noc_txreqflitv,
    chi_noc_txreqflit,
    noc_chi_txreqlcrdv,
    
    // TXDAT
    chi_noc_txdatflitpend,
    chi_noc_txdatflitv,
    chi_noc_txdatflit,
    noc_chi_txdatlcrdv,
    
    // TXRSP
    chi_noc_txrspflitpend,
    chi_noc_txrspflitv,
    chi_noc_txrspflit,
    noc_chi_txrsplcrdv,
    
    
    //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop chanel so need target ID
    chi_noc_txsnpflitpend,
    chi_noc_txsnpflitv,
    chi_noc_txsnpflit,
    noc_chi_txsnplcrdv,         
    
     // RXREQ
    noc_chi_rxreqflitpend,
    noc_chi_rxreqflitv,
    noc_chi_rxreqflit,          
    chi_noc_rxreqlcrdv,      
    
    
    // RXRSP
    noc_chi_rxrspflitpend,
    noc_chi_rxrspflitv,
    noc_chi_rxrspflit,
    chi_noc_rxrsplcrdv,
    
    // RXDAT
    noc_chi_rxdatflitpend,
    noc_chi_rxdatflitv,
    noc_chi_rxdatflit,
    chi_noc_rxdatlcrdv, 
    
    // RXSNP
    noc_chi_rxsnpflitpend,
    noc_chi_rxsnpflitv,
    noc_chi_rxsnpflit,
    chi_noc_rxsnplcrdv,
    
    //monitor txn
    req_txnid,
    rsp_txnid,
    dat_txnid,
    rsp_Comp,
    dat_Comp
  
    );
    
    `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"
    
               
    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v" 
    
    `define INCLUDE_TOPOLOGY_LOCALPARAM
    `include "topology_localparam.v"  


    
    
     localparam CACHE_ADDRw = ADDR_REQ,
              CACHE_DATAw = DATA_DAT;

   
    //control
    input   logic [31 : 0] src_id;
    input  [31 : 0] RN_NUM;
    input   logic [WRAP_REQ_W-1:0]                      wrapreq ;
    input   logic                                       wrapreqvalid;
    output  logic                                       tim_wrap_strobereq;


    input clk,reset;
           
    
    /*--------- Interface with NoC ---------------------------------*/
    // TXREQ
    output   chi_noc_txreqflitpend ;
    output   chi_noc_txreqflitv;
    output  [REQ_FLIT_SIZE-1:0]    chi_noc_txreqflit;          
    input  noc_chi_txreqlcrdv;
    // TXDAT
    output   chi_noc_txdatflitpend ;
    output   chi_noc_txdatflitv ;
    output  [DAT_FLIT_SIZE-1:0]    chi_noc_txdatflit  ;
    input    noc_chi_txdatlcrdv ;
    // TXRSP
    output    chi_noc_txrspflitpend ;
    output   chi_noc_txrspflitv ;
    output  [RSP_FLIT_SIZE-1:0]    chi_noc_txrspflit  ;
    input    noc_chi_txrsplcrdv ;
    // CRSP/RXRSP
    input    noc_chi_rxrspflitpend ;
    input    noc_chi_rxrspflitv ;
    input   [RSP_FLIT_SIZE-1:0]    noc_chi_rxrspflit ;
    output   chi_noc_rxrsplcrdv ;
    // RXDAT
    input    noc_chi_rxdatflitpend ;
    input    noc_chi_rxdatflitv ;
    input   [DAT_FLIT_SIZE-1:0]    noc_chi_rxdatflit ;
    output   chi_noc_rxdatlcrdv ; 
    // RXSNP
    input    noc_chi_rxsnpflitpend ;
    input    noc_chi_rxsnpflitv ;
    input   [SNP_FLIT_SIZE-1:0]    noc_chi_rxsnpflit ;
    output   chi_noc_rxsnplcrdv ;         
    
    
      //TXSNP // snoop tx home node
    // wire   [TGTID_REQ-1 : 0] chi_noc_tx_snp_target_id ; // we are not supporting braod casting on snoop chanel so need target ID
    output    chi_noc_txsnpflitpend ;
    output    chi_noc_txsnpflitv ;
    output   [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit ;
    input   noc_chi_txsnplcrdv ;         
    
     // RXREQ
    input   noc_chi_rxreqflitpend ;
    input   noc_chi_rxreqflitv;
    input  [REQ_FLIT_SIZE-1:0]    noc_chi_rxreqflit;          
    output   chi_noc_rxreqlcrdv;   
   

    //to monitre txn begin and comp
    output [TXNID_REQ-1 : 0]    req_txnid;
    output [TXNID_RSP-1 : 0]    rsp_txnid;
    output [TXNID_DAT-1 : 0]	dat_txnid;
    output rsp_Comp,dat_Comp;

    reg [31:0] clk_counter,trace_line;
    reg [9:0] counter;
    reg injct_r;
    always @(posedge clk or posedge reset) begin
            if(reset)begin 
              injct_r<=1'b0; 
              counter<=0;
	      clk_counter<=0;
            end else begin 
		clk_counter<=clk_counter+1;
		 //if(counter=={10{1'b1}}-1) $display("Injector %d is ready now\n",src_id);
		 if(counter!={10{1'b1}}) counter <= counter +1'b1;
                 else injct_r<=1'b1;  
            end        
    end//always

  



	always @ (posedge clk) begin 
		if (reset) trace_line<=1;
		
		if(tim_wrap_strobereq==1'b1 && wrapreqvalid==1'b1 )begin 
			//if((trace_line & 'hFFF)==0) $display ("%d:RN[%d] read trace num %d: %h\n",clk_counter,RN_NUM,trace_line,wrapreq);
			trace_line<=trace_line+1;		
		end
	end




	extract_req_flit_fileds req_extractor(
	    .req_flit( chi_noc_txreqflit ),
	  
	    .qos( ),
	    .tgtid( ),
	    .srcid( ),
	    .txnid(req_txnid),
	    .returnnid( ),
	    .endian( ),
	    .returntxnid( ),
	    .opcode( ),
	    .flitsize( ),
	    .addr( ),
	    .ns( ), 
	    .likelyshared( ),
	    .allowretry( ),
	    .order( ),
	    .pcrdtype( ),
	    .memattr( ),
	    .snpattr( ),
	    .lpid( ),
	    .excl_snoopme( ),
	    .expcompack( ),
	    .tracetag( )

	);
	

        wire [OPCODE_RSP-1:0]rsp_opcode;
	assign rsp_Comp = (rsp_opcode == RSP_OPCODE_Comp);
	 extract_rsp_flit_fileds rsp_extractor(
	 	.rsp_flit(noc_chi_rxrspflit),
	 	.qos( ),
	 	.tgtid( ),
	 	.srcid( ),
	 	.txnid(rsp_txnid),
	 	.opcode(rsp_opcode),
	 	.resperr( ),
	 	.resp( ),
	 	.fwd_datapull( ),
	 	.dbid( ),
	 	.pcrdtype( ),
	 	.tracetag( )
 	);


	wire [OPCODE_DAT-1 : 0] dat_opcode;
	assign dat_Comp = (dat_opcode == OPCODE_DAT_CompData);

	extract_dat_flit_fileds dat_extractor(
		.dat_flit(noc_chi_rxdatflit),
		.qos( ),
		.tgtid( ),
		.srcid( ),
		.txnid(dat_txnid),
		.homenid(),
		.opcode(dat_opcode),
		.resperr( ),
		.resp( ),
		.fwd_datapull( ),
		.dbid( ),	
		.ccid( ),
		.dataid( ),
		.tracetag( ),
		.be( ),
		.data( ),
		.datacheck( ),
		.poison( )
	);






	wire [ADDR_REQ-1:0]    sam_target_address_o;    
   	wire [TGTID_REQ-1:0]   sam_target_id_i ;       

	fake_sam #(
                
		.RAW_ADDR_SIZ(ADDR_REQ),
		.TRGT_ADDR_SIZ(ADDR_REQ)
       
	)
	the_sam
	(
		.raw_addr(sam_target_address_o),
		.target_hnf_id(sam_target_id_i),
		.target_addr( )
	);



	injector_top the_inject
	(
		

		// TIM Interface
		.clk(clk),
		.rst_n(injct_r),        
	      
		
		//ctrl
		.wrapreq(wrapreq),
		.wrapreqvalid(wrapreqvalid),
		.tim_wrap_strobereq(tim_wrap_strobereq),

		// CHI NoC Interface                                            
		// TXREQ
		.chi_noc_txreqflitpend_o(chi_noc_txreqflitpend),
		.chi_noc_txreqflitv_o(chi_noc_txreqflitv),
		.chi_noc_txreqflit_o(chi_noc_txreqflit),
		.noc_chi_txreqlcrdv_i(noc_chi_txreqlcrdv),
		
		// TXDAT  
		.chi_noc_txdatflitpend_o(chi_noc_txdatflitpend),
		.chi_noc_txdatflitv_o(chi_noc_txdatflitv),
		.chi_noc_txdatflit_o(chi_noc_txdatflit),
		.noc_chi_txdatlcrdv_i(noc_chi_txdatlcrdv),
		
		// TXRSP 
		.chi_noc_txrspflitpend_o(chi_noc_txrspflitpend),
		.chi_noc_txrspflitv_o(chi_noc_txrspflitv),
		.chi_noc_txrspflit_o(chi_noc_txrspflit),
		.noc_chi_txrsplcrdv_i(noc_chi_txrsplcrdv),
		
		// CRSP/RXRSP
		.noc_chi_rxrspflitpend_i(noc_chi_rxrspflitpend),
		.noc_chi_rxrspflitv_i(noc_chi_rxrspflitv),
		.noc_chi_rxrspflit_i(noc_chi_rxrspflit),
		.chi_noc_rxrsplcrdv_o(chi_noc_rxrsplcrdv),
		
		 // RDAT 
		.noc_chi_rxdatflitpend_i(noc_chi_rxdatflitpend),
		.noc_chi_rxdatflitv_i(noc_chi_rxdatflitv),
		.noc_chi_rxdatflit_i(noc_chi_rxdatflit),
		.chi_noc_rxdatlcrdv_o(chi_noc_rxdatlcrdv),
		
		// SNP/RXSNP  
		.noc_chi_rxsnpflitpend_i(noc_chi_rxsnpflitpend),
		.noc_chi_rxsnpflitv_i(noc_chi_rxsnpflitv),
		.noc_chi_rxsnpflit_i(noc_chi_rxsnpflit),
		.chi_noc_rxsnplcrdv_o(chi_noc_rxsnplcrdv),   

		// SAM
		.sam_target_address_o (sam_target_address_o),
    		.sam_target_id_i (sam_target_id_i),
    		.source_id_i(src_id [SRCID_REQ-1:0])
              

    );

endmodule
