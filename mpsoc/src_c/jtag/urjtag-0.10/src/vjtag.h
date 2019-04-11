#ifndef VJTAG_H
#define VJTAG_H
#include "../sysdep.h"



#define VJTAG_CABLE  "UsbBlaster"

char * vjtag_def_command[] = { 
	"register DRS 4",
	"register DRL 64",
	"instruction USER1 0000001110 DRS" ,
	"instruction USER1L 0000001110 DRL", 
	"instruction USER0 0000001100 DRS" ,
	"instruction USER0L 0000001100 DRL", 
	"instruction USER1L",
	"shift ir",
	"dr 0000000000000000000000000000000000000000000000000000000000000000",
	"shift dr",
	"instruction USER0",
	"shift ir",
	0
};



static unsigned vir_width = 0;
static unsigned vir_width_addr = 0;
static unsigned vir_width_ir = 0;
static unsigned vir_addr = 0;




static int vjtag_readline_multiple_commands_support(chain_t *chain, char * line) /* multiple commands should be separated with '::' */
{
  int 	r;
  char	*nextcmd = line;

  if (!line || !(strlen( line ) > 0))
		return 1;

  do {
  line = nextcmd;

  nextcmd = strstr(nextcmd, "::"); /* :: to not confuse ms-dos users ;-) */
  
  if (nextcmd) {  
	
    *nextcmd++ = 0;
//printf("\nnn\n");
     ++nextcmd;
	
	
     while (*line == ':') ++line;
  } 
  
  r = jtag_parse_line( chain, line );

  chain_flush( chain );
  
  } while (nextcmd && r);

  return r;
}


/* number of bits needed given a max value 1-255 */
unsigned needbits(unsigned max) {
	if (max > 127) return 8;
	if (max > 63) return 7;
	if (max > 31) return 6;
	if (max > 15) return 5;
	if (max > 7) return 4;
	if (max > 3) return 3;
	if (max > 1) return 2;
	return 1;
}


int jtag_dr_8x4(chain_t *chain,unsigned *out) {
	unsigned bits = 0;
	unsigned tmp;
	int n;
	for(n=0;n<8;n++){
		char line[]="dr 0000 :: shift dr :: dr"; 
		if (vjtag_readline_multiple_commands_support(chain,line)<1){
			printf( _("Error: ") );
			return 0;
		}
		tmp=strtol(chain->output, NULL, 2);
		bits |= (tmp <<= (n * 4));
		
	
	}
	
	*out = bits;
	return 1;
}







int vjtag_init( ){
	//int r;
//select Usbblaster as cable
	char *cmd[] = {NULL, NULL, NULL, NULL, NULL};
	cmd[0] = "cable";
	cmd[1] = VJTAG_CABLE;
	cmd[2] = "NULL";
	cmd[3] = NULL;

	


	
	if (cmd_run(chain, cmd) < 1) {
		printf( _("Error: could not set cable") );
		return 0;
	}
//set bsd_file
	char * work_dir;
	char * bsd_file_path;
	work_dir=getenv("PRONOC_WORK");
	
	

	bsd_file_path = (char*) malloc((strlen(work_dir)+20) * sizeof(char));
	strcpy(bsd_file_path, work_dir);
	strcat(bsd_file_path, "/bsd/");


	
	

	cmd[0] = "bsdl";
	cmd[1] = "path";
	cmd[2] = bsd_file_path;
	if (cmd_run(chain, cmd) < 1) {
		printf( _("Error: could not set BSDL path") );
		return 0;
	}
	printf("\nbsdl file path is set to:%s\n",bsd_file_path);
/*
	if (vjtag_readline_multiple_commands_support(chain, "bsdl path " BSD_FILE_PATH )<1){
		printf( _("Error: could not set BSDL path") );
		return 0;
	}
*/
	if (vjtag_readline_multiple_commands_support(chain, "detect" )<1){
		printf( _("Error: could not set BSDL path") );
		return 0;
	}
	//TODO: if multiple devices are in the chain activate the desired one and bypass the rest

	if (vjtag_readline_multiple_commands_support(chain, "print chain" )<1){
		printf( _("Error: cant print the chain") );
		return 0;
	}


	int i=0;

	while (vjtag_def_command[i]!=NULL)
	{
		if(vjtag_readline_multiple_commands_support(chain,vjtag_def_command[i])<1){
			printf( _("Error: cant define vjtag registers") );
			return 0;
		}
		i++;
	}
	
	
	
	return 1;

}








