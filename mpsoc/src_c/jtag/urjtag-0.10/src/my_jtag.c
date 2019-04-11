/*
 * $Id: jtag.c 1501 2009-04-17 20:08:53Z arniml $
 *
 * Copyright (C) 2002, 2003 ETC s.r.o.
 *
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
 * 02111-1307, USA.
 *
 * Written by Marcel Telka <marcel@telka.sk>, 2002, 2003.
 * Modified by Ajith Kumar P.C <ajithpc@kila.com>, 20/09/2006.
 *
 */
  
   
#include "sysdep.h"

#ifndef SVN_REVISION
#define SVN_REVISION "0"
#endif


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#ifdef HAVE_LIBREADLINE
#include <readline/readline.h>
#ifdef HAVE_READLINE_HISTORY_H
#include <readline/history.h>
#endif
#endif
#include <getopt.h>
#ifdef ENABLE_NLS
#include <locale.h>
#endif /* ENABLE_NLS */

#include "chain.h"
#include "bus.h"
#include "cmd.h"
#include "jtag.h"

chain_t *chain = NULL;	
#include "vjtag.h"
#include "jtag_main.c"

#ifndef HAVE_GETLINE
ssize_t getline( char **lineptr, size_t *n, FILE *stream );
#endif

int debug_mode = 0;
int big_endian = 0;
int interactive = 0;
extern cfi_array_t *cfi_array;

#define	JTAGDIR		".jtag"
#define	HISTORYFILE	"history"
#define	RCFILE		"rc"

static void
jtag_create_jtagdir( void )
{
	char *home = getenv( "HOME" );
	char *jdir;

	if (!home)
		return;

	jdir = malloc( strlen(home) + strlen(JTAGDIR) + 2 );	/* "/" and trailing \0 */
	if (!jdir)
		return;

	strcpy( jdir, home );
	strcat( jdir, "/" );
	strcat( jdir, JTAGDIR );

	/* Create the directory if it doesn't exists. */
#ifdef __MINGW32__
	mkdir( jdir );
#else
	mkdir( jdir, S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH );
#endif

	free( jdir );
}

static void
cleanup( chain_t *chain )
{
	cfi_array_free( cfi_array );
	cfi_array = NULL;

	if (bus) {
		bus_free( bus );
		bus = NULL;
	}
	chain_free( chain );
	chain = NULL;
}
				
	
							 

int main( int argc, char * argv[] )
{
	int go = 0;
	
	

	chain = chain_alloc();
	if (!chain) {
		printf( _("Out of memory\n") );
		return -1;
	}

	

	/* Create ~/.jtag */
	jtag_create_jtagdir();

	/* Parse and execute the RC file */
	go = 1 ;


	if (go) {
		jtag_main(argc,argv);
	
	}

	cleanup( chain );

	return 0;
}
