#ifndef TOPOLOGY_H
#define TOPOLOGY_H

	unsigned int nxw=0;
	unsigned int nyw=0;
	unsigned int maskx=0;
	unsigned int masky=0;
	

unsigned int fattree_addrencode( unsigned int pos, unsigned int k, unsigned int l){
	unsigned int pow,i,tmp=0;
	unsigned int addrencode=0;
	unsigned int kw=0;
	while((0x1<<kw) < k)kw++;
	pow=1;
	for (i = 0; i <l; i=i+1 ) {
		tmp=(pos/pow);
		tmp=tmp%k;
	//	printf("tmp=%u\n",tmp);
		tmp=tmp<<(i)*kw;
		addrencode=addrencode | tmp;
		pow=pow * k;
	}
	 return addrencode;
}


unsigned int fattree_addrdecode(unsigned int addrencode , unsigned int k, unsigned int l){
	unsigned int kw=0;
	unsigned int mask=0;
	unsigned int pow,i,tmp;
	unsigned int pos=0;
	while((0x1<<kw) < k){
		kw++;
		mask<<=1;
		mask|=0x1;
	}
	pow=1;
	for (i = 0; i <l; i=i+1 ) {
		tmp = addrencode & mask;
		//printf("tmp1=%u\n",tmp);
		tmp=(tmp*pow);
		pos= pos + tmp;
		pow=pow * k;
		addrencode>>=kw;
	}
	return pos;
}


void mesh_tori_addrencod_sep(unsigned int id, unsigned int *x, unsigned int *y, unsigned int *l){
	(*l)=id%T3; // id%NL
	(*x)=(id/T3)%T1;// (id/NL)%NX
	(*y)=(id/T3)/T1;// (id/NL)/NX
}


void mesh_tori_addr_sep(unsigned int code, unsigned int *x, unsigned int *y, unsigned int *l){
	(*x) = code &  maskx;
	code>>=nxw;
	(*y) = code &  masky;
	code>>=nyw;
	(*l) = code;
}



unsigned int mesh_tori_addr_join(unsigned int x, unsigned int y, unsigned int l){

    unsigned int addrencode=0;
    addrencode =(T3==1)?   (y<<nxw | x) : (l<<(nxw+nyw)|  (y<<nxw) | x);
    return addrencode;
}

unsigned int mesh_tori_addrencode(unsigned int id){
	unsigned int y, x, l;
	mesh_tori_addrencod_sep(id,&x,&y,&l);
    return mesh_tori_addr_join(x,y,l);
}


unsigned int endp_addr_encoder ( unsigned int id){
	if((strcmp(TOPOLOGY ,"FATTREE")==0)||(strcmp(TOPOLOGY ,"TREE")==0)) {
		return fattree_addrencode(id, T1, T2);
	}
	if((strcmp(TOPOLOGY ,"MESH")==0) || (strcmp(TOPOLOGY ,"TORUS")==0) || (strcmp(TOPOLOGY ,"LINE")==0) || (strcmp(TOPOLOGY ,"RING")==0) ) {
		return mesh_tori_addrencode(id);
	}
	//custom. not coded
    return id;
}

unsigned int router_addr_encoder ( unsigned int id){
	if((strcmp(TOPOLOGY ,"FATTREE")==0)||(strcmp(TOPOLOGY ,"TREE")==0)) {
		return fattree_addrencode(id, T1, T2);
	}
	if((strcmp(TOPOLOGY ,"MESH")==0) || (strcmp(TOPOLOGY ,"TORUS")==0) || (strcmp(TOPOLOGY ,"LINE")==0) || (strcmp(TOPOLOGY ,"RING")==0) ) {
		 unsigned int y, x;	
		 unsigned int addrencode=0;
		 x=id%T1;// (id/NL)%NX
		 y=id/T1;// (id/NL)/NX
    		 addrencode =    (y<<nxw | x);
		 return addrencode;
	}
	//custom. not coded
        return id;
}



unsigned int endp_addr_decoder (unsigned int code){
	if(strcmp(TOPOLOGY ,"FATTREE")==0 ||(strcmp(TOPOLOGY ,"TREE")==0)) {
		return fattree_addrdecode(code, T1, T2);
	}
	if((strcmp(TOPOLOGY ,"MESH")==0) || (strcmp(TOPOLOGY ,"TORUS")==0) || (strcmp(TOPOLOGY ,"LINE")==0) || (strcmp(TOPOLOGY ,"RING")==0) ) {
		unsigned int x, y, l;
		mesh_tori_addr_sep(code,&x,&y,&l);
		//if(code==0x1a) printf("code=%x,x=%u,y=%u,l=%u\n",code,x,y,l);
		return ((y*T1)+x)*T3+l;
	}
	//custom. not coded
	return code;
}






