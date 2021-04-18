
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

$display("***************2nd transition: Readshared rn0************");

 addr=0;
    repeat (REPEAT_NUM)begin 
	addr = addr+  CACHE_BLK_SIZ;	
	gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_ReadShared, 0); 
    end



       #10100     
      
     #180100          

`endif
