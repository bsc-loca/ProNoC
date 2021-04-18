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
*   Date:           27/09/2019
*-------------------------------------------------------------------------------
*   Title:          CHI Requestor Agent Top Wrapper
*
*   Description:    This module wraps the chi rn agent top for integration purpose 
*                   with NoC.
*            
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/
module chi_rn_agent_snoc
    import chi_rn_params_pkg::*;
(
  input  logic      clk_i,
  input  logic      rst_ni,

  // Interface with L2 
  // NoC Response Queue
  output logic                       l2_chi_q_pop_o              ,
  input  logic                       l2_chi_q_empty_i            ,
  input  l2_req_pkt_t                l2_chi_q_data_i             ,
  // Evict Queue
  output logic                       l2_chi_evt_q_pop_o          ,
  input  logic                       l2_chi_evt_q_highoccupancy_i,
  input  logic                       l2_chi_evt_q_empty_i        ,
  input  l2_evict_pkt_t              l2_chi_evt_q_data_i         ,
  // Arbitration queue
  output  logic                      l2_chi_arb_q_pop_o           ,
  input   logic                      l2_chi_arb_q_empty_i         ,
  input   logic [ARB_QUEUE_W-1:0]    l2_chi_arb_q_data_i          ,
  // To Fill Queue From CHI
  output  logic                      chi_l2_fill_q_push_o        ,
  output  l2_fill_pkt_t              chi_l2_fill_q_data_o        ,
  input   logic                      chi_l2_fill_q_full_i        ,
  // To Snoop Queue From CHI
  output  logic                      chi_l2_snp_q_push_o          ,
  output  l2_snoop_req_pkt_t         chi_l2_snp_q_data_o         ,
  input   logic                      chi_l2_snp_q_full_i         ,
  
  // Interface with NoC 
  chi_req_chan.tx   tx_req,
  chi_rsp_chan.tx   tx_rsp,
  chi_dat_chan.tx   tx_dat,
  chi_rsp_chan.rx   rx_rsp,
  chi_dat_chan.rx   rx_dat,
  chi_snp_chan.rx   rx_snp 
);

// logic definition
chi_datflit_pkt_t tx_dat_flit_aux;
chi_datflit_snoc_pkt_t rx_dat_flit_aux;

// instantiation
chi_rn_agent  chi_rn_agent_instance
(
    .clk_i                        (clk_i                       ),
    .rst_ni                       (rst_ni                      ),
    .l2_chi_q_pop_o               (l2_chi_q_pop_o              ),
    .l2_chi_q_empty_i             (l2_chi_q_empty_i            ),
    .l2_chi_q_data_i              (l2_chi_q_data_i             ),
    .l2_chi_evt_q_pop_o           (l2_chi_evt_q_pop_o          ),
    .l2_chi_evt_q_highoccupancy_i (l2_chi_evt_q_highoccupancy_i),
    .l2_chi_evt_q_empty_i         (l2_chi_evt_q_empty_i        ),
    .l2_chi_evt_q_data_i          (l2_chi_evt_q_data_i         ),
    .chi_l2_fill_q_push_o         (chi_l2_fill_q_push_o        ),
    .chi_l2_fill_q_data_o         (chi_l2_fill_q_data_o        ),
    .chi_l2_fill_q_full_i         (chi_l2_fill_q_full_i        ),
    .chi_l2_snp_q_push_o          (chi_l2_snp_q_push_o        ),
    .chi_l2_snp_q_data_o          (chi_l2_snp_q_data_o         ),
    .chi_l2_snp_q_full_i          (chi_l2_snp_q_full_i         ),
    // Arbitration queue
    .l2_chi_arb_q_pop_o          (l2_chi_arb_q_pop_o           ),
    .l2_chi_arb_q_empty_i        (l2_chi_arb_q_empty_i         ),
    .l2_chi_arb_q_data_i         (l2_chi_arb_q_data_i          ),
    // Interface with NoC 
    // TXREQ
    .chi_noc_txreqflitpend        (tx_req.flit_pend            ),
    .chi_noc_txreqflitv           (tx_req.flit_v               ),
    .chi_noc_txreqflit            (tx_req.flit                 ),
    .noc_chi_txreqlcrdv           (tx_req.lcrd_v               ),
    // TXDAT
    .chi_noc_txdatflitpend        (tx_dat.flit_pend            ),
    .chi_noc_txdatflitv           (tx_dat.flit_v               ),
    .chi_noc_txdatflit            (tx_dat_flit_aux             ),
    .noc_chi_txdatlcrdv           (tx_dat.lcrd_v               ),
    // TXRSP
    .chi_noc_txrspflitpend        (tx_rsp.flit_pend            ),
    .chi_noc_txrspflitv           (tx_rsp.flit_v               ),
    .chi_noc_txrspflit            (tx_rsp.flit                 ),
    .noc_chi_txrsplcrdv           (tx_rsp.lcrd_v               ),
    // CRSP/RXRSP
    .noc_chi_rxrspflitpend        (rx_rsp.flit_pend            ),
    .noc_chi_rxrspflitv           (rx_rsp.flit_v               ),
    .noc_chi_rxrspflit            (rx_rsp.flit                 ),
    .chi_noc_rxrsplcrdv           (rx_rsp.lcrd_v               ),
    // RDAT
    .noc_chi_rxdatflitpend        (rx_dat.flit_pend            ),
    .noc_chi_rxdatflitv           (rx_dat.flit_v               ),
    .noc_chi_rxdatflit            (rx_dat_flit_aux             ),
    .chi_noc_rxdatlcrdv           (rx_dat.lcrd_v               ),
    // SNP/RXSNP
    .noc_chi_rxsnpflitpend        (rx_snp.flit_pend            ),
    .noc_chi_rxsnpflitv           (rx_snp.flit_v               ),
    .noc_chi_rxsnpflit            (rx_snp.flit                 ),
    .chi_noc_rxsnplcrdv           (rx_snp.lcrd_v               ) 
);