int jtag_open_virtual_device(unsigned iid) {
	
	unsigned bits;
	int n;
	static unsigned hub_version = 0;
	static unsigned hub_nodecount = 0;
	static unsigned hub_mfg = 0;

	

	jtag_dr_8x4(chain, &bits);


	hub_version = (bits >> 27) & 0x1F;
	hub_nodecount = (bits >> 19) & 0xFF;
	hub_mfg = (bits >> 8) & 0x7FF;

	if (hub_mfg != 0x06e) {
		fprintf(stderr,"hub_version=%x,	hub_nodecount=%x, 	hub_mfg=%x \n",hub_version,	hub_nodecount, 	hub_mfg);

		fprintf(stderr,"HUB:    Cannot Find Virtual JTAG HUB\n");
		return -1;
	}

	/* altera docs claim this field is the sum of M bits (VIR field) and
	 * N bits (ADDR field), but empirical evidence suggests it is actually
	 * just the width of the ADDR field and the docs are wrong...
	 */
	vir_width_ir = bits & 0xFF;
	vir_width_addr = needbits(hub_nodecount);
	vir_width = vir_width_ir + vir_width_addr;

		if(DEBUG) fprintf(stderr,"HUB:    Mfg=0x%03x, Ver=0x%02x, Nodes=%d, VIR=%d+%d bits\n", hub_mfg, hub_version, hub_nodecount, vir_width_addr, vir_width_ir);

	
	int r;
	for (n = 0; n < hub_nodecount; n++) {
		unsigned node_ver, node_id, node_mfg, node_iid;
		if ((r = jtag_dr_8x4(chain,&bits)) < 1) return r;
		node_ver = (bits >> 27) & 0x1F;
		node_id = (bits >> 19) & 0xFF;
		node_mfg = (bits >> 8) & 0x7FF;
		node_iid = bits & 0xFF;

	if(DEBUG)	fprintf(stderr,"NODE:   Mfg=0x%03x, Ver=0x%02x, ID=0x%02x, IID=0x%02x\n",
			node_mfg, node_ver, node_id, node_iid);

		if ((node_id == 0x08) && (node_iid) == iid) {
			vir_addr = (n + 1) << vir_width_ir;
		}
	}

	if ((vir_addr == 0) && (iid < 256)) {
		fprintf(stderr,"ERROR: IID 0x%02x not found\n", iid);
		return 0;
	}
	char cmd[100];
 	// define virtual jtag ir data register
	sprintf(cmd, "register VIRDATA %u ::	instruction VIR 0000001110 VIRDATA",vir_width);
	//printf ("\ncmd=%s\n",cmd);
	if ((r = vjtag_readline_multiple_commands_support(chain,cmd))<1){
		 printf( _("Error: cant define virtual jtag ir data register\n") );
		 return 0; 
	}


	return 1;
}


void hexToBinary (int size, int num, char * str) {
int i;
       
	str[size]=0;
    for (i = size-1 ;i >=0 ; i--) {
		str[i]= (num & 0x1) ? '1':'0';
		num>>=1;
	}
     
	//printf("%s\n",str);
}


void BinaryToHex (int size,  char * str, unsigned int *num) {
	int i;
    unsigned int n=0;  
  
	for (i = 0 ;(i <size && str[i]!=0) ; i++) {
		n<<=1;
		
		if(str[i] == '1') n++; 
		
		
	}
	
    *num=n; 
    
	//printf("%x\n",n);
}


