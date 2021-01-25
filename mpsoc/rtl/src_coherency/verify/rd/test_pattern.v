
`ifdef     INCLUDE_TEST_PATTERN

    $display("***************1st transition: Readshared rn0************");
    addr=0;
    repeat (REPEAT_NUM)begin 
	
	gen_rntxn(1'b1, 1'b0, addr, REQ_OPCODE_ReadShared, 0); 
        addr =addr + CACHE_BLK_SIZ;
    end
      
     #180100          

`endif
