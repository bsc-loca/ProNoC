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
*   Author:         Xubin Tan
*   Email:          xubin.tan@semidynamics.com
*   Date:           11/03/2019
*-------------------------------------------------------------------------------
*   Title:          The CHI Requestor agent TXREQ Pipeline stage
*
*   Description:    This stage is used to merge the data from alloc stage in the  
*                   local pipeline, and similar data from the retry logic. 
*
*                   It includes two 4-entry FIFO buffers for both incoming data, 
*                   and always give priority to retry logic.
*                   The full signals of these two buffers will stall the corresponding
*                   Pipeline stages.
*  
*                   Add port and logic to support PCRDRETURN from the retry logic                  
*                   Add amo_size to support the atomic operations 
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module txreq_p_enc 
    import chi_rn_params_pkg::*;
    #(
        parameter CHI_REQ_HAS_ENDIAN = 0,
        parameter CHI_REQ_HAS_NS = 0,
        parameter CHI_REQ_HAS_LIKELYSHARED = 0,
        parameter CHI_REQ_HAS_TRACETAG = 0,
        // parameter for flit structs and configurable field sizes
        parameter type chi_reqflit_pkt_t = chi_reqflit_pkt_default_t,
        parameter type chi_rspflit_pkt_t = chi_rspflit_pkt_default_t,
        parameter type chi_datflit_pkt_t = chi_datflit_pkt_default_t,
        parameter type chi_snpflit_pkt_t = chi_snpflit_pkt_default_t,
        parameter REQ_FLIT_SIZE,
        parameter DAT_FLIT_SIZE,
        parameter RSP_FLIT_SIZE,
        parameter SNP_FLIT_SIZE,
        parameter SRCID_REQ,
        parameter TGTID_REQ,
        parameter ADDR_REQ,
        parameter QOS_REQ,
        parameter RETURNNID_REQ,
        parameter LPID_REQ
    )
