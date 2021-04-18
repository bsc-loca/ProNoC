 
`ifdef INCLUDE_MAPPING_FUNC  
      
    

//gen_rn_endp_id=(rn_id*3)+1;  
 function integer gen_rn_endp_id;
      input integer rn_id; begin   
        case(rn_id)
        0: gen_rn_endp_id=1;
        1: gen_rn_endp_id=4;
        2: gen_rn_endp_id=7;
        3: gen_rn_endp_id=10;
        4: gen_rn_endp_id=13;
        5: gen_rn_endp_id=16;
        6: gen_rn_endp_id=19;
        7: gen_rn_endp_id=22;
        8: gen_rn_endp_id=25;
        9: gen_rn_endp_id=28;
        10:gen_rn_endp_id=31;
        11:gen_rn_endp_id=34;
        12:gen_rn_endp_id=37;
        13:gen_rn_endp_id=40;
        14:gen_rn_endp_id=43;
        15:gen_rn_endp_id=46;
        endcase
      end   
    endfunction 
        
   //rn_endp_id_one_hot_decode = 1<<((rn_endp_id-1)/3);
//should be generated according to the above function
 function integer rn_endp_id_one_hot_decode;
      input integer rn_endp_id; begin   
        case(rn_endp_id)
        1:  rn_endp_id_one_hot_decode= 1<<0;
        4:  rn_endp_id_one_hot_decode= 1<<1;
        7:  rn_endp_id_one_hot_decode= 1<<2;
        10: rn_endp_id_one_hot_decode= 1<<3;
        13: rn_endp_id_one_hot_decode= 1<<4;
        16: rn_endp_id_one_hot_decode= 1<<5;
        19: rn_endp_id_one_hot_decode= 1<<6;
        22: rn_endp_id_one_hot_decode= 1<<7;
        25: rn_endp_id_one_hot_decode= 1<<8;
        28: rn_endp_id_one_hot_decode= 1<<9;
        31: rn_endp_id_one_hot_decode= 1<<10;
        34: rn_endp_id_one_hot_decode= 1<<11;
        37: rn_endp_id_one_hot_decode= 1<<12;
        40: rn_endp_id_one_hot_decode= 1<<13;
        43: rn_endp_id_one_hot_decode= 1<<14;
        46: rn_endp_id_one_hot_decode= 1<<15;
        
        endcase
      end   
    endfunction 

    //gen_hn_endp_id=  (hn_id*3); 
     function integer gen_hn_endp_id;
      input integer hn_id; begin   
        case(hn_id)
        0: gen_hn_endp_id=0;
        1: gen_hn_endp_id=3;
        2: gen_hn_endp_id=6;
        3: gen_hn_endp_id=9;
        4: gen_hn_endp_id=12;
        5: gen_hn_endp_id=15;
        6: gen_hn_endp_id=18;
        7: gen_hn_endp_id=21;
        8: gen_hn_endp_id=24;
        9: gen_hn_endp_id=27;
        10:gen_hn_endp_id=30;
        11:gen_hn_endp_id=33;
        12:gen_hn_endp_id=36;
        13:gen_hn_endp_id=39;
        14:gen_hn_endp_id=42;
        15:gen_hn_endp_id=45;       
        endcase
      end   
    endfunction 
    
    
     
        
    
     function integer gen_sn_endp_id;
      input integer sn_id; begin  //condition to be met : gen_sn_endp_id %3 =2   
        case(sn_id)
        0: gen_sn_endp_id=2;
        1: gen_sn_endp_id=11;
 	2: gen_sn_endp_id=38;
        3: gen_sn_endp_id=47;
        endcase
      end   
    endfunction // log2        
          
       
    function integer gen_assigned_sn_enp_id_to_hn; // get 
      input integer hn_id; begin   
        case(hn_id)
        0: gen_assigned_sn_enp_id_to_hn=0;
        1: gen_assigned_sn_enp_id_to_hn=0;
        4: gen_assigned_sn_enp_id_to_hn=0;
	5: gen_assigned_sn_enp_id_to_hn=0;

	2: gen_assigned_sn_enp_id_to_hn=1;
	3: gen_assigned_sn_enp_id_to_hn=1;
        6: gen_assigned_sn_enp_id_to_hn=1;
	7: gen_assigned_sn_enp_id_to_hn=1;

	8: gen_assigned_sn_enp_id_to_hn=2;
	9: gen_assigned_sn_enp_id_to_hn=2;
	12: gen_assigned_sn_enp_id_to_hn=2;
	13: gen_assigned_sn_enp_id_to_hn=2;

	10: gen_assigned_sn_enp_id_to_hn=3;
	11: gen_assigned_sn_enp_id_to_hn=3;
	14: gen_assigned_sn_enp_id_to_hn=3;
	15: gen_assigned_sn_enp_id_to_hn=3;


       
        endcase
      end   
    endfunction // log2   


  
     
    function integer gen_hn_loc_in_sn;
      input integer hnf_id; begin   
        case(hnf_id)
        0: gen_hn_loc_in_sn=0;
        1: gen_hn_loc_in_sn=1;
        4: gen_hn_loc_in_sn=2;
	5: gen_hn_loc_in_sn=3;

	2: gen_hn_loc_in_sn=0;
	3: gen_hn_loc_in_sn=1;
        6: gen_hn_loc_in_sn=2;
	7: gen_hn_loc_in_sn=3;

	8: gen_hn_loc_in_sn=0;
	9: gen_hn_loc_in_sn=1;
	12: gen_hn_loc_in_sn=2;
	13: gen_hn_loc_in_sn=3;

	10: gen_hn_loc_in_sn=0;
	11: gen_hn_loc_in_sn=1;
	14: gen_hn_loc_in_sn=2;
	15: gen_hn_loc_in_sn=3;
        endcase
      end   
    endfunction // log2 



	
   


`endif       
