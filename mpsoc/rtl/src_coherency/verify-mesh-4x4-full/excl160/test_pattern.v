`ifdef     INCLUDE_TEST_PATTERN  

    genvar j;
    generate 
    for(j=0;j<2;j=j+1) begin : jlp 
  
   
        initial begin
            injct_done[j]=1'b0;
            wrapreqvalid[j]=1'b0;
	        wrapreq [j]=1'b0;	    
           
            file[0] = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/verify-4-pck-inj/excl160/sample/validation_llsc-scalar_trace_0.bin","rb");
            file[1] = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/verify-4-pck-inj/excl160/sample/validation_llsc-scalar_trace_0.bin","rb");
            file[2] = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/verify-4-pck-inj/excl160/sample/validation_llsc-scalar_trace_0.bin","rb");
            file[3] = $fopen("/home/alireza/work/hca_git/ProNoC/mpsoc/src_coherency/verify-4-pck-inj/excl160/sample/validation_llsc-scalar_trace_0.bin","rb");
            
            #35000
            pck_inject_rd_trace(j,file[j],2*REPEAT_NUM);
                
          
            
        end  //initial 
   
 end//for
 endgenerate


    initial begin
        reset=1'b1;
        #100;
        reset=1'b0;
        #100
        while ( &injct_done != 1'b1) #10;  
        #100;
        $stop;
    end

	

`endif





