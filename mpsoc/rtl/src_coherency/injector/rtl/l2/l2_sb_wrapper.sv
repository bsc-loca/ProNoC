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
*   Date:           11/12/2018
*-------------------------------------------------------------------------------
*   Title:          L2 Single Bank Wrapper
*   Description:    Instantiates the main L2 blocks:
*                   L2, L2 Controller and Queues.
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module l2_sb_wrapper #(
    parameter DATA_W            = 256                                           ,
              ADDR_W            = 39                                            ,
              NOC_RSP_PKT_W     = 100                                           ,
              SP_OPC_W          = 5                                             ,
              L1_OPC_W          = 3                                             ,
              L2_ST_W           = 2                                             ,
              TIM_PTR_W         = 6                                             ,
              PTBL_DEPTH        = 32                                            ,
              RET_2_SRC_W       = 1                                             ,
              BANK_ADDR_LSB_BIT = 6                                             ,
              BANK_ADDR_MSB_BIT = 7                                             ,
              L2_WAYS           = 4                                             ,
              L2_SIZE           = 2048                                          ,
              L2_LOGWAYS        = 2                                             ,

              COMP_BIT          = 1 /* COMP RESPONSE INDICATOR */               ,
              TBL_ID_W          = $clog2(PTBL_DEPTH)                            ,
              L1_REQ_W          = TIM_PTR_W   + ADDR_W   + L1_OPC_W             ,   // 48 bits
              FL_REQ_W          = COMP_BIT    + L2_ST_W  + TBL_ID_W             ,   // 41 bits
              SP_REQ_W          = RET_2_SRC_W + TBL_ID_W + ADDR_W   + SP_OPC_W      // 50 bits
)(
    // Clock and Reset
    input   logic                       clk                     ,
    input   logic                       rst_n                   ,
    // To Snoop Queue From CHI
    input   logic                       chi_snp_val_i           ,
    input   logic [SP_REQ_W-1:0]        chi_snp_data_i          ,
    output  logic                       chi_snp_pull_o          ,
    // To Fill Queue From CHI
    input   logic                       chi_fll_q_push_i        ,
    input   logic [FL_REQ_W-1:0]        chi_fll_q_data_i        ,
    output  logic                       chi_fll_q_full_o        ,
    // L1 Request Queue
    input   logic                       l1_q_push_i             ,
    input   logic [L1_REQ_W-1:0]        l1_q_data_i             ,
    output  logic                       l1_q_full_o             ,
    // L1 Response
    input   logic                       l1_fll_q_pop_i          ,
    output  logic                       l1_fll_q_empty_o        ,
    output  logic [TIM_PTR_W-1:0]       l1_fll_q_ptr_o          ,
    output  logic                       l1_stx_ok_o             ,
    // NoC Response Queue
    input   logic                       chi_noc_q_pop_i         ,
    output  logic                       chi_noc_q_empty_o       ,
    output  logic [NOC_RSP_PKT_W-1:0]   chi_noc_q_data_o        ,
    // Evict Queue
    input   logic                       chi_evt_q_pop_i         ,
    output  logic                       chi_evt_q_empty_o       ,
    output  logic                       chi_evt_q_af_o          ,
    output  logic [ADDR_W-1:0]          chi_evt_q_data_o
);


    // Parameters
    /////////////////////////////////////
    localparam L2_INDEX_W = $clog2(L2_SIZE);


    // Logic Declaration 
    /////////////////////////////////////

    // L2 Wires
    logic [L2_ST_W-1:0]         l2_s2_cst       ;
    logic [L2_INDEX_W-1:0]      l2_s2_index     ;
    logic                       l2_s2_blocked   ;
    logic [ADDR_W-1:0]          l2_s2_ev_addr   ;
    logic                       l2_s2_ev_val    ;
    logic [ADDR_W-1:0]          l2_s2_address   ,
                                l2_s2_b_address ;
    logic                       l2_s2_valid     ;
    logic                       l2_s2_miss      ;
    logic                       l2_s2_evict     ;
    logic                       l2_s2_fill      ;
    logic [L2_INDEX_W-1:0]      l2_s3_index     ;
    logic [L2_ST_W-1:0]         l2_s3_nst       ;
    logic                       l2_s3_valid     ;
    logic                       l2_s3_snoop     ;

    // Fill Request Queue wires
    logic                       fll_q_pull      ;
    logic [FL_REQ_W-1:0]        fll_q_data      ;
    logic                       fll_q_empty     ;

    // L1 Request Queue wires
    logic                       l1_q_pull       ;
    logic [L1_REQ_W-1:0]        l1_q_data       ;
    logic                       l1_q_empty      ;
    logic                       l1_fill_val     ;
    logic [TIM_PTR_W-1:0]       l1_fill_ptr     ;

    // NoC Response Queue wires
    logic                       noc_q_push      ;
    logic [NOC_RSP_PKT_W-1:0]   noc_q_data      ;
    logic                       noc_q_full      ;

    // Evict Queue wires
    logic                       evt_q_push      ;
    logic [ADDR_W-1:0]          evt_q_data_i    ;

    // LP Monitor wires
    logic                       lp_stx_ok       ;
    logic [ADDR_W-1:0]          lp_addr         ;
    logic                       lp_ldx          ;
    logic                       lp_stx          ;
    logic                       lp_fill_stx     ;
    logic                       lp_fill         ;
    logic                       lp_snp          ;
    logic [L2_ST_W-1:0]         lp_l2_st        ;
    logic                       lp_stx_req_ack  ;
    logic                       lp_stx_req_val  ;
    logic [L1_REQ_W-1:0]        lp_stx_req_data ;

    // Implementation
    /////////////////////////////////////


    /*___L2 Controller Instance___*/
    l2_ctrl #(
        .DATA_W             ( DATA_W            ),
        .ADDR_W             ( ADDR_W            ),
        .NOC_RSP_PKT_W      ( NOC_RSP_PKT_W     ),
        .SP_OPC_W           ( SP_OPC_W          ),
        .L1_OPC_W           ( L1_OPC_W          ),
        .L2_ST_W            ( L2_ST_W           ),
        .TIM_PTR_W          ( TIM_PTR_W         ),
        .PTBL_DEPTH         ( PTBL_DEPTH        ),
        .L2_INDEX_W         ( L2_INDEX_W        ),
        .L1_REQ_W           ( L1_REQ_W          ),
        .FL_REQ_W           ( FL_REQ_W          ),
        .SP_REQ_W           ( SP_REQ_W          )
    ) i_l2_ctrl (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        // L1 Request Queue
        .l1_req_i           ( l1_q_data         ),
        .l1_req_val_i       ( ~l1_q_empty       ),
        .l1_req_pull_o      ( l1_q_pull         ),
        .l1_fill_ptr_o      ( l1_fill_ptr       ),
        .l1_fill_val_o      ( l1_fill_val       ),
        .l1_stx_ok_o        ( l1_stx_ok_o       ),
        // Snoop Request Queue
        .sp_req_i           ( chi_snp_data_i    ),
        .sp_req_val_i       ( chi_snp_val_i     ),
        .sp_req_pull_o      ( chi_snp_pull_o    ),
        // Fill Queue
        .fl_req_i           ( fll_q_data        ),
        .fl_req_val_i       ( ~fll_q_empty      ),
        .fl_req_pull_o      ( fll_q_pull        ),
        // L2
        .l2_s2_cst_i        ( l2_s2_cst         ),
        .l2_s2_index_i      ( l2_s2_index       ),
        .l2_s2_blocked_i    ( l2_s2_blocked     ),
        .l2_s2_ev_addr_i    ( l2_s2_ev_addr     ),
        .l2_s2_ev_val_i     ( l2_s2_ev_val      ),
        .l2_s2_address_o    ( l2_s2_address     ),
        .l2_s2_valid_o      ( l2_s2_valid       ),
        .l2_s2_miss_o       ( l2_s2_miss        ),
        .l2_s2_evict_o      ( l2_s2_evict       ),
        .l2_s2_fill_o       ( l2_s2_fill        ),
        .l2_s3_index_o      ( l2_s3_index       ),
        .l2_s3_nst_o        ( l2_s3_nst         ),
        .l2_s3_valid_o      ( l2_s3_valid       ),
        .l2_s3_snoop_o      ( l2_s3_snoop       ),
        // NoC Queue
        .noc_s2_q_full_i    ( noc_q_full        ),
        .noc_s3_rsp_o       ( noc_q_data        ),
        .noc_s3_rsp_val_o   ( noc_q_push        ),
        // Evict Queue
        .evict_s3_rsp_o     ( evt_q_data_i      ),
        .evict_s3_val_o     ( evt_q_push        ),
        // LP Monitor
        .lp_stx_ok_i        ( lp_stx_ok         ),
        .lp_addr_o          ( lp_addr           ),
        .lp_ldx_o           ( lp_ldx            ),
        .lp_stx_o           ( lp_stx            ),
        .lp_line_is_stx_o   ( lp_fill_stx       ),
        .lp_fill_o          ( lp_fill           ),
        .lp_snp_o           ( lp_snp            ),
        .lp_l2_st_o         ( lp_l2_st          ),
        .lp_stx_req_ack_o   ( lp_stx_req_ack    ),
        .lp_stx_req_val_i   ( lp_stx_req_val    ),
        .lp_stx_req_data_i  ( lp_stx_req_data   )

    ); // l2_ctrl_i


    /*_________L2 Instance________*/
    l2 #(
        .WAYS               ( 4                 ),
        .SIZE               ( 2048              ),
        .LOGWAYS            ( 2                 )
    ) i_l2 (
        .clk                ( clk               ),             
        .rst_n              ( rst_n             ),           
        .s2_l2_address      ( l2_s2_b_address   ),
        .s2_l2_valid        ( l2_s2_valid       ),
        .s2_l2_miss         ( l2_s2_miss        ),
        .s2_l2_evict        ( l2_s2_evict       ),
        .s2_l2_fill         ( l2_s2_fill        ),
        .s3_l2_new_state    ( l2_s3_nst         ),
        .s3_l2_valid        ( l2_s3_valid       ),
        .s3_l2_index        ( l2_s3_index       ),
        .s3_l2_snoop        ( l2_s3_snoop       ),
        .s2_l2_state        ( l2_s2_cst         ),
        .s2_l2_index        ( l2_s2_index       ),
        .s2_l2_evict_addr   ( l2_s2_ev_addr     ),
        .s2_l2_evict_valid  ( l2_s2_ev_val      ),
        .s2_l2_wrong_evict  ( /* temp unconn */ ),
        .s2_l2_blocked      ( l2_s2_blocked     )
    );

    assign l2_s2_b_address = {2'b00, l2_s2_address[ADDR_W-1:BANK_ADDR_MSB_BIT+1], l2_s2_address[BANK_ADDR_LSB_BIT-1:0]};


    /*_________L1 Response________*/
    sync_ff_fifo #(
        .DATA_W             ( TIM_PTR_W         ),
        .FIFO_DEPTH         ( 32                )
    ) i_snp_q (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        .push_i             ( l1_fill_val       ),
        .pop_i              ( l1_fll_q_pop_i    ),
        .data_i             ( l1_fill_ptr       ),
        .data_o             ( l1_fll_q_ptr_o    ),
        .full_o             ( /* not used yet */),
        .empty_o            ( l1_fll_q_empty_o  ),
        .af_o               ( /* no af flag */  ),
        .ae_o               ( /*  not used  */  )
    );


    /*_____Fill Request Queue_____*/
    sync_ff_fifo #(
        .DATA_W             ( FL_REQ_W          ),
        .FIFO_DEPTH         ( 32                )
    ) i_fll_q (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        .push_i             ( chi_fll_q_push_i  ),
        .pop_i              ( fll_q_pull        ),
        .data_i             ( chi_fll_q_data_i  ),
        .data_o             ( fll_q_data        ),
        .full_o             ( chi_fll_q_full_o  ),
        .empty_o            ( fll_q_empty       ),
        .af_o               ( /* no af flag */  ),
        .ae_o               ( /*  not used  */  )
    );


    /*______L1 Request Queue______*/
    sync_ff_fifo #(
        .DATA_W             ( L1_REQ_W          ),
        .FIFO_DEPTH         ( 32                )
    ) i_l1_q (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        .push_i             ( l1_q_push_i       ),
        .pop_i              ( l1_q_pull         ),
        .data_i             ( l1_q_data_i       ),
        .data_o             ( l1_q_data         ),
        .full_o             ( l1_q_full_o       ),
        .empty_o            ( l1_q_empty        ),
        .af_o               ( /* no af flag */  ),
        .ae_o               ( /*  not used  */  )
    );


    /*_____NoC Response Queue_____*/
    sync_ff_fifo #(
        .DATA_W             ( NOC_RSP_PKT_W     ),
        .FIFO_DEPTH         ( 32                ),
        .AF_FLAG_LIM        ( 30                )
    ) i_noc_q (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        .push_i             ( noc_q_push        ),
        .pop_i              ( chi_noc_q_pop_i   ),
        .data_i             ( noc_q_data        ),
        .data_o             ( chi_noc_q_data_o  ),
        .full_o             ( /*  not used  */  ),
        .empty_o            ( chi_noc_q_empty_o ),
        .af_o               ( noc_q_full        ),
        .ae_o               ( /*  not used  */  )
    );


    /*_____Evict Response Queue_____*/
    sync_ff_fifo #(
        .DATA_W             ( ADDR_W            ),
        .FIFO_DEPTH         ( 32                ),
        .AF_FLAG_LIM        ( 30                )
    ) i_evict_q (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        .push_i             ( evt_q_push        ),
        .pop_i              ( chi_evt_q_pop_i   ),
        .data_i             ( evt_q_data_i      ),
        .data_o             ( chi_evt_q_data_o  ),
        .full_o             ( /* won't fill */  ),
        .empty_o            ( chi_evt_q_empty_o ),
        .af_o               ( chi_evt_q_af_o    ),
        .ae_o               ( /*  not used  */  )
    );

        
    /*_____LP Monitor_____*/
    lp_monitor #(
        .ADDR_W             ( ADDR_W            ),
        .L1_REQ_W           ( L1_REQ_W          )
    ) i_lp_monitor (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        .s2_addr_i          ( lp_addr           ),
        .s2_ldx_i           ( lp_ldx            ),
        .s2_stx_i           ( lp_stx            ),
        .s2_fill_i          ( lp_fill           ),
        .s2_snp_i           ( lp_snp            ),
        .stx_req_ack_i      ( lp_stx_req_ack    ),
        .stx_req_val_o      ( lp_stx_req_val    ),
        .stx_req_data_o     ( lp_stx_req_data   ),
        .s2_l2_st_i         ( lp_l2_st          ),
        .fill_stx_i         ( lp_fill_stx       ),
        .s3_stx_ok_o        ( lp_stx_ok         )
    );


endmodule : l2_sb_wrapper
