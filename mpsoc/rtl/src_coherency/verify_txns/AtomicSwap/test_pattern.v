
`ifdef     INCLUDE_TEST_PATTERN

    
    //  gen_rntxn( .likelyshared(1'b0), .excel(1'b0), addr(0), opcode(REQ_OPCODE_ReadShared) , id(0) );
    $display("\n***********AtomicSwap, SNPF: I, SYSCHC: Miss  ************\n");
    cache_write(0,888,CACHE_UD,0); //  (addr, dat, state,  id)
    #100
    gen_rntxn( 1'b0, 1'b0, 0, REQ_OPCODE_AtomicSwap ,0); //(likelyshared, excel, addr, opcode, id)
    #5000;         

  
   
    $display("\n*******LCT*****ReadShared, SNPF: I, SYSCHC: Hit.  *******************\n");
   // make snpf U but invalid in repective RN
    gen_rntxn( 1'b0, 1'b0, 64, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id) // snpf : U
    #5000
    cache_evict(64,0);//(addr,id); 
 
   // load cache and perform atomoc swap
     $display("\n************AtomicSwap, SNPF: I, SYSCHC: Hit.  *******************\n");
    cache_write(64,999,CACHE_UD,1); //  (addr, dat, state,  id)
    #100
    gen_rntxn( 1'b0, 1'b0, 64, REQ_OPCODE_AtomicSwap ,1); //(likelyshared, excel, addr, opcode, id)
    #5000;   
   






     #20000          


`endif
