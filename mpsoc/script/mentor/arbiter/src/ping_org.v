



module ping_org_2_gg2 (
   R, 
   G,   
   Gg,
   reset,
   clk  
);

    parameter Ggw=2;
    
    input  [1       :   0]  R; 
    output [1       :   0]  G;
    input  [Ggw-1   :   0]  Gg;
    input                      reset, clk;

    reg  Fi;
    wire Fo;
    
    wire [1     :   0]      G_one;
    wire                        Fo_one;
    
    assign G_one[0] = (~R[1]    & R[0]) | (R[0] & ~Fi   );
    assign G_one[1] = (~R[0]    & R[1]) | (R[1] &  Fi   );
    assign Fo_one    = (R[0]    & ~Fi   ) | (Fi      & ~R[1]    );
    
    wire [Ggw       :   0]      G_gen_0;
    wire [Ggw       :   0]      G_gen_1;
    wire                            Gg_and;
    
    assign G_gen_0={Gg,G_one[0]};
    assign G_gen_1={Gg,G_one[1]};
    
    assign G[0]=& G_gen_0;
    assign G[1]=& G_gen_1;
    assign Gg_and= & Gg;
    
    assign Fo= (Gg_and & Fo_one)|( ~Gg_and & Fi);
    
    
    always @(posedge clk or posedge reset)begin 
        if(reset)begin 
            Fi<=1'b0;
        end else begin 
            Fi<=Fo;
        end
    end//always 
    
    
endmodule




module ping_org_2_gg1 (
   R, 
   G,   
   Gg,
   reset,
   clk  
);
   
       
    input  [1   :   0]  R; 
    output [1   :   0]  G;
    input               Gg;
    input               reset, clk;

    reg  Fi;
    wire Fo;
    
    wire [1     :   0]      G_one;
    wire                        Fo_one;
    
    assign G_one[0] = (~R[1]    & R[0]) | (R[0] & ~Fi   );
    assign G_one[1] = (~R[0]    & R[1]) | (R[1] &  Fi   );
    assign Fo_one    = (R[0]    & ~Fi   ) | (Fi      & ~R[1]    );
    
    wire [1      :   0]      G_gen_0;
    wire [1      :   0]      G_gen_1;
  
    
    assign G_gen_0={Gg,G_one[0]};
    assign G_gen_1={Gg,G_one[1]};
    
    assign G[0]=& G_gen_0;
    assign G[1]=& G_gen_1;
    
    
    assign Fo= (Gg & Fo_one)|( ~Gg & Fi);
    
    
    always @(posedge clk or posedge reset)begin 
        if(reset)begin 
            Fi<=1'b0;
        end else begin 
            Fi<=Fo;
        end
    end//always 
    
    
endmodule




/**************
	 ping_org_2 
*************/



module ping_org_2 (
   R, 
   G,
   any_grant,   
   reset,
   clk  
);
   
       
    input  [1   :   0]  R; 
    output [1   :   0]  G;
    output              any_grant;
    input               reset, clk;

    reg  Fi;
    wire Fo;
    
    wire [1     :   0]      G_one;
    wire                    Fo_one;
    
    assign G_one[0] = (~R[1]    & R[0]) | (R[0] & ~Fi   );
    assign G_one[1] = (~R[0]    & R[1]) | (R[1] &  Fi   );
    assign Fo_one   = ( R[0]    & ~Fi ) | (Fi   & ~R[1] );
    assign any_grant=|R;
      
   
    
    assign G[0]=G_one[0];
    assign G[1]=G_one[1];
    
    
    assign Fo= (any_grant & Fo_one)|( ~any_grant & Fi);
    
    
    always @(posedge clk or posedge reset)begin 
        if(reset)begin 
            Fi<=1'b0;
        end else begin 
            Fi<=Fo;
        end
    end//always 
    
    
endmodule




/**************
	ping_org_4 
*************/



