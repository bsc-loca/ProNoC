#ifndef MESH_H
	#define MESH_H

#define IS_MESH   (strcmp(TOPOLOGY ,"MESH")==0)
#define IS_TORUS  (strcmp(TOPOLOGY ,"TORUS")==0)
#define IS_LINE   (strcmp(TOPOLOGY ,"LINE")==0)
#define IS_RING   (strcmp(TOPOLOGY ,"RING")==0)
#define IS_TREE   (strcmp(TOPOLOGY ,"TREE")==0)
#define IS_FATTREE   (strcmp(TOPOLOGY ,"FATTREE")==0)

#define CHAN_SIZE   sizeof(traffic[0]->chan_in)

#define conect_r2r(T1,r1,p1,T2,r2,p2)  \
	memcpy(&router##T1 [r1]->chan_in + (p1*CHAN_SIZE), router##T2 [r2]->chan_out + (p2*CHAN_SIZE), CHAN_SIZE )

#define connect_r2gnd(T,r,p)\
	memset(&router##T [r]->chan_in + (p*CHAN_SIZE),0x00,CHAN_SIZE)

#define connect_r2e(T,r,p,e) \
	memcpy(&router##T [r]->chan_in + (p*CHAN_SIZE), traffic[e]->chan_out, CHAN_SIZE );\
	memcpy(&traffic[e]->chan_in, router##T [r]->chan_out + (p*CHAN_SIZE), CHAN_SIZE )


	#define  EAST       1 
	#define  NORTH      2  
	#define  WEST       3  
	#define  SOUTH      4

	//ring line            
	#define  FORWARD    1
	#define  BACKWARD   2
	#define router_id(x,y)  ((y * T1) +    x)
	#define endp_id(x,y,l)  ((y * T1) +    x) * T3 + l 


void mesh_connect_nodes (void){

	
	unsigned int R2R_CHANELS_MESH_TORI = (IS_RING||IS_LINE)? 2:4; 
	unsigned int nxw=0;
	while((0x1<<nxw) < T1)nxw++;	

	unsigned int  x,y,l;
	if( IS_LINE || IS_RING ) {
			
			for  (x=0;   x<T1; x=x+1) {             
                       
				router1[x]->current_r_addr = x;   
				if(x    <   T1-1){// not_last_node 
					//assign  router_chan_in[x][FORWARD] = router_chan_out [(x+1)][BACKWARD];
					conect_r2r(1,x,FORWARD,1,(x+1),BACKWARD);

				} else { //last_node
					
					if(IS_LINE) {// : line_last_x
						//assign  router_chan_in[x][FORWARD]= {ROUTER_CHANEL_w{1'b0}};
						connect_r2gnd(1,x,FORWARD);				      
					}else {// : ring_last_x
						//assign router_chan_in[x][FORWARD]= router_chan_out [0][BACKWARD];
						conect_r2r(1,x,FORWARD,1,0,BACKWARD);
					}
				}
            
				if(x>0){// :not_first_x
					//assign router_chan_in[x][BACKWARD]= router_chan_out [(x-1)][FORWARD];
					conect_r2r(1,x,BACKWARD,1,(x-1),FORWARD);
				
				}else {// :first_x
					if(IS_LINE) {// : line_first_x
						//assign  router_chan_in[x][BACKWARD]={ROUTER_CHANEL_w{1'b0}};					
						connect_r2gnd(1,x,BACKWARD);
					}else {// : ring_first_x
						//assign  router_chan_in[x][BACKWARD]= router_chan_out [(NX-1)][FORWARD];											
						conect_r2r(1,x,BACKWARD,1,(T1-1),FORWARD);
					}
				}           
            
				// connect other local ports
				for  (l=0;   l<T3; l=l+1) {// :locals
					unsigned int ENDPID = endp_id(x,0,l); 
					unsigned int LOCALP = (l==0) ? l : l + R2R_CHANELS_MESH_TORI; // first local port is connected to router port 0. The rest are connected at the } 
					//assign router_chan_in[x][LOCALP]= chan_in_all [ENDPID];
					//assign chan_out_all [ENDPID] = router_chan_out[x][LOCALP];
					connect_r2e(1,x,LOCALP,ENDPID);
					                
				}// locals               
			}//x    
			
		}else {// :mesh_torus
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
					if(IS_MESH) {// :last_x_mesh
						//	assign router_chan_in[`router_id(x,y)][EAST] = {ROUTER_CHANEL_w{1'b0}};					
						connect_r2gnd(1,router_id(x,y),EAST);
					}else if(IS_TORUS) {// : last_x_torus
						//assign router_chan_in[`router_id(x,y)][EAST] = router_chan_out [`router_id(0,y)][WEST];
						conect_r2r(1,router_id(x,y),EAST,1,router_id(0,y),WEST);						
					}//topology
				}
            
        
				if(y>0) {// : not_first_y
					//assign router_chan_in[`router_id(x,y)][NORTH] =  router_chan_out [`router_id(x,(y-1))][SOUTH];					
					conect_r2r(1,router_id(x,y),NORTH,1,router_id(x,(y-1)),SOUTH);		
				}else {// :first_y
					if(IS_MESH) {// : first_y_mesh
					 	//assign router_chan_in[`router_id(x,y)][NORTH] =  {ROUTER_CHANEL_w{1'b0}};												
					 	connect_r2gnd(1,router_id(x,y),NORTH);	 
					}else if(IS_TORUS) {// :first_y_torus
						//assign router_chan_in[`router_id(x,y)][NORTH] =  router_chan_out [`router_id(x,(T2-1))][SOUTH];
						conect_r2r(1,router_id(x,y),NORTH,1,router_id(x,(T2-1)),SOUTH);							
					}//topology
				}//y>0
            
            
				if(x>0){// :not_first_x
					//assign    router_chan_in[`router_id(x,y)][WEST] =  router_chan_out [`router_id((x-1),y)][EAST];					
					conect_r2r(1,router_id(x,y),WEST,1,router_id((x-1),y),EAST);	
				}else {// :first_x
					 
					if(IS_MESH) {// :first_x_mesh
						//assign    router_chan_in[`router_id(x,y)][WEST] =   {ROUTER_CHANEL_w{1'b0}};
						connect_r2gnd(1,router_id(x,y),WEST);							
						                
					}else if(IS_TORUS) {// :first_x_torus
						//assign    router_chan_in[`router_id(x,y)][WEST] =   router_chan_out [`router_id((NX-1),y)][EAST] ;						
						conect_r2r(1,router_id(x,y),WEST,1,router_id((T1-1),y),EAST);
					}//topology
				}   
            
				if(y    <    T2-1) {// : firsty
					//assign  router_chan_in[`router_id(x,y)][SOUTH] =    router_chan_out [`router_id(x,(y+1))][NORTH];					
					conect_r2r(1,router_id(x,y),SOUTH,1,router_id(x,(y+1)),NORTH);
				}else     {// : lasty
					 
					if(IS_MESH) {// :ly_mesh
						 
						//assign  router_chan_in[`router_id(x,y)][SOUTH]=  {ROUTER_CHANEL_w{1'b0}};
						connect_r2gnd(1,router_id(x,y),SOUTH);	
						 
					}else if(TOPOLOGY == "TORUS") {// :ly_torus						 
						//assign  router_chan_in[`router_id(x,y)][SOUTH]=    router_chan_out [`router_id(x,0)][NORTH];
						conect_r2r(1,router_id(x,y),SOUTH,1,router_id(x,0),NORTH);						
					}//topology
				}         
        
        
				// endpoint(s) connection
				// connect other local ports
				for  (l=0;   l<T3; l=l+1) {// :locals
					unsigned int ENDPID = endp_id(x,y,l); 
					unsigned int LOCALP = (l==0) ? l : l + R2R_CHANELS_MESH_TORI; // first local port is connected to router port 0. The rest are connected at the } 
                
					//assign router_chan_in [`router_id(x,y)][LOCALP] =    chan_in_all [ENDPID];
					//assign chan_out_all [ENDPID] = router_chan_out [`router_id(x,y)][LOCALP];			
                    connect_r2e(1,router_id(x,y),LOCALP,ENDPID);          
				}// locals                 
    
			}//y
		}//x
	}// mesh_torus        
    


	
}	
#endif
