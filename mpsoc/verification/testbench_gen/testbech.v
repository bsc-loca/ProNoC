`timescale     1ns/1ps

module pronoc_jtag_uart_testbench;
// parameters
	 parameter JTAG_INDEX =  126;
	 parameter JAw = 32;
	 parameter JINDEXw = 8;
	 parameter JSTATUSw = 8;
	 parameter BUFF_Aw =    10;
	 parameter SELw =    4;
	 parameter Aw =    1;
	 parameter Dw =    32;
	 parameter TAGw =    3;
	 parameter JDw =  32;

// Ports
	 reg  clk;
	 wire  dataavailable;
	 reg [J2WBw-1:0] jtag_to_wb;
	 wire  readyfordata;
	 reg  reset;
	 wire  wb_ack_o;
	 reg  wb_adr_i;
	 reg  wb_cyc_i;
	 reg [Dw-1:0] wb_dat_i;
	 wire [Dw-1:0] wb_dat_o;
	 wire  wb_irq;
	 reg  wb_stb_i;
	 wire [WB2Jw-1:0] wb_to_jtag;
	 reg  wb_we_i;

// top module instance
 	 pronoc_jtag_uart #(
		.JTAG_INDEX(JTAG_INDEX),
		.JAw(JAw),
		.JINDEXw(JINDEXw),
		.JSTATUSw(JSTATUSw),
		.BUFF_Aw(BUFF_Aw),
		.SELw(SELw),
		.Aw(Aw),
		.Dw(Dw),
		.TAGw(TAGw),
		.JDw(JDw)
	)
	uut
	(
		.clk(clk),
		.dataavailable(dataavailable),
		.jtag_to_wb(jtag_to_wb),
		.readyfordata(readyfordata),
		.reset(reset),
		.wb_ack_o(wb_ack_o),
		.wb_adr_i(wb_adr_i),
		.wb_cyc_i(wb_cyc_i),
		.wb_dat_i(wb_dat_i),
		.wb_dat_o(wb_dat_o),
		.wb_irq(wb_irq),
		.wb_stb_i(wb_stb_i),
		.wb_to_jtag(wb_to_jtag),
		.wb_we_i(wb_we_i)
	);

initial begin 
    clk = 1'b0;
    forever clk = #10 ~clk;
end 

initial begin
	 jtag_to_wb=0;
	 reset=0;
	 wb_adr_i=0;
	 wb_cyc_i=0;
	 wb_dat_i=0;
	 wb_stb_i=0;
	 wb_we_i=0;

 //write your testbench code here
 


end //initial 
endmodule