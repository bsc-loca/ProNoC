
`ifdef     INCLUDE_TEST_PATTERN

;end 



generate
    for (i = 0; i < 4; i = i + 1) begin : block
        
   



initial begin
     ReqOpcode[i] = REQ_OPCODE_ReadShared; 
     read_addr[i]=0;
     initial_cache_state[i]=0;// invalid
     Write_dat[i]=0; 
           

    #25000

    $display("***************RN %d ReadShared Random LoC************",i);   
    initial_cache_state[i]=CACHE_I;
  
    
  
    
    repeat(REPEAT_NUM)begin
        @(posedge clk)  
        #1
        while ( can_accept_new_req_all[i]==1'b0) begin 
            #1;
            Request_en_all[i]=1'b0;
            @(posedge clk);  
        end
        read_addr[i]= ($urandom%10000) * CACHE_BLK_SIZ;
        Request_en_all[i]=1'b1;
        //Readshared[0]=1'b1;
        //read_addr[0]=read_addr[0]+16;
        
                
    end
    
    @(posedge clk)  Request_en_all[i]=1'b0;
    
    //read_addr=0;
      #400000  
    #400000  
      
    
    $stop;


end //initial 


 end
endgenerate
    


initial begin 
	#4000000

      
     #180100          

`endif
