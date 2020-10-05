module custom_ni_routing  #(
    parameter TOPOLOGY = "CUSTOM_NAME",
    parameter ROUTE_NAME = "CUSTOM_NAME",
    parameter ROUTE_TYPE = "DETERMINISTIC",
    parameter RAw  = 4,  
    parameter EAw  = 4,   
    parameter DSTPw = 4   
)
(
    dest_e_addr,
    src_e_addr,
    destport        
);    

    input   [EAw-1   :0] dest_e_addr;
    input   [EAw-1   :0] src_e_addr;
    output  [DSTPw-1 :0] destport;   


   generate 
    
    
    
	//do not modify this line ===TtestRtest===
    if(TOPOLOGY == "test" && ROUTE_NAME== "test" ) begin : TtestRtest
    
        TtestRtest_ni_conventional_routing  #(
            .RAw(RAw),  
            .EAw(EAw),   
            .DSTPw(DSTPw)  
        )
        the_conventional_routing
        (
            .dest_e_addr(dest_e_addr),
            .src_e_addr(src_e_addr),
            .destport(destport)        
        );    
    
    end	
    
     
	
    
     
	//do not modify this line ===TmuliRtest===
    if(TOPOLOGY == "muli" && ROUTE_NAME== "test" ) begin : TmuliRtest
    
        TmuliRtest_ni_conventional_routing  #(
            .RAw(RAw),  
            .EAw(EAw),   
            .DSTPw(DSTPw)  
        )
        the_conventional_routing
        (
            .dest_e_addr(dest_e_addr),
            .src_e_addr(src_e_addr),
            .destport(destport)        
        );    
    
    end	
    
     
	//do not modify this line ===TlRl===
    if(TOPOLOGY == "l" && ROUTE_NAME== "l" ) begin : TlRl
    
        TlRl_ni_conventional_routing  #(
            .RAw(RAw),  
            .EAw(EAw),   
            .DSTPw(DSTPw)  
        )
        the_conventional_routing
        (
            .dest_e_addr(dest_e_addr),
            .src_e_addr(src_e_addr),
            .destport(destport)        
        );    
    
    end	
    
     
	//do not modify this line ===TllRll===
    if(TOPOLOGY == "ll" && ROUTE_NAME== "ll" ) begin : TllRll
    
        TllRll_ni_conventional_routing  #(
            .RAw(RAw),  
            .EAw(EAw),   
            .DSTPw(DSTPw)  
        )
        the_conventional_routing
        (
            .dest_e_addr(dest_e_addr),
            .src_e_addr(src_e_addr),
            .destport(destport)        
        );    
    
    end	
    
     
	//do not modify this line ===TalirezaRwww===
    if(TOPOLOGY == "alireza" && ROUTE_NAME== "www" ) begin : TalirezaRwww
    
        TalirezaRwww_ni_conventional_routing  #(
            .RAw(RAw),  
            .EAw(EAw),   
            .DSTPw(DSTPw)  
        )
        the_conventional_routing
        (
            .dest_e_addr(dest_e_addr),
            .src_e_addr(src_e_addr),
            .destport(destport)        
        );    
    
    end	
    
     
	//do not modify this line ===TtestRtest1===
    if(TOPOLOGY == "test" && ROUTE_NAME== "test1" ) begin : TtestRtest1
    
        TtestRtest1_ni_conventional_routing  #(
            .RAw(RAw),  
            .EAw(EAw),   
            .DSTPw(DSTPw)  
        )
        the_conventional_routing
        (
            .dest_e_addr(dest_e_addr),
            .src_e_addr(src_e_addr),
            .destport(destport)        
        );    
    
    end	
    
    endgenerate
    	
 
    	
 
    	
 
    	
 
    	
 
    	
 
    	
 
    	
 
 

endmodule
 
 
