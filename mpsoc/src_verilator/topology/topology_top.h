#ifndef TOPOLOGY_TOP_H
#define TOPOLOGY_TOP_H


	

	

	unsigned int er_addr [NE+1]; 
	char start_i=0;
	char start_o[NE+1]={0};

	unsigned int Log2 (unsigned int n){
		unsigned int l=1;
		while((0x1<<l) < n)l++;
		return l;
	}

	unsigned int powi (unsigned int x, unsigned int y){ // x^y
		unsigned int i;        
		unsigned int pow=1;
        for (int i = 0; i <y; i=i+1 ) {
            pow=pow * x;
        }
		return pow;    
	}

	unsigned int sum_powi (unsigned int x, unsigned int y){//x^(y-1) + x^(y-2) + ...+ 1;
        unsigned int i; 
        unsigned int sum = 0;
        for (i = 0; i < y; i=i+1){
            sum = sum + powi( x, i );
      	}   
		return sum;
    }


	unsigned int fattree_addrencode( unsigned int pos, unsigned int k, unsigned int l){
	unsigned int pow,i,tmp=0;
	unsigned int addrencode=0;
	unsigned int kw=0;
	while((0x1<<kw) < k)kw++;
	pow=1;
	for (i = 0; i <l; i=i+1 ) {
		tmp=(pos/pow);
		tmp=tmp%k;
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
			tmp=(tmp*pow);
			pos= pos + tmp;
			pow=pow * k;
			addrencode>>=kw;
		}
		return pos;
	}


	unsigned int nxw=0;
	unsigned int nyw=0;
	unsigned int maskx=0;
	unsigned int masky=0;

	

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
		#if defined (IS_TREE)  || defined (IS_FATTREE)
			return fattree_addrencode(id, T1, T2);
		#endif
		#if defined (IS_MESH) || defined (IS_TORUS) || defined (IS_LINE) || defined (IS_RING )
			return mesh_tori_addrencode(id);
		#endif
		//custom. not coded
		return id;
	}


	unsigned int endp_addr_decoder (unsigned int code){
		#if defined (IS_TREE)  || defined (IS_FATTREE)
			return fattree_addrdecode(code, T1, T2);
		#endif
		#if defined (IS_MESH) || defined (IS_TORUS) || defined (IS_LINE) || defined (IS_RING )
			unsigned int x, y, l;
			mesh_tori_addr_sep(code,&x,&y,&l);
			//if(code==0x1a) printf("code=%x,x=%u,y=%u,l=%u\n",code,x,y,l);
			return ((y*T1)+x)*T3+l;
		#endif
		//custom. not coded
		return code;
	}


	#if defined (IS_MESH) || defined (IS_TORUS) || defined (IS_LINE) || defined (IS_RING )
		#include "mesh.h" 
	#endif


	#if defined (IS_FATTREE) || defined (IS_TREE)
		inline unsigned int  Ti( unsigned int id){
		  return (id < NR1)? 1 : 2;
		}
		inline unsigned int Ri(unsigned int id){
			return  (id < NR1)? id : id-NR1;
		}
		
		#define 	K T1
		#define     L T2 
		#define CNT_R2R_SIZ  ((NR1+NR2+1)*(K+1)) 
		#define CNT_R2E_SIZ  (NE+1)
		
		typedef struct R2R_CNT_TABLE {
			unsigned int t1;
			unsigned int r1;
			unsigned int p1;
			unsigned int t2;
			unsigned int r2;
			unsigned int p2;	
		} r2r_cnt_table_t;  

		r2r_cnt_table_t r2r_cnt_all[CNT_R2R_SIZ];

		typedef struct R2E_CNT_TABLE {
			unsigned int r1;
			unsigned int p1;  
		} r2e_cnt_table_t;  

		r2e_cnt_table_t r2e_cnt_all[CNT_R2E_SIZ];

inline void fattree_connect ( r2r_cnt_table_t in){
			unsigned int t1 = in.t1;
			unsigned int r1 = in.r1; 
			unsigned int p1 = in.p1; 
			unsigned int t2 = in.t2; 
			unsigned int r2 = in.r2;
			unsigned int p2 = in.p2;

			if (t1==1 && t2 == 1) {
				conect_r2r(1,r1,p1,1,r2,p2);
				conect_r2r(1,r2,p2,1,r1,p1);
			}
			else if (t1==1 && t2 == 2) {
				conect_r2r(1,r1,p1,2,r2,p2);
				conect_r2r(2,r2,p2,1,r1,p1);
			}
			else if (t1==2 && t2 == 1){
				conect_r2r(2,r1,p1,1,r2,p2);
				conect_r2r(1,r2,p2,2,r1,p1);
			}
			else{
				conect_r2r(2,r1,p1,2,r2,p2);
				conect_r2r(2,r2,p2,2,r1,p1);
			}
		}


		#if defined (IS_FATTREE) 
			#include "fattree.h" 
		#else
			#include "tree.h" 
		#endif
	#endif

	#if defined (IS_STAR) 
		#include "star.h" 
	#endif

	







	




#endif

