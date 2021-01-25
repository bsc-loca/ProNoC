
`ifdef     INCLUDE_TEST_PATTERN

$display("***************1st transition  WriteBackfull rn1************");   
    initial_cache_state[0]=CACHE_UD;
    initial_cache_state[1]=CACHE_I;
    Write_dat[1]={400{1'b1}};
    ReqOpcode[1] = REQ_OPCODE_WriteBackFull;
    repeat (REPEAT_NUM)begin 
        @(posedge clk)   #1;
       
         while ( can_accept_new_req_all[1]==1'b0) begin 
            
            Request_en_all[1]=1'b0;
            @(posedge clk);  #1;
        end
        
      
        
        read_addr[1]= read_addr[1]+ 2* CACHE_BLK_SIZ+8;
	
        Request_en_all[1]=1'b1;
       
    end
    
      @(posedge clk)  Request_en_all[1]=1'b0;
    
     #10100        
   






$display("***************4th transition: AtomicLoad_ADD rn2************");
    initial_cache_state[0]=CACHE_I;// invalid
    initial_cache_state[1]=CACHE_I;// invalid
    
    
    read_addr[2]=0;
    ReqOpcode[2] = REQ_OPCODE_AtomicSwap;
    Write_dat[2]={8'hAA,64'h00};
    repeat(REPEAT_NUM)begin
        @(posedge clk)  
        #1
        while ( can_accept_new_req_all[2]==1'b0) begin 
            
            Request_en_all[2]=1'b0;
            @(posedge clk);  #1;
        end
        read_addr[2]=   2* CACHE_BLK_SIZ+8;
        Request_en_all[2]=1'b1;
        
     /*   
        @(posedge clk)  
        #1
        while ( can_accept_new_req_all[0]==1'b0) begin 
            
            Request_en_all[0]=1'b0;
            @(posedge clk);  #1;
        end
        read_addr[0]=       CACHE_BLK_SIZ;
        Request_en_all[0]=1'b1;
        
        
        
        //Readshared[0]=1'b1;
        //read_addr[0]=read_addr[0]+16;
        
                
   /
	@(posedge clk)  
        #1
        while ( can_accept_new_req_all[0]==1'b0) begin 
            
            Request_en_all[0]=1'b0;
            @(posedge clk);  #1;
        end
        read_addr[0]=read_addr[0]+  CACHE_BLK_SIZ ;
        Request_en_all[0]=1'b1;

*/








 end
    
    @(posedge clk)  Request_en_all[2]=1'b0;


















    
    //read_addr=0;
       #10100     
      
     #180100          

`endif
