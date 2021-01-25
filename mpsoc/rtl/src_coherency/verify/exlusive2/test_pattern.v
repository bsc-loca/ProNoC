
`ifdef     INCLUDE_TEST_PATTERN

 

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
   
 #10100   



$display("***************1st transition  WriteBackfull rn1************");   
    addr=0;
    repeat (REPEAT_NUM)begin 
	addr = addr+ 100 * CACHE_BLK_SIZ;	
	cache_write(addr,addr,CACHE_UD,1); //  (addr, dat, state,  id)  
    end
#200
    addr=0;
    repeat (REPEAT_NUM)begin 
	addr = addr+ 100* CACHE_BLK_SIZ;	
	gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_WriteBackFull, 1);         
    end
   
 #10100   






$display("*************** \
1-Readshared Exlusive rn0 \
2-Readshared Exlusive rn1 \
3- CleanUnique Exlusive rn0 must success \
4- CleanUnique Exlusive rn1 must success \
************");

 read_addr[0]=0;
 read_addr[1]=0;
 repeat(REPEAT_NUM)begin

  
  
  
    //1-Readshared Exlusive rn0 
    initial_cache_state[0]=CACHE_I;// invalid
    initial_cache_state[1]=CACHE_I;// invalid
    ReqOpcode[0] = REQ_OPCODE_ReadShared;
     
    @(posedge clk) #1
    while ( can_accept_new_req_all[0]==1'b0) begin 
    #1;    
        Request_en_all[0]=1'b0;
        @(posedge clk);  
    end
    read_addr[0]=read_addr[0]+ CACHE_BLK_SIZ;
    exclusive_all[0]=1'b1;
    Request_en_all[0]=1'b1;    
    
    @(posedge clk)  #1
    Request_en_all[0]=1'b0;
    exclusive_all[0]=1'b0;
    initial_cache_state[0]=CACHE_UC;     
    #4100;  
 

    //2-Readshared Exlusive rn1 
    ReqOpcode[1] = REQ_OPCODE_ReadShared;
   
     
    @(posedge clk) #1
    while ( can_accept_new_req_all[1]==1'b0) begin 
    #1;    
        Request_en_all[1]=1'b0;
        @(posedge clk);  
    end
    read_addr[1]=read_addr[1]+ 100 * CACHE_BLK_SIZ;
    exclusive_all[1]=1'b1;
    Request_en_all[1]=1'b1;    
    
    @(posedge clk)  #1
    Request_en_all[1]=1'b0;
    exclusive_all[1]=1'b0;
    initial_cache_state[1]=CACHE_UC; 
    initial_cache_state[0]=CACHE_UC; 
    #4100;  
 




    //3- CleanUnique Exlusive rn0 must sucecss
    
    ReqOpcode[0] = REQ_OPCODE_CleanUnique;
    
    @(posedge clk) #1
    while ( can_accept_new_req_all[0]==1'b0) begin 
    #1;    
        Request_en_all[0]=1'b0;
        @(posedge clk);  
    end
    exclusive_all[0]=1'b1;
    Request_en_all[0]=1'b1;    
    
    @(posedge clk)  #1
    Request_en_all[0]=1'b0;
    exclusive_all[0]=1'b0;
    
    #4100; 


   //3- CleanUnique Exlusive rn1 must success
   ReqOpcode[1] = REQ_OPCODE_CleanUnique;
   
    @(posedge clk) #1
    while ( can_accept_new_req_all[1]==1'b0) begin 
    #1;    
        Request_en_all[1]=1'b0;
        @(posedge clk);  
    end
    exclusive_all[1]=1'b1;
    Request_en_all[1]=1'b1;    
    
    @(posedge clk)  #1
    Request_en_all[1]=1'b0;
    exclusive_all[1]=1'b0;
   
     
    #4100;  
  
  
  
  
  
  
  
  
  
  
  

end //repeat
    
     



      
     #180100          

`endif
