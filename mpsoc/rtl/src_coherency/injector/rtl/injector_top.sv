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
*   Date:           06/06/2019
*-------------------------------------------------------------------------------
*   Title:          Injector Top
*   Description:    top block of the injector design
*
*   Release Notes:  Replaced fake_l2 with real L2
*-----------------------------------------------------------------------------*/
`ifdef INJECTOR_EXCLUDE_CHI_AGENT
module injector_top #(
    parameter DATA_W            = 256                               ,                                               
              ADDR_W            = 39                                ,                                               
              NOC_RSP_PKT_W     = 100                               ,                                               
              SP_OPC_W          = 5                                 ,                                               
              L1_OPC_W          = 3                                 ,                                               
              L2_ST_W           = 2                                 ,                                               
              TIM_PTR_W         = 6                                 ,                                               
              PTBL_DEPTH        = 32                                ,                                               
              L2_INDEX_W        = 13                                ,                                               
              RET_2_SRC_W       = 1                                 ,                                               
              NUM_OF_BANKS      = 4                                 ,                                               
              BANK_ADDR_LSB_BIT = 6                                 ,                                               
              COMP_BIT          = 1 /* COMP RESPONSE INDICATOR */   ,                                               
              L2_WAYS           = 4                                 ,                                               
              L2_SIZE           = 2048                              ,                                               
              L2_LOGWAYS        = 2                                 ,                                               
              WRAP_REQ_W        = 64                                ,
                                                                                                                    
              TBL_ID_W          = $clog2(PTBL_DEPTH)                ,                                               
              L1_REQ_W          = TIM_PTR_W   + ADDR_W   + L1_OPC_W ,   // 48 bits                                  
              FL_REQ_W          = COMP_BIT    + L2_ST_W  + TBL_ID_W ,   // 8  bits                                  
              SP_REQ_W          = RET_2_SRC_W + ADDR_W   + SP_OPC_W ,   // 50 bits
                                                                                                        
              BANK_ADDR_W       = $clog2(NUM_OF_BANKS)              ,                                               
              NOC_PLUS_BANK_W   = NOC_RSP_PKT_W + BANK_ADDR_W       ,   // Adding extra bits for bank addressing    
              FLL_PLUS_BANK_W   = FL_REQ_W      + BANK_ADDR_W           // so a fill can be muxed accordingly to the
)(                                                                      // right bank.                              
    input   logic                               clk                 ,
    input   logic                               rst_n               ,
    input   logic        [WRAP_REQ_W-1:0]       wrapreq             ,
    input   logic                               wrapreqvalid        ,
    output  logic                               tim_wrap_strobereq  ,

    // NoC Response Queue                                                    
    input   logic                               chi_noc_q_pop_i     ,
    output  logic                               chi_noc_q_empty_o   ,
    output  logic [NOC_PLUS_BANK_W-1:0]         chi_noc_q_data_o    ,
    // Evict Queue                                                   
    input   logic                               chi_evt_q_pop_i     ,
    output  logic                               chi_evt_q_empty_o   ,
    output  logic                               chi_evt_q_af_o      ,
    output  logic [ADDR_W-1:0]                  chi_evt_q_data_o    ,
    // To Fill Queue From CHI                                        
    input   logic                               chi_fll_q_push_i    ,
    input   logic [FLL_PLUS_BANK_W-1:0]         chi_fll_q_data_i    ,
    output  logic                               chi_fll_q_full_o    ,
    // To Snoop Queue From CHI                                       
    input   logic                               chi_snp_q_val_i     ,
    input   logic [SP_REQ_W-1:0]                chi_snp_q_data_i    ,
    output  logic                               chi_snp_q_pull_o             
);


    // Logic Declaration 
    /////////////////////////////////////

    logic                   wrapdone        ;

    logic [WRAP_REQ_W-1:0]  wrap_tim_req    ;
    logic                   tim_strobereq   ;


    // Implementation
    /////////////////////////////////////

    logic                   tim_reqvalid        ;
    logic [L1_REQ_W-1:0]    tim_req             ;
    logic [TIM_PTR_W-1:0]   l2_tim_fillptr      ;
    logic                   l2_tim_fillvalid    ;
    logic                   l2_tim_stxdone      ;
    logic                   l2_tim_reqqnocredits;
    
    // TIM Instance
    tim tim (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wrap_req           ( wrapreq               ),
        .wrap_reqvalid      ( wrapreqvalid          ),
        .l2_fillptr         ( l2_tim_fillptr        ),
        .l2_fillvalid       ( l2_tim_fillvalid      ),
        .l2_stxdone         ( l2_tim_stxdone        ),
        .l2_reqqnocredits   ( l2_tim_reqqnocredits  ),
        
        .tim_strobereq      ( tim_wrap_strobereq    ),
        .tim_reqvalid       ( tim_reqvalid          ),
        .tim_req            ( tim_req               )
    );        
    
    logic [TIM_PTR_W-1:0]   l2_fillptr      ;
    logic                   l2_fillvalid    ;
    logic                   l2_stxdone      ;
    logic                   l2_reqqnocredits;
    logic [L1_REQ_W-1:0]    tim_l2_req      ;
    logic                   tim_l2_reqvalid ;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            l2_tim_fillptr          <= {TIM_PTR_W{1'b0}};
            l2_tim_fillvalid        <= 1'b0;
            l2_tim_stxdone          <= 1'b0;
            l2_tim_reqqnocredits    <= 1'b0;
            tim_l2_req              <= {L1_REQ_W{1'b0}};
            tim_l2_reqvalid         <= 1'b0;
        end
        else begin
            l2_tim_fillptr          <= l2_fillptr;
            l2_tim_fillvalid        <= l2_fillvalid;
            l2_tim_stxdone          <= l2_stxdone;
            l2_tim_reqqnocredits    <= l2_reqqnocredits;
            tim_l2_req              <= tim_req;
            tim_l2_reqvalid         <= tim_reqvalid;
        end
    end


    l2_wrapper #(
        .DATA_W                     ( DATA_W            ),
        .ADDR_W                     ( ADDR_W            ),
        .NOC_RSP_PKT_W              ( NOC_RSP_PKT_W     ),
        .SP_OPC_W                   ( SP_OPC_W          ),
        .L1_OPC_W                   ( L1_OPC_W          ),
        .L2_ST_W                    ( L2_ST_W           ),
        .TIM_PTR_W                  ( TIM_PTR_W         ),
        .PTBL_DEPTH                 ( PTBL_DEPTH        ),
        .L2_INDEX_W                 ( L2_INDEX_W        ),
        .RET_2_SRC_W                ( RET_2_SRC_W       ),
        .NUM_OF_BANKS               ( NUM_OF_BANKS      ),
        .BANK_ADDR_LSB_BIT          ( BANK_ADDR_LSB_BIT ),
        .COMP_BIT                   ( COMP_BIT          ),
        .L2_WAYS                    ( L2_WAYS           ),
        .L2_SIZE                    ( L2_SIZE           ),
        .L2_LOGWAYS                 ( L2_LOGWAYS        )
    ) i_l2_wrapper (
        // Clock and Reset
        .clk                        ( clk               ),
        .rst_n                      ( rst_n             ),
        // L1 Request Queue                           
        .l1_q_push_i                ( tim_l2_reqvalid   ),
        .l1_q_data_i                ( tim_l2_req        ),
        .l1_q_full_o                ( l2_reqqnocredits  ),
        // L1 Response                                
        .l1_fill_ptr_o              ( l2_fillptr        ),
        .l1_fill_val_o              ( l2_fillvalid      ),
        .l1_stx_ok_o                ( l2_stxdone        ),
        // NoC Response Queue                         
        .chi_noc_q_pop_i            ( chi_noc_q_pop_i   ),
        .chi_noc_q_empty_o          ( chi_noc_q_empty_o ),
        .chi_noc_q_data_o           ( chi_noc_q_data_o  ),
        // Evict Queue                                 
        .chi_evt_q_pop_i            ( chi_evt_q_pop_i   ),
        .chi_evt_q_empty_o          ( chi_evt_q_empty_o ),
        .chi_evt_q_af_o             ( chi_evt_q_af_o    ),
        .chi_evt_q_data_o           ( chi_evt_q_data_o  ),
        // To Fill Queue From CHI                      
        .chi_fll_q_push_i           ( chi_fll_q_push_i  ),
        .chi_fll_q_data_i           ( chi_fll_q_data_i  ),
        .chi_fll_q_full_o           ( chi_fll_q_full_o  ),
        // To Snoop Queue From CHI                     
        .chi_snp_q_val_i            ( chi_snp_q_val_i   ),
        .chi_snp_q_data_i           ( chi_snp_q_data_i  ),
        .chi_snp_q_pull_o           ( chi_snp_q_pull_o  )
);


endmodule : injector_top

`else  // if INJECTOR_EXCLUDE_CHI_AGENT not defined

