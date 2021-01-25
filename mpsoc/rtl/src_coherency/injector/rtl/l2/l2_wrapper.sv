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
* Horizon 2020 Grant Agreement and the terms and conditions of MontBlanc 2020
* Consortium Agreement under which the program(s) have been distributed. Unless
* required by applicable law or agreed in writing, the program(s) is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied.
*-------------------------------------------------------------------------------
*   Author:         Jordi Cortina
*   Email:          jordi.cortina@semidynamics.com
*   Date:           25/01/2019
*-------------------------------------------------------------------------------
*   Title:          L2 Wrapper
*   Description:
*
*   Release Notes:
*-----------------------------------------------------------------------------*/
module l2_wrapper #(
    parameter DATA_W            = 256                                       ,
              ADDR_W            = 39                                        ,
              NOC_RSP_PKT_W     = 100                                       ,
              SP_OPC_W          = 5                                         ,
              L1_OPC_W          = 3                                         ,
              L2_ST_W           = 2                                         ,
              TIM_PTR_W         = 6                                         ,
              PTBL_DEPTH        = 32                                        ,
              L2_INDEX_W        = 13                                        ,
              RET_2_SRC_W       = 1                                         ,
              NUM_OF_BANKS      = 4                                         ,
              BANK_ADDR_LSB_BIT = 6                                         ,
              COMP_BIT          = 1 /* COMP RESPONSE INDICATOR */           ,
              L2_WAYS           = 4                                         ,
              L2_SIZE           = 2048                                      ,
              L2_LOGWAYS        = 2                                         ,

              TBL_ID_W          = $clog2(PTBL_DEPTH)                        ,
              L1_REQ_W          = TIM_PTR_W   + ADDR_W   + L1_OPC_W         ,   // 48 bits
              FL_REQ_W          = COMP_BIT    + L2_ST_W  + TBL_ID_W         ,   // 8 bits
              SP_REQ_W          = RET_2_SRC_W + TBL_ID_W + ADDR_W + SP_OPC_W,   // 50 bits

              BANK_ADDR_W       = $clog2(NUM_OF_BANKS)                      ,
              NOC_PLUS_BANK_W   = NOC_RSP_PKT_W + BANK_ADDR_W               ,   // Adding extra bits for bank addressing
              FLL_PLUS_BANK_W   = FL_REQ_W      + BANK_ADDR_W                   // so a fill can be muxed accordingly to the
)(                                                                              // right bank.
    // Clock and Reset
    input   logic                       clk                         ,
    input   logic                       rst_n                       ,
    // L1 Request Queue
    input   logic                       l1_q_push_i                 ,
    input   logic [L1_REQ_W-1:0]        l1_q_data_i                 ,
    output  logic                       l1_q_full_o                 ,
    // L1 Response
    output  logic [TIM_PTR_W-1:0]       l1_fill_ptr_o               ,
    output  logic                       l1_fill_val_o               ,
    output  logic                       l1_stx_ok_o                 ,
    // NoC Response Queue
    input   logic                       chi_noc_q_pop_i             ,
    output  logic                       chi_noc_q_empty_o           ,
    output  logic [NOC_PLUS_BANK_W-1:0] chi_noc_q_data_o            ,
    // Evict Queue
    input   logic                       chi_evt_q_pop_i             ,
    output  logic                       chi_evt_q_empty_o           ,
    output  logic                       chi_evt_q_af_o              ,
    output  logic [ADDR_W-1:0]          chi_evt_q_data_o            ,
    // To Fill Queue From CHI
    input   logic                       chi_fll_q_push_i            ,
    input   logic [FLL_PLUS_BANK_W-1:0] chi_fll_q_data_i            ,
    output  logic                       chi_fll_q_full_o            ,
    // To Snoop Queue From CHI
    input   logic                       chi_snp_q_val_i             ,
    input   logic [SP_REQ_W-1:0]        chi_snp_q_data_i            ,
    output  logic                       chi_snp_q_pull_o
);


    // Parameters
    /////////////////////////////////////

    localparam BANK_ADDR_MSB_BIT = BANK_ADDR_LSB_BIT+BANK_ADDR_W-1  ;

    // Logic Declaration 
    /////////////////////////////////////
    logic [ADDR_W-1:0]          l1_req_addr                         ;
    logic [NUM_OF_BANKS-1:0]    l1_addr_sel                         ;
    logic [NUM_OF_BANKS-1:0]    l1_q_push                           ;
    logic [NUM_OF_BANKS-1:0]    l1_q_full                           ;
    logic [NUM_OF_BANKS-1:0]    l1_fll_q_empty                      ;
    logic [NUM_OF_BANKS-1:0]    l1_fll_q_pop                        ;
    logic [TIM_PTR_W-1:0]       l1_fll_q_ptr    [NUM_OF_BANKS-1:0]  ;
    logic [NUM_OF_BANKS-1:0]    l1_stx_ok                           ;

    logic [NUM_OF_BANKS-1:0]    chi_noc_q_empty                     ;
    logic [NUM_OF_BANKS-1:0]    chi_noc_q_pop                       ;
    logic [NOC_RSP_PKT_W-1:0]   chi_noc_q_data  [NUM_OF_BANKS-1:0]  ;

    logic [NUM_OF_BANKS-1:0]    chi_evt_q_empty                     ;
    logic [NUM_OF_BANKS-1:0]    chi_evt_q_af                        ;
    logic [NUM_OF_BANKS-1:0]    chi_evt_q_pop                       ;
    logic [ADDR_W-1:0]          chi_evt_q_data  [NUM_OF_BANKS-1:0]  ;

    logic [NUM_OF_BANKS-1:0]    fll_addr_sel                        ;
    logic [NUM_OF_BANKS-1:0]    fll_q_push                          ;
    logic [NUM_OF_BANKS-1:0]    fll_q_full                          ;

    logic [NUM_OF_BANKS-1:0]    snp_addr_sel                        ;
    logic [ADDR_W-1:0]          snp_req_addr                        ;
    logic [NUM_OF_BANKS-1:0]    snp_q_val                           ;
    logic [NUM_OF_BANKS-1:0]    chi_snp_pull                        ;


    // Implementation
    /////////////////////////////////////
    genvar i;
    generate 
        for (i=0; i<NUM_OF_BANKS; i++) begin : l2_single_bank
            
            l2_sb_wrapper #(
                .DATA_W                         ( DATA_W                                            ),
                .ADDR_W                         ( ADDR_W                                            ),
                .NOC_RSP_PKT_W                  ( NOC_RSP_PKT_W                                     ),
                .SP_OPC_W                       ( SP_OPC_W                                          ),
                .L1_OPC_W                       ( L1_OPC_W                                          ),
                .L2_ST_W                        ( L2_ST_W                                           ),
                .TIM_PTR_W                      ( TIM_PTR_W                                         ),
                .PTBL_DEPTH                     ( PTBL_DEPTH                                        ),
                .RET_2_SRC_W                    ( RET_2_SRC_W                                       ),
                .BANK_ADDR_LSB_BIT              ( BANK_ADDR_LSB_BIT                                 ),
                .BANK_ADDR_MSB_BIT              ( BANK_ADDR_MSB_BIT                                 ),
                .L2_WAYS                        ( L2_WAYS                                           ),
                .L2_SIZE                        ( L2_SIZE                                           ),
                .L2_LOGWAYS                     ( L2_LOGWAYS                                        )
            ) i_l2_sb_wrapper (
                .clk                            ( clk                                               ),
                .rst_n                          ( rst_n                                             ),
                // To L2 Snoop Channel
                .chi_snp_val_i                  ( snp_q_val[i]                                      ),
                .chi_snp_data_i                 ( chi_snp_q_data_i                                  ),
                .chi_snp_pull_o                 ( chi_snp_pull[i]                                   ),
                // To L2 Fill Channel
                .chi_fll_q_push_i               ( fll_q_push[i]                                     ),
                .chi_fll_q_data_i               ( chi_fll_q_data_i[FLL_PLUS_BANK_W-1:BANK_ADDR_W]   ),
                .chi_fll_q_full_o               ( fll_q_full[i]                                     ),
                // L1 to L2 Request Queue
                .l1_q_push_i                    ( l1_q_push[i]                                      ),
                .l1_q_data_i                    ( l1_q_data_i                                       ),
                .l1_q_full_o                    ( l1_q_full[i]                                      ),
                // L2 to L1 Fill Queue
                .l1_fll_q_pop_i                 ( l1_fll_q_pop[i]                                   ),
                .l1_fll_q_empty_o               ( l1_fll_q_empty[i]                                 ),
                .l1_fll_q_ptr_o                 ( l1_fll_q_ptr[i]                                   ),
                .l1_stx_ok_o                    ( l1_stx_ok[i]                                      ),
                // To CHI NoC Request Channel
                .chi_noc_q_pop_i                ( chi_noc_q_pop[i]                                  ),
                .chi_noc_q_empty_o              ( chi_noc_q_empty[i]                                ),
                .chi_noc_q_data_o               ( chi_noc_q_data[i]                                 ),
                // Evict Queue To CHI
                .chi_evt_q_pop_i                ( chi_evt_q_pop[i]                                  ),
                .chi_evt_q_empty_o              ( chi_evt_q_empty[i]                                ),
                .chi_evt_q_af_o                 ( chi_evt_q_af[i]                                   ),
                .chi_evt_q_data_o               ( chi_evt_q_data[i]                                 )
            );

        end
    endgenerate



    // L1 Arbiting
    //################################################################

    assign l1_req_addr = l1_q_data_i[L1_OPC_W+:ADDR_W];

    // Bank Address Decoding
    assign l1_addr_sel  = 1'b1 << l1_req_addr[BANK_ADDR_MSB_BIT:BANK_ADDR_LSB_BIT];

    assign l1_q_push    = (l1_addr_sel & {NUM_OF_BANKS{l1_q_push_i}});
    assign l1_q_full_o  = &l1_q_full;


    // L1 Fill Round Robin Arbiter
    psd_rr_arb #(
        .DEPTH      ( NUM_OF_BANKS      )
    ) i_l1_psd_rr_arb (
        .clk        ( clk               ),
        .rst_n      ( rst_n             ),
        .enable_i   ( 1'b1              ),
        .valid_i    ( ~l1_fll_q_empty   ),
        .sel_o      ( l1_fll_q_pop      )
    );

    assign l1_fill_val_o = |l1_fll_q_pop;
    assign l1_stx_ok_o   = |l1_stx_ok   ;

        
    // L1 Ptr Fill bus mux
    always_comb begin
        l1_fill_ptr_o = {TIM_PTR_W{1'b0}};
        for (int i=0; i<NUM_OF_BANKS; i++) begin
            if (l1_fll_q_pop[i]) begin
                l1_fill_ptr_o = l1_fll_q_ptr[i];
            end
        end
    end


    // NoC Req Arbiting
    //################################################################

    psd_rr_arb #(
        .DEPTH      ( NUM_OF_BANKS      )
    ) i_noc_psd_rr_arb (
        .clk        ( clk               ),
        .rst_n      ( rst_n             ),
        .enable_i   ( chi_noc_q_pop_i   ),
        .valid_i    ( ~chi_noc_q_empty  ),
        .sel_o      ( chi_noc_q_pop     )
    );

    assign chi_noc_q_empty_o = &chi_noc_q_empty;

    // NoC Req bus mux
    always_comb begin
        chi_noc_q_data_o = {NOC_PLUS_BANK_W{1'b0}};
        for (int i=0; i<NUM_OF_BANKS; i++) begin
            if (chi_noc_q_pop[i]) begin
                chi_noc_q_data_o = {chi_noc_q_data[i],i[0+:BANK_ADDR_W]}; // Adding BANK ID, so when a fill
            end                                                           // comes back, it can be correctly
        end                                                               // muxed into the right bank.
    end


    // Evict Queue Arbiting
    //################################################################

    psd_rr_arb #(
        .DEPTH      ( NUM_OF_BANKS      )
    ) i_evt_psd_rr_arb (
        .clk        ( clk               ),
        .rst_n      ( rst_n             ),
        .enable_i   ( chi_evt_q_pop_i   ),
        .valid_i    ( ~chi_evt_q_empty  ),
        .sel_o      ( chi_evt_q_pop     )
    );

    assign chi_evt_q_empty_o = &chi_evt_q_empty;

    // evt Req bus mux
    always_comb begin
        chi_evt_q_data_o = {ADDR_W{1'b0}};
        for (int i=0; i<NUM_OF_BANKS; i++) begin
            if (chi_evt_q_pop[i]) begin
                chi_evt_q_data_o = chi_evt_q_data[i] | {i,{BANK_ADDR_LSB_BIT{1'b0}}};
            end
        end
    end

    // Evict Queue high occupancy flag
    assign chi_evt_q_af_o = |chi_evt_q_af;


    // Fill Queue Arbiting
    //################################################################

    // Bank Address Decoding
    assign fll_addr_sel     = 1'b1 << chi_fll_q_data_i[0+:BANK_ADDR_W];
    assign fll_q_push       = (fll_addr_sel & {NUM_OF_BANKS{chi_fll_q_push_i}});
    assign chi_fll_q_full_o = |fll_q_full;


    // Snoop Queue Arbiting
    //################################################################

    // Bank Address Decoding
    assign snp_req_addr     = chi_snp_q_data_i[SP_OPC_W+:ADDR_W];
    assign snp_addr_sel     = 1'b1 << snp_req_addr[BANK_ADDR_MSB_BIT:BANK_ADDR_LSB_BIT];
    assign snp_q_val        = (snp_addr_sel & {NUM_OF_BANKS{chi_snp_q_val_i}});
    assign chi_snp_q_pull_o = |chi_snp_pull;


endmodule : l2_wrapper
