/*
 ***************************************************
 * Round-robin arbiter with variable priority vector
 * ---------------------
 * G. Dimitrakopoulos
 * Nov. 2008
 ***************************************************
 */


module fra #(
		parameter	ARBITER_WIDTH	=4,
		parameter	CHOISE 			=1  // 0 blind round-robin and 1 true round robin
)
(	
   clk, 
   reset, 
   request, 
   grant,
   any_grant
);

	function integer log2;
      input integer number;	begin	
         log2=0;	
         while(2**log2<number) begin	
            log2=log2+1;	
         end	
      end	
   endfunction // log2 

  localparam N = ARBITER_WIDTH;
  localparam S = log2(ARBITER_WIDTH); // ceil of log_2 of N - put manually
  

  // I/O interface
  input           clk;
  input           reset;
  input  [N-1:0]  request;
  output [N-1:0]  grant;
  output          any_grant;
  
  
  // internal pointers
  reg [N-1:0] priority_reg; // one-hot priority vector
  
  
  // Outputs of combinational logic - real wires - declared as regs for use in a alway block
  // Better to change to wires and use generate statements in the future
  
  wire [N-1:0]  g[S:0]; // S levels of priority generate
  wire [N-1:0]  p[S-1:0]; // S-1 levels of priority propagate

  // internal synonym wires of true outputs any_grant and grant 
  wire anyGnt;
  wire [N-1:0] gnt;

  assign any_grant = anyGnt;
  assign grant = gnt;
  
  


/////////////////////////////////////////////////
// Parallel prefix arbitration phase
/////////////////////////////////////////////////
  genvar i,j;

  // arbitration phase
        // transfer request vector to the first propagate positions
  	assign    p[0] = {~request[N-2:0], ~request[N-1]};

      // transfer priority vector to the first generate positions
      	assign g[0] = priority_reg;
      
      // first log_2n - 1 prefix levels
generate
      for (i=1; i < S; i = i + 1) begin: lp1
        for (j = 0; j < N ; j = j + 1) begin: lp2
          if (j<2**(i-1) ) begin: lp3
           assign g[i][j] = g[i-1][j] | (p[i-1][j] & g[i-1][N+j-2**(i-1)]);           
           assign p[i][j] = p[i-1][j] & p[i-1][N+j-2**(i-1)];
          end else begin: lp4
            assign g[i][j] = g[i-1][j] | (p[i-1][j] & g[i-1][j-2**(i-1)]);           
            assign p[i][j] = p[i-1][j] & p[i-1][j-2**(i-1)];
          end            
        end
      end  
      
      // last prefix level
      for (j = 0; j < N; j = j + 1) begin: lp5
        if (j<2**(S-1) ) begin:lp6 
          assign g[S][j] = g[S-1][j] | (p[S-1][j] & g[S-1][N+j-2**(S-1)]);           
        end else begin :lp7
          assign g[S][j] = g[S-1][j] | (p[S-1][j] & g[S-1][j-2**(S-1)]);  
	end         
      end
endgenerate

  // any grant generation at last prefix level
  assign anyGnt = ~(p[S-1][N-1] & p[S-1][N/2-1]);
  
  // output stage logic
  assign gnt  = request & g[S];  


/////////////////////////////////////////////////
// Pointer update logic
// ------------------------
// Version 1 - blind round robin CHOISE = 0
// Priority visits each input in a circural manner irrespective the granted output
// ------------------------
// Version 2 - true round robin CHOISE = 1
// Priority moves next to the granted output
// ------------------------
// Priority moves only when a grant was given, i.e., at least one active request
//////////////////////////////////////////////////

  always@(posedge clk or posedge reset)
    begin
      if (reset == 1'b1) begin
        priority_reg <= 1;
      end else begin
        // update pointers only if at leas one match exists
        if (anyGnt == 1'b1) begin  
            if (CHOISE == 0) begin // blind circular round robin
                // shift left one-hot priority vector
                priority_reg[N-1:1] <= priority_reg[N-2:0];
                priority_reg[0] <= priority_reg[N-1];  
            end else begin // true round robin
                // shift left one-hot grant vector
                priority_reg[N-1:1] <= grant[N-2:0];
                priority_reg[0] <= grant[N-1];  
            end    
        end
      end
    end

 
endmodule




