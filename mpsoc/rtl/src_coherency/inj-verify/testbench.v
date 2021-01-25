`timescale     1ns/1ns

module testbench;

    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

    `define INCLUDE_TEST_LOCALPARAM
    `include "test_localparam.v"

    

// Ports

    reg  reset;
    reg  clk;

    reg  [NUM_OF_RNs-1 : 0] exclusive_all,likelyshared_all;
    
    wire [(NUM_OF_RNs * OPCODE_REQ)-1 : 0 ] ReqOpcode_all;
    reg [NUM_OF_RNs-1 : 0] Request_en_all;
    reg [OPCODE_REQ-1 : 0 ] ReqOpcode [NUM_OF_RNs-1 : 0];
    
    wire [NUM_OF_RNs-1 : 0] send_done_all;
    wire [NUM_OF_RNs-1 : 0] can_accept_new_req_all;
    
    
    wire [DATA_DAT*NUM_OF_RNs-1 : 0] Write_dat_all; 
    wire [ADDR_REQ*NUM_OF_RNs-1 : 0] read_addr_all;
    wire [CACHE_STATUSw*NUM_OF_RNs-1 : 0]  initial_cache_state_all;
    
    
    reg [DATA_DAT-1 : 0] Write_dat [NUM_OF_RNs-1 : 0]; 
    reg [ADDR_REQ-1 : 0] read_addr [NUM_OF_RNs-1 : 0];
    reg [CACHE_STATUSw-1 : 0]  initial_cache_state [NUM_OF_RNs-1 : 0];



     //core_cache_wr

localparam CACHE_ADDRw = ADDR_REQ,
              CACHE_DATAw = DATA_DAT;

    wire [CACHE_ADDRw*NUM_OF_RNs-1 : 0] core_to_cache_wr_addr_all;
    wire [CACHE_DATAw*NUM_OF_RNs-1 : 0] core_to_cache_wr_data_all;
    wire [CACHE_STATUSw*NUM_OF_RNs-1:0] core_to_cache_wr_state_all;
    wire [CACHE_ACTw*NUM_OF_RNs-1   :0] core_to_cache_wr_action_all;
    reg  [NUM_OF_RNs-1 : 0] core_to_cache_wr_en_all;
    reg  [NUM_OF_RNs-1 : 0] core_to_cache_wr_evict_all;
    wire [NUM_OF_RNs-1 : 0] cache_to_core_wr_hit_all;
    wire [NUM_OF_RNs-1 : 0] cache_to_core_wr_done_all;
    wire [NUM_OF_RNs-1 : 0] cache_to_core_wr_ready_all;



    reg [CACHE_ADDRw-1  : 0] core_to_cache_wr_addr  [NUM_OF_RNs-1 : 0];
    reg [CACHE_DATAw-1  : 0] core_to_cache_wr_data  [NUM_OF_RNs-1 : 0];
    reg [CACHE_STATUSw-1: 0] core_to_cache_wr_state [NUM_OF_RNs-1 : 0];
    reg [CACHE_ACTw-1   : 0] core_to_cache_wr_action[NUM_OF_RNs-1 : 0];
  
    

    reg [31 : 0] addr;
    
    
    
    reg   [WRAP_REQ_W-1:0]   wrapreq;
    reg                      wrapreqvalid;
    wire                     tim_wrap_strobereq;    
    reg [5:0] pck_injct_trace_file; 

	

task automatic gen_rntxn;
    input likelyshared;
    input excel;    
    input [ADDR_REQ-1   : 0] addr;
    input [OPCODE_REQ-1 : 0] opcode;
    input [31:0] id;
    begin

    likelyshared_all[id]=likelyshared;
    exclusive_all[id]=excel;
    read_addr[id]=addr;
    ReqOpcode[id] = opcode;
    @(posedge clk)  
    #1
    while ( can_accept_new_req_all[id]==1'b0) begin 
        #1; Request_en_all[id]=1'b0;
        @(posedge clk);  
    end 
    Request_en_all[id]=1'b1; 
    @(posedge clk) 
    Request_en_all[id]=1'b0;

    end
endtask



task automatic cache_evict;
    input [CACHE_ADDRw-1  : 0] addr;
    input [31 : 0 ] id;
    begin
    core_to_cache_wr_addr  [id]=addr;
    
    @(posedge clk)  
    #1
    while ( cache_to_core_wr_ready_all[id]==1'b0) begin 
        #1;
        core_to_cache_wr_en_all[id]=1'b0;
        core_to_cache_wr_evict_all[id]=1'b0;
        @(posedge clk);  
    end 
    core_to_cache_wr_en_all[id]=1'b1;
    core_to_cache_wr_evict_all[id]=1'b1;
    @(posedge clk) 
    core_to_cache_wr_en_all[id]=1'b0;
    core_to_cache_wr_evict_all[id]=1'b0;
    
    end
endtask

task automatic cache_write;
    input [CACHE_ADDRw-1  : 0] addr;
    input [CACHE_DATAw-1 :  0] dat;
    input [CACHE_STATUSw-1: 0] state;   
    input [31 : 0 ] id;
    begin
    core_to_cache_wr_addr  [id]=addr;
    core_to_cache_wr_data  [id]=dat;
    core_to_cache_wr_state [id]=state;
    core_to_cache_wr_action[id]=SNPF_REPLACE;
    core_to_cache_wr_evict_all[id]=1'b0;
    
    
    
    @(posedge clk)  
    #1
    while ( cache_to_core_wr_ready_all[id]==1'b0) begin 
        #1; 
        core_to_cache_wr_en_all[id]=1'b0;
        @(posedge clk);  
    end 
    core_to_cache_wr_en_all[id]=1'b1;  
    @(posedge clk) 
    core_to_cache_wr_en_all[id]=1'b0;      
    end
endtask


//file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/wr_rd_rd_clnu/trace/trace.bin", "rb");
task automatic pck_inject_rd_trace;
	input integer read_trace_num;
	begin
	if (file == 0) begin
   	    $display("data_file handle was NULL");
    	    $finish;
   	 end
    
        $display("***************start feeding traces to packet injector************");
    
    	wrapreq={WRAP_REQ_W{1'b0}};
    	wrapreqvalid=1'b0;
        trace_line=0;
     
	while (!$feof(file) && trace_line< read_trace_num)begin         
       		if(!$feof(file)) begin     
        		if($fread(trace, file)==-1) $display("ERROR: fread failed");
			trace_line=trace_line+1;
                	$display("trace_line=%d",trace_line);
        		if(!$feof(file)) begin //the last data read from the file is invalid?        
            		$display ("read trace num %d: %h\n",trace_line,trace);
                        wrapreq= trace & 64'h000000ffffffffff;
            		wrapreqvalid=1'b1;
            		#1 while(tim_wrap_strobereq==1'b0 ) begin #1 @(posedge clk); end
            		#1 @(posedge clk);
        	end
    	end       
    end
    wrapreqvalid=1'b0;
    $display("End of trace file at trace_line=%d ",trace_line);
    end
endtask







    genvar i;
    generate 
    for(i=0;i<NUM_OF_RNs;i=i+1)begin: rn
         assign Write_dat_all [(i+1)*DATA_DAT-1 : i*DATA_DAT]= Write_dat [i]; 
         assign read_addr_all [(i+1)*ADDR_REQ-1 : i*ADDR_REQ]= read_addr [i]; 
         assign ReqOpcode_all [(i+1)*OPCODE_REQ-1 : i*OPCODE_REQ]=ReqOpcode[i];
     
         assign initial_cache_state_all [(i+1)*CACHE_STATUSw-1 : i*CACHE_STATUSw]=initial_cache_state[i];    	
	 assign core_to_cache_wr_addr_all  [(i+1)*CACHE_ADDRw-1   : i*CACHE_ADDRw  ] = core_to_cache_wr_addr  [i];
         assign core_to_cache_wr_data_all  [(i+1)*CACHE_DATAw-1   : i*CACHE_DATAw  ] = core_to_cache_wr_data  [i];
         assign core_to_cache_wr_state_all [(i+1)*CACHE_STATUSw-1 : i*CACHE_STATUSw] = core_to_cache_wr_state [i];
         assign core_to_cache_wr_action_all[(i+1)*CACHE_ACTw-1    : i*CACHE_ACTw   ] = core_to_cache_wr_action[i];


    end 
    endgenerate 
    
    
    

// top module instance
    top_one_injct #(
        .VERBOSITY(VERBOSITY),
        .B(15),
        .TOPOLOGY("MESH"),
        .T1(T1),
        .T2(T2),
        .T3(1),
        .ROUTE_NAME("XY"),
	.SYS_CACHE_EN(SYS_CACHE_EN),
        .NUM_OF_RNs(NUM_OF_RNs),
        .NUM_OF_HNs(NUM_OF_HNs),
        .NUM_OF_SNs(NUM_OF_SNs)
    )
    top_mesh
    (
        .reset(reset),
        .clk(clk),
        
        .wrapreq(wrapreq),
        .wrapreqvalid(wrapreqvalid),
        .tim_wrap_strobereq(tim_wrap_strobereq),
        .likelyshared_all(likelyshared_all),
    	.exclusive_all(exclusive_all),
        .ReqOpcode_all(ReqOpcode_all),
        .Request_en_all(Request_en_all),
        .send_done_all(send_done_all),
        .can_accept_new_req_all(can_accept_new_req_all),
        .Write_dat_all(Write_dat_all),
        .read_addr_all(read_addr_all),
        .core_to_cache_wr_addr_all   (core_to_cache_wr_addr_all  ),
	    .core_to_cache_wr_data_all   (core_to_cache_wr_data_all  ),
        .core_to_cache_wr_state_all  (core_to_cache_wr_state_all ),
        .core_to_cache_wr_action_all (core_to_cache_wr_action_all),
        .core_to_cache_wr_en_all     (core_to_cache_wr_en_all    ),
        .core_to_cache_wr_evict_all  (core_to_cache_wr_evict_all ),
        .cache_to_core_wr_hit_all    (cache_to_core_wr_hit_all   ),
        .cache_to_core_wr_done_all   (cache_to_core_wr_done_all  ),
        .cache_to_core_wr_ready_all  (cache_to_core_wr_ready_all )
        
    );

initial begin 
    clk = 1'b0;
    forever clk = #10 ~clk;
end 



reg counter;

integer k; 
initial begin
     exclusive_all= {NUM_OF_RNs{1'b0}};
     likelyshared_all={NUM_OF_RNs{1'b0}};
  
     for(k=0;k<NUM_OF_RNs;k=k+1)begin 
       read_addr[k]=0;
       Write_dat[k]=0; 
       ReqOpcode[k]=0;
       Request_en_all[k]=1'b0;
       
        core_to_cache_wr_addr  [k]=0;
        core_to_cache_wr_data  [k]=0;
        core_to_cache_wr_state [k]=0;
        core_to_cache_wr_action[k]=0;
        core_to_cache_wr_en_all[k]=1'b0;
        core_to_cache_wr_evict_all[k]=1'b0;
       
     end
     
     reset=1;
   
 //write your testbench code here
    @(posedge clk)  reset =1'b0;
  




	`define INCLUDE_TEST_PATTERN
	`include "test_pattern.v"
     
     
     
    
    $stop;


end //initial 
endmodule



