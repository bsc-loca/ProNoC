# -*- Makefile -*-
#*****************************************************************************
#
# DESCRIPTION: Verilator Example: Makefile for inside object directory
#
# This is executed in the object directory, and called by ../Makefile
#
# Copyright 2003-2014 by Wilson Snyder. This program is free software; you can
# redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License Version 3 or the Perl Artistic License
# Version 2.0.
#
#*****************************************************************************

default: sim


M0 = Vinject
M1 = Vrnf
M2 = Vhnf
M3 = Vsnf
M4 = Vdatrouter
M5 = Vreqrouter
M6 = Vrsprouter
M7 = Vsnprouter

A0 = $(M0)__ALL.a
A1 = $(M1)__ALL.a
A2 = $(M2)__ALL.a
A3 = $(M3)__ALL.a
A4 = $(M4)__ALL.a
A5 = $(M5)__ALL.a
A6 = $(M6)__ALL.a
A7 = $(M7)__ALL.a	

MODULES_ALL = $(A0) $(A1) $(A2) $(A3) $(A4) $(A5) $(A6) $(A7)
MODULES_H = $(M0).h  $(M1).h  $(M2).h  $(M3).h  $(M4).h  $(M5).h  $(M6).h  $(M7).h  
#MUDULC = Vtraffic


include Vdatrouter.mk

lib:  lib0 lib1 lib2 lib3 lib4 lib5 lib6 lib7

lib0: 
	$(MAKE) -f $(M0).mk
lib1:
	$(MAKE) -f $(M1).mk
lib2:
	$(MAKE) -f $(M2).mk
lib3:
	$(MAKE) -f $(M3).mk
lib4:
	$(MAKE) -f $(M4).mk
lib5:
	$(MAKE) -f $(M5).mk
lib6:
	$(MAKE) -f $(M6).mk
lib7:
	$(MAKE) -f $(M7).mk 
	
	



#######################################################################
# Compile flags

CPPFLAGS += -DVL_DEBUG=1
ifeq ($(CFG_WITH_CCWARN),yes)	# Local... Else don't burden users
CPPFLAGS += -DVL_THREADED=1
CPPFLAGS += -W -Werror -Wall
endif

#######################################################################
# Linking final exe -- presumes have a sim_main.cpp


sim: testbench.o $(VK_GLOBAL_OBJS) $(MODULES_ALL) 
	$(LINK) $(LDFLAGS) -g $^ $(LOADLIBES) $(LDLIBS) -o testbench $(LIBS) -Wall -O3 2>&1 | c++filt	
#$(MUDULB)__ALL.a $(MUDULA)__ALL.a $(MUDULC)__ALL.a
	

testbench.o: testbench.cpp $(MODULES_H)
# $(MUDULB).h $(MUDULC).h

clean:
	rm *.o *.a main