unsigned int get_router_num (unsigned int x, unsigned int y) {
	if(strcmp(TOPOLOGY ,"FATTREE")==0 ||(strcmp(TOPOLOGY ,"TREE")==0)) {
		return fattree_addrdecode(x, T1, T2);
	}if((strcmp(TOPOLOGY ,"MESH")==0) || (strcmp(TOPOLOGY ,"TORUS")==0) || (strcmp(TOPOLOGY ,"LINE")==0) || (strcmp(TOPOLOGY ,"RING")==0) ) {
		 return (y*T1)+x;		
	}else{//custom
		//It is not used for custom topology 
	}
}


#define IS_MESH   (strcmp(TOPOLOGY ,"MESH")==0)
#define IS_FMESH   (strcmp(TOPOLOGY ,"FMESH")==0)
#define IS_TORUS  (strcmp(TOPOLOGY ,"TORUS")==0)
#define IS_LINE   (strcmp(TOPOLOGY ,"LINE")==0)
#define IS_RING   (strcmp(TOPOLOGY ,"RING")==0)
#define IS_TREE   (strcmp(TOPOLOGY ,"TREE")==0)
#define IS_FATTREE   (strcmp(TOPOLOGY ,"FATTREE")==0)



//remove local port
#define EAST      0 
#define NORTH     1  
#define WEST      2  
#define SOUTH     3
#define FORWARD   0
#define BACKWARD  1




void get_connected_router_mesh (unsigned int src_id , unsigned int src_p,unsigned int * dst_id, unsigned int * dst_p){
	
	unsigned int y, x;
	y= src_id/T1;
	x= src_id%T1;

	*dst_p = -1;
	*dst_id= -1;//connect to GND 

	if( IS_RING || IS_LINE) {
		
		if(src_p == FORWARD){
			if(x    <   T1-1){
				*dst_p = BACKWARD;//remove local port
				*dst_id=get_router_num(x+1,0);
				return;
			}        
		        if(IS_LINE) return; //connect to GND  
		     	*dst_p = BACKWARD;
			*dst_id=get_router_num(0,0);
			return;
	  	} 
		if(src_p == BACKWARD ) {
			if(x>0){
				*dst_p = FORWARD;
				*dst_id=get_router_num(x-1,0);
				return;
			}
			if(IS_LINE) return; //connect to GND  
			*dst_p = FORWARD;
			*dst_id=get_router_num(T1-1,0);
			return;
		 }
		return;
	}     
        
	//mesh torus
	if(src_p == EAST){
		if(x < T1-1  ) {
			*dst_p = WEST;
			*dst_id=get_router_num(x+1,y);
			return;
		}       
		if(IS_MESH  ) return; //connect to GND

		*dst_p = WEST;
		*dst_id=get_router_num(0,y);
		return;
	}        
       
	if(src_p == NORTH){
		if(y>0){
			*dst_p=SOUTH;
			*dst_id=get_router_num(x,y-1);
			return;
		}       
		if(IS_MESH  ) return; //connect to GND
		*dst_p=SOUTH;
		*dst_id=get_router_num(x,(T2-1));
		return;
 	}
	if(src_p == WEST){
		if(x>0){
			*dst_p=EAST;
			*dst_id=get_router_num(x-1,y);
		      	return;
		}
		if(IS_MESH  ) return; //connect to GND
		*dst_p=EAST;
		*dst_id=get_router_num((T1-1),y);
		return;
	}
	if(src_p == SOUTH){              
		if(y    <    T2-1){
			*dst_p=NORTH;
			*dst_id=get_router_num(x,y+1);
		      	return;
		}
		if(IS_MESH  ) return; //connect to GND
		*dst_p=NORTH;
		*dst_id=get_router_num(x,0);
		return;
	}
        return;
}        
        


unsigned int powi (unsigned int x, unsigned int y){// x^y
	unsigned int r=1;
	int i;
	for ( i = 0; i < y; ++i) {
    		r *= x;
  	}
  return r;
}


unsigned int sum_powi (unsigned int x, unsigned int y){ //x^(y-1) + x^(y-2) + ...+ 1;
	unsigned int r = 0;
	for (int i = 0; i < y; i++){
    		r += powi( x, i );
    	}
  	return r;
}	



void get_topology_info  (unsigned int * NENDP,unsigned int * NROUTER )
{	
	
	if(IS_TREE) {
		int K =  T1;
        	int L =  T2;
        	*NENDP = powi( K,L );
        	*NROUTER = sum_powi ( K,L );	
	}else if(IS_FATTREE) {
		int K =  T1;
		int L =  T2;
		*NENDP = powi( K,L );
        	*NROUTER = L * powi( K , L - 1 );
        }else if (IS_RING || IS_LINE){
		int NX=T1;
		int NY=1;
		int NLL=T3;
		*NENDP = NX*NY*NLL;
        	*NROUTER = NX*NY;    
        }else if (IS_MESH ||  IS_TORUS) {
		int NX=T1;
		int NY=T2;
		int NLL=T3;
		*NENDP = NX*NY*NLL;
		*NROUTER = NX*NY;    
       
	}	
	else{ //custom
		*NENDP= T1; 
		*NROUTER= T2;			
	}	
}
	




#endif
