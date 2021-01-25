`ifdef     INCLUDE_TEST_PATTERN  

	pck_injct_trace_file[0] =1'b0;
	pck_injct_trace_file[1] =1'b0;

	#25000

	pck_injct_trace_file[0] =1'b1;


$display("***************1st transition  WriteBackfull rn1************");   
    addr=0;
    repeat (MINE_REPEAT_NUM)begin 
	addr = addr+  CACHE_BLK_SIZ;	
	cache_write(addr,addr,CACHE_UD,1); //  (addr, dat, state,  id)  
    end
#200
    addr=0;
    repeat (MINE_REPEAT_NUM)begin 
	addr = addr+  CACHE_BLK_SIZ;	
	gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_WriteBackFull, 1);         
    end
   
 #10100   

$display("***************2nd/3d/4th transition: Readshared rn3,rn1,rn2************");

 addr=0;
    repeat (MINE_REPEAT_NUM)begin 
	addr = addr+  CACHE_BLK_SIZ;	
	gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_ReadShared, 3); 
        gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_ReadShared, 1); 
        gen_rntxn(1'b0, 1'b0, addr, REQ_OPCODE_ReadShared, 2); 
    end







       #10100;     
      
     #180100;          

end //initial

initial begin 

	file = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/inj-verify/excl160/validation_llsc-scalar-160/validation_llsc-scalar_trace_0.bin","rb");
	@(posedge pck_injct_trace_file[0]) #1	
	pck_inject_rd_trace(2*REPEAT_NUM);
	$fclose(file);
	#10100;  

`endif





