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
*   Author:         Vasilis Dimitsas
*   Email:          vasilis.dimitsas@semidynamics.com
*   Date:           01/02/2019
*   Modify:         Xubin Tan
*   Email           xubin.tan@semidynamics.com
*   Date:           14/02/2019
*-------------------------------------------------------------------------------
*   Title:          The CHI agent TX stage
*
*   Description:    This component sends the flits to the NOC. Furthermore, it
*                   controls the available L-credits to ensure that is allowed
*                   to send data flits.
*   Modify:         Adapt it to be used in the CHI Requestor Agent
*
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module rxrsp_p_tx
    import chi_rn_params_pkg::*;
    #(
        parameter LOG_LCREDITS_NUM = 4,
        parameter NOC_INITS_CRED = 0,
        parameter REQ_FLIT_SIZE,
        parameter DAT_FLIT_SIZE,
        parameter RSP_FLIT_SIZE,
        parameter SNP_FLIT_SIZE
    )
(
    //generic
    input  logic                     clk            ,
    input  logic                     rst_n          ,
    input  logic [DAT_FLIT_SIZE-1:0] arb_tx_datflit ,
    input  logic                     arb_tx_datflitv,
    input  logic                     noc_rx_datlcrdv,
    output logic                     tx_datflitpend ,
    output logic                     tx_datflitv    ,
    output logic [DAT_FLIT_SIZE-1:0] tx_datflit     ,
    output logic                     tx_arb_stop
);


flit_flow #(
    .LOG_LCREDITS_NUM       (LOG_LCREDITS_NUM),
    .FLIT_SIZE              (DAT_FLIT_SIZE),
    .NOC_INITS_CRED         (NOC_INITS_CRED)
    ) rx_datflit_flow (
    .clk                (clk),
    .rst_n              (rst_n),
    .valid_flit         (arb_tx_datflitv),
    .flit               (arb_tx_datflit),
    .lcrdv              (noc_rx_datlcrdv),
    .flitpend           (tx_datflitpend),
    .flitv              (tx_datflitv),
    .out_flit           (tx_datflit),
    .stop_flow          (tx_arb_stop)
);

endmodule 
