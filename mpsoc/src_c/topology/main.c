#include "stdio.h"
#include  "stdlib.h"

#define MAX_CORE_NUM 1000


 

int powi(unsigned int x, unsigned int y){
	unsigned int r=1,i;
	for ( i = 0; i < y; i++ ) {
    		r *= x;
  	}
  return r;
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

void addresses_encode(unsigned int k, unsigned int l){
	unsigned int NE = powi( k,l );
	unsigned int i;
	unsigned int coded;
	printf("\\***************\n  K=%u L=%u \n****************\\ \n  module fattree_addr_encode_k%u_l%u #( parameter IDw=4, parameter CODw=4)(id,code);\n",k,l,k,l);
	printf("\t input [IDw-1 : 0] id;\n \t output reg [CODw-1 : 0] code;\n \t always @(*) begin \n \t\t case(id) \n ");
	for (i = 0; i <NE; i++) {
		coded = fattree_addrencode( i, k, l);
		printf("\t\t %d: code = %d;\n",i,coded);
	}
	printf("\t\t default: code=%u;\n \t\t endcase\n \t end \n endmodule\n ",coded+1);

}


void addresses_decode(unsigned int k, unsigned int l){
	unsigned int NE = powi( k,l );
	unsigned int i;
	unsigned int coded;
	printf("\\************\n K=%u L=%u \n**************\\ \n  module fattree_addr_decode_k%u_l%u #( parameter IDw=4, parameter CODw=4)(id,code);\n",k,l,k,l);
	printf("\t output reg [IDw-1 : 0] id;\n \t input [CODw-1 : 0] code;\n \t always @(*) begin \n \t\t case(code) \n ");
	for (i = 0; i <NE; i++) {
		coded = fattree_addrencode( i, k, l);
		printf("\t\t %d: id = %d;\n",coded,i);
	}
	printf("\t\t default: code=%u;\n \t\t endcase\n \t end \n endmodule\n ",i);

}

void fattree_addr_encode (void){
	unsigned int NE,k,l;
	printf("module fattree_addr_encode #(parameter K=2, parameter L=2, parameter IDw=4, parameter CODw=4)(id,code);\n");
	printf("\t input [IDw-1 :0] id;\n \t output [CODw-1 : 0] code;\n");
	printf("\t generate\n\t");
	
	for (l = 1; l <16; l=l+1 ) {
		for (k = 2; k <8; k=k+1 ) {
			NE = powi( k,l );  //total number of endpoints
			if(NE> MAX_CORE_NUM) continue; 
			printf("if (K==%d && L==%d) begin: k%u_L%u\n",k,l,k,l);
				
				printf("\t\taddr_decode_k%u_l%u (id,code);\n",k,l);
			
			printf("\tend else ");
			
			

			
		}
	}
		printf("begin: outof_range \n \tend\n\t endgenerate\nendmodule\n");	


for (l = 1; l <16; l=l+1 ) {
		for (k = 2; k <8; k=k+1 ) {
			NE = powi( k,l );  //total number of endpoints
			if(NE> MAX_CORE_NUM) continue; 
				addresses_encode(k, l);
		}}

}

void fattree_addr_decode (void){
	unsigned int NE,k,l;
	printf("module fattree_addr_decode #(parameter K=2, parameter L=2, parameter IDw=4, parameter CODw=4)(id,code);\n");
	printf("\t input [IDw-1 :0] id;\n \t output [CODw-1 : 0] code;\n");
	printf("\t generate\n\t");
	
	for (l = 1; l <16; l=l+1 ) {
		for (k = 2; k <8; k=k+1 ) {
			NE = powi( k,l );  //total number of endpoints
			if(NE> MAX_CORE_NUM) continue; 
			printf("if (K==%d && L==%d) begin: k%u_L%u\n",k,l,k,l);
				
				printf("\t\taddr_decode_k%u_l%u (id,code);\n",k,l);
			
			printf("\tend else ");
			
			

			
		}
	}
	printf("begin: outof_range \n \tend\n\t endgenerate\nendmodule\n");	


for (l = 1; l <16; l=l+1 ) {
		for (k = 2; k <8; k=k+1 ) {
			NE = powi( k,l );  //total number of endpoints
			if(NE> MAX_CORE_NUM) continue; 
				addresses_decode(k, l);
		}}

}


int main(){
	fattree_addr_encode ();
	fattree_addr_decode ();	
}	


