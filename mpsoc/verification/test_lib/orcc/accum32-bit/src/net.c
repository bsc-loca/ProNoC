// Generated from "accumulatorv2.net"

#include <locale.h>
#include <stdio.h>
#include <stdlib.h>

#include "types.h"
#include "fifo.h"
#include "util.h"
#include "dataflow.h"
#include "serialize.h"
#include "options.h"
#include "scheduler.h"

/////////////////////////////////////////////////
// FIFO allocation
DECLARE_FIFO(i32, 32, 0, 1)
DECLARE_FIFO(i32, 32, 1, 1)
DECLARE_FIFO(i32, 32, 2, 1)
DECLARE_FIFO(i32, 32, 3, 1)
DECLARE_FIFO(i32, 32, 4, 1)
DECLARE_FIFO(i32, 32, 5, 1)

/////////////////////////////////////////////////
// FIFO pointer assignments
fifo_i32_t *src1_Output2 = &fifo_0;
fifo_i32_t *add2_Input1 = &fifo_0;

fifo_i32_t *src1_Output1 = &fifo_1;
fifo_i32_t *add1_Input1 = &fifo_1;

fifo_i32_t *src2_Output2 = &fifo_2;
fifo_i32_t *add2_Input2 = &fifo_2;

fifo_i32_t *src2_Output1 = &fifo_3;
fifo_i32_t *add1_Input2 = &fifo_3;

fifo_i32_t *add1_Output = &fifo_4;
fifo_i32_t *print1_result = &fifo_4;

fifo_i32_t *add2_Output = &fifo_5;
fifo_i32_t *print2_result = &fifo_5;


/////////////////////////////////////////////////
// Actor functions
extern void src1_initialize(schedinfo_t *si);
extern void src1_scheduler(schedinfo_t *si);
extern void src2_initialize(schedinfo_t *si);
extern void src2_scheduler(schedinfo_t *si);
extern void add1_initialize(schedinfo_t *si);
extern void add1_scheduler(schedinfo_t *si);
extern void add2_initialize(schedinfo_t *si);
extern void add2_scheduler(schedinfo_t *si);
extern void print1_initialize(schedinfo_t *si);
extern void print1_scheduler(schedinfo_t *si);
extern void print2_initialize(schedinfo_t *si);
extern void print2_scheduler(schedinfo_t *si);

/////////////////////////////////////////////////
// Declaration of the actors array
actor_t src1 = {"src1", src1_initialize, src1_scheduler, 0, 0, 0, 0, NULL, -1, 0, 0, 1, 0, 0, 0, NULL, 0, 0, "", 0, 0, 0};
actor_t src2 = {"src2", src2_initialize, src2_scheduler, 0, 0, 0, 0, NULL, -1, 1, 0, 1, 0, 0, 0, NULL, 0, 0, "", 0, 0, 0};
actor_t add1 = {"add1", add1_initialize, add1_scheduler, 0, 0, 0, 0, NULL, -1, 2, 0, 1, 0, 0, 0, NULL, 0, 0, "", 0, 0, 0};
actor_t add2 = {"add2", add2_initialize, add2_scheduler, 0, 0, 0, 0, NULL, -1, 3, 0, 1, 0, 0, 0, NULL, 0, 0, "", 0, 0, 0};
actor_t print1 = {"print1", print1_initialize, print1_scheduler, 0, 0, 0, 0, NULL, -1, 4, 0, 1, 0, 0, 0, NULL, 0, 0, "", 0, 0, 0};
actor_t print2 = {"print2", print2_initialize, print2_scheduler, 0, 0, 0, 0, NULL, -1, 5, 0, 1, 0, 0, 0, NULL, 0, 0, "", 0, 0, 0};

actor_t *actors[] = {
	&src1,
	&src2,
	&add1,
	&add2,
	&print1,
	&print2
};

/////////////////////////////////////////////////
// Declaration of the connections array
connection_t connection_add1_Input1 = {&src1, &add1, 0, 0};
connection_t connection_add2_Input1 = {&src1, &add2, 0, 0};
connection_t connection_add1_Input2 = {&src2, &add1, 0, 0};
connection_t connection_add2_Input2 = {&src2, &add2, 0, 0};
connection_t connection_print2_result = {&add2, &print2, 0, 0};
connection_t connection_print1_result = {&add1, &print1, 0, 0};

connection_t *connections[] = {
	&connection_add1_Input1,
	&connection_add2_Input1,
	&connection_add1_Input2,
	&connection_add2_Input2,
	&connection_print2_result,
	&connection_print1_result
};

/////////////////////////////////////////////////
// Declaration of the network
network_t network = {"accumulatorv2.net", actors, connections, 6, 6};

////////////////////////////////////////////////////////////////////////////////
// Main
int main(int argc, char *argv[]) {
	
	options_t *opt = init_orcc(argc, argv);
	set_scheduling_strategy("RR", opt);
	
	launcher(opt, &network);
	
	return compareErrors;
}
