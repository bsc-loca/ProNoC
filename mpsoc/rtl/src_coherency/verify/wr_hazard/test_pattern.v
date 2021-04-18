
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
        
      
        
        read_addr[1]= read_addr[1]+  CACHE_BLK_SIZ/8;
	Write_dat[1]= Write_dat[1]+ CACHE_BLK_SIZ/8;
        Request_en_all[1]=1'b1;
       
    end
    
      @(posedge clk)  Request_en_all[1]=1'b0;
    
    
     #100100             
      
     #180100          

`endif
