/*------------------------------------------------------------------------------
* Copyright (C) 2018, 2019, SemiDynamics Technology Services, S.L.U.
* The copyright to the computer program(s) herein is the property of
* SemiDynamics Technology Services, S.L.U. All Rights Reserved.  NOTICE: the
* intellectual and technical concepts contained herein are proprietary to
* SemiDynamics Technology Services, S.L.U. and are protected by trade secret or
* copyright law.  Dissemination of this information and use or reproduction of
* this material is strictly forbidden unless prior written permission is
* obtained from SemiDynamics Technology Services, S.L.U. The program(s) may be
* used and/or reproduced only with the written permission of SemiDynamics
* Technology Services, S.L.U. and in accordance with the regulations under the
* Horizon 2020 Grant Agreement and the terms and conditions of MontBlanc 2020/EPI
* Consortium Agreement under which the program(s) have been distributed. Unless
* required by applicable law or agreed in writing, the program(s) is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied.
*-------------------------------------------------------------------------------
*   Author:         Alberto Moreno/Sebastiano Pomata
*   Email:          alberto.moreno@semidynamics.com
*   Date:           28/11/2019
*-------------------------------------------------------------------------------
*   Title:          Avispado top level
*   Description:    contains Avispado and VPU wrapper
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module avispado
    import vpu_pkg::*;
    import avispado_chi_defs_pkg::*;
    import avispado_pkg::MEMORY_MAP_SIZE;
    import avispado_pkg::memory_map_t;
#(
    parameter int          USE_DUALPORT_IDATA_12LP  = 0                 ,
    parameter logic        MATCH_SPIKE_CYCLE_COUNT  = 1'b0              , // force matching of cycle counter
    parameter              NOC_INITS_CRED           = 1                 , // CHI RN-F credits handshake with NoC
    parameter logic [63:0] DmBaseAddress            = 64'h0             , // debug module base address
    parameter bit          SwapEndianess            = 0                 , // swap endianess in l15 adapter
    parameter logic [63:0] CachedAddrEnd            = 64'h80_0000_0000  , // end of cached region
    parameter logic [63:0] CachedAddrBeg            = 64'h00_8000_0000    // begin of cached region
) (
    input  logic                                    clk_i               ,
    input  logic                                    rst_ni              ,
    // Core ID, Cluster ID and boot address are considered more or less static
    input  logic [         63:0]                    boot_addr_i         , // reset boot address
    input  logic [         63:0]                    hart_id_i           , // hart id in a multicore environment (reflected in a CSR)
    // Interrupt inputs
    input  logic [          1:0]                    irq_i               , // level sensitive IR lines, mip & sip (async)
    input  logic                                    ipi_i               , // inter-processor interrupts (async)
    // Timer facilities
    input  logic                                    time_irq_i          , // timer interrupt in (async)
    input  logic                                    debug_req_i         , // debug request (async)
    input  logic                                    kick_core_i         ,
    input  logic                                    vpu_en_i            ,
    input  memory_map_t [MEMORY_MAP_SIZE-1:0]       memory_map_i        , //Programable PMA memory map
    // CHI NoC Interface
    chi_req_chan.tx                                 chi_tx_req          ,
    chi_rsp_chan.tx                                 chi_tx_rsp          ,
    chi_dat_chan.tx                                 chi_tx_dat          ,
    chi_rsp_chan.rx                                 chi_rx_rsp          ,
    chi_dat_chan.rx                                 chi_rx_dat          ,
    chi_snp_chan.rx                                 chi_rx_snp          ,
    // AXI4 Lite Interface
    output  axi_lite_pkg::req_lite_t                axi_lite_req_o      ,
    input   axi_lite_pkg::resp_lite_t               axi_lite_resp_i     ,
    
    input  logic [TGTID_REQ-1:0]                    sam_target_id_i     ,
    input  logic [SRCID_REQ-1:0]                    source_id_i         ,
    output logic [ ADDR_REQ-1:0]                    sam_target_address_o
);

    // VPU
    avispado_vpu_ports_t   avispado_vpu   ;
    vpu_avispado_ports_t   vpu_avispado   ;

    //-----------------------------
    // Instantiates Avispado Core
    //-----------------------------
    avispado_core #(
        .USE_DUALPORT_IDATA_12LP(USE_DUALPORT_IDATA_12LP),
        .MATCH_SPIKE_CYCLE_COUNT(MATCH_SPIKE_CYCLE_COUNT),
        .NOC_INITS_CRED         (NOC_INITS_CRED         ),
        .SwapEndianess          (SwapEndianess          ),
        .CachedAddrEnd          (CachedAddrEnd          ),
        .CachedAddrBeg          (CachedAddrBeg          ),
        .DmBaseAddress          (DmBaseAddress          )
    ) i_avispado_core (
        .clk_i               (clk_i               ),
        .rst_ni              (rst_ni              ),
        .boot_addr_i         (boot_addr_i         ), // start fetching from RAM
        .hart_id_i           (hart_id_i           ),
        .irq_i               (irq_i               ),
        .ipi_i               (ipi_i               ),
        .time_irq_i          (time_irq_i          ),
        .debug_req_i         (debug_req_i         ),
        .kick_core_i         (kick_core_i         ),
        .vpu_en_i            (vpu_en_i            ),
        .memory_map_i        (memory_map_i        ),
        .chi_tx_req          (chi_tx_req          ),
        .chi_tx_rsp          (chi_tx_rsp          ),
        .chi_tx_dat          (chi_tx_dat          ),
        .chi_rx_rsp          (chi_rx_rsp          ),
        .chi_rx_dat          (chi_rx_dat          ),
        .chi_rx_snp          (chi_rx_snp          ),
        .sam_target_id_i     (sam_target_id_i     ),
        .source_id_i         (source_id_i         ),
        .sam_target_address_o(sam_target_address_o),
        `ifdef AVISPADO_ENV_BSC_VPU
          .vpu_ports_o         (avispado_vpu        ),
          .vpu_ports_i         (vpu_avispado        ),
        `else
          .vpu_ports_o         (avispado_vpu        ),
          .vpu_ports_i         (vpu_avispado        ),
        `endif
        .axi_lite_req_o      (axi_lite_req_o      ),
        .axi_lite_resp_i     (axi_lite_resp_i     )
    );

      //---------------
      // VPU wrapper
      //---------------
    `ifdef AVISPADO_ENV_BSC_VPU
      bsc_vpu_wrapper i_vpu_wrapper (
          .clk_i      (clk_i        ),
          .rst_ni     (rst_ni       ),
          .vpu_ports_i(avispado_vpu ),
          .vpu_ports_o(vpu_avispado )
      );
    `elsif AVISPADO_ENV_FAKE_VPU
      vpu_wrapper i_vpu_wrapper (
          .clk_i      (clk_i        ),
          .rst_ni     (rst_ni       ),
          .vpu_ports_i(avispado_vpu ),
          .vpu_ports_o(vpu_avispado )
      );
    `endif
	wire check_i=1'b0;
	simple_test test	(
		.check_i(check_i),
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		
		.chi_tx_req(chi_tx_req),
		.chi_tx_rsp(chi_tx_rsp),
		.chi_tx_dat(chi_tx_dat),
		.chi_rx_rsp(chi_rx_rsp),
		.chi_rx_dat(chi_rx_dat),
		.chi_rx_snp(chi_rx_snp),
		
		.vpu_ports_i(avispado_vpu),
		.vpu_ports_o(vpu_avispado )
		
	);

endmodule


module simple_test
	import vpu_pkg::*;
	import avispado_chi_defs_pkg::*;
	import avispado_pkg::MEMORY_MAP_SIZE;
	import avispado_pkg::memory_map_t;
	(
		input check_i,
		input clk_i,
		input rst_ni,
		
		chi_req_chan.rx                                 chi_tx_req,
		chi_rsp_chan.rx                                 chi_tx_rsp,
		chi_dat_chan.rx                                 chi_tx_dat,

		chi_rsp_chan.rx                                 chi_rx_rsp,
		chi_dat_chan.rx                                 chi_rx_dat,
		chi_snp_chan.rx                                 chi_rx_snp,
		
		input  avispado_vpu_ports_t             vpu_ports_i,
		input vpu_avispado_ports_t             vpu_ports_o
		
	);
	
	
	issue_t    issue_vpu;
	dispatch_t dispatch_vpu;
	memop_t    memop_vpu;
	load_t     load_vpu;
	logic      mask_credit_vpu;
	logic      store_credit_vpu;

	logic      issue_credit_vpu;
	logic      memop_sync_start_vpu;
	mask_idx_t mask_idx_vpu;
	store_t    store_vpu;
	complete_t complete_vpu;
	
	
	assign issue_credit_vpu =  vpu_ports_o.issue_credit_vpu;
	assign memop_sync_start_vpu = vpu_ports_o.memop_sync_start_vpu;
	assign mask_idx_vpu = vpu_ports_o.mask_idx_vpu;
	assign store_vpu = vpu_ports_o.store_vpu;
	assign complete_vpu = vpu_ports_o.complete_vpu;

	assign issue_vpu = vpu_ports_i.issue_vpu;
	assign dispatch_vpu = vpu_ports_i.dispatch_vpu;
	assign memop_vpu = vpu_ports_i.memop_vpu;
	assign load_vpu = vpu_ports_i.load_vpu;
	assign mask_credit_vpu = vpu_ports_i.mask_credit_vpu;
	assign store_credit_vpu  = vpu_ports_i.store_credit_vpu;
	
	reg [31: 0] inst_valid [100: 0];
	reg [31: 0] comp_valid [100: 0];

	reg reported;
	genvar i;
	generate
		for (i=0;i<100; i=i+1) begin :ii
			always @(posedge clk_i) begin 
				if(rst_ni == 1'b0) begin 
					inst_valid[i]<=0;
					comp_valid[i]<=0; 
					
				end else begin
					if((i==issue_vpu.sb_id) && (issue_vpu.valid==1 )) inst_valid[i]<=inst_valid[i]+1;
					if(
((i==complete_vpu.sb_id) && (complete_vpu.valid==1))  || ((i==dispatch_vpu.sb_id) && (dispatch_vpu.kill==1)) 
) comp_valid[i]<=comp_valid[i]+1;	
								
					if(check_i==1'b1 && reported==1'b0) begin 
						if(inst_valid[i] != 	comp_valid[i]) begin 
							$display("Error the number of issued instructions (%d) dosnt match with the completed and killed ones (%d) for sb_id %d",inst_valid[i],inst_valid[i], i);
						end else if (inst_valid[i]>0)begin 
							$display("matched %d\n",i);
						end
					end	//if
				end//else
			end//always
		end //for
	endgenerate

	always @ (posedge clk_i)begin 
		if(rst_ni == 1'b0) begin 
			reported<=1'b0;
		end else begin 
			if (check_i==1'b1) reported<=1'b1;
		end		
	end	
	


	
	req_flit_t tx_req_flit;
	logic  tx_req_flit_v;
	assign tx_req_flit = chi_tx_req.flit;
	assign tx_req_flit_v = chi_tx_req.flit_v;


	rsp_flit_t rx_rsp_flit;
	logic  rx_rsp_flit_v;
	assign rx_rsp_flit = chi_rx_rsp.flit;
	assign rx_rsp_flit_v = chi_rx_rsp.flit_v;

	data_flit_t rx_dat_flit;
	logic  rx_dat_flit_v;
	assign rx_dat_flit = chi_rx_dat.flit;
	assign rx_dat_flit_v = chi_rx_dat.flit_v;
	

	
	 reg [254: 0] txn_table;
		
				
         always @ (posedge clk_i) begin 
		 if (rst_ni == 1'b0) txn_table <= 255'd0;
		 if (tx_req_flit_v == 1'b1)begin 
			if (txn_table[tx_req_flit.txn_id]==1'b1) begin 
				$display("Error transaxion id %d is used while it was still active",tx_req_flit.txn_id);
				$stop;
			end
			txn_table[tx_req_flit.txn_id] <= 1'b1;
		 end
		 if (rx_rsp_flit_v) begin 
			if( (rx_rsp_flit.opcode == COMP )   || (rx_rsp_flit.opcode == COMP_DBID_RESP)) begin 
				if (txn_table[rx_rsp_flit.txn_id]==1'b0) begin 
				$display("Error got comp on invalid transaxion id %d",rx_rsp_flit.txn_id);
				$stop;
			end
			txn_table[rx_rsp_flit.txn_id] <= 1'b0;
			end
		end
		if (rx_dat_flit_v) begin 
			if(rx_dat_flit.opcode == COMP_DATA )begin 
				if (txn_table[rx_dat_flit.txn_id]==1'b0) begin 
				$display("Error got comp on invalid transaxion id %d",rx_dat_flit.txn_id);
				$stop;
			end
			txn_table[rx_dat_flit.txn_id] <= 1'b0;
			end
		end
                
		if(check_i==1'b1 && reported==1'b0) begin 
			if(txn_table == 255'd0) $display("Chi txn id is ok");
			else $display("Error : ollowing txn has not finished %b",txn_table);
		
		end 

	 end

        
	
endmodule
