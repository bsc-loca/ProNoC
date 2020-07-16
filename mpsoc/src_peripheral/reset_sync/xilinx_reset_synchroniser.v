/**************************************
* Module: xilinx_reset_synchroniser
* Date:2020-07-16  
* Author: alireza     
*
* Description: 
***************************************/
module  xilinx_reset_synchroniser(
    input clk,
    input aresetin,
    output sync_reset

);


    (* ASYNC_REG = "true" *) reg sreg1, sreg2; 
    always @(posedge clk or posedge aresetin) begin
        if(aresetin) begin
            sreg1 <= 1'b1; 
            sreg2 <= 1'b1;
        end 
        else begin 
            sreg1 <= 1'b0; 
            sreg2 <= sreg1; 
        end 
    end 
    assign sync_reset = sreg2; 


endmodule

