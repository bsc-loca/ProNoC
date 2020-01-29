// Source file is "L/add/src/accumulatorv2/source2.cal"

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
extern fifo_i8_t *src2_Output1;
extern fifo_i8_t *src2_Output2;

////////////////////////////////////////////////////////////////////////////////
// Output Fifo control variables
static unsigned int index_Output1;
#define NUM_READERS_Output1 1
#define SIZE_Output1 32
#define tokens_Output1 src2_Output1->contents

static unsigned int index_Output2;
#define NUM_READERS_Output2 1
#define SIZE_Output2 32
#define tokens_Output2 src2_Output2->contents

////////////////////////////////////////////////////////////////////////////////
// Successors
extern actor_t add1;
extern actor_t add2;


////////////////////////////////////////////////////////////////////////////////
// State variables of the actor
static i8 i = 0;
#define INPUT_SIZE 100
static const i8 SRC1[100] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100};
static const i8 SRC2[100] = {101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200};
static i8 j = 0;



////////////////////////////////////////////////////////////////////////////////
// Token functions

static void write_Output1() {
	index_Output1 = src2_Output1->write_ind;
}

static void write_end_Output1() {
	src2_Output1->write_ind = index_Output1;
}
static void write_Output2() {
	index_Output2 = src2_Output2->write_ind;
}

static void write_end_Output2() {
	src2_Output2->write_ind = index_Output2;
}

////////////////////////////////////////////////////////////////////////////////
// Functions/procedures


////////////////////////////////////////////////////////////////////////////////
// Actions
static i32 isSchedulable_sendData1() {
	i32 result;
	i8 local_i;
	i8 local_INPUT_SIZE;

	local_i = i;
	local_INPUT_SIZE = INPUT_SIZE;
	result = local_i < local_INPUT_SIZE;
	return result;
}

static void sendData1() {
	u8 Out;
	i8 local_i;
	local_i = i;
	Out = SRC1[local_i];
	local_i = i;
	i = local_i + 1;
	tokens_Output1[(index_Output1 + (0)) % SIZE_Output1] = Out;
	// Update ports indexes
	index_Output1 += 1;
}
static i32 isSchedulable_sendData2() {
	i32 result;
	i8 local_j;
	i8 local_INPUT_SIZE;

	local_j = j;
	local_INPUT_SIZE = INPUT_SIZE;
	result = local_j < local_INPUT_SIZE;
	return result;
}

static void sendData2() {
	u8 Out;
	i8 local_j;
	local_j = j;
	Out = SRC2[local_j];
	local_j = j;
	j = local_j + 1;
	tokens_Output2[(index_Output2 + (0)) % SIZE_Output2] = Out;
	// Update ports indexes
	index_Output2 += 1;
}

////////////////////////////////////////////////////////////////////////////////
// Initializes

void src2_initialize(schedinfo_t *si) {
	int i = 0;
	write_Output1();
	write_Output2();
finished:
	write_end_Output1();
	write_end_Output2();
	return;
}

////////////////////////////////////////////////////////////////////////////////
// Action scheduler
void src2_scheduler(schedinfo_t *si) {
	int i = 0;
	si->ports = 0;

	write_Output1();
	write_Output2();

	while (1) {
		if (isSchedulable_sendData1()) {
			int stop = 0;
			if (1 > SIZE_Output1 - index_Output1 + src2_Output1->read_inds[0]) {
				stop = 1;
			}
			if (stop != 0) {
				si->num_firings = i;
				si->reason = full;
				goto finished;
			}
			sendData1();
			i++;
		} else if (isSchedulable_sendData2()) {
			int stop = 0;
			if (1 > SIZE_Output2 - index_Output2 + src2_Output2->read_inds[0]) {
				stop = 1;
			}
			if (stop != 0) {
				si->num_firings = i;
				si->reason = full;
				goto finished;
			}
			sendData2();
			i++;
		} else {
			si->num_firings = i;
			si->reason = starved;
			goto finished;
		}
	}

finished:

	write_end_Output1();
	write_end_Output2();
}
