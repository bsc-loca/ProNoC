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
     ENTITY = 258,
     PORT = 259,
     GENERIC = 260,
     USE = 261,
     ATTRIBUTE = 262,
     IS = 263,
     OF = 264,
     CONSTANT = 265,
     STRING = 266,
     END = 267,
     ALL = 268,
     PHYSICAL_PIN_MAP = 269,
     PIN_MAP_STRING = 270,
     TRUE = 271,
     FALSE = 272,
     SIGNAL = 273,
     LOW = 274,
     BOTH = 275,
     IN = 276,
     OUT = 277,
     INOUT = 278,
     BUFFER = 279,
     LINKAGE = 280,
     BIT = 281,
     BIT_VECTOR = 282,
     TO = 283,
     DOWNTO = 284,
     PACKAGE = 285,
     BODY = 286,
     TYPE = 287,
     SUBTYPE = 288,
     RECORD = 289,
     ARRAY = 290,
     POSITIVE = 291,
     RANGE = 292,
     CELL_INFO = 293,
     INPUT = 294,
     OUTPUT2 = 295,
     OUTPUT3 = 296,
     CONTROL = 297,
     CONTROLR = 298,
     INTERNAL = 299,
     CLOCK = 300,
     BIDIR = 301,
     BIDIR_IN = 302,
     BIDIR_OUT = 303,
     EXTEST = 304,
     SAMPLE = 305,
     INTEST = 306,
     RUNBIST = 307,
     PI = 308,
     PO = 309,
     UPD = 310,
     CAP = 311,
     X = 312,
     BIN_X_PATTERN = 313,
     ZERO = 314,
     ONE = 315,
     Z = 316,
     IDENTIFIER = 317,
     SINGLE_QUOTE = 318,
     QUOTED_STRING = 319,
     DECIMAL_NUMBER = 320,
     REAL_NUMBER = 321,
     CONCATENATE = 322,
     SEMICOLON = 323,
     COMMA = 324,
     LPAREN = 325,
     RPAREN = 326,
     COLON = 327,
     BOX = 328,
     COLON_EQUAL = 329,
     PERIOD = 330,
     ILLEGAL = 331,
     BSDL_EXTENSION = 332,
     OBSERVE_ONLY = 333,
     STD_1532_2001 = 334,
     STD_1532_2002 = 335
   };
#endif
/* Tokens.  */
#define ENTITY 258
#define PORT 259
#define GENERIC 260
#define USE 261
#define ATTRIBUTE 262
#define IS 263
#define OF 264
#define CONSTANT 265
#define STRING 266
#define END 267
#define ALL 268
#define PHYSICAL_PIN_MAP 269
#define PIN_MAP_STRING 270
#define TRUE 271
#define FALSE 272
#define SIGNAL 273
#define LOW 274
#define BOTH 275
#define IN 276
#define OUT 277
#define INOUT 278
#define BUFFER 279
#define LINKAGE 280
#define BIT 281
#define BIT_VECTOR 282
#define TO 283
#define DOWNTO 284
#define PACKAGE 285
#define BODY 286
#define TYPE 287
#define SUBTYPE 288
#define RECORD 289
#define ARRAY 290
#define POSITIVE 291
#define RANGE 292
#define CELL_INFO 293
#define INPUT 294
#define OUTPUT2 295
#define OUTPUT3 296
#define CONTROL 297
#define CONTROLR 298
#define INTERNAL 299
#define CLOCK 300
#define BIDIR 301
#define BIDIR_IN 302
#define BIDIR_OUT 303
#define EXTEST 304
#define SAMPLE 305
#define INTEST 306
#define RUNBIST 307
#define PI 308
#define PO 309
#define UPD 310
#define CAP 311
#define X 312
#define BIN_X_PATTERN 313
#define ZERO 314
#define ONE 315
#define Z 316
#define IDENTIFIER 317
#define SINGLE_QUOTE 318
#define QUOTED_STRING 319
#define DECIMAL_NUMBER 320
#define REAL_NUMBER 321
#define CONCATENATE 322
#define SEMICOLON 323
#define COMMA 324
#define LPAREN 325
#define RPAREN 326
#define COLON 327
#define BOX 328
#define COLON_EQUAL 329
#define PERIOD 330
#define ILLEGAL 331
#define BSDL_EXTENSION 332
#define OBSERVE_ONLY 333
#define STD_1532_2001 334
#define STD_1532_2002 335




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 177 "vhdl_bison.y"
{
  int   integer;
  char *str;
}
/* Line 1489 of yacc.c.  */
#line 214 "vhdl_bison.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



