
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


$display("*************** \
1-Readshared Exlusive rn0 \
2-Readshared Exlusive rn1 \
3- CleanUnique Exlusive rn0 must success \
4- CleanUnique Exlusive rn1 must fail \
************");

 addr=0;
 repeat(REPEAT_NUM)begin
	//1-Readshared Exlusive rn0 
	addr = addr+  CACHE_BLK_SIZ;	
	gen_rntxn(1'b1, 1'b1, addr, REQ_OPCODE_ReadShared, 0); 
        #4100;  
 
	//2-Readshared Exlusive rn1 
   	gen_rntxn(1'b1, 1'b1, addr, REQ_OPCODE_ReadShared, 1); 
        #4100;  
 
	//3- CleanUnique Exlusive rn0 must sucecss
        gen_rntxn(1'b1, 1'b1, addr, REQ_OPCODE_CleanUnique, 0); 
        #4100; 


	//4- CleanUnique Exlusive rn1 must fail
   	gen_rntxn(1'b1, 1'b1, addr, REQ_OPCODE_CleanUnique, 1); 
        #4100; 
    
  
end //repeat
    
     



      
     #180100          

`endif
