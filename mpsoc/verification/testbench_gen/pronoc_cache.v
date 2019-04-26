/************
 * Set Associative Cache
 * ***********/

module pronoc_cache #(
    parameter WAY_NUM = 8,
    parameter RESET_DELAY= "IGNORE",   /*
        "IGNORE" : No policy is implemented for resetting the cache valid bits at reset time. Assumption is that the ram is reset externally  
        "SINGLE_CLK": valid bits are implemented as registers. it is only practical if the cache size is small  
        "MULTI_CLKS": the cache controller reset the entire cache block after  reset assertion. The number of needed clock cycle is equal to cache line number
        */
    parameter TAGw = 20,
    parameter DATAw = 32,
    parameter INDEXw=10,
    parameter ADDRw=32,
    parameter BYTE_WR_EN="NO"
)(
    addr,
    we,
    data_in,
    byteen_in,
    data_out,
    reset,
    hit,
    busy,
    evict,
    clk
);

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
        BYTE_ENw= ( BYTE_WR_EN == "YES")? DATAw/8 : 1,
        VALID_POS = 1'b0,
        RESET_RAM_CONTENT=(RESET_DELAY=="MULTI_CLKS")? "ENABLE" : "NONE";

    localparam 
        STATUSw =1, // valid invalid
        OFFSETw = ADDRw -  TAGw -INDEXw,
        INFOw = TAGw + STATUSw,
        WAYw = log2(WAY_NUM),
        RAM_Aw = INDEXw;    
        
    // States
    localparam ST_NUM=6;

    localparam [ST_NUM-1 :   0]
        READ = 1,
        WRITE=2,
        EVICT=8;
                   
    
    input [ADDRw-1 : 0] addr;
    input [DATAw-1 : 0] data_in;
    input [BYTE_ENw-1 : 0] byteen_in;
    output[DATAw-1 : 0] data_out;
    input we;
    input reset;
    input clk;
    output busy;    
    output hit;
    input evict;
        
    wire [TAGw-1 : 0] tag_in;
    wire new_status=1'b1;
    wire [INDEXw-1 : 0] index_in;
    wire [RAM_Aw-1 : 0] ram_addr_i = index_in;
      
   
    reg [WAY_NUM-1 : 0] ram_we_i;
    reg [INFOw-1:0] info_ram_in;
    wire [INFOw-1:0] info_array [WAY_NUM-1 : 0];
    wire [TAGw-1: 0] tag_array [WAY_NUM-1 : 0];
    wire [STATUSw-1 : 0] status_array[WAY_NUM-1 : 0];
    wire [DATAw-1 : 0] data_array [WAY_NUM-1 : 0];
    wire [WAY_NUM-1 : 0] compartors_array;
    wire [WAY_NUM-1 : 0] hit_array;
    wire [WAY_NUM-1 : 0] valid_array, empty_ways;
    wire ram_not_ready;
    reg [ST_NUM-1 : 0] ps,ns;
    reg random_pos_en;
    reg [WAY_NUM-1 : 0] random_way;
    wire [WAY_NUM-1 : 0] empty_candidate_way;
    wire any_empty;
    
    assign busy = ram_not_ready | ps!=READ;
    assign empty_ways = ~ valid_array;
    // decode the input addr
    assign {tag_in,index_in} = addr[ADDRw-1 : OFFSETw];       
  
    
    always @(*)begin 
        ns=ps;
        random_pos_en=1'b0;
        info_ram_in={INFOw{1'b0}};
        ram_we_i={WAY_NUM{1'b0}};
        case(ps)
        READ: begin 
            if(we) begin 
                ns=  WRITE;
            end  
            if(evict) begin 
                ns= EVICT;            
            end
        end 
        WRITE:begin   
             info_ram_in={new_status ,tag_in};
            if(hit) begin // This cache exists inside the memory rewrite the new data
                ram_we_i=hit_array;           
            end 
            // this is a new cache data  
            else if (any_empty) begin // select random way to evict
                      ram_we_i=empty_candidate_way;              
            end else begin  // all ways are full select one random loc to evict 
                random_pos_en=1'b1;
                ram_we_i=random_way;                  
            end
             ns=  READ;
        end    
        EVICT:begin  
            if(hit) begin // This cache exists inside the memory rewrite the new data
                ram_we_i=hit_array;           
            end 
            ns=  READ;
        end        
        endcase    
    end
    
        
    always @(posedge clk or posedge reset) begin
        if(reset)begin 
            ps<= READ;
            random_way<={WAY_NUM{1'b1}};
        end else begin 
            ps<=ns;
            if(random_pos_en) random_way<= {random_way[WAY_NUM-2:0],random_way[WAY_NUM-1]};
        end        
    end
    
    //select one empty way
    fixed_priority_arbiter #(
    	.ARBITER_WIDTH(WAY_NUM)
    )
    arbiter
    (
    	.request(empty_ways),
    	.grant(empty_candidate_way),
    	.any_grant(any_empty)
    );    
    
    
    genvar i;
    generate 
    for (i=0; i<WAY_NUM; i=i+1)begin:way
      
      cache_ram #(
      	.Dw(INFOw),
        .Aw(INDEXw),
        .RESET_RAM_CONTENT(RESET_RAM_CONTENT),
        .BYTE_WR_EN("NO"),
        .INITIAL_EN("NO")      
      )
      info_cache_ram
      (
      	.data(info_ram_in),
      	.addr(ram_addr_i),
      	.byteen(),
      	.we(ram_we_i[i]),
      	.clk(clk),
      	.q(info_array[i]),
      	.reset(reset),
      	.not_ready(ram_not_ready)
      );
      
      
      cache_ram #(
        .Dw(DATAw),
        .Aw(INDEXw),
        .RESET_RAM_CONTENT("NONE"),
        .BYTE_WR_EN(BYTE_WR_EN),
        .INITIAL_EN("NO")      
      )
      data_cache_ram
      (
        .data(data_in),
        .addr(ram_addr_i),
        .byteen(byteen_in),
        .we(ram_we_i[i]),
        .clk(clk),
        .q(data_array[i]),
        .reset(reset),
        .not_ready()
      );      
     
      assign {status_array[i], tag_array[i]} = info_array[i];
      assign compartors_array[i] = tag_array[i] == tag_in;
      assign valid_array[i] = status_array[i][VALID_POS];
      assign hit_array[i] = compartors_array[i] & valid_array[i];            
      
    end  
    endgenerate  
   
  
   
    wire [WAYw-1 : 0] hit_binary;
    
    one_hot_to_bin #(
        .ONE_HOT_WIDTH(),
        .BIN_WIDTH()
    )
    encoder
    (
        .one_hot_code(hit_array),
        .bin_code(hit_binary)
    );
   
   
    assign data_out =  data_array[hit_binary];
    assign hit = | hit_array;    
    

endmodule 


module test;
endmodule
