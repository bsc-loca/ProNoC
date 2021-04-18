/**************************************
* Module: single_port_ram_with_reset
* Date:2019-04-25  
* Author: alireza     
*
* Description: The RAM contents are set to zero at reset time. 
***************************************/

`timescale   1ns/1ns

module cache_ram #(
    parameter Dw=8, 
    parameter Aw=6,
    parameter RESET_RAM_CONTENT= "ENABLE",
    parameter BYTE_WR_EN= "YES",//"YES","NO"
    parameter INITIAL_EN= "NO",
    parameter INIT_FILE= "sw/ram/ram0.txt"// ram initial file in hex ascii format
)
(
   data,
   addr,
   byteen,
   we,
   clk,
   reset,
   not_ready,
   q   
);   
    /* verilator lint_off WIDTH */
    localparam BYTE_ENw= ( BYTE_WR_EN == "YES")? Dw/8 : 1;
    /* verilator lint_on WIDTH */
    
    input [(Dw-1):0] data;
    input [(Aw-1):0] addr;
    input [BYTE_ENw-1   :   0]  byteen;
    input we, clk;
    output  [(Dw-1):0] q;
    input reset;
    output not_ready;    


    generate
    if(RESET_RAM_CONTENT == "ENABLE") begin: multi 
    
        single_port_ram_with_reset #(
        	.Dw(Dw),
        	.Aw(Aw),
        	.BYTE_WR_EN(BYTE_WR_EN),
        	.INITIAL_EN(INITIAL_EN),
        	.INIT_FILE(INIT_FILE)
        )
        ram
        (
        	.data(data),
        	.addr(addr),
        	.byteen(byteen),
        	.we(we),
        	.clk(clk),
        	.q(q),
        	.reset(reset),
        	.not_ready(not_ready)
        );
    end else begin 
    
        generic_single_port_ram #(
        	.Dw(Dw),
            .Aw(Aw),
            .BYTE_WR_EN(BYTE_WR_EN),
            .INITIAL_EN(INITIAL_EN),
            .INIT_FILE(INIT_FILE)
        )
        ram
        (
           	.data(data),
        	.addr(addr),
        	.byteen(byteen),
        	.we(we),
        	.clk(clk),
        	.q(q)
        );
        assign not_ready = 1'b0;
    end
    endgenerate



endmodule



module cache_dual_port_ram #(
    parameter Dw=8, 
    parameter Aw=6,
    parameter RESET_RAM_CONTENT= "ENABLE",
    parameter BYTE_WR_EN= "NO",//"YES","NO"
    parameter INITIAL_EN= "NO",
    parameter INIT_FILE= "sw/ram/ram0.txt"// ram initial file in hex ascii format
)
(
   data_a,
   addr_a,
   byteen_a,
   we_a,
   q_a,
   
   data_b,
   addr_b,
   byteen_b,
   we_b,
   
   
   clk,
   reset,
   not_ready,
   q_b   
);   

    /* verilator lint_off WIDTH */
    localparam BYTE_ENw= ( BYTE_WR_EN == "YES")? Dw/8 : 1;
    /* verilator lint_on WIDTH */
    
    input [(Dw-1):0] data_a, data_b;
    input [(Aw-1):0] addr_a, addr_b;
    input [BYTE_ENw-1   :   0]  byteen_a, byteen_b;
    input we_a , we_b, clk;
    output  [(Dw-1):0] q_a, q_b;
    input reset;
    output not_ready;    


    generate
    if(RESET_RAM_CONTENT == "ENABLE") begin: multi 
        
        dual_port_ram_with_reset #(
        	.Dw(Dw),
            .Aw(Aw),
            .BYTE_WR_EN(BYTE_WR_EN),
            .INITIAL_EN(INITIAL_EN),
            .INIT_FILE(INIT_FILE)
        )
        dual_port_ram
        (
        	.data_a(data_a),
        	.data_b(data_b),
        	.addr_a(addr_a),
        	.addr_b(addr_b),
        	.byteen_a(byteen_a),
        	.byteen_b(byteen_b),
        	.we_a(we_a),
        	.we_b(we_b),
        	.clk(clk),
        	.q_a(q_a),
        	.q_b(q_b),
        	.reset(reset),
        	.not_ready(not_ready)
        );
        
      
    
       
    end else begin 
    
        generic_dual_port_ram #(
        	 .Dw(Dw),
            .Aw(Aw),
            .BYTE_WR_EN(BYTE_WR_EN),
            .INITIAL_EN(INITIAL_EN),
            .INIT_FILE(INIT_FILE)
        )
        dual_port_ram
        (
        	.data_a(data_a),
        	.data_b(data_b),
        	.addr_a(addr_a),
        	.addr_b(addr_b),
        	.byteena_a(byteen_a),
        	.byteena_b(byteen_b),
        	.we_a(we_a),
        	.we_b(we_b),
        	.clk(clk),
        	.q_a(q_a),
        	.q_b(q_b)
        );
            
     
        assign not_ready = 1'b0;
    end
    endgenerate



endmodule






module  single_port_ram_with_reset #(
    parameter Dw=8, 
    parameter Aw=6,
    parameter BYTE_WR_EN= "YES",//"YES","NO"
    parameter INITIAL_EN= "NO",
    parameter INIT_FILE= "sw/ram/ram0.txt"// ram initial file in hex ascii format
)
(
   data,
   addr,
   byteen,
   we,
   clk,
   reset,
   not_ready,
   q
   
);   
    /* verilator lint_off WIDTH */
    localparam BYTE_ENw= ( BYTE_WR_EN == "YES")? Dw/8 : 1;
    /* verilator lint_on WIDTH */
    
    input [(Dw-1):0] data;
    input [(Aw-1):0] addr;
    input [BYTE_ENw-1   :   0]  byteen;
    input we, clk;
    output  [(Dw-1):0] q;
    input reset;
    output not_ready;    
    
    reg [Aw-1: 0] counter,counter_next;
    reg busy,busy_next;
    wire [Dw-1 : 0] ram_data;
    wire [Aw-1:0] ram_addr;
    wire ram_we;    
    
    assign not_ready = busy;
    
    always @(posedge clk or posedge reset) begin
        if(reset)begin 
            counter <= {Aw{1'b0}};
            busy<= 1'b1;
        end else begin 
            counter <= counter_next;
            busy<= busy_next;
        end        
    end
        
    always @(*) begin
        counter_next = counter;
        busy_next = busy;
        if(busy) counter_next = counter +1'b1;
        if(counter=={Aw{1'b1}}) busy_next = 1'b0;
    end

   assign ram_data = (busy)? {Dw{1'b0}}: data;
   assign ram_addr= (busy)? counter : addr;
   assign ram_we= (busy)? 1'b1 : we;


    generic_single_port_ram #(
    	.Dw(Dw),
    	.Aw(Aw),
    	.BYTE_WR_EN(BYTE_WR_EN),
    	.INITIAL_EN(INITIAL_EN),
    	.INIT_FILE(INIT_FILE)
    )
    ram
    (
    	.data(ram_data),
    	.addr(ram_addr),
    	.byteen(byteen),
    	.we(ram_we),
    	.clk(clk),
    	.q(q)
    );
        

endmodule




module  dual_port_ram_with_reset #(
    parameter Dw=8, 
    parameter Aw=6,
    parameter BYTE_WR_EN= "NO",//"YES","NO"
    parameter INITIAL_EN= "NO",
    parameter INIT_FILE= "sw/ram/ram0.txt"// ram initial file in hex ascii format
)
(
   
   data_a,
   addr_a,
   byteen_a,
   we_a,
   
   data_b,
   addr_b,
   byteen_b,
   we_b,    
   
   clk,
   reset,
   not_ready,
   q_a,
   q_b
   
);   

    /* verilator lint_off WIDTH */
    localparam BYTE_ENw= ( BYTE_WR_EN == "YES")? Dw/8 : 1;
    /* verilator lint_on WIDTH */
    
    input [(Dw-1):0] data_a,data_b;
    input [(Aw-1):0] addr_a,addr_b;
    input [BYTE_ENw-1   :   0]  byteen_a, byteen_b;
    input we_a, we_b, clk;
    output  [(Dw-1):0] q_a, q_b;
    input reset;
    output not_ready;    
    
    reg [Aw-1: 0] counter,counter_next;
    reg busy,busy_next;
    wire [Dw-1 : 0] ram_data_a;
    wire [Aw-1:0] ram_addr_a;
    wire ram_we_a;    
    
    assign not_ready = busy;
    
    always @(posedge clk or posedge reset) begin
        if(reset)begin 
            counter <= {Aw{1'b0}};
            busy<= 1'b1;
        end else begin 
            counter <= counter_next;
            busy<= busy_next;
        end        
    end
        
    always @(*) begin
        counter_next = counter;
        busy_next = busy;
        if(busy) counter_next = counter +1'b1;
        if(counter=={Aw{1'b1}}) busy_next = 1'b0;
    end

   assign ram_data_a = (busy)? {Dw{1'b0}}: data_a;
   assign ram_addr_a= (busy)? counter : addr_a;
   assign ram_we_a= (busy)? 1'b1 : we_a;


    generic_dual_port_ram #(
    	.Dw(Dw),
    	.Aw(Aw),
    	.BYTE_WR_EN(BYTE_WR_EN),
    	.INITIAL_EN(INITIAL_EN),
    	.INIT_FILE(INIT_FILE)
    )
    generic_dual_port_ram(
    	.data_a(ram_data_a),
    	.data_b(data_b),
    	.addr_a(ram_addr_a),
    	.addr_b(addr_b),
    	.byteena_a(byteen_a),
    	.byteena_b(byteen_b),
    	.we_a(ram_we_a),
    	.we_b(we_b),
    	.clk(clk),
    	.q_a(q_a),
    	.q_b(q_b)
    );

    

endmodule


