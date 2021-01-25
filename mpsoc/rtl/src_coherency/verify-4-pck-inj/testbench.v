`timescale     1ns/1ns

module testbench;

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

    `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"

    

// Ports

    reg  reset;
    reg  clk;
   
    reg   [WRAP_REQ_W-1:0]   wrapreq [NUM_OF_RNs-1 : 0];
    reg   [NUM_OF_RNs-1 : 0] wrapreqvalid;
    wire  [NUM_OF_RNs-1 : 0] tim_wrap_strobereq;    


	wire [WRAP_REQ_W*NUM_OF_RNs-1 : 0] wrapreq_all;


//file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/wr_rd_rd_clnu/trace/trace.bin", "rb");
task automatic pck_inject_rd_trace;
    input integer in;
    input integer file_pt;
	input integer read_trace_num;
	reg [63: 0] trace;
	reg [31: 0] trace_line;
	begin
	if (file_pt == 0) begin
   	    $display("data_file handle was NULL");
    	    $finish;
   	 end
    
    $display("***************start feeding traces to packet injector %d************",in);
    
    wrapreq[in]={WRAP_REQ_W{1'b0}};
    wrapreqvalid[in]=1'b0;
    trace_line=0;
     
	while (!$feof(file_pt) && trace_line< read_trace_num)begin         
    	if(!$feof(file_pt)) begin     
       		if($fread(trace, file_pt)==-1) $display("ERROR: fread failed");
            trace_line=trace_line+1;
            $display("RN[%d] trace_line=%d",in,trace_line);
      		if(!$feof(file_pt)) begin //the last data read from the file is invalid?        
               	$display ("RN[%d] read trace num %d: %h\n",in,trace_line,trace);
                wrapreq[in]= trace & 64'h000000ffffffffff;
              	wrapreqvalid[in]=1'b1;
               	#1 while(tim_wrap_strobereq[in]==1'b0 ) begin #1 @(posedge clk); end
               	#1 @(posedge clk);
           	end
        end       
    end
    wrapreqvalid[in]=1'b0;
    $display("End of trace file %d at trace_line=%d ",in,trace_line[in]);
    $fclose(file_pt);
    #20100; 
    injct_done[in]=1'b1;
    end
endtask







    genvar i;
    generate 
    for(i=0;i<NUM_OF_RNs;i=i+1)begin: rn
        assign wrapreq_all [WRAP_REQ_W*(i+1)-1 : WRAP_REQ_W*i] =wrapreq[i];	
    end 
    endgenerate 
    
    
    

// top module instance
    top_chi_noc #(
        .VERBOSITY(VERBOSITY),
        .B(B),
        .TOPOLOGY(TOPOLOGY),
        .T1(T1),
        .T2(T2),
        .T3(T3),
        .ROUTE_NAME(ROUTE_NAME),
        .SYS_CACHE_EN(SYS_CACHE_EN),
        .NUM_OF_RNs(NUM_OF_RNs),
        .NUM_OF_HNs(NUM_OF_HNs),
        .NUM_OF_SNs(NUM_OF_SNs)
    )
    top_mesh
    (
        .reset(reset),
        .clk(clk),
        
        .wrapreq_all(wrapreq_all),
        .wrapreqvalid(wrapreqvalid),
        .tim_wrap_strobereq(tim_wrap_strobereq)
        
        
    );

initial begin 
    clk = 1'b0;
    forever clk = #10 ~clk;
end 



  `define INCLUDE_TEST_PATTERN
   `include "test_pattern.v"
     




	
     
     
    
   


endmodule



