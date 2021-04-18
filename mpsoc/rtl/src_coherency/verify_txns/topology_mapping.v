 
`ifdef INCLUDE_MAPPING_FUNC  
      
      
      
        
      function integer gen_rn_endp_id;
      input integer rn_id; begin   
        case(rn_id)
        0: gen_rn_endp_id=0;
        1: gen_rn_endp_id=1;
        2: gen_rn_endp_id=2;
        3: gen_rn_endp_id=3;
        endcase
      end   
    endfunction // log2 
        
//should be generated according to the above function
 function integer rn_endp_id_one_hot_decode;
      input integer rn_endp_id; begin   
        case(rn_endp_id)
        0: rn_endp_id_one_hot_decode= 1<<0;
        1: rn_endp_id_one_hot_decode= 1<<1;
        2: rn_endp_id_one_hot_decode= 1<<2;
        3: rn_endp_id_one_hot_decode= 1<<3;
        endcase
      end   
    endfunction // log2 

        
    function integer gen_hn_endp_id;
      input integer hn_id; begin   
        case(hn_id)
	0: gen_hn_endp_id=4;
        1: gen_hn_endp_id=5;
        2: gen_hn_endp_id=6;
        3: gen_hn_endp_id=7;
            
        endcase
      end   
    endfunction // log2  
        
    
     function integer gen_sn_endp_id;
      input integer sn_id; begin   
        case(sn_id)
        0: gen_sn_endp_id=8;
        endcase
      end   
    endfunction // log2        
          
       
    function integer gen_assigned_sn_enp_id_to_hn; // get 
      input integer hn_id; begin   
        case(hn_id)
        0: gen_assigned_sn_enp_id_to_hn=0;
        1: gen_assigned_sn_enp_id_to_hn=0;
        2: gen_assigned_sn_enp_id_to_hn=0;
        3: gen_assigned_sn_enp_id_to_hn=0;
      
        endcase
      end   
    endfunction // log2     
     
    function integer gen_hn_loc_in_sn;
      input integer hnf_id; begin   
        case(hnf_id)
        0: gen_hn_loc_in_sn=0;
        1: gen_hn_loc_in_sn=1;
        2: gen_hn_loc_in_sn=2;
        3: gen_hn_loc_in_sn=3;
       
        endcase
      end   
    endfunction // log2 



	
   


`endif       
