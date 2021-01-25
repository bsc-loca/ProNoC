
`ifdef     INCLUDE_TEST_PATTERN

    
   
  
    address=0;
    $display("********RN0: ReadUnique, SNPF: I SYSCHC: miss, likeshrd: 1  excl:0 ******************");
    repeat(8)begin //make snpf row full
    	gen_rntxn( 1'b1, 1'b0, address, REQ_OPCODE_ReadUnique ,0); //(likelyshared, excel, address, opcode, id)  DMT data wont be cached in hnf
        address=address +1024*CACHE_BLK_SIZ;
    end

    #5000

    $display("********Cache RN0 write Unique Dirty******************");
    address=0;
    repeat(4)begin
    	cache_write(address,888,CACHE_UD,0); //  (address, dat, state,  id)   
        address=address + 1024*CACHE_BLK_SIZ;
    end


     #50000


 address=0;
    $display("********RN0: ReadUnique, SNPF: I SYSCHC: miss, likeshrd: 1  excl:0 ******************");
    repeat(8)begin //make snpf row full
    	gen_rntxn( 1'b1, 1'b0, address, REQ_OPCODE_ReadShared ,3); //(likelyshared, excel, address, opcode, id)  DMT data wont be cached in hnf
        address=address +1024*CACHE_BLK_SIZ;
    end

    #5000





    $display("********RN1: ReadUnique, SNPF: I SYSCHC: miss, likeshrd: 1  excl:0 ******************");
    address=8*1024*CACHE_BLK_SIZ;
    repeat(8)begin //make snpf row full
    	gen_rntxn( 1'b1, 1'b0, address, REQ_OPCODE_ReadUnique ,1); //(likelyshared, excel, address, opcode, id)  DMT data wont be cached in hnf
        address=address+1024*CACHE_BLK_SIZ;
    end





     #20000          


`endif
