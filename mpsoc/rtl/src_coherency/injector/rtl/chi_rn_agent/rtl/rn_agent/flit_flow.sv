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
*   Author:         Xubin Tan
*   Email:          xubin.tan@semidynamics.com
*   Date:           14/02/2019
*-------------------------------------------------------------------------------
*   Title:          The CHI agent TX flit flow logic
*
*   Description:    This component handles the flow of the
*                   flits with the following control mechanisms:
*                   
*                   1) It assures that the flit will be sent at the right
*                   time (one cycle after setting the flitpend signal).
*
*                   2) It checks and updates the available L-credits to
*                   to leverage the flit flow according to the CHI
*                   spec.
*
*   Modification:   Modified the mechanism to generate stop_flow, flitpend, flitv to 
*                   suit txreq pipeline.
* 
*   Release Notes:  Initial Release
*-----------------------------------------------------------------------------*/

module flit_flow
    import chi_rn_params_pkg::*;
    #(
        parameter LOG_LCREDITS_NUM = 4,
        parameter FLIT_SIZE = 32,
        parameter NOC_INITS_CRED = 0
    )
(
   // generic
   input  logic                  clk       ,
   input  logic                  rst_n     ,
   // the valid flit signal
   input  logic                  valid_flit,
   // the flit
   input  logic [FLIT_SIZE-1:0]  flit      ,
   input  logic                  lcrdv     ,
   output logic                  flitpend  ,
   output logic                  flitv     ,
   output logic [FLIT_SIZE-1:0]  out_flit  ,
   // stop the flow because the TX cannot send more flits
   output logic                  stop_flow
);

// logic definition
// l-credit counter
// it counts how many flits have we sent and decides 
// whether we can send a new one or not
logic [LOG_LCREDITS_NUM-1:0]   lcredit_counter;
// register for the valid flit signal to
// drive the flitpend signal
logic valid_flit_reg;
// register for the flit
logic [FLIT_SIZE-1:0] flit_reg;
logic  valid_flit_ack;

// assume we have 15 credit at the very beginning
// lcredit_counter should decrease when we use one, accept one valid flit
// lcredit_counter should increase when we get one, receive a lcrdv pulse
// when both accepting both a valid flit and a lcrdv pulse at the same time, 
// we should neither increase or decrease the counter.
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      if (NOC_INITS_CRED) begin
        lcredit_counter <= 4'h0;
      end else begin
        lcredit_counter <= (2**LOG_LCREDITS_NUM)-1;
      end
    end else begin
        if(!valid_flit && lcrdv) begin        	
        	if(lcredit_counter != 4'hF) begin
        		lcredit_counter <= lcredit_counter + 1;
        	end
        end else if(valid_flit && !lcrdv && lcredit_counter > 0) begin
            lcredit_counter <= lcredit_counter - 1;
        end
    end
end

assign valid_flit_ack = (valid_flit && (lcredit_counter != 0)) || (valid_flit && (lcredit_counter) == 0 && lcrdv);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        valid_flit_reg <= 1'b0;
        flit_reg <= {FLIT_SIZE{1'b0}};
    end else begin
        valid_flit_reg <= valid_flit_ack;
        flit_reg <= flit;
    end
end

// assign the outputs
assign flitpend = valid_flit; //valid_flit_reg;
assign flitv = valid_flit_reg; 
assign out_flit = flit_reg; //flit_reg2;
assign stop_flow = (lcredit_counter == 0) && !(valid_flit && (lcredit_counter) == 0 && lcrdv);

`ifndef VERILATOR
assert property (
  @(posedge clk) (lcredit_counter == 4'hF && !valid_flit) |-> (!lcrdv))
  else $error ("%m : increasing counter but already at maximum value");
`endif

endmodule : flit_flow
