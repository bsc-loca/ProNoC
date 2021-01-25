
`ifdef     INCLUDE_TEST_PATTERN

$display("***************1st transition  WriteBackfull rn1************");   
    initial_cache_state[0]=CACHE_UD;
    initial_cache_state[1]=CACHE_I;
    Write_dat[1]={256{2'b10}};

    ReqOpcode[1] = REQ_OPCODE_WriteBackFull;
    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 0;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;
    
   
    read_addr[1]= 1*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;

//AtomicLoad_SMAX  
    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 2*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;

    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 3*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;

//AtomicLoad_UMAX  
    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 4*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;
    
    Write_dat[1][63:0] =64'h0; 
    read_addr[1]= 5*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;
    

//AtomicLoad_SMIN 
    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 6*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;

    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 7*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;

//AtomicLoad_UMIN  
    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 8*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;
    
    Write_dat[1][63:0] =64'h0; 
    read_addr[1]= 9*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;
    


//AtomicLoad_SET
    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 10*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;
    
//AtomicLoad_SWAP
    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 11*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;
    
//Atomic Xor       

    Write_dat[1][63:0] =64'hffffffff80000000;
    read_addr[1]= 12*64;
    @(posedge clk)   #1; while ( can_accept_new_req_all[1]==1'b0) begin Request_en_all[1]=1'b0; @(posedge clk);  #1;  end Request_en_all[1]=1'b1; @(posedge clk)  Request_en_all[1]=1'b0;
    

   #10100        
   






$display("***************AtomicLoad_ADD rn2************");
    initial_cache_state[0]=CACHE_I;// invalid
    initial_cache_state[1]=CACHE_I;// invalid
    
    
   
    Write_dat[2] ={256{2'b01}};




    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_ADD;
    Write_dat[2][63:0] =64'hfffffffffffff800;
    read_addr[2]=0;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    
   




$display("*************** AtomicLoad_CLR rn2************");
    read_addr[2]=   1*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_CLR;
    Write_dat[2][63:0] =~64'hfffffffffffff800;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    
   
        
$display("*************** AtomicLoad_SMAX rn2************");        
    read_addr[2]=   2*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_SMAX;
    Write_dat[2][63:0] =64'hfffffffffffff800;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    
 
    read_addr[2]=   3*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_SMAX;
    Write_dat[2][63:0] =64'h1;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    


$display("*************** AtomicLoad_UMAX rn2************");        
    read_addr[2]=   4*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_UMAX;
    Write_dat[2][63:0] =64'hfffffffffffff800;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    

    read_addr[2]=   5*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_UMAX;
    Write_dat[2][63:0] =64'hffffffffffffffff;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    

$display("*************** AtomicLoad_SMIN rn2************");        
    read_addr[2]= 6*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_SMIN;
    Write_dat[2][63:0] =64'hfffffffffffff800;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    

    read_addr[2]= 7*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_SMIN;
    Write_dat[2][63:0] =64'h1;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
  


$display("*************** AtomicLoad_UMIN rn2************");        
    read_addr[2]= 8*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_UMIN;
    Write_dat[2][63:0] =64'hfffffffffffff800;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    

    read_addr[2]= 9*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_UMIN;
    Write_dat[2][63:0] =64'hffffffffffffffff;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    



$display("*************** AtomicLoad_SET rn2************");        
    read_addr[2]= 10*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_SET;
    Write_dat[2][63:0] =64'hfffffffffffff800;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;

    Write_dat[2][63:0] =64'h1;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;
    

$display("*************** AtomicLoad_SWAP rn2************");        
   read_addr[2]= 11*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicSwap;
    Write_dat[2][63:0] =64'h00008000000;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;



$display("*************** AtomicLoad_XOR rn2************");        
    read_addr[2]= 12*64;
    ReqOpcode[2] = REQ_OPCODE_AtomicLoad_EOR;
    Write_dat[2][63:0] =64'hfffffffffffff800;
    @(posedge clk)   #1; while ( can_accept_new_req_all[2]==1'b0) begin Request_en_all[2]=1'b0; @(posedge clk);  #1;  end Request_en_all[2]=1'b1; @(posedge clk)  Request_en_all[2]=1'b0;



    
    //read_addr=0;
       #10100     
      
     #180100          

`endif