module ping_org_4 (
	R, 
   G,
	Gin,
	any_grant,
   reset,
   clk	
);

	input  [3		: 	0]	R; 
    output [3		:	0]	G;
	input 					Gin;
	output 					any_grant;	
	input                   reset, clk;

	
	wire [1:0]Gg0,Gg1;
	wire [1:0] R_inter, G_inter;
	assign R_inter[0]=R[0]|R[1];
	assign R_inter[1]=R[2]|R[3];	
	assign Gg0 = {Gin,G_inter[0]};
	assign Gg1 = {Gin,G_inter[1]};

	

	ping_org_2_gg2  leaf0 (
		.R(R[1:0]), 
		.G(G[1:0]),	
		.Gg(Gg0),
		.reset(reset),
		.clk(clk)	
	);
	
	ping_org_2_gg2  leaf1 (
		.R(R[3:2]), 
		.G(G[3:2]),	
		.Gg(Gg1),
		.reset(reset),
		.clk(clk)	
	);	
	
	ping_org_2_gg1  inter (
		.R(R_inter), 
		.G(G_inter),	
		.Gg(Gin),
		.reset(reset),
		.clk(clk)	
	);

	
	assign any_grant = |R;

endmodule	








/**************
	ping_org_8 
*************/



module ping_org_8 (
	R, 
    G,
	Gin,
	any_grant,
   reset,
   clk	
);

	input  [7		: 	0]	R; 
   output [7		:	0]	G;
	input 					Gin;
	output 					any_grant;	
	input					   reset, clk;


	wire [1:0] R_inter, G_inter;
	
	ping_org_4 leaf0 (
		.R(R[3:0]), 
		.G(G[3:0]),	
		.Gin(G_inter[0]),
		.reset(reset),
		.any_grant(R_inter[0]),
		.clk(clk)	
	);
	
	ping_org_4  leaf1 (
		.R(R[7:4]), 
		.G(G[7:4]),	
		.Gin(G_inter[1]),
		.any_grant(R_inter[1]),
		.reset(reset),
		.clk(clk)	
	);
	
	

	
	
	ping_org_2_gg1  inter (
		.R(R_inter), 
		.G(G_inter),	
		.Gg(Gin),
		.reset(reset),
		.clk(clk)	
	);

	assign any_grant= | R_inter;



endmodule





/**************
	ping_org_16 
*************/



