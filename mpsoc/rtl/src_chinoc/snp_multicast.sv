`timescale   1ns/1ns

import l2c_pkg::*;
import hn_inf_pkg::*;
import amba_5_chi_c_pkg::*;

module  snp_flit_multicast_gen #(
	parameter WARMUP_DELAY=10,
	parameter VERBOSITY = 0,
	parameter EAw=4,
	parameter B = 15
   
)
(
	reset,
	clk,
	tx_snp,
	src_id,
	 //TXSNP // snoop tx home node
	chi_noc_txsnpflitpend,
	chi_noc_txsnpflitv,
	chi_noc_txsnpflit,
	noc_chi_txsnplcrdv,
	snp_target_id 
);

	//`define INCLUDE_CHI_LOCALPARAM
	//`include "chi_localparam.v"   

	input reset,clk;
	input [SRCID_REQ-1:0] src_id;
	chi_snp_chan.rx            tx_snp;
	 //TXSNP // snoop tx home node
	output    chi_noc_txsnpflitpend;
	output  reg  chi_noc_txsnpflitv;
	output   [SNP_FLIT_SIZE-1:0]    chi_noc_txsnpflit;
	input   noc_chi_txsnplcrdv;
	output  [TGTID_DAT-1 : 0 ] snp_target_id; 
         
	assign chi_noc_txsnpflitpend =1'b1;
	//buffer input tx_snp.flit

	wire    [SNP_FLIT_SIZE-1:0]    txsnpflit_in,txsnpflit_out;
	wire    [23:0]  target_ids_in, target_ids_out;

assign  chi_noc_txsnpflit= txsnpflit_out;        

   snp_forth_to_bsc convert (
        .forth_snp_flit(tx_snp.flit),
        .bsc_snp_flit(txsnpflit_in),
        .target_ids( target_ids_in)
   );   
    


    wire fifo_empty;
	reg  fifo_rd_en;

    fifo #(
        .Dw(SNP_FLIT_SIZE+24),
        .B(B)
    )        
    buffer
    (
    	.din({target_ids_in,txsnpflit_in}),
    	.wr_en(tx_snp.flit_v),
    	.rd_en(fifo_rd_en),
    	.dout({target_ids_out,txsnpflit_out}),
    	.full(),
    	.nearly_full(),
    	.empty(fifo_empty),
    	.reset(reset),
    	.clk(clk)
    );

	reg [1:0] pst,nst;
	localparam IDEAL =1 ;
	localparam SEND_SNOOP=2;
	reg  [23:0]  sent_targets,sent_targets_next;
	wire [23:0]  target_rn;
	wire have_credit;
	reg forth_credit_incr;
	wire any_target;

	always @(*) begin 
		fifo_rd_en = 1'b0;
		sent_targets_next=sent_targets;
		forth_credit_incr =1'b0;
		chi_noc_txsnpflitv = 1'b0;
		nst=pst;
		case(pst) 
		IDEAL: begin 
			if(  ~fifo_empty ) begin 
				fifo_rd_en = 1'b1;
                		nst = SEND_SNOOP; 
				sent_targets_next=24'd0;               
			end        
		end
		SEND_SNOOP : begin 
			if(any_target)begin 
				if( have_credit) begin 
					sent_targets_next = sent_targets | target_rn; // set the target snoope in sent_targets list 
					chi_noc_txsnpflitv = 1'b1;             
			end// have_credit            
			end else begin // We are done as all snoop requsrts are sent
				forth_credit_incr =1'b1;				
				if(~fifo_empty ) begin  // if fifo is not empty read the new flit and stay in the same state
					 fifo_rd_en = 1'b1;               		
					 sent_targets_next=24'd0; 
				end else begin                 
					nst = IDEAL;               
				end
		end        
		end //SEND_SNOOP
        	endcase     
    	end//always
  


	// select one snoope at a time. we dont support broad casting yet
	wire [23 : 0 ] request =  target_ids_out & (~sent_targets);

    arbiter #(
    	.ARBITER_WIDTH(24)
    )
    arbiter
    (
    	.request(request),
    	.grant(target_rn),
    	.any_grant(any_target),
    	.clk(clk),
    	.reset(reset)
    );
    
    // get the target id of one-hot target_rn
    spv_to_rnfid_addr_decode #(
        .SPVw(24),
        .IDw(TGTID_DAT)
    )
    addr_decode
    (
       .rnf_spv_i(target_rn),
       .rnf_id_o (snp_target_id)
    );
    
    // check the credit availability in NoC
    credit_check #(
        .B(B)
     )
     credict
     (
        .chi_noc_flitv(chi_noc_txsnpflitv),
        .noc_chi_lcrdv(noc_chi_txsnplcrdv),
        .have_credit(have_credit),
        .nearly_full(),
        .reset(reset),
        .clk(clk)
     );

	always @(posedge clk) begin
        if(reset)begin
            pst<= IDEAL;
            sent_targets<= 24'd0;
        end else begin
            pst<=nst;
            sent_targets<=sent_targets_next;
        end
	end	

	//assign tx_snp.lcrd_v = forth_credit_incr;
	/*
	pronoc_to_chi_credit_adapt #(
		.B(B), 
		.WARMUP_DELAY(WARMUP_DELAY)
	)
	tx_snp_credit_adapt
	(    
		.pronoc_credit_in  (forth_credit_incr), 
		.chi_credit_out    (tx_snp.lcrd_v), 
		.clk               (clk), 
		.reset             (reset)
	);
	*/
	// credit release after reset
	wire credit_release_out;
    reg [3: 0] counter;
    always @(posedge clk)begin 
    	if (reset) counter<=0;
    	else if(counter<WARMUP_DELAY) counter=counter+1'b1;    	
    end
    
    wire c_en = counter == WARMUP_DELAY;
    
	credit_release_gen #(
			.CREDIT_NUM  (B)
		) credit_release_gen (
			.clk         (clk   ), 
			.reset       (reset ), 
			.en          (c_en  ), //TODO should be taken as input port 
			.credit_out  (credit_release_out )
		);

	assign   tx_snp.lcrd_v = forth_credit_incr | credit_release_out;
	

	//synthesis translate_off 
	//synopsys  translate_off
	always @ (posedge clk) begin  
		if((target_ids_in == 24'd0) &  tx_snp.flit_v==1'b1) begin 
			$display("%t:Error: hnf (%d) snoop target_ids_in is zero while flit_v is asserted",$time,src_id);
			$stop;
		end	
	end
    
   

    //synopsys  translate_on
    //synthesis translate_on 
    
    
endmodule

