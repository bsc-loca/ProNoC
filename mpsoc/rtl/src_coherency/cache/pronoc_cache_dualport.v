/**************************************
* Module: pronoc_cache_dualport
* Date:2019-05-08  
* Author: alireza     
*
* Description: 
***************************************/
`timescale   1ns/1ns

module  pronoc_cache_dualport#(
    parameter VERBOSITY=0,  
   // parameter src_id=0,
    parameter WAY_NUM = 8,
    parameter STATUSw = 3, // cache state width
    parameter BLK_SIZ = 64, //cache block size in byte
    parameter ADDRw=32,
    parameter INDEXw=10,  // cache size is 2**INDEX * BLK_SIZ
    parameter DATAw = 32, // supposed to be (BLK_SIZ*8). However we made it smaller for simulation as we are not working with real data yet   
    parameter BYTE_WR_EN="NO"
)(   
    src_id,
    wr_addr,
    wr_data,
    wr_en,
    wr_evict,
    wr_state,
    wr_hit, 
    wr_action,
    wr_ready,
    wr_byteen,
    wr_done,    
    
    rd_addr,
    rd_data,
    rd_en,
    rd_ready,   
    rd_state,
    rd_hit,
    rd_done,  
    
    re_fill,
    clk,
    reset
);


    `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

    function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 


