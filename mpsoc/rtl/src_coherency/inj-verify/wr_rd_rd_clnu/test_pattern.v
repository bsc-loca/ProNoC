`ifdef     INCLUDE_TEST_PATTERN  



    #25000



 $display("***************1st transition  WriteBackfull rn1************");   
    addr=0;
    repeat (REPEAT_NUM)begin 
	addr = addr+  CACHE_BLK_SIZ;	
	cache_write(addr,addr,CACHE_UD,1); //  (addr, dat, state,  id)  
    end
#200
    addr=0;
    repeat (REPEAT_NUM)begin 
	addr = addr+  CACHE_BLK_SIZ;	
	gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_WriteBackFull, 1); 
    end
   







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
    
    #1000000
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
    ReqOpcode[1] = REQ_OPCODE_ReadShared;
    repeat(REPEAT_NUM)begin
        @(posedge clk)  
        #1
        while ( can_accept_new_req_all[1]==1'b0) begin 
            #1;
            Request_en_all[1]=1'b0;
            @(posedge clk);  
        end
        read_addr[1]=read_addr[1] + CACHE_BLK_SIZ;
        Request_en_all[1]=1'b1;
        //Readshared[0]=1'b1;
        //read_addr[0]=read_addr[0]+16;
        
                
    end
    
    @(posedge clk)  Request_en_all[1]=1'b0;
  
  
 
 
      #4100


$display("***************4th transition: CleanUnique rn2************");
    initial_cache_state[0]=CACHE_SC;
    initial_cache_state[1]=CACHE_SC;
    
    read_addr[0]=0;
    read_addr[1]=0;
    read_addr[2]=0;
    ReqOpcode[2] = REQ_OPCODE_CleanUnique; 
    repeat(REPEAT_NUM)begin
        @(posedge clk)  
        #1
        while ( can_accept_new_req_all[2]==1'b0) begin 
            #1;
            Request_en_all[2]=1'b0;
            @(posedge clk);  
        end
        read_addr[2]=read_addr[2] + CACHE_BLK_SIZ;
        Request_en_all[2]=1'b1;
        //Readshared[0]=1'b1;
        //read_addr[0]=read_addr[0]+16;
        
                
    end
    
    @(posedge clk)  Request_en_all[2]=1'b0;
      




    
     #102100000          
     
     $display(" %t: ***************End of simulation************",$time);
     
    
  `endif


