// synthesis translate_off
`timescale   1ns/1ns


module synfull_top;
    
    import pronoc_pkg::*; 
    import dpi_int_pkg::*; 
    
    reg     reset ,clk;
    
    initial begin 
        clk = 1'b0;
        forever clk = #10 ~clk;
    end 
    
    
    smartflit_chanel_t chan_in_all  [NE-1 : 0];
    smartflit_chanel_t chan_out_all [NE-1 : 0];
    
    pck_injct_t pck_injct_in [NE-1 : 0];
    pck_injct_t _pck_injct_in [NE-1 : 0];
    pck_injct_t pck_injct_out[NE-1 : 0];

    logic [NE-1 : 0] init_socket     ;
    logic [NE-1 : 0] wakeup_synfull  ;
    logic [NE-1 : 0] end_injection   ;

    req_t     [NE-1 : 0] synfull_pronoc_req_all  ;
    deliver_t [NE-1 : 0] pronoc_synfull_del_all  ;
    
    noc_top     the_noc
    (
        .reset(reset),
        .clk(clk),    
        .chan_in_all(chan_in_all),
        .chan_out_all(chan_out_all)  
    );


    top_dpi_interface synfull (
        .clk_i         (clk), 
        .rst_i         (reset),
        .init_i        (init_socket[0]),
        .startCom_i    (wakeup_synfull[0]),
        .pronoc_synfull_del_all_i(pronoc_synfull_del_all),  
        .synfull_pronoc_req_all_o(synfull_pronoc_req_all),
        .endCom_o      (end_injection[0])  
    );


        
    reg [NEw-1 : 0] dest_id [NE-1 : 0];
    wire [NEw-1: 0] current_e_addr [NE-1 : 0];
        
    genvar i;
    generate 
    for(i=0; i< NE; i=i+1) begin : endpoints
        
        assign pck_injct_in[i].data = synfull_pronoc_req_all[i].id;
        assign pck_injct_in[i].size = 1;
        assign pck_injct_in[i].pck_wr = synfull_pronoc_req_all[i].valid;    
        assign dest_id[i] = synfull_pronoc_req_all[i].dest;             
        
        assign pck_injct_in[i].class_num = _pck_injct_in[i].class_num; 
        assign pck_injct_in[i].init_weight = _pck_injct_in[i].init_weight;
        assign pck_injct_in[i].vc = _pck_injct_in[i].vc;
        //assign pck_injct_in[i].ready = 1'b1; //TODO: set 1 when I'm ready to receive.
        //assign pck_injct_in[i].distance = 4; 
        //assign pck_injct_in[i].h2t_delay = 20;
        
        //to synfull
        assign pronoc_synfull_del_all[i].id    = pck_injct_out[i].data   ; 
        assign pronoc_synfull_del_all[i].valid = pck_injct_out[i].pck_wr ; 
        
        endp_addr_encoder #( .TOPOLOGY(TOPOLOGY), .T1(T1), .T2(T2), .T3(T3), .EAw(EAw),  .NE(NE)) encode1 ( .id(i[NEw-1 :0]), .code(current_e_addr[i]));
        
        packet_injector pck_inj(
            //general
            .current_e_addr(current_e_addr[i]),
            .reset(reset),
            .clk(clk),      
            //noc port
            .chan_in(chan_out_all[i]),
            .chan_out(chan_in_all[i]),  
            //control interafce
            .pck_injct_in(pck_injct_in[i]),
            .pck_injct_out(pck_injct_out[i])        
        );          
    

        endp_addr_encoder #( .TOPOLOGY(TOPOLOGY), .T1(T1), .T2(T2), .T3(T3), .EAw(EAw),  .NE(NE)) encode2 ( .id(dest_id[i]), .code(pck_injct_in[i].endp_addr));
        
        
       reg [31:0]k;

        initial begin 
            reset = 1'b1;
            k=0;
            //pck_injct_in[i].data =0;
            init_socket[i] = 1'b0;
            wakeup_synfull[i] = 1'b0;
            #10
            _pck_injct_in[i].class_num=0; 
            _pck_injct_in[i].init_weight=1;
            _pck_injct_in[i].vc=1;
            //_pck_injct_in[i].pck_wr=1'b0; 
            #100
            @(posedge clk) #1;
            reset=1'b0;
            #100
            init_socket[i] = 1'b1;
            #20
            init_socket[i] = 1'b0;
            #100
            wakeup_synfull[i] = 1'b1;
            /*
            #100
            @(posedge clk) #1;
            if(i==1) begin 
                repeat(10) begin 
                    while (pck_injct_out[i].ready[0] == 1'b0) @(posedge clk)   #1;
                        
                    pck_injct_in[i].data='h987654321+k;
                    pck_injct_in[i].size=1;
                    dest_id[i]=0;               
                    pck_injct_in[i].pck_wr=1'b1;    
                    @(posedge clk)  #1 k++;
                    pck_injct_in[i].pck_wr=1'b0;
                    @(posedge clk)  #1 k++;

                end

                #8000
            @(posedge clk) $stop;
            end
        */  
            
            //#800000
            while (end_injection[0]==1'b0) @(posedge clk)   #1;

            @(posedge clk) $stop;   
    end
        
        always @(posedge clk) begin
            if(pck_injct_out[i].pck_wr) begin 
                $display ("%t:pck_inj(%d) got a packet: source=%d, size=%d, data=%h",$time,i,
                        pck_injct_out[i].endp_addr,pck_injct_out[i].size,pck_injct_out[i].data);
            end     
            
        end
        
        always @(posedge clk) begin
            if(end_injection[0]) begin 
                $display ("*** END ***");
            end     
        end
    
      
    end//for
    endgenerate
   
endmodule
// synthesis translate_on

