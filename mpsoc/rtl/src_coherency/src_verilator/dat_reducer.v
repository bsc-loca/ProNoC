module dat_reducer #(
	parameter FLIT_SIZE = 600,		
	parameter HASH_DAT =32
)
(
	    dat_in,
	    dat_out 
);
	
	 `define INCLUDE_CHI_LOCALPARAM
	`include "../chi_localparam.v"
	localparam DAT_HASH_FLIT_SIZE = FLIT_SIZE - DATA_DAT + HASH_DAT;

	input [FLIT_SIZE-1 : 0] dat_in;
	output [DAT_HASH_FLIT_SIZE-1:0] dat_out;

    
    wire [DATA_DAT-1:0]            data ;
    wire [DATACHECK_DAT-1:0]       datacheck;
    wire [POISON_DAT-1:0]          poison; 
    wire [FLIT_SIZE-DATA_DAT-DATACHECK_DAT-POISON_DAT-1 : 0] rest;
    assign {rest ,data ,datacheck  ,poison} = dat_in;
    wire [HASH_DAT-1 : 0] dat_hash = data[HASH_DAT-1 : 0];
     
    assign dat_out = {rest ,dat_hash ,datacheck  ,poison}; 
	 
	    	    	    
	    	    
   
endmodule



module dat_incr #(
	parameter FLIT_SIZE = 600,	
	parameter HASH_DAT =32
)
(
	    dat_in,
	    dat_out 
);
	
	 `define INCLUDE_CHI_LOCALPARAM
	`include "../chi_localparam.v"
	localparam DAT_HASH_FLIT_SIZE = FLIT_SIZE - DATA_DAT + HASH_DAT;

	input [DAT_HASH_FLIT_SIZE-1 : 0] dat_in;
	output [FLIT_SIZE -1:0] dat_out;

    
    wire [DATA_DAT-1:0]            data ;
    wire [DATACHECK_DAT-1:0]       datacheck;// not supported
    wire [POISON_DAT-1:0]          poison; // not supported
    wire [DAT_HASH_FLIT_SIZE-HASH_DAT-DATACHECK_DAT-POISON_DAT-1 : 0] rest;
    wire [HASH_DAT-1 : 0] dat_hash;    

    assign {rest ,dat_hash ,datacheck  ,poison} = dat_in;
    
    assign  data[DATA_DAT-1 :HASH_DAT] ={(DATA_DAT-HASH_DAT){1'b0}}; 
    assign  data[HASH_DAT-1 : 0] = dat_hash;
     
    assign dat_out = {rest ,data ,datacheck  ,poison}; 
   
	    	    
   
endmodule
