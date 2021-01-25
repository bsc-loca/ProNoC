`timescale     1ns/1ns

module testbench;


localparam REPEAT_NUM=1;

    parameter 
        T1 = 3,
        T2 = 3,
        NUM_OF_RNs=4,
        NUM_OF_HNs=4,
        NUM_OF_SNs=1,
        WRAP_REQ_W=64;

/*

  parameter 
        T1 = 2,
        T2 = 2,
        NUM_OF_RNs=2,
        NUM_OF_HNs=1,
        NUM_OF_SNs=1;

*/

    `define INCLUDE_CHI_LOCALPARAM
    `include "../../chi_localparam.v"
   
   
    
    

// Ports

     reg  reset;
     reg  clk;


    reg  [NUM_OF_RNs-1 : 0] Readshared_all;
    reg  [NUM_OF_RNs-1 : 0] ReadUnique_all; 
    reg  [NUM_OF_RNs-1 : 0] CleanUnique_all;
    reg  [NUM_OF_RNs-1 : 0] WriteBackFull_all;
    wire [NUM_OF_RNs-1 : 0] send_done_all;
    wire [NUM_OF_RNs-1 : 0] can_accept_new_req_all;
    
    
    wire [DATA_DAT*NUM_OF_RNs-1 : 0] Write_dat_all; 
    wire [ADDR_REQ*NUM_OF_RNs-1 : 0] read_addr_all;
    wire [CACHE_STATUSw*NUM_OF_RNs-1 : 0]  initial_cache_state_all;
    
    
    reg [DATA_DAT-1 : 0] Write_dat [NUM_OF_RNs-1 : 0]; 
    reg [ADDR_REQ-1 : 0] read_addr [NUM_OF_RNs-1 : 0];
    reg [CACHE_STATUSw-1 : 0]  initial_cache_state [NUM_OF_RNs-1 : 0];
    
    
    reg   [WRAP_REQ_W-1:0]   wrapreq;
    reg                      wrapreqvalid;
    wire                     tim_wrap_strobereq;
    
    
    genvar i;
    generate 
    for(i=0;i<NUM_OF_RNs;i=i+1)begin: rn
         assign Write_dat_all [(i+1)*DATA_DAT-1 : i*DATA_DAT]= Write_dat [i]; 
         assign read_addr_all [(i+1)*ADDR_REQ-1 : i*ADDR_REQ]= read_addr [i]; 
         assign initial_cache_state_all [(i+1)*CACHE_STATUSw-1 : i*CACHE_STATUSw]=initial_cache_state[i];    
    end 
    endgenerate 
    
    
     localparam VERBOSITY = 0
       | MONITORE_FLIT_INJECT
       | MONITORE_FLIT_INJECT_FILEDS
       | MONITORE_TXN_CMD 
       | MONITORE_WAIT_LIST
       | MONITORE_CACHE 
       | MONITORE_SNPF 
       | MONITORE_TXNID_GEN 
       | MONITORE_MAIN_MEM 
       | MONITORE_REQ_TYPE
       |0;


// top module instance
    top_one_injct #(
        .VERBOSITY(VERBOSITY),
        .B(15),
        .TOPOLOGY("MESH"),
        .T1(T1),
        .T2(T2),
        .T3(1),
        .ROUTE_NAME("XY"),
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
        
        .Readshared_all(Readshared_all),
        .ReadUnique_all(ReadUnique_all),
        .CleanUnique_all(CleanUnique_all),
        .WriteBackFull_all(WriteBackFull_all),
        .send_done_all(send_done_all),
        .can_accept_new_req_all(can_accept_new_req_all),
        .Write_dat_all(Write_dat_all),
        .read_addr_all(read_addr_all),
        .initial_cache_state_all(initial_cache_state_all)
    );   



initial begin 
    clk = 1'b0;
    forever clk = #10 ~clk;
end 





integer file;
reg [63: 0] trace;


integer  ignore_lines [99 : 0];

// ignore lines should be in ordered
integer ignore_line, trace_line;

initial begin 
    ignore_lines[0]=12000;
    ignore_lines[1]=16;
    ignore_lines[2]=20;
    ignore_lines[3]=22;
    ignore_lines[4]=0;//end
end














integer k=0; 
initial begin
     CleanUnique_all=0;
     ReadUnique_all=0;
     Readshared_all=0;
     WriteBackFull_all=0;
         
     for(k=0;k<NUM_OF_RNs;k=k+1)begin 
       read_addr[k]=0;
       initial_cache_state[k]=0;// invalid
       Write_dat[k]=0; 
     end
         
     
     reset=1;
   
 //write your testbench code here
    @(posedge clk)  reset =1'b0;
    #25000



$display("***************1st transition  WriteBackfull rn1************");   
    initial_cache_state[0]=CACHE_UD;
    initial_cache_state[1]=CACHE_I;
    Write_dat[1]=0;  
    repeat (REPEAT_NUM)begin 
        @(posedge clk)   #1;
       
         while ( can_accept_new_req_all[1]==1'b0) begin 
            
            WriteBackFull_all[1]=1'b0;
            @(posedge clk);  #1;
        end
        
      
        
        read_addr[1]= read_addr[1]+  CACHE_BLK_SIZ;
	Write_dat[1]= Write_dat[1]+ CACHE_BLK_SIZ;
        WriteBackFull_all[1]=1'b1;
       
    end
    
      @(posedge clk)  WriteBackFull_all[1]=1'b0;
    
     #10100             







$display("***************2nd transition: Readshared rn0 (pck injector)************");




    ignore_line=0;
    //    file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/rd/sample160000/validation_160000_trace.bin", "rb");
    //  file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/rd/validation_llsc-scalar/validation_llsc-scalar-160/validation_llsc-scalar_trace_0.bin","rb");
    file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/wr_rd_rd_clnu/trace/trace.bin", "rb");
    
    if (file == 0) begin
        $display("data_file handle was NULL");
        $finish;
    end
    
    
    
    wrapreq={WRAP_REQ_W{1'b0}};
    wrapreqvalid=1'b0;
    
    #4000000
    $display("***************start feeding traces to packet injector************");
     
     
    trace_line=0;
     
    while (!$feof(file))begin
         
        while(ignore_lines[ignore_line] == trace_line+1)begin
           
         if($fread(trace, file)==-1) $display("ERROR: fread failed"); trace_line=trace_line+1;
                 $display("trace_line=%d",trace_line);
             $display ("ignored trace num %d: %h\n",trace_line,trace);
         ignore_line=ignore_line+1;
        
    end

    if(!$feof(file)) begin 
    
    
        if($fread(trace, file)==-1) $display("ERROR: fread failed"); trace_line=trace_line+1;
                $display("trace_line=%d",trace_line);
        if(!$feof(file)) begin //the ast data read from the file is invalid?        
            $display ("read trace num %d: %h\n",trace_line,trace);
            
            wrapreq= trace & 64'h000000ffffffffff;
            wrapreqvalid=1'b1;
            #1 while(tim_wrap_strobereq==1'b0 ) begin #1 @(posedge clk); end
            #1 @(posedge clk);
        end
    end
    
       
    end
   
    
     wrapreqvalid=1'b0;
    #1000000;
 $display("End of trace file at trace_line=%d ",trace_line);


  
  
  
  
  
  $display("***************3rd transition: Readshared rn1************");
    initial_cache_state[0]=CACHE_UC;
    initial_cache_state[1]=CACHE_I;// invalid
    
    read_addr[0]=0;
    read_addr[1]=0;
    
    repeat(REPEAT_NUM)begin
        @(posedge clk)  
        #1
        while ( can_accept_new_req_all[1]==1'b0) begin 
            #1;
            Readshared_all[1]=1'b0;
            @(posedge clk);  
        end
        read_addr[1]=read_addr[1] + CACHE_BLK_SIZ;
        Readshared_all[1]=1'b1;
        //Readshared[0]=1'b1;
        //read_addr[0]=read_addr[0]+16;
        
                
    end
    
    @(posedge clk)  Readshared_all[1]=1'b0;
    
    //read_addr=0;
      #4100


$display("***************4rd transition: CleanUnique rn2************");
    initial_cache_state[0]=CACHE_SC;
    initial_cache_state[1]=CACHE_SC;
    
    read_addr[0]=0;
    read_addr[1]=0;
    read_addr[2]=0;
    
    repeat(REPEAT_NUM)begin
        @(posedge clk)  
        #1
        while ( can_accept_new_req_all[2]==1'b0) begin 
            #1;
            CleanUnique_all[2]=1'b0;
            @(posedge clk);  
        end
        read_addr[2]=read_addr[2] + CACHE_BLK_SIZ;
        CleanUnique_all[2]=1'b1;
        //Readshared[0]=1'b1;
        //read_addr[0]=read_addr[0]+16;
        
                
    end
    
    @(posedge clk)  CleanUnique_all[2]=1'b0;
    
    //read_addr=0;
      




    
     #102100000          
     
     $display(" %t: ***************End of simulation************",$time);
     
    
    $stop;


end //initial 
endmodule



