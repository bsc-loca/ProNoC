
`ifdef     INCLUDE_TEST_PATTERN

 pck_injct_trace_file[0] =1'b0;
 pck_injct_trace_file[1] =1'b0;

#25000



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

$display("***************2nd/3d transition: Readshared rn0,rn1************");

 addr=0;
    repeat (REPEAT_NUM)begin 
	addr = addr+  CACHE_BLK_SIZ;	
	//gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_ReadShared, 0); 
	pck_injct_trace_file[0]=1;
        gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_ReadShared, 1); 
    end
	pck_injct_trace_file[0]=0;
	
  #10100     

addr=0;

 pck_injct_trace_file[1] =1'b1;
   // repeat (REPEAT_NUM)begin 
//	addr = addr+  CACHE_BLK_SIZ;	
	//gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_CleanUnique, 0); 

  //  end
#100;
pck_injct_trace_file[1] =1'b0;



end //initial 





initial begin
	#25000
	file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/wr_rd_rd_clean1/trace/ReadShared.bin", "rb");
	@(posedge pck_injct_trace_file[0]) #1	
	pck_inject_rd_trace(2*REPEAT_NUM);
	$fclose(file);
	#10
	file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/wr_rd_rd_clean1/trace/ReadUnique.bin", "rb");
	@(posedge pck_injct_trace_file[1]) #1	
	pck_inject_rd_trace(2*REPEAT_NUM);
	$fclose(file);


       #10100     
      
     #180100          

`endif