//On power-up / reset : clear all valid bits 
    localparam 
        OFFSETw = log2(BLK_SIZ), // The address range in cache block
        TAGw = ADDRw - INDEXw - OFFSETw, // the remainig address bits are dedicated as tag
        BYTE_ENw= ( BYTE_WR_EN == "YES")? DATAw/8 : 1;

    localparam 
        INFOw = TAGw + STATUSw + 1, // add one info bit to check if the cache way has any data
        WAYw = log2(WAY_NUM),
        RAM_Aw = INDEXw;    
        
    // States
    localparam ST_NUM=3;

    localparam [ST_NUM-1 :   0]
        READ = 1,
        WRITE=2,
        EVICT=4;
    
                   
    input [31 : 0] src_id;                   
        
    //read chanel 
    input [ADDRw-1 : 0] wr_addr;
    input [DATAw-1 : 0] wr_data;
    input wr_en;
    input wr_evict;
    input [STATUSw-1 : 0] wr_state;
    input [CACHE_ACTw-1 : 0] wr_action;
    output wr_hit;
    output wr_ready;  
    input [BYTE_ENw-1 : 0] wr_byteen;
    output reg wr_done; 
    
        
  
    //write chanel
    input [ADDRw-1 : 0] rd_addr;   
    output[DATAw-1 : 0] rd_data;
    input rd_en;
    output rd_ready;    
    output[STATUSw-1 : 0] rd_state;
    output rd_hit;    
    output reg  rd_done;
     
    output reg re_fill;
     
    input reset;
    input clk;
      
   
    reg [STATUSw-1 : 0] wr_state_delay;
        
    wire [TAGw-1 : 0] tag_in_rd_next,tag_in_wr_next;
    reg  [TAGw-1 : 0] tag_in_wr,tag_in_rd;
    wire [STATUSw-1 : 0] new_status,wr_state_old;    
    wire [INDEXw-1 : 0] index_in_rd_next,index_in_wr_next;
    reg  [INDEXw-1 : 0] index_in_wr;
    wire [RAM_Aw-1 : 0] ram_addr_i_rd = index_in_rd_next;
    reg  [RAM_Aw-1 : 0] ram_addr_i_wr;  
    reg  [DATAw-1 : 0] wr_data_reg;
    wire [DATAw-1 : 0] wr_dat_old;
   
    reg [WAY_NUM-1 : 0] ram_we_i_wr;
    reg [INFOw-1:0] info_ram_in_wr;
    wire [INFOw-1:0] info_array_rd [WAY_NUM-1 : 0];
    wire [INFOw-1:0] info_array_wr [WAY_NUM-1 : 0];    
    wire [TAGw-1: 0] tag_array_rd [WAY_NUM-1 : 0];
    wire [TAGw-1: 0] tag_array_wr [WAY_NUM-1 : 0];    
    wire [STATUSw-1 : 0] status_array_rd[WAY_NUM-1 : 0];
    wire [STATUSw-1 : 0] status_array_wr[WAY_NUM-1 : 0];
    wire [DATAw-1 : 0] data_array_rd [WAY_NUM-1 : 0];
    wire [DATAw-1 : 0] data_array_wr [WAY_NUM-1 : 0]; 
    
  
    wire [WAY_NUM-1 : 0] compartors_array_rd;
    wire [WAY_NUM-1 : 0] compartors_array_wr;
    wire [WAY_NUM-1 : 0] hit_array_rd;
    wire [WAY_NUM-1 : 0] hit_array_wr;
    wire [WAY_NUM-1 : 0] valid_array_rd;
    wire [WAY_NUM-1 : 0] valid_array_wr, empty_ways_wr;
    wire [WAY_NUM-1 : 0] ram_not_ready;
   
    reg [ST_NUM-1 : 0] ps,ns;
    reg random_pos_en;
    reg [WAY_NUM-1 : 0] random_way;
    wire [WAY_NUM-1 : 0] empty_candidate_way_wr;
    wire any_empty_wr;
    reg wr_done_next;
    reg [CACHE_ACTw-1: 0] wr_action_delay;
    reg new_cache_block;
    
    wire new_valid =1'b1;
    wire [DATAw-1 : 0] new_data;
    
    assign wr_ready = ~ram_not_ready[0] & (ps==READ);
    assign rd_ready = ~ram_not_ready[0];
    
    assign empty_ways_wr = ~ valid_array_wr;
    // decode the input addr
    assign {tag_in_rd_next,index_in_rd_next} = rd_addr[ADDRw-1 : OFFSETw];  
    assign {tag_in_wr_next,index_in_wr_next} = wr_addr[ADDRw-1 : OFFSETw];   
    
   
     
    //  reg  [STATUSw : 0] new_status={wr_state_delay,1'b1}; 
    assign new_status =
        (wr_action_delay == CACHE_UPDATE_DAT_ST || wr_action_delay ==CACHE_UPDATE_ST)  ? wr_state_delay :
        (new_cache_block)?  SNPF_I :
         wr_state_old;
          
         
    assign new_data=
        ((wr_action_delay== CACHE_UPDATE_DAT_ST) || (wr_action_delay == CACHE_UPDATE_DAT) )? wr_data_reg  : 
         wr_dat_old;   
    
    always @(posedge clk)begin  
        tag_in_wr  <= tag_in_wr_next; 
        index_in_wr<= index_in_wr_next;
        wr_state_delay <=  wr_state;
        wr_data_reg<= wr_data;
        wr_action_delay <= wr_action;
        if(rd_en) tag_in_rd<= tag_in_rd_next;
    end  
     
     
     
  
   //wr st 
    always @(*)begin 
        ns=ps;
        random_pos_en=1'b0;
        info_ram_in_wr={INFOw{1'b0}};
        ram_we_i_wr={WAY_NUM{1'b0}};
        re_fill=1'b0;
        wr_done_next=0;
        ram_addr_i_wr=index_in_wr_next;// default for read in write chanel. addr directly gotton from input 
        new_cache_block=1'b0;
        case(ps)
        READ: begin 
            if(wr_en) begin 
                ns=  WRITE;
            end  
            if(wr_evict) begin 
                ns= EVICT;            
            end
        end 
        WRITE:begin  
            ram_addr_i_wr =  index_in_wr;  // take it now from register to write  
            wr_done_next=1'b1;
            info_ram_in_wr={new_valid,new_status ,tag_in_wr};
            if(~wr_hit) new_cache_block=1'b1;
            if(wr_hit) begin // This cache exists inside the memory rewrite the new data
                ram_we_i_wr=hit_array_wr;           
            end 
            // this is a new cache data  
            else if (any_empty_wr) begin // select random way to evict
                      ram_we_i_wr=empty_candidate_way_wr;              
            end else begin  // all ways are full select one random loc to evict 
                random_pos_en=1'b1;
                ram_we_i_wr=random_way;  
                re_fill=1'b1;
            end
             ns=  READ;
        end    
        EVICT:begin 
            ram_addr_i_wr =  index_in_wr;  // take it now from register to write  
            wr_done_next=1'b1;
            if(wr_hit) begin // This cache exists inside the memory rewrite the new data
                ram_we_i_wr=hit_array_wr;           
            end 
            ns=  READ;
        end        
        endcase    
    end
    
    localparam [WAY_NUM-1 : 0] RND_INIT = 1;
        
    always @(posedge clk or posedge reset) begin
        if(reset)begin 
            ps<= READ;
            random_way<= RND_INIT;
            rd_done<=1'b0;
            wr_done <= 1'b0;     
        end else begin 
            ps<=ns;
            if(random_pos_en) random_way<= {random_way[WAY_NUM-2:0],random_way[WAY_NUM-1]};
            rd_done <= rd_en;
            wr_done <= wr_done_next;     
        end        
    end
    
    //select one empty way to write
    fixed_priority_arbiter #(
        .ARBITER_WIDTH(WAY_NUM)
    )
    arbiter
    (
        .request(empty_ways_wr),
        .grant(empty_candidate_way_wr),
        .any_grant(any_empty_wr)
    );    
    
    
    genvar i;
    generate 
    for (i=0; i<WAY_NUM; i=i+1)begin:way
      
      snpf_ram #(
        .Dw(INFOw),
        .Aw(INDEXw)
       )
       ram1
       (
       //chanel a . rd & wr
        .wr_dat_a(info_ram_in_wr),
        .addr_a(ram_addr_i_wr),
        .wr_en_a(ram_we_i_wr[i]),
        .rd_dat_a(info_array_wr[i]),
        
       //chanel b rd only  
        .rd_dat_b(info_array_rd[i]),
        .addr_b(ram_addr_i_rd),
        .rd_en_b(rd_en),
        
        .clk(clk),
        .reset(reset),
        .not_ready(ram_not_ready[i])
       );
      
      
      
      
      
      /*
      cache_dual_port_ram #(
      	.Dw(INFOw),
        .Aw(INDEXw),
        .RESET_RAM_CONTENT(RESET_RAM_CONTENT),
        .BYTE_WR_EN("NO"),
        .INITIAL_EN("NO")      
      )
       info_cache_ram
       (
      	//write
      	.data_a(info_ram_in_wr),     	
      	.addr_a(ram_addr_i_wr),
        .byteen_a(wr_byteen),
      	.we_a(ram_we_i_wr[i]),
      	.q_a(info_array_wr[i]),
      
      	 //read
      	.data_b( ),
      	.addr_b(ram_addr_i_rd),
       	.byteen_b({BYTE_ENw{1'b0}}),      
      	.we_b(1'b0),
      	.q_b(info_array_rd[i] ),
      	
      	.clk(clk),
      
      	
      	.reset(reset),
      	.not_ready(ram_not_ready[i])
      );
      
      */
      
      snpf_ram #(
         .Dw(DATAw),
        .Aw(INDEXw)
       )
       ram2
       (
       //chanel a . rd & wr
        .wr_dat_a(new_data),
        .addr_a(ram_addr_i_wr ),
        .wr_en_a(ram_we_i_wr[i] ),
        .rd_dat_a( data_array_wr[i]),
        
       //chanel b rd only  
        .rd_dat_b(data_array_rd[i] ),
        .addr_b(ram_addr_i_rd),
        .rd_en_b(rd_en),
        
        .clk(clk),
        .reset(reset),
        .not_ready( )
       );
      
      
      
      /*
      
      cache_dual_port_ram #(
        .Dw(DATAw),
        .Aw(INDEXw),
        .RESET_RAM_CONTENT("NONE"),
        .BYTE_WR_EN("NO"),
        .INITIAL_EN("NO")      
      )
        data_cache_ram
       (
        //write
        .data_a(wr_data_reg),        
        .addr_a(ram_addr_i_wr),
        .byteen_a(wr_byteen),
        .we_a(ram_we_i_wr[i]),
        .q_a( ),
      
         //read
        .data_b(),
        .addr_b(ram_addr_i_rd),
        .byteen_b({BYTE_ENw{1'b0}}),      
        .we_b(1'b0),
        .q_b(data_array_rd[i]),
        
        .clk(clk),
      
        
        .reset(reset),
        .not_ready()
      );
      */
      
      
     
      assign {valid_array_rd[i],status_array_rd[i], tag_array_rd[i]} = info_array_rd[i];
      assign compartors_array_rd[i] = tag_array_rd[i] == tag_in_rd;
      assign hit_array_rd[i] = compartors_array_rd[i] & valid_array_rd[i];
      
      assign {valid_array_wr[i],status_array_wr[i], tag_array_wr[i]} = info_array_wr[i];
      assign compartors_array_wr[i] = tag_array_wr[i] == tag_in_wr;
     
      
      assign hit_array_wr[i] = compartors_array_wr[i] & valid_array_wr[i];   
      
      
    end  
    endgenerate  
   
  
   
    wire [WAYw-1 : 0] hit_binary_rd,hit_binary_wr;
    
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(WAY_NUM),
        .BIN_WIDTH(WAYw)
    )
    encoder_rd
    (
        .one_hot_code(hit_array_rd),
        .bin_code(hit_binary_rd)
    );
   
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(WAY_NUM),
        .BIN_WIDTH(WAYw)
    )
    encoder_wr
    (
        .one_hot_code(hit_array_wr),
        .bin_code(hit_binary_wr)
    );
   
    assign wr_dat_old = data_array_wr[hit_binary_wr];
    assign wr_state_old = status_array_wr[hit_binary_wr];
    
    assign rd_data =  data_array_rd[hit_binary_rd];
    assign rd_state = (rd_hit) ? status_array_rd[hit_binary_rd] : CACHE_I;
    assign rd_hit = | hit_array_rd;    
      
    
    assign wr_hit = | hit_array_wr;     
    
    //synthesis translate_off 
    //synopsys  translate_off
    
     reg  [ADDRw-1 : 0] wr_addr_reg;
     
    
     wire [23 : 0] st_str = 
        (ps == EVICT ) ? "  I" :
        (new_status == CACHE_I  )? "  I" : 
        (new_status == CACHE_UC )? " UC" :
        (new_status == CACHE_SC )? " SC" :
        (new_status == CACHE_UCE)? "UCE" : 
        (new_status == CACHE_UD )? " UD" :
        (new_status == CACHE_SD )? " SD" : 
        (new_status == CACHE_UDP)? "UDP" : "XXX";
   
    
     
    
    always @(posedge clk)begin 
        wr_addr_reg<= wr_addr;
        if(wr_done_next &  ((VERBOSITY & MONITORE_CACHE)!=0)) begin 
            $display("%t: cch ( %d ) Write ( %h ) with state %s on addr ( %d )",$time, src_id, new_data,st_str, wr_addr_reg );
        end
        if(ram_not_ready[0] && (wr_en | rd_en) ) begin 
            $display("%t: cch ( %d ) Error: a cache read or write command recived while the cache was not ready yet",$time,src_id);
            $stop;
        end
    /* 
        if(re_fill) begin  
            $display("%t: cch (%d) re_fill is asserted. This will cause snpf result would not be valid anymore which is not yet supportd to be handled",$time, src_id); 
            $stop;
        end
    */
    end
    //synthesis translate_on 
    //synopsys  translate_on
    
    

endmodule 


