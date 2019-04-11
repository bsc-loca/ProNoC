module han_carison_pe#(
	parameter WIDTH=256
	)
	(
	input [WIDTH-1:0] in,
	output[WIDTH-1:0] out
);


function integer log2;
      input integer number;	begin	
         log2=0;	
         while(2**log2<number) begin	
            log2=log2+1;	
         end	
      end	
   endfunction // log2

	localparam LAYER_NUM	=log2(WIDTH)+2;


	wire [WIDTH-1	:	0]	layer [LAYER_NUM-1	:	0];
	
	assign layer[0]=in; 
	assign out=layer[LAYER_NUM-1];
	
	genvar i,j;
	generate
	

		
	 
	
	for(j=1;j<LAYER_NUM-1;j=j+1)begin :layer_lp1
		for(i=1;i<WIDTH;i=i+2)begin :width_lp1
			if(j==1 || (i>=(2**(j-1))))begin : gated1
					assign layer[j][i]= layer[j-1][i] | layer[j-1][i-(2**(j-1) )]; 
			end else begin 
					assign layer[j][i]=layer[j-1][i];			
			end
		end
	end
		
		
	for(j=1;j<LAYER_NUM-1;j=j+1)begin :layer_lp2
		for(i=0;i<WIDTH;i=i+2)begin :width_lp2
			assign layer[j][i]=layer[j-1][i];			
		end
	end
	
		
	
	for(i=0;i<WIDTH;i=i+1)begin :width_lp3
			if((i[0]==1'b0) && i>1) begin :last_layer_gated
						assign layer[LAYER_NUM-1][i]=(layer[LAYER_NUM-2][i]|layer[LAYER_NUM-2][i-1]);
			end else begin : last_layer_ngated
					assign layer[LAYER_NUM-1][i]=layer[LAYER_NUM-2][i];
			end //last_layer_ngated	
	end
		
		
		
	endgenerate





endmodule