void hexlongToBinary (int size, unsigned int * num, char * str, int words) {
int i;
       
	str[size]=0;
	for (i = size-1 ;i >=0 ; i--) {
		str[i]= (num[(size-i-1)/32] & 0x1) ? '1':'0';
		num[(size-i-1)/32]>>=1;
	}
     
	//printf("\n%s\n",str);
}


void BinarylongToHex (int size,  char * str, unsigned int *num, int words) {
	int i;
	unsigned int n=0,k=0,j=0;  
	for(i=0; i<words; i++ ) num[i]=0;
	for (i = size-1 ;i >=0; i--) {
			
		if(str[i] == '1') n+= (1<<j);
		j++; 
		if(j==32){
				num[k]=n;
				k++;
				j=0;
				n=0;
			
		}	
		
	}
	  if(j!=0)  num[k]=n; 
    
	//printf("%x\n",n);
}





static uint32_t defined_register_list[10]={0};

int register_data_reg(chain_t *chain, unsigned int size){
		int r;
		if (defined_register_list[size>>5] && (1<<(size & 0x1F))>0) return 1; //  this with has already been registered
		char cmd[100];
		sprintf(cmd, "register VD_REG%u %u ::	instruction VD%u 0000001100  VD_REG%u",size,size,size,size);
		//printf ("\ncmd=%s\n",cmd);
		if ((r = vjtag_readline_multiple_commands_support(chain,cmd))<1){
			printf( "Error: cant define virtual jtag data reg with size %u\n",size);
			return 0; 
		}	
	
		defined_register_list[size>>5] |=(1<<(size & 0x1F));
		return 1;
}	


int jtag_vir( unsigned vir) {
	int r;
	//if ((r = jtag_ir(ir_width, 14)) < 0) return r;	
	char cmd[100]={"instruction VIR :: shift ir"};
	if ((r = vjtag_readline_multiple_commands_support(chain,cmd))<1) return -1; 
	//if ((r = jtag_dr(vir_width, vir_addr | vir, 0)) < 0) return r;
	char data[65];
	hexToBinary (vir_width, (vir_addr | vir), data);
	sprintf(cmd,"dr %s :: shift dr",data);
	if ((r = vjtag_readline_multiple_commands_support(chain,cmd))<1) return -1; 	
	return 0;
}

int jtag_vdr( unsigned sz, unsigned bits, unsigned *out) {
	int r;
	//if ((r = jtag_ir(ir_width, 12)) < 0) return r;
	if (register_data_reg(chain,sz)<1) return -1;
	char cmd[100];
	sprintf(cmd,"instruction VD%u :: shift ir",sz);
	if ((r = vjtag_readline_multiple_commands_support(chain,cmd))<1) return -1; 
	//if ((r = jtag_dr(sz, bits, out)) < 0) return r;
	char data[100];
	
	hexToBinary (sz, bits, data);
	sprintf(cmd,"dr %s :: shift dr :: dr",data);
	if ((r = vjtag_readline_multiple_commands_support(chain,cmd))<1) return -1; 
	*out=strtol(chain->output, NULL, 2);	// convert from binerry to hex	
	
	//BinaryToHex (sz, chain->output, out);
	//printf("%x,out\n", (*out));
	return 0;
}





int jtag_vdr_long( unsigned sz,  unsigned * bits, unsigned *out, int words) {
	int r;
	//if ((r = jtag_ir(ir_width, 12)) < 0) return r;
	if (register_data_reg(chain,sz)<1) return -1;
	char cmd[1000];
	sprintf(cmd,"instruction VD%u :: shift ir",sz);
	if ((r = vjtag_readline_multiple_commands_support(chain,cmd))<1) return -1; 
	//if ((r = jtag_dr(sz, bits, out)) < 0) return r;
	char data[1000];
	hexlongToBinary (sz, bits, data, words);
	sprintf(cmd,"dr %s :: shift dr :: dr",data);
	//printf ("cmd=%s\n",cmd);
	if ((r = vjtag_readline_multiple_commands_support(chain,cmd))<1) return -1; 
	BinarylongToHex (sz,  chain->output, out,  words);	
	//printf ("chain->output=%s\n",chain->output);	
	return 0;
}


#endif