module injector_top #(
    parameter DATA_W            = 256                                           ,                                               
              ADDR_W            = 39                                            ,                                               
              NOC_RSP_PKT_W     = 100                                           ,                                               
              NOC_INITS_CRED    = 1'b0                                          ,
              SP_OPC_W          = 5                                             ,                                               
              L1_OPC_W          = 3                                             ,                                               
              L2_ST_W           = 2                                             ,                                               
              TIM_PTR_W         = 6                                             ,                                               
              PTBL_DEPTH        = 32                                            ,                                               
              L2_INDEX_W        = 13                                            ,                                               
              RET_2_SRC_W       = 1                                             ,                                               
              NUM_OF_BANKS      = 4                                             ,                                               
              BANK_ADDR_LSB_BIT = 6                                             ,                                               
              COMP_BIT          = 1 /* COMP RESPONSE INDICATOR */               ,                                               
              L2_WAYS           = 4                                             ,                                               
              L2_SIZE           = 2048                                          ,                                               
              L2_LOGWAYS        = 2                                             ,                                               
              WRAP_REQ_W        = 64                                            ,
                                                                                                                                
              TBL_ID_W          = $clog2(PTBL_DEPTH)                            ,                                               
              L1_REQ_W          = TIM_PTR_W   + ADDR_W   + L1_OPC_W             ,   // 48 bits                                  
              FL_REQ_W          = COMP_BIT    + L2_ST_W  + TBL_ID_W             ,   // 8  bits                                  
              //SP_REQ_W          = RET_2_SRC_W + ADDR_W   + SP_OPC_W           ,   // 45 bits                                  
              SP_REQ_W          = RET_2_SRC_W + TBL_ID_W + ADDR_W   + SP_OPC_W  ,   // 50 bits
                                                                                                                    
              BANK_ADDR_W       = $clog2(NUM_OF_BANKS)                          ,                                               
              NOC_PLUS_BANK_W   = NOC_RSP_PKT_W + BANK_ADDR_W                   ,   // Adding extra bits for bank addressing    
              FLL_PLUS_BANK_W   = FL_REQ_W      + BANK_ADDR_W                       // so a fill can be muxed accordingly to the
)(                                                                                  // right bank.                              
    // TIM Interface
    input   logic                                       clk                     ,
    input   logic                                       rst_n                   ,
    input   logic [WRAP_REQ_W-1:0]                      wrapreq                 ,
    input   logic                                       wrapreqvalid            ,
    output  logic                                       tim_wrap_strobereq      ,

    // CHI NoC Interface                                            
    // TXREQ                                                         
    output logic                                        chi_noc_txreqflitpend_o ,
    output logic                                        chi_noc_txreqflitv_o    ,
    output chi_rn_params_pkg::chi_reqflit_pkt_default_t chi_noc_txreqflit_o     ,
    input  logic                                        noc_chi_txreqlcrdv_i    ,
    // TXDAT                                                     
    output logic                                        chi_noc_txdatflitpend_o ,
    output logic                                        chi_noc_txdatflitv_o    ,
    output chi_rn_params_pkg::chi_datflit_pkt_default_t chi_noc_txdatflit_o     ,
    input  logic                                        noc_chi_txdatlcrdv_i    ,
    // TXRSP                                                     
    output logic                                        chi_noc_txrspflitpend_o ,
    output logic                                        chi_noc_txrspflitv_o    ,
    output chi_rn_params_pkg::chi_rspflit_pkt_default_t chi_noc_txrspflit_o     ,
    input  logic                                        noc_chi_txrsplcrdv_i    ,
    // CRSP/RXRSP                                                
    input  logic                                        noc_chi_rxrspflitpend_i ,
    input  logic                                        noc_chi_rxrspflitv_i    ,
    input  chi_rn_params_pkg::chi_rspflit_pkt_default_t noc_chi_rxrspflit_i     ,
    output logic                                        chi_noc_rxrsplcrdv_o    ,
    // RDAT                                                      
    input  logic                                        noc_chi_rxdatflitpend_i ,
    input  logic                                        noc_chi_rxdatflitv_i    ,
    input  chi_rn_params_pkg::chi_datflit_pkt_default_t noc_chi_rxdatflit_i     ,
    output logic                                        chi_noc_rxdatlcrdv_o    ,
    // SNP/RXSNP                                                 
    input  logic                                        noc_chi_rxsnpflitpend_i ,
    input  logic                                        noc_chi_rxsnpflitv_i    ,
    input  chi_rn_params_pkg::chi_snpflit_pkt_default_t noc_chi_rxsnpflit_i     ,
    output logic                                        chi_noc_rxsnplcrdv_o    ,
    // SAM
    output [chi_rn_params_pkg::ADDR_REQ_DEFAULT-1:0]    sam_target_address_o    ,
    input  [chi_rn_params_pkg::TGTID_REQ_DEFAULT-1:0]   sam_target_id_i         ,
    input  [chi_rn_params_pkg::SRCID_REQ_DEFAULT-1:0]   source_id_i

);
    
    // Import required packages
    import l2_pkg::*;


    // NoC Request/Response packet type
    typedef struct packed {
        rsp_ch_t                        rsp_ch1 ; //_
        logic       [NOC_OPC_W-1:0]     opcode1 ; // \
        noc_resp_t                      resp1   ; //  > RSP 1 ( Home Node Req/Rsp )
                                                  //_/
        rsp_ch_t                        rsp_ch2 ; // \
        logic       [NOC_OPC_W-1:0]     opcode2 ; //  > RSP 2 ( Requester Node Req/Rsp )
        noc_resp_t                      resp2   ; //_/
        //noc_resp_t                    fwdst2  ; // This field is redundant. Same value as resp1

        logic       [ADDR_W-1:0]        addr    ;
        logic       [TBL_ID_W-1:0]      tbl_id  ;
        logic                           ex_bit  ; // LDX/STX bit
    } noc_req_pkt_t;

    localparam SNP_DATA_W = $bits(chi_rn_params_pkg::l2_snoop_req_pkt_default_t);


    // Logic Declaration 
    /////////////////////////////////////

    logic                                           wrapdone            ;

    logic [WRAP_REQ_W-1:0]                          wrap_tim_req        ;
    logic                                           tim_strobereq       ;

    logic                                           tim_reqvalid        ;
    logic [L1_REQ_W-1:0]                            tim_req             ;
    logic [TIM_PTR_W-1:0]                           l2_tim_fillptr      ;
    logic                                           l2_tim_fillvalid    ;
    logic                                           l2_tim_stxdone      ;
    logic                                           l2_tim_reqqnocredits;
    
    logic [TIM_PTR_W-1:0]                           l2_fillptr          ;
    logic                                           l2_fillvalid        ;
    logic                                           l2_stxdone          ;
    logic                                           l2_reqqnocredits    ;
    logic [L1_REQ_W-1:0]                            tim_l2_req          ;
    logic                                           tim_l2_reqvalid     ;

    // CHI Interconnection Logic
    chi_rn_params_pkg::l2_req_pkt_default_t         chi_noc_q_data      ;
    noc_req_pkt_t                                   chi_noc_q_data_aux  ;
    logic [NOC_PLUS_BANK_W-1:0]                     chi_noc_q_data_less ;
    logic [BANK_ADDR_W-1:0]                         chi_noc_q_ba_addr   ;
    logic                                           chi_noc_q_pop       ;
    logic                                           chi_noc_q_empty     ;

    chi_rn_params_pkg::l2_evict_pkt_default_t       chi_evt_q_data      ;
    logic [ADDR_W-1:0]                              chi_evt_q_data_less ;
    logic                                           chi_evt_q_pop       ;
    logic                                           chi_evt_q_empty     ;
    logic                                           chi_evt_q_af        ;

    chi_rn_params_pkg::l2_fill_pkt_default_t        chi_fll_q_data      ;
    logic [FLL_PLUS_BANK_W-1:0]                     chi_fll_q_data_less ;
    logic                                           chi_fll_q_push      ;
    logic                                           chi_fll_q_full      ;

    chi_rn_params_pkg::l2_snoop_req_pkt_default_t   chi_snp_q_data      ;
    logic [SP_REQ_W-1:0]                            chi_snp_q_data_less ;
    logic                                           chi_snp_q_val       ;
    logic                                           chi_snp_q_pull      ;


    // NoC Request packet wires
    logic [NOC_RPC_W-1:0]                           l2_chi_rsp_ch1      ;
    logic [NOC_OPC_W-1:0]                           l2_chi_opcode1      ;
    logic [NOC_RSP_W-1:0]                           l2_chi_resp1        ;
    logic [NOC_RPC_W-1:0]                           l2_chi_rsp_ch2      ;
    logic [NOC_OPC_W-1:0]                           l2_chi_opcode2      ;
    logic [NOC_RSP_W-1:0]                           l2_chi_resp2        ;
    logic [ADDR_W-1:0]                              l2_chi_addr         ;
    logic [TBL_ID_W-1:0]                            l2_chi_tbl_id       ;
    logic                                           l2_chi_ex_bit       ;

    // Implementation
    /////////////////////////////////////

    // TIM Instance
    tim tim (
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        .wrap_req           ( wrapreq               ),
        .wrap_reqvalid      ( wrapreqvalid          ),
        .l2_fillptr         ( l2_tim_fillptr        ),
        .l2_fillvalid       ( l2_tim_fillvalid      ),
        .l2_stxdone         ( l2_tim_stxdone        ),
        .l2_reqqnocredits   ( l2_tim_reqqnocredits  ),
        
        .tim_strobereq      ( tim_wrap_strobereq    ),
        .tim_reqvalid       ( tim_reqvalid          ),
        .tim_req            ( tim_req               )
    );        

    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            l2_tim_fillptr          <= {TIM_PTR_W{1'b0}};
            l2_tim_fillvalid        <= 1'b0;
            l2_tim_stxdone          <= 1'b0;
            l2_tim_reqqnocredits    <= 1'b0;
            tim_l2_req              <= {L1_REQ_W{1'b0}};
            tim_l2_reqvalid         <= 1'b0;
        end
        else begin
            l2_tim_fillptr          <= l2_fillptr;
            l2_tim_fillvalid        <= l2_fillvalid;
            l2_tim_stxdone          <= l2_stxdone;
            l2_tim_reqqnocredits    <= l2_reqqnocredits;
            tim_l2_req              <= tim_req;
            tim_l2_reqvalid         <= tim_reqvalid;
        end
    end


    // L2 Instance
    l2_wrapper #(
        .DATA_W                     ( DATA_W                ),
        .ADDR_W                     ( ADDR_W                ),
        .NOC_RSP_PKT_W              ( NOC_RSP_PKT_W         ),
        .SP_OPC_W                   ( SP_OPC_W              ),
        .L1_OPC_W                   ( L1_OPC_W              ),
        .L2_ST_W                    ( L2_ST_W               ),
        .TIM_PTR_W                  ( TIM_PTR_W             ),
        .PTBL_DEPTH                 ( PTBL_DEPTH            ),
        .L2_INDEX_W                 ( L2_INDEX_W            ),
        .RET_2_SRC_W                ( RET_2_SRC_W           ),
        .NUM_OF_BANKS               ( NUM_OF_BANKS          ),
        .BANK_ADDR_LSB_BIT          ( BANK_ADDR_LSB_BIT     ),
        .COMP_BIT                   ( COMP_BIT              ),
        .L2_WAYS                    ( L2_WAYS               ),
        .L2_SIZE                    ( L2_SIZE               ),
        .L2_LOGWAYS                 ( L2_LOGWAYS            )
    ) i_l2_wrapper (
        // Clock and Reset
        .clk                        ( clk                   ),
        .rst_n                      ( rst_n                 ),
        // L1 Request Queue                           
        .l1_q_push_i                ( tim_l2_reqvalid       ),
        .l1_q_data_i                ( tim_l2_req            ),
        .l1_q_full_o                ( l2_reqqnocredits      ),
        // L1 Response                                
        .l1_fill_ptr_o              ( l2_fillptr            ),
        .l1_fill_val_o              ( l2_fillvalid          ),
        .l1_stx_ok_o                ( l2_stxdone            ),
        // NoC Response Queue                         
        .chi_noc_q_pop_i            ( chi_noc_q_pop         ),
        .chi_noc_q_empty_o          ( chi_noc_q_empty       ),
        .chi_noc_q_data_o           ( chi_noc_q_data_less   ),
        // Evict Queue                                 
        .chi_evt_q_pop_i            ( chi_evt_q_pop         ),
        .chi_evt_q_empty_o          ( chi_evt_q_empty       ),
        .chi_evt_q_af_o             ( chi_evt_q_af          ),
        .chi_evt_q_data_o           ( chi_evt_q_data_less   ),
        // To Fill Queue From CHI                      
        .chi_fll_q_push_i           ( chi_fll_q_push        ),
        .chi_fll_q_data_i           ( chi_fll_q_data_less   ),
        .chi_fll_q_full_o           ( chi_fll_q_full        ),
        // To Snoop Queue From CHI                     
        .chi_snp_q_val_i            ( ~chi_snp_q_val        ),
        .chi_snp_q_data_i           ( chi_snp_q_data_less   ),
        .chi_snp_q_pull_o           ( chi_snp_q_pull        )
    );

    
    logic                                           chi_l2_snp_q_push;
    chi_rn_params_pkg::l2_snoop_req_pkt_default_t   chi_l2_snp_q_data;
    logic                                           chi_l2_snp_q_full;


    // add a fifo between chi snp to l2
    sync_ff_fifo #(
        .DATA_W                         ( SNP_DATA_W        ),
        .FIFO_DEPTH                     ( 4                 )
    ) fifo_snp_2_l2 (
        .clk                            ( clk               ),
        .rst_n                          ( rst_n             ),
        .push_i                         ( chi_l2_snp_q_push ),
        .pop_i                          ( chi_snp_q_pull    ),
        .data_i                         ( chi_l2_snp_q_data ),
        .data_o                         ( chi_snp_q_data    ),
        .full_o                         ( chi_l2_snp_q_full ),
        .empty_o                        ( chi_snp_q_val     ),
        .af_o                           ( /* Not Used */    ),
        .ae_o                           ( /* Not Used */    )
    ); 


    // CHI Agent Instance
    chi_rn_agent #(
        .NOC_INITS_CRED                 ( NOC_INITS_CRED            ),
        .OPCODE_DAT                     ( 4                         )
    ) i_chi_rn_agent_top (
        .clk_i                          ( clk                       ),
        .rst_ni                         ( rst_n                     ),
        // Interface with L2
        // NoC Response Queue
        .l2_chi_q_pop_o                 ( chi_noc_q_pop             ),
        .l2_chi_q_empty_i               ( chi_noc_q_empty           ),
        .l2_chi_q_data_i                ( chi_noc_q_data            ),
        // Evict Queue
        .l2_chi_evt_q_pop_o             ( chi_evt_q_pop             ),
        .l2_chi_evt_q_highoccupancy_i   ( chi_evt_q_af              ),
        .l2_chi_evt_q_empty_i           ( chi_evt_q_empty           ),
        .l2_chi_evt_q_data_i            ( chi_evt_q_data            ), 
        // Arbitration queue
        .l2_chi_arb_q_pop_o             ( /* Not used by Injector */),
        .l2_chi_arb_q_empty_i           ( 1'b0                      ),
        .l2_chi_arb_q_data_i            ( '0                        ),
        // To Fill Queue From CHI
        .chi_l2_fill_q_push_o           ( chi_fll_q_push            ),
        .chi_l2_fill_q_data_o           ( chi_fll_q_data            ),
        .chi_l2_fill_q_full_i           ( chi_fll_q_full            ),
        // To Snoop Queue From CHI
        .chi_l2_snp_q_push_o            ( chi_l2_snp_q_push         ),
        .chi_l2_snp_q_data_o            ( chi_l2_snp_q_data         ),
        .chi_l2_snp_q_full_i            ( chi_l2_snp_q_full         ),

        // Interface with NoC
        // TXREQ
        .chi_noc_txreqflitpend          ( chi_noc_txreqflitpend_o   ),
        .chi_noc_txreqflitv             ( chi_noc_txreqflitv_o      ),
        .chi_noc_txreqflit              ( chi_noc_txreqflit_o       ),
        .noc_chi_txreqlcrdv             ( noc_chi_txreqlcrdv_i      ),
        // TXDAT                                                 
        .chi_noc_txdatflitpend          ( chi_noc_txdatflitpend_o   ),
        .chi_noc_txdatflitv             ( chi_noc_txdatflitv_o      ),
        .chi_noc_txdatflit              ( chi_noc_txdatflit_o       ),
        .noc_chi_txdatlcrdv             ( noc_chi_txdatlcrdv_i      ),
        // TXRSP                                                 
        .chi_noc_txrspflitpend          ( chi_noc_txrspflitpend_o   ),
        .chi_noc_txrspflitv             ( chi_noc_txrspflitv_o      ),
        .chi_noc_txrspflit              ( chi_noc_txrspflit_o       ),
        .noc_chi_txrsplcrdv             ( noc_chi_txrsplcrdv_i      ),
        // CRSP/RXRSP                                            
        .noc_chi_rxrspflitpend          ( noc_chi_rxrspflitpend_i   ),
        .noc_chi_rxrspflitv             ( noc_chi_rxrspflitv_i      ),
        .noc_chi_rxrspflit              ( noc_chi_rxrspflit_i       ),
        .chi_noc_rxrsplcrdv             ( chi_noc_rxrsplcrdv_o      ),
        // RDAT                                                  
        .noc_chi_rxdatflitpend          ( noc_chi_rxdatflitpend_i   ),  // Injector does not care about
        .noc_chi_rxdatflitv             ( noc_chi_rxdatflitv_i      ),  // about incoming data.
        .noc_chi_rxdatflit              ( noc_chi_rxdatflit_i       ),
        .chi_noc_rxdatlcrdv             ( chi_noc_rxdatlcrdv_o      ),
        // SNP/RXSNP                                             
        .noc_chi_rxsnpflitpend          ( noc_chi_rxsnpflitpend_i   ),
        .noc_chi_rxsnpflitv             ( noc_chi_rxsnpflitv_i      ),
        .noc_chi_rxsnpflit              ( noc_chi_rxsnpflit_i       ),
        .chi_noc_rxsnplcrdv             ( chi_noc_rxsnplcrdv_o      ),
        // SAM
        .sam_target_address_o           ( sam_target_address_o      ),
        .sam_target_id_i                ( sam_target_id_i           ),
        .src_id                         ( source_id_i               )
    );

    wire l2_chi_resperr1,l2_chi_resperr2;

    // Adapting CHI buses to L2 Injector buses.
    assign chi_noc_q_data_aux = chi_noc_q_data_less[NOC_PLUS_BANK_W-1:BANK_ADDR_W];                       
    assign chi_noc_q_ba_addr  = chi_noc_q_data_less[BANK_ADDR_W-1:0];                                     

    assign l2_chi_rsp_ch1 = chi_noc_q_data_aux.rsp_ch1;
    assign l2_chi_opcode1 = chi_noc_q_data_aux.opcode1;
    assign l2_chi_resp1   = chi_noc_q_data_aux.resp1  ;
    assign l2_chi_resperr1   = '0  ;
    assign l2_chi_rsp_ch2 = chi_noc_q_data_aux.rsp_ch2;
    assign l2_chi_opcode2 = chi_noc_q_data_aux.opcode2;
    assign l2_chi_resp2   = chi_noc_q_data_aux.resp2  ;
    assign l2_chi_resperr2   = '0  ;
    assign l2_chi_addr    = chi_noc_q_data_aux.addr   ;
    assign l2_chi_tbl_id  = chi_noc_q_data_aux.tbl_id ;
    assign l2_chi_ex_bit  = chi_noc_q_data_aux.ex_bit ;

    assign chi_noc_q_data.rsp_ch1       = chi_rn_params_pkg::rsp_ch_t'(l2_chi_rsp_ch1)  ;
    assign chi_noc_q_data.opcode1       = l2_chi_opcode1                                ;                         
    assign chi_noc_q_data.resp1         = chi_rn_params_pkg::noc_resp_t'(l2_chi_resp1)  ;
    assign chi_noc_q_data.resperr1      = '0                                            ;                         
    assign chi_noc_q_data.rsp_ch2       = chi_rn_params_pkg::rsp_ch_t'(l2_chi_rsp_ch2)  ; 
    assign chi_noc_q_data.opcode2       = l2_chi_opcode2                                ; 
    assign chi_noc_q_data.resp2         = chi_rn_params_pkg::noc_resp_t'(l2_chi_resp2)  ;
    assign chi_noc_q_data.resperr2      = '0                                            ;
    assign chi_noc_q_data.addr          = {5'h0, l2_chi_addr}                           ;
    assign chi_noc_q_data.tbl_id        = l2_chi_tbl_id                                 ;   
    assign chi_noc_q_data.bank_addr     = chi_noc_q_ba_addr                             ;
    assign chi_noc_q_data.excl_snoopme  = l2_chi_ex_bit                                 ;

    // Adapting CHI Evict Bus Queue to expected CHI format
    assign chi_evt_q_data.opcode        = chi_rn_params_pkg::WRITEBACKFULL  ;
    assign chi_evt_q_data.addr          = chi_evt_q_data_less               ;
    assign chi_evt_q_data.tbl_id        = '0                                ;
    assign chi_evt_q_data.bank_addr     = '0                                ;
    assign chi_evt_q_data.data          = '0                                ;
    assign chi_evt_q_data.dmask         = '0                                ;
    assign chi_evt_q_data.excl_snoopme  = l2_chi_ex_bit                     ;

    // Fill Queue hookup.
    assign chi_fll_q_data_less = {chi_fll_q_data.comp,chi_fll_q_data.st_w,chi_fll_q_data.tbl_id,chi_fll_q_data.bank_addr};

    // Snoop Queue hookup.
    assign chi_snp_q_data_less = {chi_snp_q_data.rettosrc,chi_snp_q_data.snoop_table_index,chi_snp_q_data.addr[38:0],chi_snp_q_data.opcode[4:0]};


endmodule : injector_top

`endif // INJECTOR_EXCLUDE_CHI_AGENT
