module fake_sam #(
    parameter RAW_ADDR_SIZ =10,
    parameter TRGT_ADDR_SIZ = 10
   
)(
    raw_addr,
    target_hnf_id, // destination endpoint number
    target_addr // address in destination endpoint
);

   

  `define INCLUDE_MAPPING_FUNC
  `include "topology_mapping.v"  

  `define INCLUDE_CHI_LOCALPARAM
    `include "../chi_localparam.v"

  `define INCLUDE_TEST_LOCALPARAM
  `include "test_localparam.v"  


   input [RAW_ADDR_SIZ-1 : 0] raw_addr;
   output [TGTID_REQ-1 : 0] target_hnf_id;
   output [TRGT_ADDR_SIZ-1: 0] target_addr;

    
    // set target home node acording to mb2020 
    // consequatve cache blocks are mapped in different HNFs 
    // No odd even yet supported in ache/snoop filter
     function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2 

    localparam 
        LOW_OFFSETw = log2(CACHE_BLK_SIZ),        // The address range in cache block
      //  BLK_ADDRw = RAW_ADDR_SIZ - OFFSETw,
        HNF_ADDRw = log2(NUM_OF_HNs),
        HIGH_OFFSETw = RAW_ADDR_SIZ - HNF_ADDRw - LOW_OFFSETw;  
  
  
  
        wire [LOW_OFFSETw-1 : 0] low_offset_addr;
       // wire [BLK_ADDRw-1 : 0] block_addr = raw_addr [RAW_ADDR_SIZ-1 : OFFSETw];
        wire [HNF_ADDRw-1 : 0] hnf_num;
        wire [HIGH_OFFSETw-1 : 0] high_offset_addr;
       
        assign {high_offset_addr,hnf_num,low_offset_addr} = raw_addr;
       
        assign target_hnf_id = gen_hn_endp_id(hnf_num);
      //  assign target_addr = {high_offset_addr,low_offset_addr};
         assign target_addr = raw_addr;
   


endmodule









module rnfid_to_spv_addr_decode #(
    parameter SPVw=5,
    parameter IDw=8
)(
    rnf_id_i,
    rnf_spv_o
);

    input [IDw-1 : 0] rnf_id_i;
    output [SPVw-1 : 0] rnf_spv_o;

    wire [(2**IDw)-1 : 0] one_hot_code;

    `define INCLUDE_MAPPING_FUNC
    `include "topology_mapping.v"   
/*
    //The rnf_id depends on NoC mapping assume all rnfs get ID from 0 to N where is the last RN num
    bin_to_one_hot #(
    	.BIN_WIDTH(IDw)    	
    )
    convert
    (
    	.bin_code(rnf_id_i),
    	.one_hot_code(one_hot_code)
    );

    assign rnf_spv_o = one_hot_code [SPVw-1 : 0];

*/    
	assign rnf_spv_o=rn_endp_id_one_hot_decode( rnf_id_i);

   

endmodule






module spv_to_rnfid_addr_decode #(
    parameter SPVw=5,
    parameter IDw=8
)(
    rnf_id_o,
    rnf_spv_i
);

    output  [IDw-1 : 0] rnf_id_o;
    input [SPVw-1 : 0] rnf_spv_i;

 `define INCLUDE_MAPPING_FUNC
    `include "topology_mapping.v"   

     function integer log2;
      input integer number; begin   
         log2=(number <=1) ? 1: 0;    
         while(2**log2<number) begin    
            log2=log2+1;    
         end       
      end   
    endfunction // log2     

    localparam BINw= log2(SPVw);

    wire [BINw-1 : 0] bin_code;
       
    one_hot_to_bin #(
    	.ONE_HOT_WIDTH(SPVw)    
    )
    convert(
    	.one_hot_code(rnf_spv_i),
    	.bin_code(bin_code)
    );

   assign rnf_id_o= gen_rn_endp_id(bin_code);
/*
    always @(*)begin
         rnf_id_o = {IDw{1'b0}} ;
         rnf_id_o[BINw-1 : 0] = bin_code;
    end
*/   

endmodule













