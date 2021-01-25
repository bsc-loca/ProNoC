
`ifdef     INCLUDE_TEST_PATTERN

$display("***************1st transition  WriteBackfull rn1************");   
    Write_dat[1]={256{2'b10}};
    Write_dat[1][63:0] =64'h20;

    cache_write(0,Write_dat[1],CACHE_UD,1); //  (addr, dat, state,  id)  
    #20;
    gen_rntxn(1'b0, 1'b0, 0, REQ_OPCODE_WriteBackFull, 1);     


   
   
repeat (15)begin 


$display("***************AtomicLoad_ADD rn2************");
    Write_dat[2] ={256{2'b01}};
    Write_dat[2][63:0] =64'hffffffffffffffff;// = -1
    cache_write(0,Write_dat[2],CACHE_UD,2); //  (addr, dat, state,  id)  
    #200;
   
    gen_rntxn(1'b0, 1'b0, 0, REQ_OPCODE_AtomicLoad_ADD, 2);  
     #2000;
    
end
    
      
     #180100          

`endif
