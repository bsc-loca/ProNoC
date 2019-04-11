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
     CONSTANT = 258,
     PIN_MAP = 259,
     PHYSICAL_PIN_MAP = 260,
     PIN_MAP_STRING = 261,
     TAP_SCAN_IN = 262,
     TAP_SCAN_OUT = 263,
     TAP_SCAN_MODE = 264,
     TAP_SCAN_RESET = 265,
     TAP_SCAN_CLOCK = 266,
     INSTRUCTION_LENGTH = 267,
     INSTRUCTION_OPCODE = 268,
     INSTRUCTION_CAPTURE = 269,
     INSTRUCTION_DISABLE = 270,
     INSTRUCTION_GUARD = 271,
     INSTRUCTION_PRIVATE = 272,
     REGISTER_ACCESS = 273,
     BOUNDARY_LENGTH = 274,
     BOUNDARY_REGISTER = 275,
     IDCODE_REGISTER = 276,
     USERCODE_REGISTER = 277,
     BOUNDARY = 278,
     DEVICE_ID = 279,
     INPUT = 280,
     OUTPUT2 = 281,
     OUTPUT3 = 282,
     CONTROL = 283,
     CONTROLR = 284,
     INTERNAL = 285,
     CLOCK = 286,
     BIDIR = 287,
     BIDIR_IN = 288,
     BIDIR_OUT = 289,
     Z = 290,
     WEAK0 = 291,
     WEAK1 = 292,
     IDENTIFIER = 293,
     PULL0 = 294,
     PULL1 = 295,
     KEEPER = 296,
     DECIMAL_NUMBER = 297,
     BINARY_PATTERN = 298,
     BIN_X_PATTERN = 299,
     COMMA = 300,
     LPAREN = 301,
     RPAREN = 302,
     LBRACKET = 303,
     RBRACKET = 304,
     COLON = 305,
     ASTERISK = 306,
     COMPLIANCE_PATTERNS = 307,
     OBSERVE_ONLY = 308,
     BYPASS = 309,
     CLAMP = 310,
     EXTEST = 311,
     HIGHZ = 312,
     IDCODE = 313,
     INTEST = 314,
     PRELOAD = 315,
     RUNBIST = 316,
     SAMPLE = 317,
     USERCODE = 318,
     COMPONENT_CONFORMANCE = 319,
     STD_1149_1_1990 = 320,
     STD_1149_1_1993 = 321,
     STD_1149_1_2001 = 322,
     ISC_CONFORMANCE = 323,
     STD_1532_2001 = 324,
     STD_1532_2002 = 325,
     ISC_PIN_BEHAVIOR = 326,
     ISC_FIXED_SYSTEM_PINS = 327,
     ISC_STATUS = 328,
     IMPLEMENTED = 329,
     ISC_BLANK_USERCODE = 330,
     ISC_SECURITY = 331,
     ISC_DISABLE_READ = 332,
     ISC_DISABLE_PROGRAM = 333,
     ISC_DISABLE_ERASE = 334,
     ISC_DISABLE_KEY = 335,
     ISC_FLOW = 336,
     UNPROCESSED = 337,
     EXIT_ON_ERROR = 338,
     ARRAY = 339,
     SECURITY = 340,
     INITIALIZE = 341,
     REPEAT = 342,
     TERMINATE = 343,
     LOOP = 344,
     MIN = 345,
     MAX = 346,
     DOLLAR = 347,
     EQUAL = 348,
     HEX_STRING = 349,
     WAIT = 350,
     REAL_NUMBER = 351,
     PLUS = 352,
     MINUS = 353,
     SH_RIGHT = 354,
     SH_LEFT = 355,
     TILDE = 356,
     QUESTION_MARK = 357,
     EXCLAMATION_MARK = 358,
     QUESTION_EXCLAMATION = 359,
     CRC = 360,
     OST = 361,
     ISC_PROCEDURE = 362,
     ISC_ACTION = 363,
     PROPRIETARY = 364,
     OPTIONAL = 365,
     RECOMMENDED = 366,
     ISC_ILLEGAL_EXIT = 367,
     ILLEGAL = 368
   };
