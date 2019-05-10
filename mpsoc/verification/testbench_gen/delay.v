module start_delay_gen #(
	parameter NC     =	64 //number of cores

)(
	clk,
	reset,
	start_i,
	start_o
);

	input reset,clk,start_i;
	output [NC-1	:	0] start_o;
	reg start_i_reg;
	wire start;
	wire cnt_increase;
	reg  [NC-1	:	0] start_o_next;
	reg [NC-1	:	0] start_o_reg;
	
	assign start= start_i_reg|start_i;

	always @(*)begin 
		if(NC[0]==1'b0)begin // odd
			start_o_next={start_o[NC-3:0],start_o[NC-2],start};
		end else begin //even
			start_o_next={start_o[NC-3:0],start_o[NC-1],start};
		
		end	
	end
	
	reg [2:0] counter;
	assign cnt_increase=(counter==3'd0);
	always @(posedge clk or posedge reset) begin 
		if(reset) begin 
			
			start_o_reg		<= {NC{1'b0}};
			start_i_reg	<=1'b0;
			counter		<=3'd0;
		end else begin 
		   counter		<= counter+3'd1;
		   start_i_reg	<=start_i;
			if(cnt_increase | start) start_o_reg <=start_o_next;
			

		end//reset
	end //always

	assign start_o=(cnt_increase | start)? start_o_reg : {NC{1'b0}};

endmodule
