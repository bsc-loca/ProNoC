 module fixed_priority_arbiter #(
     parameter   ARBITER_WIDTH   =8,
     parameter   HIGH_PRORITY_BIT = "HSB"
 )
 (   
  
   request, 
   grant,
   any_grant
);

    
    input   [ARBITER_WIDTH-1            :   0]  request;
    output  [ARBITER_WIDTH-1            :   0]  grant;
    output                                      any_grant;
   /*
    wire    [ARBITER_WIDTH-1            :   0]  cout;
    reg     [ARBITER_WIDTH-1            :   0]  cin;
    
    
  
    
    assign grant    = cin & request;
    assign cout     = cin & ~request; 
    
     always @(*) begin 
        if( HIGH_PRORITY_BIT == "HSB")  cin      = {1'b1, cout[ARBITER_WIDTH-1 :1]}; // hsb has highest priority
        else                            cin      = {cout[ARBITER_WIDTH-2 :0] ,1'b1}; // lsb has highest priority
    end//always
    
    */
    
    assign  any_grant= | request;
    wire  [ARBITER_WIDTH-1            :   0] termo_code, edge_mask;
    
     
    genvar i;
    generate
    if( HIGH_PRORITY_BIT == "LSB") begin :hsb
        for(i=0;i<ARBITER_WIDTH;i=i+1)begin :lp
            assign termo_code[i]= | in[i    :0];    
        end
        assign edge_mask=  {termo_code[ARBITER_WIDTH-2:0],1'b0};
        
    end else begin :hsb
        for(i=0;i<ARBITER_WIDTH;i=i+1)begin :lp
            assign termo_code[i]= | in[WIDTH-1    :i];    
        end
        assign edge_mask=  {1'b0, termo_code[ARBITER_WIDTH-1:1]};
        
    end
    endgenerate
    
    assign grant= termo_code ^ edge_mask;
    
    
    
endmodule
