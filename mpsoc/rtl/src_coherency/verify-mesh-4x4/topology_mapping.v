 
`ifdef INCLUDE_MAPPING_FUNC  
      
      
      
        
      function integer gen_rn_endp_id;
      input integer rn_id; begin   
        case(rn_id)
        0: gen_rn_endp_id=1;
        1: gen_rn_endp_id=3;
        2: gen_rn_endp_id=5;
        3: gen_rn_endp_id=7;
        4: gen_rn_endp_id=9;
        5: gen_rn_endp_id=11;
        6: gen_rn_endp_id=13;
        7: gen_rn_endp_id=15;
        8: gen_rn_endp_id=17;
        9: gen_rn_endp_id=19;
        10:gen_rn_endp_id=21;
        11:gen_rn_endp_id=23;
        12:gen_rn_endp_id=25;
        13:gen_rn_endp_id=27;
        14:gen_rn_endp_id=29;
        endcase
      end   
    endfunction // log2 
        
//should be generated according to the above function
 function integer rn_endp_id_one_hot_decode;
      input integer rn_endp_id; begin   
        case(rn_endp_id)
        1: rn_endp_id_one_hot_decode= 1<<0;
        3: rn_endp_id_one_hot_decode= 1<<1;
        5: rn_endp_id_one_hot_decode= 1<<2;
        7: rn_endp_id_one_hot_decode= 1<<3;
        9: rn_endp_id_one_hot_decode= 1<<4;
        11:rn_endp_id_one_hot_decode= 1<<5;
        13:rn_endp_id_one_hot_decode= 1<<6;
        15:rn_endp_id_one_hot_decode= 1<<7;
        17:rn_endp_id_one_hot_decode= 1<<8;
        19:rn_endp_id_one_hot_decode= 1<<9;
        21:rn_endp_id_one_hot_decode= 1<<10;
        23:rn_endp_id_one_hot_decode= 1<<11;
        25:rn_endp_id_one_hot_decode= 1<<12;
        27:rn_endp_id_one_hot_decode= 1<<13;
        29:rn_endp_id_one_hot_decode= 1<<14;
        endcase
      end   
    endfunction // log2 

        
    function integer gen_hn_endp_id;
      input integer hn_id; begin   
        case(hn_id)
	0: gen_hn_endp_id=0;
        1: gen_hn_endp_id=2;
        2: gen_hn_endp_id=4;
        3: gen_hn_endp_id=8;
        4: gen_hn_endp_id=10;
        5: gen_hn_endp_id=12;
        6: gen_hn_endp_id=14;
        7: gen_hn_endp_id=16;
        8: gen_hn_endp_id=18;
        9: gen_hn_endp_id=20;
        10:gen_hn_endp_id=22;
        11:gen_hn_endp_id=24;
        12:gen_hn_endp_id=26;
        13:gen_hn_endp_id=28;
        14:gen_hn_endp_id=30;

       
        endcase
      end   
    endfunction // log2  
        
    
     function integer gen_sn_endp_id;
      input integer sn_id; begin   
        case(sn_id)
        0: gen_sn_endp_id=6;
        1: gen_sn_endp_id=31;
        endcase
      end   
    endfunction // log2        
          
       
    function integer gen_assigned_sn_enp_id_to_hn; // get 
      input integer hn_id; begin   
        case(hn_id)
        0: gen_assigned_sn_enp_id_to_hn=0;
        1: gen_assigned_sn_enp_id_to_hn=1;
        2: gen_assigned_sn_enp_id_to_hn=0;
        3: gen_assigned_sn_enp_id_to_hn=1;
        4: gen_assigned_sn_enp_id_to_hn=0;
        5: gen_assigned_sn_enp_id_to_hn=1;
        6: gen_assigned_sn_enp_id_to_hn=0;
        7: gen_assigned_sn_enp_id_to_hn=1;
        8: gen_assigned_sn_enp_id_to_hn=0;
        9: gen_assigned_sn_enp_id_to_hn=1;
        10:gen_assigned_sn_enp_id_to_hn=0;
        11:gen_assigned_sn_enp_id_to_hn=1;
        12:gen_assigned_sn_enp_id_to_hn=0;
        13:gen_assigned_sn_enp_id_to_hn=1;
        14:gen_assigned_sn_enp_id_to_hn=0;
        endcase
      end   
    endfunction // log2     
     
    function integer gen_hn_loc_in_sn;
      input integer hnf_id; begin   
        case(hnf_id)
        0: gen_hn_loc_in_sn=0;
        1: gen_hn_loc_in_sn=0;
        2: gen_hn_loc_in_sn=1;
        3: gen_hn_loc_in_sn=1;
        4: gen_hn_loc_in_sn=2;
        5: gen_hn_loc_in_sn=2;
        6: gen_hn_loc_in_sn=3;
        7: gen_hn_loc_in_sn=3;
        8: gen_hn_loc_in_sn=4;
        9: gen_hn_loc_in_sn=4;
        10:gen_hn_loc_in_sn=5;
        11:gen_hn_loc_in_sn=5;
        12:gen_hn_loc_in_sn=6;
        13:gen_hn_loc_in_sn=6;
        14:gen_hn_loc_in_sn=7;
        endcase
      end   
    endfunction // log2 



	
   


`endif       
