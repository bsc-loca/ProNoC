
#ifndef  LM32_SYS_H
	#define LM32_SYS_H
	 
/***************************************************************************
 * IRQ handling
 */

/****************************************************************************
 * Types
 */
#include <stdint.h>

/****************************************************************************/






typedef void(*isr_ptr_t)(void);
void     halt();
void     jump(uint32_t addr);


isr_ptr_t isr_table[32];



void isr_null()
{

}

void irq_handler(uint32_t pending)
{
	int i;

	for(i=0; i<32; i++) {
		if (pending & 0x01) (*isr_table[i])();
		pending >>= 1;
	}
}

void isr_init()
{
	int i;
	for(i=0; i<32; i++)
		isr_table[i] = &isr_null;
}

void isr_register(int irq, isr_ptr_t isr)
{
	isr_table[irq] = isr;
}

void isr_unregister(int irq)
{
	isr_table[irq] = &isr_null;
}





/******************
*	General inttrupt functions for all CPUs added to ProNoC
*******************/

extern void irq_set_mask (unsigned long);
extern unsigned long irq_get_mask(void);
extern void irq_enable (void);

#define general_int_init isr_init


int general_int_add(unsigned long irq, isr_ptr_t handler, void *arg)
{
	
	isr_register(irq, handler);
        return 0;
}



void general_int_enable(unsigned long irq){
	irq_set_mask( (0x00000001L << irq)| irq_get_mask() );
	
}

#define  general_cpu_int_en	irq_enable










#endif