module ping_org_16 (
	R, 
   G,
	Gin,
	any_grant,
   reset,
   clk	
);

	
	input  [15		: 	0]	R; 
   output [15		:	0]	G;
	input 					Gin;
	output 					any_grant;	
	input					   reset, clk;


	wire [3:0] R_inter, G_inter;
	
	ping_org_4 leaf0 (
		.R(R[3:0]), 
		.G(G[3:0]),	
		.Gin(G_inter[0]),
		.reset(reset),
		.any_grant(R_inter[0]),
		.clk(clk)	
	);
	
	ping_org_4  leaf1 (
		.R(R[7:4]), 
		.G(G[7:4]),	
		.Gin(G_inter[1]),
		.any_grant(R_inter[1]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_4  leaf2 (
		.R(R[11:8]), 
		.G(G[11:8]),	
		.Gin(G_inter[2]),
		.any_grant(R_inter[2]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_4  leaf3 (
		.R(R[15:12]), 
		.G(G[15:12]),	
		.Gin(G_inter[3]),
		.any_grant(R_inter[3]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_4  inter (
		.R(R_inter), 
		.G(G_inter),	
		.Gin(Gin),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)	
	);


	


endmodule





/**************
	ping_org_32 
*************/



module ping_org_32 (
	R, 
   G,
	Gin,
	any_grant,
   reset,
   clk	
);

	
	input  [31		: 	0]	R; 
   output [31		:	0]	G;
	input 					Gin;
	output 					any_grant;	
	input					   reset, clk;


	wire [1:0] R_inter, G_inter;
	
	ping_org_16 leaf0 (
		.R(R[15:0]), 
		.G(G[15:0]),	
		.Gin(G_inter[0]),
		.reset(reset),
		.any_grant(R_inter[0]),
		.clk(clk)	
	);
	
	ping_org_16  leaf1 (
		.R(R[31:16]), 
		.G(G[31:16]),	
		.Gin(G_inter[1]),
		.any_grant(R_inter[1]),
		.reset(reset),
		.clk(clk)	
	);
	

	ping_org_2_gg1  inter (
		.R(R_inter), 
		.G(G_inter),	
		.Gg(Gin),
		.reset(reset),
		.clk(clk)	
	);

	assign any_grant= | R_inter;
	
endmodule




/**************
	ping_org_64 
*************/



module ping_org_64 (
	R, 
   G,
	Gin,
	any_grant,
   reset,
   clk	
);

	
	input  [63		: 	0]	R; 
   output [63		:	0]	G;
	input 					Gin;
	output 					any_grant;	
	input					   reset, clk;


	wire [3:0] R_inter, G_inter;
	
	ping_org_16 leaf0 (
		.R(R[15:0]), 
		.G(G[15:0]),	
		.Gin(G_inter[0]),
		.reset(reset),
		.any_grant(R_inter[0]),
		.clk(clk)	
	);
	
	ping_org_16  leaf1 (
		.R(R[31:16]), 
		.G(G[31:16]),	
		.Gin(G_inter[1]),
		.any_grant(R_inter[1]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_16  leaf2 (
		.R(R[47:32]), 
		.G(G[47:32]),	
		.Gin(G_inter[2]),
		.any_grant(R_inter[2]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_16  leaf3 (
		.R(R[63:48]), 
		.G(G[63:48]),	
		.Gin(G_inter[3]),
		.any_grant(R_inter[3]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_4  inter (
		.R(R_inter), 
		.G(G_inter),	
		.Gin(Gin),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)	
	);




endmodule






/**************
	ping_org_128
*************/



module ping_org_128 (
	R, 
   G,
	Gin,
	any_grant,
   reset,
   clk	
);

	
	input  [127		: 	0]	R; 
   output [127		:	0]	G;
	input 					Gin;
	output 					any_grant;	
	input					   reset, clk;


	wire [1:0] R_inter, G_inter;
	
	ping_org_64 leaf0 (
		.R(R[63:0]), 
		.G(G[63:0]),	
		.Gin(G_inter[0]),
		.reset(reset),
		.any_grant(R_inter[0]),
		.clk(clk)	
	);
	
	ping_org_64  leaf1 (
		.R(R[127:64]), 
		.G(G[127:64]),	
		.Gin(G_inter[1]),
		.any_grant(R_inter[1]),
		.reset(reset),
		.clk(clk)	
	);
	

	ping_org_2_gg1  inter (
		.R(R_inter), 
		.G(G_inter),	
		.Gg(Gin),
		.reset(reset),
		.clk(clk)	
	);

	assign any_grant= | R_inter;
	
endmodule




/**************
	ping_org_64 
*************/



module ping_org_256 (
	R, 
   G,
	Gin,
	any_grant,
   reset,
   clk	
);

	
	input  [255		: 	0]	R; 
   output [255		:	0]	G;
	input 					Gin;
	output 					any_grant;	
	input					   reset, clk;


	wire [3:0] R_inter, G_inter;
	
	ping_org_64 leaf0 (
		.R(R[63:0]), 
		.G(G[63:0]),	
		.Gin(G_inter[0]),
		.reset(reset),
		.any_grant(R_inter[0]),
		.clk(clk)	
	);
	
	ping_org_64  leaf1 (
		.R(R[127:64]), 
		.G(G[127:64]),	
		.Gin(G_inter[1]),
		.any_grant(R_inter[1]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_64  leaf2 (
		.R(R[191:128]), 
		.G(G[191:128]),	
		.Gin(G_inter[2]),
		.any_grant(R_inter[2]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_64  leaf3 (
		.R(R[255:192]), 
		.G(G[255:192]),	
		.Gin(G_inter[3]),
		.any_grant(R_inter[3]),
		.reset(reset),
		.clk(clk)	
	);
	
	
	ping_org_4  inter (
		.R(R_inter), 
		.G(G_inter),	
		.Gin(Gin),
		.any_grant(any_grant),
		.reset(reset),
		.clk(clk)	
	);


endmodule

