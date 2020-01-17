// Source file is "L/add/src/accumulatorv2/printer1.cal"

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
extern actor_t print1;

////////////////////////////////////////////////////////////////////////////////
// Shared Variables

////////////////////////////////////////////////////////////////////////////////
// Input FIFOs
extern fifo_i8_t *print1_result;

////////////////////////////////////////////////////////////////////////////////
// Input Fifo control variables
static unsigned int index_result;
static unsigned int numTokens_result;
#define SIZE_result 512
#define tokens_result print1_result->contents

extern connection_t connection_print1_result;
#define rate_result connection_print1_result.rate

////////////////////////////////////////////////////////////////////////////////
// Predecessors
extern actor_t add1;


////////////////////////////////////////////////////////////////////////////////
// State variables of the actor
static i8 temp = 0;
static i8 temp2 = 0;



////////////////////////////////////////////////////////////////////////////////
// Token functions
static void read_result() {
	index_result = print1_result->read_inds[0];
	numTokens_result = index_result + fifo_i8_get_num_tokens(print1_result, 0);
}

static void read_end_result() {
	print1_result->read_inds[0] = index_result;
}


////////////////////////////////////////////////////////////////////////////////
// Functions/procedures


////////////////////////////////////////////////////////////////////////////////
// Actions
static i32 isSchedulable_untagged_0() {
	i32 result;

	result = 1;
	return result;
}

static void untagged_0() {
	i8 a;
	i8 local_temp;
	i8 local_temp2;
	a = tokens_result[(index_result + (0)) % SIZE_result];
	local_temp = temp;
	temp = local_temp + 1;
	local_temp2 = temp2;
	local_temp = temp;
	temp2 = local_temp2 - local_temp / 10 * 10;
	local_temp = temp;
	if (local_temp == 60) {
		printf("The result printer1 is %i\n", a);
	}
	// Update ports indexes
	index_result += 1;
	rate_result += 1;
}

////////////////////////////////////////////////////////////////////////////////
// Initializes

void print1_initialize(schedinfo_t *si) {
	int i = 0;
finished:
	return;
}

////////////////////////////////////////////////////////////////////////////////
// Action scheduler
void print1_scheduler(schedinfo_t *si) {
	int i = 0;
	si->ports = 0;

	read_result();

	while (1) {
		if (numTokens_result - index_result >= 1 && isSchedulable_untagged_0()) {
			untagged_0();
			i++;
		} else {
			si->num_firings = i;
			si->reason = starved;
			goto finished;
		}
	}

finished:

	read_end_result();
}