(
    //generic
    input  logic                              clk                             ,
    input  logic                              rst_n                           ,
    //stall signal from the next stage
    input  logic                              tx_enc_stop_i                   ,
    // retry request has higher priority over the local queue
    input  logic [TGTID_REQ-1:0]              retry_tgtid_i                   ,
    input  logic [SRCID_REQ-1:0]              retry_srcid_i                   ,
    input  logic [TXNID_REQ-1:0]              retry_txnid_i                   ,
    input  logic [OPCODE_REQ-1:0]             retry_opcode_i                  ,
    input  logic [ADDR_REQ-1:0]               retry_addr_i                    ,
    input  logic [1:0]                        retry_amo_size_i                ,
    input  logic [PCRDTYPE_REQ-1:0]           retry_pcrdtype_i                ,
    input  logic                              retry_excl_snoopme_i            ,
    input  logic                              retry_req_metadata_valid_i      ,
    output logic                              retry_stall_o                   ,
    // from previous stage - alloc 
    input  logic [TGTID_REQ-1:0]              tgtid_i                         ,
    input  logic [SRCID_REQ-1:0]              srcid_i                         ,
    input  logic [TXNID_REQ-1:0]              txnid_i                         ,
    input  logic [OPCODE_REQ-1:0]             opcode_i                        ,
    input  logic [ADDR_REQ-1:0]               addr_i                          ,
    input  logic [1:0]                        amo_size_i                      ,
    input  logic                              excl_snoopme_i                  ,
    input  logic                              req_metadata_valid_i            ,
    // output to the next stage
    output logic                              enc_tx_reqflitv_o               ,
    output logic [REQ_FLIT_SIZE-1:0]          enc_tx_reqflit_o                ,
    // output stop signal
    output logic                              enc_alloc_stop_o 
);
    


    // logic definition 
    chi_reqflit_pkt_t         tmp_reqflit,
                              tmp_reqflit_retry;
    logic [REQ_FLIT_SIZE-1:0] tmp_local_p_reqflit_o;
    logic [REQ_FLIT_SIZE-1:0] tmp_alien_p_reqflit_o;
    logic                     fifo_alloc_stop_o ;
    logic                     tmp_local_p_pop ;
    logic                     tmp_alien_p_pop ;
    logic                     tmp_fifo_local_p_empty ;
    logic                     tmp_fifo_alien_p_empty ;
    logic                     tmp_alloc_enc_reqflitv;
    logic [REQ_FLIT_SIZE-1:0] tmp_alloc_enc_reqflit;
    logic                     tmp_retry_reqflitv;
    logic [REQ_FLIT_SIZE-1:0] tmp_retry_reqflit;
                                                                         
    // start coding body
    // encode
    // assign reqflit values
    assign tmp_reqflit.tgtid = tgtid_i;
    assign tmp_reqflit.srcid = srcid_i;
    assign tmp_reqflit.txnid = txnid_i;
    // For normal requests we support, here we set all the mandatory fixed values to some fields
    // For example,  returntxnid should be set to zero
    assign tmp_reqflit.returntxnid = {RETURNTXNID_REQ{1'b0}};
    assign tmp_reqflit.opcode = opcode_i;
    assign tmp_reqflit.addr = addr_i;
    assign tmp_reqflit.expcompack = (opcode_i == READSHARED || opcode_i == READUNIQUE || opcode_i == CLEANUNIQUE)? 1'b1 : 1'b0;
    assign tmp_reqflit.qos           = {QOS_REQ{1'b0}};
    assign tmp_reqflit.returnnid     = {RETURNNID_REQ{1'b0}};
    generate
        if (CHI_REQ_HAS_ENDIAN) assign tmp_reqflit.endian = 1'b0;
    endgenerate
    assign tmp_reqflit.flitsize      = (opcode_i >= ATOMICS_START && opcode_i <= ATOMICS_END) ? {1'b0, amo_size_i}:3'b110;
    generate
        if (CHI_REQ_HAS_NS) assign tmp_reqflit.ns = 1'b1;
    endgenerate
    generate
        if (CHI_REQ_HAS_LIKELYSHARED) assign tmp_reqflit.likelyshared = 1'b0;
    endgenerate
    assign tmp_reqflit.allowretry    = 1'b1;
    assign tmp_reqflit.order         = 2'b11;
    assign tmp_reqflit.pcrdtype      = {PCRDTYPE_REQ{1'b0}};
    assign tmp_reqflit.memattr       = 4'b1101;
    assign tmp_reqflit.snpattr       = 1'b1;
    assign tmp_reqflit.lpid          = {LPID_REQ{1'b0}};
    assign tmp_reqflit.excl_snoopme  = excl_snoopme_i;
    generate
        if (CHI_REQ_HAS_TRACETAG) assign tmp_reqflit.tracetag      = 1'b0;
    endgenerate

    assign tmp_alloc_enc_reqflitv = req_metadata_valid_i;  
    assign tmp_alloc_enc_reqflit  = tmp_reqflit;

    // push local requests to the local queue
    sync_ff_fifo 
    #(
        .DATA_W                ( REQ_FLIT_SIZE),
        .FIFO_DEPTH            ( 4            ),
        .AF_FLAG_LIM           ( 3            ),
        .AE_FLAG_LIM           ( 1            )
    ) fifo_localreq
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (tmp_alloc_enc_reqflitv      ),
        .pop_i                           (tmp_local_p_pop             ),
        .data_i                          (tmp_alloc_enc_reqflit       ),
        .data_o                          (tmp_local_p_reqflit_o       ),
        .full_o                          (fifo_alloc_stop_o           ),
        .empty_o                         (tmp_fifo_local_p_empty      ),
        .af_o                            () ,
        .ae_o                            ()
    );

    // encode
    // assign reqflit values
    assign tmp_reqflit_retry.tgtid         = retry_tgtid_i;
    assign tmp_reqflit_retry.srcid         = retry_srcid_i;
    assign tmp_reqflit_retry.txnid         = retry_txnid_i;
    // For normal requests we support, here we set all the mandatory fixed values to some fields
    // For example,  returntxnid should be set to zero
    assign tmp_reqflit_retry.returntxnid   = {RETURNTXNID_REQ{1'b0}}; //txnid_i;
    assign tmp_reqflit_retry.opcode        = retry_opcode_i;
    assign tmp_reqflit_retry.addr          = retry_addr_i;
    assign tmp_reqflit_retry.expcompack    = (retry_opcode_i == READSHARED || retry_opcode_i == READUNIQUE)? 1'b1 : 1'b0;
    assign tmp_reqflit_retry.qos           = {QOS_REQ{1'b0}};
    assign tmp_reqflit_retry.returnnid     = {RETURNNID_REQ{1'b0}};
    generate
        if (CHI_REQ_HAS_ENDIAN) assign tmp_reqflit_retry.endian = 1'b0;
    endgenerate
    assign tmp_reqflit_retry.flitsize      = (retry_opcode_i == PCRDRETURN)? 3'b000: (retry_opcode_i >= ATOMICS_START && retry_opcode_i <= ATOMICS_END)? {1'b0, retry_amo_size_i} : 3'b110;
    generate
        if (CHI_REQ_HAS_NS) assign tmp_reqflit_retry.ns = (retry_opcode_i == PCRDRETURN)? 1'b0 : 1'b1;
    endgenerate
    generate
        if (CHI_REQ_HAS_LIKELYSHARED) assign tmp_reqflit_retry.likelyshared  = 1'b0;
    endgenerate
    assign tmp_reqflit_retry.allowretry    = (retry_opcode_i == PCRDRETURN)? 1'b0 : 1'b1;
    assign tmp_reqflit_retry.order         = (retry_opcode_i == PCRDRETURN)? 2'b00 : 2'b11;
    assign tmp_reqflit_retry.pcrdtype      = retry_pcrdtype_i;
    assign tmp_reqflit_retry.memattr       = (retry_opcode_i == PCRDRETURN)? 4'h0 : 4'b1101;
    assign tmp_reqflit_retry.snpattr       = (retry_opcode_i == PCRDRETURN)? 1'b0 : 1'b1;
    assign tmp_reqflit_retry.lpid          = {LPID_REQ{1'b0}};
    assign tmp_reqflit_retry.excl_snoopme  = retry_excl_snoopme_i;
    generate
        if (CHI_REQ_HAS_TRACETAG) assign tmp_reqflit_retry.tracetag = 1'b0;
    endgenerate

    // push retry reqflit into the alien queue
    assign tmp_retry_reqflitv = retry_req_metadata_valid_i;  
    assign tmp_retry_reqflit  = tmp_reqflit_retry;
    sync_ff_fifo 
    #(
        .DATA_W                ( REQ_FLIT_SIZE),
        .FIFO_DEPTH            ( 4            ),
        .AF_FLAG_LIM           ( 3            ),
        .AE_FLAG_LIM           ( 1            )
    ) fifo_alienreq
    (
        .clk                             (clk                         ),
        .rst_n                           (rst_n                       ),
        .push_i                          (tmp_retry_reqflitv          ),
        .pop_i                           (tmp_alien_p_pop             ),
        .data_i                          (tmp_retry_reqflit           ),
        .data_o                          (tmp_alien_p_reqflit_o       ),
        .full_o                          (retry_stall_o               ),
        .empty_o                         (tmp_fifo_alien_p_empty      ),
        .af_o                            () ,
        .ae_o                            ()
    );
  
    // Retry should take higher priority than local request 
    localparam IDLE = 2'b00,
               S0   = 2'b01,
               S1   = 2'b10;
    logic [1:0] state;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            case (state) 
                IDLE: if((!tmp_fifo_local_p_empty || !tmp_fifo_alien_p_empty) && !tx_enc_stop_i) begin
                          state <= S0;
                      end else begin
                          state <= IDLE;
                      end
               // S0 reads alien retry queue
               S0:    if ((!tmp_fifo_local_p_empty && tmp_fifo_alien_p_empty) && !tx_enc_stop_i) begin state <= S1; end
               // S1 reads local queue
               S1:    if (!tmp_fifo_alien_p_empty && !tx_enc_stop_i) begin state <= S0; end
            endcase
        end
    end

    assign tmp_alien_p_pop = state == S0 && !tmp_fifo_alien_p_empty && !tx_enc_stop_i;
    assign tmp_local_p_pop = state == S1 && !tmp_fifo_local_p_empty && !tx_enc_stop_i;
    assign enc_tx_reqflitv_o = tmp_local_p_pop || tmp_alien_p_pop; 
    assign enc_tx_reqflit_o  = tmp_alien_p_pop? tmp_alien_p_reqflit_o : tmp_local_p_reqflit_o;
    assign enc_alloc_stop_o  = fifo_alloc_stop_o ; 
 
endmodule
