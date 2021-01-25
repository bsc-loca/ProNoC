
`ifdef     INCLUDE_TEST_PATTERN

 

$display("***************1st transition  WriteBackfull rn1************");   
    initial_cache_state[0]=CACHE_UD;
    initial_cache_state[1]=CACHE_I;
    Write_dat[1]=0;
    ReqOpcode[1] = REQ_OPCODE_WriteBackFull;  
    repeat (REPEAT_NUM)begin 
        @(posedge clk)   #1;
       
         while ( can_accept_new_req_all[1]==1'b0) begin 
            
            Request_en_all[1]=1'b0;
            @(posedge clk);  #1;
        end
        
      
        
        read_addr[1]= read_addr[1]+  CACHE_BLK_SIZ;
	Write_dat[1]= Write_dat[1]+ CACHE_BLK_SIZ;
        Request_en_all[1]=1'b1;
       
    end
    
      @(posedge clk)  Request_en_all[1]=1'b0;
    
     #10100             





$display("***************2nd transition: Readshared rn0************");
    initial_cache_state[0]=CACHE_I;// invalid
    initial_cache_state[1]=CACHE_I;// invalid
    
    read_addr[0]=0;
    read_addr[1]=0;
    ReqOpcode[0] = REQ_OPCODE_ReadShared;
    repeat(REPEAT_NUM)begin
        @(posedge clk)  
        #1
        while ( can_accept_new_req_all[0]==1'b0) begin 
            #1;
            Request_en_all[0]=1'b0;
            @(posedge clk);  
        end
        read_addr[0]=read_addr[0]+ CACHE_BLK_SIZ;
        Request_en_all[0]=1'b1;
        //Readshared[0]=1'b1;
        //read_addr[0]=read_addr[0]+16;
        
                
    end
    
    @(posedge clk)  Request_en_all[0]=1'b0;
    
    //read_addr=0;
      #4100  
  
  
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
    
    //read_addr=0;
      #4100



      
     #180100          

`endif
