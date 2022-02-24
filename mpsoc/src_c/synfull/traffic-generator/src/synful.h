#ifndef _SYNFUL_H
	#define  _SYNFUL_H
	
	#define SYNFUL_ENDP_NUM 32


	

extern queue_t** synful_inject;
extern unsigned long long synful_cycle;
	
void synful_eval ();
void synful_init(char *, bool , int);
void synful_run_one_cycle ();

	
	
	
#endif
