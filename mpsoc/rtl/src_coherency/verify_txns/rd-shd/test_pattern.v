
`ifdef     INCLUDE_TEST_PATTERN

    
    //  gen_rntxn( .likelyshared(1'b0), .excel(1'b0), addr(0), opcode(REQ_OPCODE_ReadShared) , id(0) );
    $display("*******DMT*****Readshared, SNPF: I, SYSCHC: Miss, the likelyshared and exclusive flag are de-asserted ************");
    gen_rntxn( 1'b0, 1'b0, 0, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)
    #5000;         

    $display("*******IDMT****ReadShared, SNPF: I, SYSCHC: Miss, the likeshrd: 1, excl:0 ************");
    gen_rntxn( 1'b1, 1'b0, 0, REQ_OPCODE_ReadShared ,0);
    #5000;   
    
    $display("*******LCT*****ReadShared, SNPF: I, SYSCHC: Hit.  *******************");
    cache_evict(0,0);//(addr,id);
    gen_rntxn( 1'b0, 1'b0, 0, REQ_OPCODE_Evict ,0);
    #5000; 
    gen_rntxn( 1'b0, 1'b0, 0, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)
    #5000;
    
    $display("*******DCT*****ReadShared, SNPF: U, SYSCHC: X, likeshrd: 0  excl:0, Holder RN:  UC*******************");
    gen_rntxn( 1'b0, 1'b0, 0, REQ_OPCODE_ReadShared ,1);
    #5000; 

    
    $display("***DCT-LCT*****ReadShared, SNPF: U SYSCHC: Hit, likeshrd: 0  excl:0, Holder RN:  I******************");
    cache_evict(0,0);//(addr,id); 
    gen_rntxn( 1'b0, 1'b0, 0, REQ_OPCODE_Evict ,0);  //notify home node about eviction. //make snpf U
    cache_evict(0,1);//(addr,id); do not notify home node scilent cahe transtion
    #20
    gen_rntxn( 1'b0, 1'b0, 0, REQ_OPCODE_ReadShared ,2); //(likelyshared, excel, addr, opcode, id)
    
    #5000; 
    
    $display("****DCT-IDMT****ReadShared, SNPF: U SYSCHC: Miss, likeshrd: 0  excl:0, Holder RN:  I******************");
    gen_rntxn( 1'b0, 1'b0, 64, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    #5000;         
    cache_evict(64,0);//(addr,id); evict the cache in hnf 0. Dont notify the hnf  
    #10
    gen_rntxn( 1'b0, 1'b0, 64, REQ_OPCODE_ReadShared ,1); //(likelyshared, excel, addr, opcode, id)  DCT which should be failed and lead to IDMT 
    #5000; 


    $display("****DCT-PD****ReadShared, SNPF: U SYSCHC: x, likeshrd: 0  excl:0, Holder RN:  DU******************");
    gen_rntxn( 1'b0, 1'b0, 128, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    #5000;         
    cache_write(128,888,CACHE_UD,0); //  (addr, dat, state,  id)
    #20
    gen_rntxn( 1'b0, 1'b0, 128, REQ_OPCODE_ReadShared ,1); //(likelyshared, excel, addr, opcode, id)  DCT which should be failed and lead to IDMT 
    #5000; 




    $display("****IDCT-UC****ReadShared, SNPF: U SYSCHC: x, likeshrd: 1  excl:0, Holder RN:  UC******************");
    gen_rntxn( 1'b0, 1'b0, 192, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    #5000;         
    gen_rntxn( 1'b1, 1'b0, 192, REQ_OPCODE_ReadShared ,1); //(likelyshared, excel, addr, opcode, id)  IDCT 
    #5000; 



    $display("****IDCT-UD****ReadShared, SNPF: U SYSCHC: x, likeshrd: 1  excl:0, Holder RN:  UD******************");
    gen_rntxn( 1'b0, 1'b0, 192, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    #5000;  
    cache_write(192,888,CACHE_UD,0); //  (addr, dat, state,  id)       
    gen_rntxn( 1'b1, 1'b0, 192, REQ_OPCODE_ReadShared ,1); //(likelyshared, excel, addr, opcode, id)  IDCT 
    #5000; 


    $display("****IDCT-I****ReadShared, SNPF: U SYSCHC: miss, likeshrd: 1  excl:0, Holder RN:  I******************");
    gen_rntxn( 1'b0, 1'b0, 256, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    #5000;  
    cache_evict(256,0);   
    gen_rntxn( 1'b1, 1'b0, 256, REQ_OPCODE_ReadShared ,1); //(likelyshared, excel, addr, opcode, id)  IDCT 
    #5000; 


     $display("****IDCT-I****ReadShared, SNPF: U SYSCHC: hit, likeshrd: 1  excl:0, Holder RN:  I******************");
    gen_rntxn( 1'b1, 1'b0, 320, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    #5000;  
    cache_evict(320,0);   
    gen_rntxn( 1'b1, 1'b0, 320, REQ_OPCODE_ReadShared ,1); //(likelyshared, excel, addr, opcode, id)  IDCT 
    #5000; 



    $display("****LCT-S****ReadShared, SNPF: S SYSCHC: hit, likeshrd: 1  excl:0, Holder RN:  S******************");
    gen_rntxn( 1'b1, 1'b0, 384, REQ_OPCODE_ReadShared ,0); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    gen_rntxn( 1'b1, 1'b0, 384, REQ_OPCODE_ReadShared ,1); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    gen_rntxn( 1'b1, 1'b0, 384, REQ_OPCODE_ReadShared ,2); //(likelyshared, excel, addr, opcode, id)  DMT data wont be cached in hnf
    #5000;  
    

     #20000          


`endif
