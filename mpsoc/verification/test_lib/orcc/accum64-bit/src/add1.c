// Source file is "L/add/src/accumulatorv2/accumulator1.cal"

#include <stdio.h>
#include <stdlib.h>
#include "orcc_config.h"

#include "types.h"
#include "fifo.h"
#include "util.h"
#include "scheduler.h"
#include "dataflow.h"
#include "cycle.h"


////////////////////////////////////////////////////////////////////////////////
// Instance
extern actor_t add1;

////////////////////////////////////////////////////////////////////////////////
// Shared Variables

////////////////////////////////////////////////////////////////////////////////
// Input FIFOs
extern fifo_i64_t *add1_Input1;
extern fifo_i64_t *add1_Input2;

////////////////////////////////////////////////////////////////////////////////
// Input Fifo control variables
static unsigned int index_Input1;
static unsigned int numTokens_Input1;
#define SIZE_Input1 512
#define tokens_Input1 add1_Input1->contents

extern connection_t connection_add1_Input1;
#define rate_Input1 connection_add1_Input1.rate

static unsigned int index_Input2;
static unsigned int numTokens_Input2;
#define SIZE_Input2 512
#define tokens_Input2 add1_Input2->contents

extern connection_t connection_add1_Input2;
#define rate_Input2 connection_add1_Input2.rate

////////////////////////////////////////////////////////////////////////////////
// Predecessors
extern actor_t src1;
extern actor_t src2;

////////////////////////////////////////////////////////////////////////////////
// Output FIFOs
extern fifo_i64_t *add1_Output;

////////////////////////////////////////////////////////////////////////////////
// Output Fifo control variables
static unsigned int index_Output;
#define NUM_READERS_Output 1
#define SIZE_Output 512
#define tokens_Output add1_Output->contents

////////////////////////////////////////////////////////////////////////////////
// Successors
extern actor_t print1;


////////////////////////////////////////////////////////////////////////////////
// State variables of the actor
static i64 temp = 0;



////////////////////////////////////////////////////////////////////////////////
// Token functions
static void read_Input1() {
	index_Input1 = add1_Input1->read_inds[0];
	numTokens_Input1 = index_Input1 + fifo_i64_get_num_tokens(add1_Input1, 0);
}

static void read_end_Input1() {
	add1_Input1->read_inds[0] = index_Input1;
}
static void read_Input2() {
	index_Input2 = add1_Input2->read_inds[0];
	numTokens_Input2 = index_Input2 + fifo_i64_get_num_tokens(add1_Input2, 0);
}

static void read_end_Input2() {
	add1_Input2->read_inds[0] = index_Input2;
}

static void write_Output() {
	index_Output = add1_Output->write_ind;
}

static void write_end_Output() {
	add1_Output->write_ind = index_Output;
}

////////////////////////////////////////////////////////////////////////////////
// Functions/procedures


////////////////////////////////////////////////////////////////////////////////
// Actions
static i32 isSchedulable_add() {
	i32 result;

	result = 1;
	return result;
}

static void add() {
	i64 a;
	i64 b;
	i64 local_temp;
	a = tokens_Input1[(index_Input1 + (0)) % SIZE_Input1];
	b = tokens_Input2[(index_Input2 + (0)) % SIZE_Input2];
	local_temp = temp;
	temp = local_temp + a + b;
	local_temp = temp;
	tokens_Output[(index_Output + (0)) % SIZE_Output] = local_temp;
	// Update ports indexes
	index_Input1 += 1;
	index_Input2 += 1;
	index_Output += 1;
	rate_Input1 += 1;
	rate_Input2 += 1;
}

////////////////////////////////////////////////////////////////////////////////
// Initializes

void add1_initialize(schedinfo_t *si) {
	int i = 0;
	write_Output();
finished:
	write_end_Output();
	return;
}

////////////////////////////////////////////////////////////////////////////////
// Action scheduler
void add1_scheduler(schedinfo_t *si) {
	int i = 0;
	si->ports = 0;

	read_Input1();
	read_Input2();
	write_Output();

	while (1) {
		if (numTokens_Input1 - index_Input1 >= 1 && numTokens_Input2 - index_Input2 >= 1 && isSchedulable_add()) {
			int stop = 0;
			if (1 > SIZE_Output - index_Output + add1_Output->read_inds[0]) {
				stop = 1;
			}
			if (stop != 0) {
				si->num_firings = i;
				si->reason = full;
				goto finished;
			}
			add();
			i++;
		} else {
			si->num_firings = i;
			si->reason = starved;
			goto finished;
		}
	}

finished:

	read_end_Input1();
	read_end_Input2();
	write_end_Output();
}