// adapt TX_DAT and RX_DAT packets
assign tx_dat.flit.qos           = tx_dat_flit_aux.qos            ;
assign tx_dat.flit.tgtid         = tx_dat_flit_aux.tgtid          ;
assign tx_dat.flit.srcid         = tx_dat_flit_aux.srcid          ;
assign tx_dat.flit.txnid         = tx_dat_flit_aux.txnid          ;
assign tx_dat.flit.homenid       = tx_dat_flit_aux.homenid        ;
assign tx_dat.flit.opcode        = tx_dat_flit_aux.opcode         ;
assign tx_dat.flit.resperr       = tx_dat_flit_aux.resperr        ;
assign tx_dat.flit.resp          = tx_dat_flit_aux.resp           ;
assign tx_dat.flit.fwd_datapull  = tx_dat_flit_aux.fwd_datapull   ;
assign tx_dat.flit.dbid          = tx_dat_flit_aux.dbid           ;
assign tx_dat.flit.ccid          = tx_dat_flit_aux.ccid           ;
assign tx_dat.flit.dataid        = tx_dat_flit_aux.dataid         ;
assign tx_dat.flit.tracetag      = tx_dat_flit_aux.tracetag       ;
assign tx_dat.flit.be            = tx_dat_flit_aux.be             ;
assign tx_dat.flit.data          = tx_dat_flit_aux.data           ;

assign rx_dat_flit_aux.qos           = rx_dat.flit.qos            ;
assign rx_dat_flit_aux.tgtid         = rx_dat.flit.tgtid          ;
assign rx_dat_flit_aux.srcid         = rx_dat.flit.srcid          ;
assign rx_dat_flit_aux.txnid         = rx_dat.flit.txnid          ;
assign rx_dat_flit_aux.homenid       = rx_dat.flit.homenid        ;
assign rx_dat_flit_aux.opcode        = rx_dat.flit.opcode         ;
assign rx_dat_flit_aux.resperr       = rx_dat.flit.resperr        ;
assign rx_dat_flit_aux.resp          = rx_dat.flit.resp           ;
assign rx_dat_flit_aux.fwd_datapull  = rx_dat.flit.fwd_datapull   ;
assign rx_dat_flit_aux.dbid          = rx_dat.flit.dbid           ;
assign rx_dat_flit_aux.ccid          = rx_dat.flit.ccid           ;
assign rx_dat_flit_aux.dataid        = rx_dat.flit.dataid         ;
assign rx_dat_flit_aux.tracetag      = rx_dat.flit.tracetag       ;
assign rx_dat_flit_aux.be            = rx_dat.flit.be             ;
assign rx_dat_flit_aux.data          = rx_dat.flit.data           ;

endmodule
