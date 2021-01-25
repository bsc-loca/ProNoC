
`ifdef     INCLUDE_TEST_PATTERN

    
    //  gen_rntxn( .likelyshared(1'b0), .excel(1'b0), addr(0), opcode(REQ_OPCODE_ReadShared) , id(0) );
    $display("************CleanUnique, SNPF: I, SYSCHC: X, the likelyshared and exclusive flag are de-asserted ************");
    gen_rntxn( 1'b0, 1'b0, 0, REQ_OPCODE_CleanUnique ,0); //(likelyshared, excel, addr, opcode, id)
    #5000;         

  
        

    
   
    $display("***********ReadUnique, SNPF: U, SYSCHC: X, likeshrd: 0  excl:0, Holder RN:  UC  *******************");
    gen_rntxn( 1'b0, 1'b0, 64, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)
    #5000;
    gen_rntxn( 1'b0, 1'b0, 64, REQ_OPCODE_CleanUnique ,1); //(likelyshared, excel, addr, opcode, id)
    #5000;







    $display("***LCT****ReadUnique, SNPF: U, SYSCHC: hit, likeshrd: 0  excl:0, Holder RN:  I  *******************");
    gen_rntxn( 1'b1, 1'b0, 128, REQ_OPCODE_ReadUnique ,0); //(likelyshared, excel, addr, opcode, id)
    #5000;  
    cache_evict(128,0);//(addr,id); //Silent transition
    #20
    gen_rntxn( 1'b0, 1'b0, 128, REQ_OPCODE_CleanUnique ,1); //(likelyshared, excel, addr, opcode, id)
    #5000;




    $display("****PD****ReadUnique, SNPF: U SYSCHC: x, likeshrd: 0  excl:0, Holder RN:  UD******************");
    gen_rntxn( 1'b0, 1'b0, 256, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    #5000;         
    cache_write(256,888,CACHE_UD,0); //  (addr, dat, state,  id)
    #20
    gen_rntxn( 1'b0, 1'b0, 256, REQ_OPCODE_CleanUnique ,1); //(likelyshared, excel, addr, opcode, id)  DCT which should be failed and lead to IDMT 
    #5000; 

/*

    $display("********ReadUnique, SNPF: S SYSCHC: hit, likeshrd: 1  excl:0, Holder RN:  S******************");
    gen_rntxn( 1'b1, 1'b0, 384, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    gen_rntxn( 1'b1, 1'b0, 384, REQ_OPCODE_ReadShared ,1); //(likelyshared, excel, addr, opcode, id)  
    #5000; 
    gen_rntxn( 1'b1, 1'b0, 384, REQ_OPCODE_ReadUnique ,2); //(likelyshared, excel, addr, opcode, id)  
    #5000;  

*/



    






     #20000          


`endif
