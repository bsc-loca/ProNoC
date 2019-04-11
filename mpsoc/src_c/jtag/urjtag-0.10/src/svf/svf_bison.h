/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     SVF_EOF = 0,
     IDENTIFIER = 258,
     NUMBER = 259,
     HEXA_NUM = 260,
     VECTOR_STRING = 261,
     EMPTY = 262,
     ENDDR = 263,
     ENDIR = 264,
     FREQUENCY = 265,
     HZ = 266,
     STATE = 267,
     RESET = 268,
     IDLE = 269,
     TDI = 270,
     TDO = 271,
     MASK = 272,
     SMASK = 273,
     TRST = 274,
     ON = 275,
     OFF = 276,
     Z = 277,
     ABSENT = 278,
     HDR = 279,
     HIR = 280,
     SDR = 281,
     SIR = 282,
     TDR = 283,
     TIR = 284,
     PIO = 285,
     PIOMAP = 286,
     IN = 287,
     OUT = 288,
     INOUT = 289,
     H = 290,
     L = 291,
     U = 292,
     D = 293,
     X = 294,
     RUNTEST = 295,
     MAXIMUM = 296,
     SEC = 297,
     TCK = 298,
     SCK = 299,
     ENDSTATE = 300,
     IRPAUSE = 301,
     IRSHIFT = 302,
     IRUPDATE = 303,
     IRSELECT = 304,
     IREXIT1 = 305,
     IREXIT2 = 306,
     IRCAPTURE = 307,
     DRPAUSE = 308,
     DRSHIFT = 309,
     DRUPDATE = 310,
     DRSELECT = 311,
     DREXIT1 = 312,
     DREXIT2 = 313,
     DRCAPTURE = 314
   };
#endif
/* Tokens.  */
#define SVF_EOF 0
#define IDENTIFIER 258
#define NUMBER 259
#define HEXA_NUM 260
#define VECTOR_STRING 261
#define EMPTY 262
#define ENDDR 263
#define ENDIR 264
#define FREQUENCY 265
#define HZ 266
#define STATE 267
#define RESET 268
#define IDLE 269
#define TDI 270
#define TDO 271
#define MASK 272
#define SMASK 273
#define TRST 274
#define ON 275
#define OFF 276
#define Z 277
#define ABSENT 278
#define HDR 279
#define HIR 280
#define SDR 281
#define SIR 282
#define TDR 283
#define TIR 284
#define PIO 285
#define PIOMAP 286
#define IN 287
#define OUT 288
#define INOUT 289
#define H 290
#define L 291
#define U 292
#define D 293
#define X 294
#define RUNTEST 295
#define MAXIMUM 296
#define SEC 297
#define TCK 298
#define SCK 299
#define ENDSTATE 300
#define IRPAUSE 301
#define IRSHIFT 302
#define IRUPDATE 303
#define IRSELECT 304
#define IREXIT1 305
#define IREXIT2 306
#define IRCAPTURE 307
#define DRPAUSE 308
#define DRSHIFT 309
#define DRUPDATE 310
#define DRSELECT 311
#define DREXIT1 312
#define DREXIT2 313
#define DRCAPTURE 314




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 52 "svf_bison.y"
{
  int    token;
  double dvalue;
  char  *cvalue;
  int    ivalue;
  struct tdval tdval;
  struct tcval *tcval;
}
/* Line 1489 of yacc.c.  */
#line 178 "svf_bison.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



#if ! defined YYLTYPE && ! defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE
{
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} YYLTYPE;
# define yyltype YYLTYPE /* obsolescent; will be withdrawn */
# define YYLTYPE_IS_DECLARED 1
# define YYLTYPE_IS_TRIVIAL 1
#endif


