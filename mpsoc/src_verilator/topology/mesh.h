#ifndef MESH_H
	#define MESH_H


	#define  EAST       1 
	#define  NORTH      2  
	#define  WEST       3  
	#define  SOUTH      4

	//ring line            
	#define  FORWARD    1
	#define  BACKWARD   2
	#define router_id(x,y)  ((y * T1) +    x)
	#define endp_id(x,y,l)  ((y * T1) +    x) * T3 + l 


void topology_connect_all_nodes (void){

	
	
	unsigned int nxw=0;
	while((0x1<<nxw) < T1)nxw++;	

	unsigned int  x,y,l;
	#if defined (IS_LINE) || defined (IS_RING ) 
			#define R2R_CHANELS_MESH_TORI   2 
			for  (x=0;   x<T1; x=x+1) {             
                       
				router1[x]->current_r_addr = x;   
				if(x    <   T1-1){// not_last_node 
					//assign  router_chan_in[x][FORWARD] = router_chan_out [(x+1)][BACKWARD];
					conect_r2r(1,x,FORWARD,1,(x+1),BACKWARD);

				} else { //last_node
					
					#if defined (IS_LINE) // : line_last_x
						//assign  router_chan_in[x][FORWARD]= {ROUTER_CHANEL_w{1'b0}};
						connect_r2gnd(1,x,FORWARD);				      
					#else // : ring_last_x
						//assign router_chan_in[x][FORWARD]= router_chan_out [0][BACKWARD];
						conect_r2r(1,x,FORWARD,1,0,BACKWARD);
					#endif
				}
            
				if(x>0){// :not_first_x
					//assign router_chan_in[x][BACKWARD]= router_chan_out [(x-1)][FORWARD];
					conect_r2r(1,x,BACKWARD,1,(x-1),FORWARD);
				
				}else {// :first_x
					#if defined (IS_LINE) // : line_first_x
						//assign  router_chan_in[x][BACKWARD]={ROUTER_CHANEL_w{1'b0}};					
						connect_r2gnd(1,x,BACKWARD);
					#else // : ring_first_x
						//assign  router_chan_in[x][BACKWARD]= router_chan_out [(NX-1)][FORWARD];											
						conect_r2r(1,x,BACKWARD,1,(T1-1),FORWARD);
					#endif
				}           
            
				// connect other local ports
				for  (l=0;   l<T3; l=l+1) {// :locals
					unsigned int ENDPID = endp_id(x,0,l); 
					unsigned int LOCALP = (l==0) ? l : l + R2R_CHANELS_MESH_TORI; // first local port is connected to router port 0. The rest are connected at the } 
					//assign router_chan_in[x][LOCALP]= chan_in_all [ENDPID];
					//assign chan_out_all [ENDPID] = router_chan_out[x][LOCALP];
					connect_r2e(1,x,LOCALP,ENDPID);
					er_addr [ENDPID] = x;        
					                
				}// locals               
			}//x    
			
		#else // :mesh_torus
			#define R2R_CHANELS_MESH_TORI   4 
			for (y=0;    y<T2;    y=y+1) {//: y_loop
				for (x=0;    x<T1; x=x+1) {// :x_loop
				unsigned int R_ADDR = (y<<nxw) + x;            
				unsigned int ROUTER_NUM = (y * T1) +    x;					
				//assign current_r_addr [ROUTER_NUM] = R_ADDR[RAw-1 :0];
             	router1[ROUTER_NUM]->current_r_addr = R_ADDR;  
					      
        
				if(x    <    T1-1) {//: not_last_x
					//assign router_chan_in[`router_id(x,y)][EAST]= router_chan_out [`router_id(x+1,y)][WEST];
					conect_r2r(1,router_id(x,y),EAST,1,router_id(x+1,y),WEST);
									
				}else {// :last_x
					#if defined (IS_MESH) // :last_x_mesh
						//	assign router_chan_in[`router_id(x,y)][EAST] = {ROUTER_CHANEL_w{1'b0}};					
						connect_r2gnd(1,router_id(x,y),EAST);
					#else // : last_x_torus
						//assign router_chan_in[`router_id(x,y)][EAST] = router_chan_out [`router_id(0,y)][WEST];
						conect_r2r(1,router_id(x,y),EAST,1,router_id(0,y),WEST);						
					#endif//topology
				}
            
        
				if(y>0) {// : not_first_y
					//assign router_chan_in[`router_id(x,y)][NORTH] =  router_chan_out [`router_id(x,(y-1))][SOUTH];					
					conect_r2r(1,router_id(x,y),NORTH,1,router_id(x,(y-1)),SOUTH);		
				}else {// :first_y
					#if defined (IS_MESH) // : first_y_mesh
					 	//assign router_chan_in[`router_id(x,y)][NORTH] =  {ROUTER_CHANEL_w{1'b0}};												
					 	connect_r2gnd(1,router_id(x,y),NORTH);	 
					#else// :first_y_torus
						//assign router_chan_in[`router_id(x,y)][NORTH] =  router_chan_out [`router_id(x,(T2-1))][SOUTH];
						conect_r2r(1,router_id(x,y),NORTH,1,router_id(x,(T2-1)),SOUTH);							
					#endif//topology
				}//y>0
            
            
				if(x>0){// :not_first_x
					//assign    router_chan_in[`router_id(x,y)][WEST] =  router_chan_out [`router_id((x-1),y)][EAST];					
					conect_r2r(1,router_id(x,y),WEST,1,router_id((x-1),y),EAST);	
				}else {// :first_x
					 
					#if defined (IS_MESH) // :first_x_mesh
						//assign    router_chan_in[`router_id(x,y)][WEST] =   {ROUTER_CHANEL_w{1'b0}};
						connect_r2gnd(1,router_id(x,y),WEST);							
						                
					#else // :first_x_torus
						//assign    router_chan_in[`router_id(x,y)][WEST] =   router_chan_out [`router_id((NX-1),y)][EAST] ;						
						conect_r2r(1,router_id(x,y),WEST,1,router_id((T1-1),y),EAST);
					#endif//topology
				}   
            
				if(y    <    T2-1) {// : firsty
					//assign  router_chan_in[`router_id(x,y)][SOUTH] =    router_chan_out [`router_id(x,(y+1))][NORTH];					
					conect_r2r(1,router_id(x,y),SOUTH,1,router_id(x,(y+1)),NORTH);
				}else     {// : lasty
					 
					#if defined (IS_MESH) // :ly_mesh
						 
						//assign  router_chan_in[`router_id(x,y)][SOUTH]=  {ROUTER_CHANEL_w{1'b0}};
						connect_r2gnd(1,router_id(x,y),SOUTH);	
						 
					#else // :ly_torus						 
						//assign  router_chan_in[`router_id(x,y)][SOUTH]=    router_chan_out [`router_id(x,0)][NORTH];
						conect_r2r(1,router_id(x,y),SOUTH,1,router_id(x,0),NORTH);						
					#endif//topology
				}         
        
        
				// endpoint(s) connection
				// connect other local ports
				for  (l=0;   l<T3; l=l+1) {// :locals
					unsigned int ENDPID = endp_id(x,y,l); 
					unsigned int LOCALP = (l==0) ? l : l + R2R_CHANELS_MESH_TORI; // first local port is connected to router port 0. The rest are connected at the } 
                
					//assign router_chan_in [`router_id(x,y)][LOCALP] =    chan_in_all [ENDPID];
					//assign chan_out_all [ENDPID] = router_chan_out [`router_id(x,y)][LOCALP];	
					//assign er_addr [ENDPID] = R_ADDR;		
                    connect_r2e(1,router_id(x,y),LOCALP,ENDPID); 
					er_addr [ENDPID] = R_ADDR;         
				}// locals                 
    
			}//y
		}//x
	#endif     
    
	
}	


void topology_init(void){

}

#endif