#endif
/* Tokens.  */
#define CONSTANT 258
#define PIN_MAP 259
#define PHYSICAL_PIN_MAP 260
#define PIN_MAP_STRING 261
#define TAP_SCAN_IN 262
#define TAP_SCAN_OUT 263
#define TAP_SCAN_MODE 264
#define TAP_SCAN_RESET 265
#define TAP_SCAN_CLOCK 266
#define INSTRUCTION_LENGTH 267
#define INSTRUCTION_OPCODE 268
#define INSTRUCTION_CAPTURE 269
#define INSTRUCTION_DISABLE 270
#define INSTRUCTION_GUARD 271
#define INSTRUCTION_PRIVATE 272
#define REGISTER_ACCESS 273
#define BOUNDARY_LENGTH 274
#define BOUNDARY_REGISTER 275
#define IDCODE_REGISTER 276
#define USERCODE_REGISTER 277
#define BOUNDARY 278
#define DEVICE_ID 279
#define INPUT 280
#define OUTPUT2 281
#define OUTPUT3 282
#define CONTROL 283
#define CONTROLR 284
#define INTERNAL 285
#define CLOCK 286
#define BIDIR 287
#define BIDIR_IN 288
#define BIDIR_OUT 289
#define Z 290
#define WEAK0 291
#define WEAK1 292
#define IDENTIFIER 293
#define PULL0 294
#define PULL1 295
#define KEEPER 296
#define DECIMAL_NUMBER 297
#define BINARY_PATTERN 298
#define BIN_X_PATTERN 299
#define COMMA 300
#define LPAREN 301
#define RPAREN 302
#define LBRACKET 303
#define RBRACKET 304
#define COLON 305
#define ASTERISK 306
#define COMPLIANCE_PATTERNS 307
#define OBSERVE_ONLY 308
#define BYPASS 309
#define CLAMP 310
#define EXTEST 311
#define HIGHZ 312
#define IDCODE 313
#define INTEST 314
#define PRELOAD 315
#define RUNBIST 316
#define SAMPLE 317
#define USERCODE 318
#define COMPONENT_CONFORMANCE 319
#define STD_1149_1_1990 320
#define STD_1149_1_1993 321
#define STD_1149_1_2001 322
#define ISC_CONFORMANCE 323
#define STD_1532_2001 324
#define STD_1532_2002 325
#define ISC_PIN_BEHAVIOR 326
#define ISC_FIXED_SYSTEM_PINS 327
#define ISC_STATUS 328
#define IMPLEMENTED 329
#define ISC_BLANK_USERCODE 330
#define ISC_SECURITY 331
#define ISC_DISABLE_READ 332
#define ISC_DISABLE_PROGRAM 333
#define ISC_DISABLE_ERASE 334
#define ISC_DISABLE_KEY 335
#define ISC_FLOW 336
#define UNPROCESSED 337
#define EXIT_ON_ERROR 338
#define ARRAY 339
#define SECURITY 340
#define INITIALIZE 341
#define REPEAT 342
#define TERMINATE 343
#define LOOP 344
#define MIN 345
#define MAX 346
#define DOLLAR 347
#define EQUAL 348
#define HEX_STRING 349
#define WAIT 350
#define REAL_NUMBER 351
#define PLUS 352
#define MINUS 353
#define SH_RIGHT 354
#define SH_LEFT 355
#define TILDE 356
#define QUESTION_MARK 357
#define EXCLAMATION_MARK 358
#define QUESTION_EXCLAMATION 359
#define CRC 360
#define OST 361
#define ISC_PROCEDURE 362
#define ISC_ACTION 363
#define PROPRIETARY 364
#define OPTIONAL 365
#define RECOMMENDED 366
#define ISC_ILLEGAL_EXIT 367
#define ILLEGAL 368




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 175 "bsdl_bison.y"
{
  int   integer;
  char *str;
}
/* Line 1489 of yacc.c.  */
#line 280 "bsdl_bison.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



