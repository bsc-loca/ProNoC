// Source file is "L/chanel/src/accum/src2.cal"

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
extern actor_t src2;

////////////////////////////////////////////////////////////////////////////////
// Shared Variables

////////////////////////////////////////////////////////////////////////////////
// Output FIFOs
extern fifo_i32_t *src2_source;

////////////////////////////////////////////////////////////////////////////////
// Output Fifo control variables
static unsigned int index_source;
#define NUM_READERS_source 2
#define SIZE_source 32
#define tokens_source src2_source->contents

////////////////////////////////////////////////////////////////////////////////
// Successors
extern actor_t add1;
extern actor_t add2;


////////////////////////////////////////////////////////////////////////////////
// State variables of the actor
static i32 i = 0;
#define INPUT_SIZE 100
static const i32 SRC1[100] = {5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5};



////////////////////////////////////////////////////////////////////////////////
// Token functions

static void write_source() {
	index_source = src2_source->write_ind;
}

static void write_end_source() {
	src2_source->write_ind = index_source;
}

////////////////////////////////////////////////////////////////////////////////
// Functions/procedures


////////////////////////////////////////////////////////////////////////////////
// Actions
static i32 isSchedulable_sendData() {
	i32 result;
	i32 local_i;
	i32 local_INPUT_SIZE;

	local_i = i;
	local_INPUT_SIZE = INPUT_SIZE;
	result = local_i < local_INPUT_SIZE;
	return result;
}

static void sendData() {
	u32 Out;
	i32 local_i;
	local_i = i;
	Out = SRC1[local_i];
	local_i = i;
	i = local_i + 1;
	tokens_source[(index_source + (0)) % SIZE_source] = Out;
	// Update ports indexes
	index_source += 1;
}

////////////////////////////////////////////////////////////////////////////////
// Initializes

void src2_initialize(schedinfo_t *si) {
	int i = 0;
	write_source();
finished:
	write_end_source();
	return;
}

////////////////////////////////////////////////////////////////////////////////
// Action scheduler
void src2_scheduler(schedinfo_t *si) {
	int i = 0;
	si->ports = 0;

	write_source();

	while (1) {
		if (isSchedulable_sendData()) {
			int stop = 0;
			if (1 > SIZE_source - index_source + src2_source->read_inds[0]) {
				stop = 1;
			}
			if (1 > SIZE_source - index_source + src2_source->read_inds[1]) {
				stop = 1;
			}
			if (stop != 0) {
				si->num_firings = i;
				si->reason = full;
				goto finished;
			}
			sendData();
			i++;
		} else {
			si->num_firings = i;
			si->reason = starved;
			goto finished;
		}
	}

finished:

	write_end_source();
}
