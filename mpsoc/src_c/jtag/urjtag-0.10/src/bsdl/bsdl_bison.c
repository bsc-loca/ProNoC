/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 1

/* Using locations.  */
#define YYLSP_NEEDED 0

/* Substitute the variable and function names.  */
#define yyparse bsdlparse
#define yylex   bsdllex
#define yyerror bsdlerror
#define yylval  bsdllval
#define yychar  bsdlchar
#define yydebug bsdldebug
#define yynerrs bsdlnerrs


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




/* Copy the first part of user declarations.  */
#line 125 "bsdl_bison.y"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "bsdl_sysdep.h"

#include "bsdl_types.h"
#include "bsdl_msg.h"

/* interface to flex */
#include "bsdl_bison.h"
#include "bsdl_parser.h"

#ifdef DMALLOC
#include "dmalloc.h"
#endif

#define YYLEX_PARAM priv_data->scanner
int yylex (YYSTYPE *, void *);

#if 1
#define ERROR_LIMIT 0
#define BUMP_ERROR if (bsdl_flex_postinc_compile_errors( priv_data->scanner ) > ERROR_LIMIT) \
                          {Give_Up_And_Quit( priv_data ); YYABORT;}
#else
#define BUMP_ERROR {Give_Up_And_Quit( priv_data );YYABORT;}
#endif

static void Print_Error( bsdl_parser_priv_t *, const char * );
static void Print_Warning( bsdl_parser_priv_t *, const char * );
static void Give_Up_And_Quit( bsdl_parser_priv_t * );

/* semantic functions */
static void add_instruction( bsdl_parser_priv_t *, char *, char * );
static void ac_set_register( bsdl_parser_priv_t *, char *, int );
static void ac_add_instruction( bsdl_parser_priv_t *, char * );
static void ac_apply_assoc( bsdl_parser_priv_t * );
static void prt_add_name( bsdl_parser_priv_t *, char * );
static void prt_add_bit( bsdl_parser_priv_t * );
static void prt_add_range( bsdl_parser_priv_t *, int, int );
static void ci_no_disable( bsdl_parser_priv_t * );
static void ci_set_cell_spec_disable( bsdl_parser_priv_t *, int, int, int );
static void ci_set_cell_spec( bsdl_parser_priv_t *, int, char * );
static void ci_append_cell_info( bsdl_parser_priv_t *, int );

void yyerror( bsdl_parser_priv_t *, const char * );


/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 175 "bsdl_bison.y"
{
  int   integer;
  char *str;
}
/* Line 187 of yacc.c.  */
#line 385 "bsdl_bison.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 398 "bsdl_bison.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  138
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   434

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  114
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  124
/* YYNRULES -- Number of rules.  */
#define YYNRULES  285
/* YYNRULES -- Number of states.  */
#define YYNSTATES  441

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   368

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104,
     105,   106,   107,   108,   109,   110,   111,   112,   113
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    11,    13,    15,    17,
      19,    21,    23,    25,    27,    29,    31,    33,    35,    37,
      39,    41,    43,    45,    47,    50,    53,    57,    61,    63,
      67,    69,    73,    75,    80,    82,    85,    88,    91,    94,
      97,   100,   103,   105,   109,   111,   116,   118,   122,   124,
     127,   130,   133,   136,   138,   142,   144,   146,   149,   152,
     155,   157,   161,   166,   168,   173,   175,   177,   179,   181,
     183,   185,   189,   191,   193,   195,   197,   199,   201,   203,
     205,   207,   209,   211,   213,   216,   219,   221,   225,   227,
     232,   234,   238,   246,   248,   253,   255,   257,   259,   261,
     263,   265,   267,   269,   271,   273,   275,   277,   283,   285,
     287,   289,   291,   293,   295,   298,   299,   307,   309,   313,
     316,   319,   322,   324,   326,   328,   330,   332,   334,   336,
     338,   340,   342,   345,   348,   351,   353,   355,   357,   360,
     362,   366,   368,   370,   375,   379,   380,   382,   385,   388,
     396,   398,   401,   404,   407,   410,   412,   414,   416,   420,
     423,   425,   429,   431,   434,   438,   443,   446,   450,   453,
     455,   457,   460,   464,   469,   472,   476,   479,   483,   487,
     489,   491,   493,   495,   497,   500,   504,   507,   509,   512,
     514,   516,   523,   524,   527,   530,   532,   535,   540,   546,
     552,   559,   561,   565,   567,   568,   573,   575,   577,   579,
     581,   583,   585,   586,   591,   594,   597,   601,   603,   605,
     607,   611,   612,   617,   619,   622,   626,   629,   631,   634,
     635,   637,   640,   642,   644,   647,   651,   654,   657,   661,
     668,   670,   672,   676,   679,   682,   684,   686,   688,   690,
     692,   694,   696,   698,   701,   704,   707,   709,   713,   719,
     726,   728,   730,   734,   737,   739,   743,   749,   756,   763,
     771,   773,   775,   779,   781,   784,   788,   792,   797,   800,
     804,   807,   809,   811,   814,   816
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
     115,     0,    -1,   116,    -1,   117,    -1,   122,    -1,   123,
      -1,   124,    -1,   125,    -1,   126,    -1,   127,    -1,   128,
      -1,   133,    -1,   134,    -1,   135,    -1,   136,    -1,   139,
      -1,   140,    -1,   141,    -1,   149,    -1,   150,    -1,   160,
      -1,   164,    -1,   165,    -1,     1,    -1,     4,     5,    -1,
       6,   118,    -1,   117,    45,   118,    -1,    38,    50,   119,
      -1,   121,    -1,    46,   120,    47,    -1,   121,    -1,   120,
      45,   121,    -1,    38,    -1,    38,    46,    42,    47,    -1,
      42,    -1,     7,    42,    -1,     8,    42,    -1,     9,    42,
      -1,    10,    42,    -1,    11,    42,    -1,    12,    42,    -1,
      13,   129,    -1,   130,    -1,   129,    45,   130,    -1,     1,
      -1,    38,    46,   131,    47,    -1,   132,    -1,   131,    45,
     132,    -1,    43,    -1,    14,    44,    -1,    15,    38,    -1,
      16,    38,    -1,    17,   137,    -1,   138,    -1,   137,    45,
     138,    -1,     1,    -1,    38,    -1,    21,    44,    -1,    22,
      44,    -1,    18,   142,    -1,   143,    -1,   142,    45,   143,
      -1,   144,    46,   146,    47,    -1,   145,    -1,    38,    48,
      42,    49,    -1,    23,    -1,    54,    -1,    58,    -1,    63,
      -1,    24,    -1,   148,    -1,   146,    45,   148,    -1,    54,
      -1,    55,    -1,    56,    -1,    57,    -1,    58,    -1,    59,
      -1,    60,    -1,    61,    -1,    62,    -1,    63,    -1,    38,
      -1,   147,    -1,    19,    42,    -1,    20,   151,    -1,   152,
      -1,   151,    45,   152,    -1,     1,    -1,    42,    46,   153,
      47,    -1,   154,    -1,   154,    45,   158,    -1,    38,    45,
     155,    45,   156,    45,   157,    -1,    38,    -1,    38,    46,
      42,    47,    -1,    51,    -1,    25,    -1,    26,    -1,    27,
      -1,    28,    -1,    29,    -1,    30,    -1,    31,    -1,    32,
      -1,    53,    -1,    38,    -1,    42,    -1,    42,    45,    42,
      45,   159,    -1,    35,    -1,    36,    -1,    37,    -1,    39,
      -1,    40,    -1,    41,    -1,    52,   161,    -1,    -1,    46,
     120,    47,   162,    46,   163,    47,    -1,    44,    -1,   163,
      45,    44,    -1,    64,    65,    -1,    64,    66,    -1,    64,
      67,    -1,   166,    -1,   167,    -1,   169,    -1,   172,    -1,
     174,    -1,   175,    -1,   183,    -1,   226,    -1,   230,    -1,
     236,    -1,    68,    69,    -1,    68,    70,    -1,    71,   168,
      -1,    57,    -1,    55,    -1,     1,    -1,    72,   170,    -1,
     171,    -1,   170,    45,   171,    -1,     1,    -1,    38,    -1,
      38,    46,    42,    47,    -1,    73,   173,    74,    -1,    -1,
      38,    -1,    75,    44,    -1,    76,   176,    -1,   177,    45,
     178,    45,   179,    45,   180,    -1,     1,    -1,    77,   181,
      -1,    78,   181,    -1,    79,   181,    -1,    80,   182,    -1,
      51,    -1,    42,    -1,    51,    -1,    42,    98,    42,    -1,
      81,   184,    -1,   185,    -1,   184,    45,   185,    -1,   186,
      -1,   186,   189,    -1,   186,   189,   190,    -1,   186,   189,
     190,   191,    -1,   186,   190,    -1,   186,   190,   191,    -1,
     186,   191,    -1,     1,    -1,    38,    -1,    38,   187,    -1,
      38,   187,    82,    -1,    38,   187,    82,    83,    -1,    38,
      82,    -1,    38,    82,    83,    -1,    38,    83,    -1,    46,
     188,    47,    -1,    46,    38,    47,    -1,    84,    -1,    63,
      -1,    85,    -1,    58,    -1,    60,    -1,    86,   192,    -1,
      87,    42,   192,    -1,    88,   192,    -1,   193,    -1,   192,
     193,    -1,   198,    -1,   194,    -1,    89,   195,   196,    46,
     197,    47,    -1,    -1,    90,    42,    -1,    91,    42,    -1,
     198,    -1,   197,   198,    -1,    46,   147,   215,    47,    -1,
      46,   147,   199,   215,    47,    -1,    46,   147,   215,   208,
      47,    -1,    46,   147,   199,   215,   208,    47,    -1,   200,
      -1,   199,    45,   200,    -1,    42,    -1,    -1,    42,    50,
     201,   202,    -1,    94,    -1,   207,    -1,   203,    -1,   218,
      -1,   204,    -1,   206,    -1,    -1,   218,    93,   205,    94,
      -1,   218,   207,    -1,   218,   220,    -1,   218,   219,    42,
      -1,   221,    -1,   223,    -1,   209,    -1,   208,    45,   209,
      -1,    -1,    42,    50,   210,   211,    -1,   212,    -1,   212,
     224,    -1,   212,   224,   225,    -1,   212,   225,    -1,   213,
      -1,   213,   214,    -1,    -1,   222,    -1,   222,   202,    -1,
     202,    -1,    51,    -1,    51,   222,    -1,    51,   222,   202,
      -1,    51,   202,    -1,    95,   216,    -1,    95,   216,    90,
      -1,    95,   216,    90,    50,   216,    91,    -1,   217,    -1,
      96,    -1,   217,    45,    96,    -1,   171,    42,    -1,    92,
      38,    -1,    97,    -1,    98,    -1,    99,    -1,   100,    -1,
     101,    -1,   102,    -1,   103,    -1,   104,    -1,    50,   105,
      -1,    50,   106,    -1,   107,   227,    -1,   228,    -1,   227,
      45,   228,    -1,    38,    93,    46,   229,    47,    -1,    38,
     187,    93,    46,   229,    47,    -1,     1,    -1,   186,    -1,
     229,    45,   186,    -1,   108,   231,    -1,   232,    -1,   231,
      45,   232,    -1,    38,    93,    46,   233,    47,    -1,    38,
     187,    93,    46,   233,    47,    -1,    38,   109,    93,    46,
     233,    47,    -1,    38,   187,   109,    93,    46,   233,    47,
      -1,     1,    -1,   234,    -1,   233,    45,   234,    -1,    38,
      -1,    38,   187,    -1,    38,   187,   109,    -1,    38,   187,
     235,    -1,    38,   187,   109,   235,    -1,    38,   109,    -1,
      38,   109,   235,    -1,    38,   235,    -1,   110,    -1,   111,
      -1,   112,   237,    -1,    38,    -1,   237,    45,    38,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   234,   234,   235,   236,   237,   238,   239,   240,   241,
     242,   243,   244,   245,   246,   247,   248,   249,   250,   251,
     252,   253,   254,   255,   264,   268,   269,   271,   274,   275,
     277,   278,   280,   282,   284,   288,   292,   296,   300,   304,
     308,   313,   315,   316,   317,   325,   328,   330,   338,   343,
     348,   353,   358,   360,   361,   362,   369,   374,   379,   384,
     386,   387,   389,   392,   394,   397,   399,   401,   403,   405,
     408,   409,   411,   413,   415,   417,   419,   421,   423,   425,
     427,   429,   431,   434,   440,   445,   447,   448,   449,   453,
     456,   458,   460,   467,   472,   477,   483,   485,   487,   489,
     491,   493,   495,   497,   499,   502,   504,   513,   516,   518,
     520,   522,   524,   526,   531,   534,   533,   537,   539,   544,
     546,   548,   552,   553,   554,   555,   556,   557,   558,   559,
     560,   561,   564,   565,   568,   570,   571,   572,   580,   582,
     583,   584,   591,   593,   597,   599,   600,   604,   608,   610,
     611,   618,   620,   622,   624,   626,   627,   629,   630,   633,
     635,   636,   638,   639,   640,   641,   642,   643,   644,   645,
     652,   654,   656,   658,   660,   662,   664,   667,   668,   671,
     671,   671,   671,   671,   673,   675,   677,   679,   680,   682,
     683,   685,   687,   688,   690,   692,   693,   695,   697,   699,
     701,   704,   705,   707,   709,   708,   713,   715,   716,   718,
     719,   720,   723,   722,   729,   731,   732,   734,   735,   737,
     738,   741,   740,   745,   746,   747,   748,   750,   751,   753,
     754,   755,   756,   758,   759,   760,   761,   763,   764,   765,
     767,   768,   770,   773,   775,   778,   780,   782,   784,   787,
     789,   791,   793,   795,   797,   800,   802,   803,   805,   807,
     809,   816,   817,   820,   822,   823,   825,   827,   829,   831,
     833,   840,   841,   843,   845,   847,   849,   851,   853,   855,
     857,   860,   860,   863,   865,   867
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "CONSTANT", "PIN_MAP",
  "PHYSICAL_PIN_MAP", "PIN_MAP_STRING", "TAP_SCAN_IN", "TAP_SCAN_OUT",
  "TAP_SCAN_MODE", "TAP_SCAN_RESET", "TAP_SCAN_CLOCK",
  "INSTRUCTION_LENGTH", "INSTRUCTION_OPCODE", "INSTRUCTION_CAPTURE",
  "INSTRUCTION_DISABLE", "INSTRUCTION_GUARD", "INSTRUCTION_PRIVATE",
  "REGISTER_ACCESS", "BOUNDARY_LENGTH", "BOUNDARY_REGISTER",
  "IDCODE_REGISTER", "USERCODE_REGISTER", "BOUNDARY", "DEVICE_ID", "INPUT",
  "OUTPUT2", "OUTPUT3", "CONTROL", "CONTROLR", "INTERNAL", "CLOCK",
  "BIDIR", "BIDIR_IN", "BIDIR_OUT", "Z", "WEAK0", "WEAK1", "IDENTIFIER",
  "PULL0", "PULL1", "KEEPER", "DECIMAL_NUMBER", "BINARY_PATTERN",
  "BIN_X_PATTERN", "COMMA", "LPAREN", "RPAREN", "LBRACKET", "RBRACKET",
  "COLON", "ASTERISK", "COMPLIANCE_PATTERNS", "OBSERVE_ONLY", "BYPASS",
  "CLAMP", "EXTEST", "HIGHZ", "IDCODE", "INTEST", "PRELOAD", "RUNBIST",
  "SAMPLE", "USERCODE", "COMPONENT_CONFORMANCE", "STD_1149_1_1990",
  "STD_1149_1_1993", "STD_1149_1_2001", "ISC_CONFORMANCE", "STD_1532_2001",
  "STD_1532_2002", "ISC_PIN_BEHAVIOR", "ISC_FIXED_SYSTEM_PINS",
  "ISC_STATUS", "IMPLEMENTED", "ISC_BLANK_USERCODE", "ISC_SECURITY",
  "ISC_DISABLE_READ", "ISC_DISABLE_PROGRAM", "ISC_DISABLE_ERASE",
  "ISC_DISABLE_KEY", "ISC_FLOW", "UNPROCESSED", "EXIT_ON_ERROR", "ARRAY",
  "SECURITY", "INITIALIZE", "REPEAT", "TERMINATE", "LOOP", "MIN", "MAX",
  "DOLLAR", "EQUAL", "HEX_STRING", "WAIT", "REAL_NUMBER", "PLUS", "MINUS",
  "SH_RIGHT", "SH_LEFT", "TILDE", "QUESTION_MARK", "EXCLAMATION_MARK",
  "QUESTION_EXCLAMATION", "CRC", "OST", "ISC_PROCEDURE", "ISC_ACTION",
  "PROPRIETARY", "OPTIONAL", "RECOMMENDED", "ISC_ILLEGAL_EXIT", "ILLEGAL",
  "$accept", "BSDL_Statement", "BSDL_Pin_Map", "BSDL_Map_String",
  "Pin_Mapping", "Physical_Pin_Desc", "Physical_Pin_List", "Physical_Pin",
  "BSDL_Tap_Scan_In", "BSDL_Tap_Scan_Out", "BSDL_Tap_Scan_Mode",
  "BSDL_Tap_Scan_Reset", "BSDL_Tap_Scan_Clock", "BSDL_Inst_Length",
  "BSDL_Opcode", "BSDL_Opcode_Table", "Opcode_Desc", "Binary_Pattern_List",
  "Binary_Pattern", "BSDL_Inst_Capture", "BSDL_Inst_Disable",
  "BSDL_Inst_Guard", "BSDL_Inst_Private", "Private_Opcode_List",
  "Private_Opcode", "BSDL_Idcode_Register", "BSDL_Usercode_Register",
  "BSDL_Register_Access", "Register_String", "Register_Assoc",
  "Register_Decl", "Standard_Reg", "Reg_Opcode_List", "Instruction_Name",
  "Reg_Opcode", "BSDL_Boundary_Length", "BSDL_Boundary_Register",
  "BSDL_Cell_Table", "Cell_Entry", "Cell_Info", "Cell_Spec", "Port_Name",
  "Cell_Function", "Safe_Value", "Disable_Spec", "Disable_Value",
  "BSDL_Compliance_Patterns", "BSDL_Compliance_Pattern", "@1",
  "Bin_X_Pattern_List", "BSDL_Component_Conformance", "ISC_Extension",
  "ISC_Conformance", "ISC_Pin_Behavior", "Pin_Behavior_Option",
  "ISC_Fixed_System_Pins", "Fixed_Pin_List", "Port_Id", "ISC_Status",
  "Status_Modifier", "ISC_Blank_Usercode", "ISC_Security",
  "Protection_Spec", "Read_Spec", "Program_Spec", "Erase_Spec", "Key_Spec",
  "Bit_Spec", "Bit_Range", "ISC_Flow", "Flow_Definition_List",
  "Flow_Definition", "Flow_Descriptor", "Data_Name", "Standard_Data_Name",
  "Initialize_Block", "Repeat_Block", "Terminate_Block", "Activity_List",
  "Activity_Element", "Loop_Block", "Loop_Min_Spec", "Loop_Max_Spec",
  "Loop_Activity_List", "Activity", "Update_Field_List", "Update_Field",
  "@2", "Data_Expression", "Variable_Expression", "Variable_Assignment",
  "@3", "Variable_Update", "Input_Specifier", "Capture_Field_List",
  "Capture_Field", "@4", "Capture_Field_Rest", "Capture_Specification",
  "Expected_Data", "Compare_Mask", "Wait_Specification",
  "Duration_Specification", "Clock_Cycles", "Variable", "Binary_Operator",
  "Complement_Operator", "Input_Operator", "Output_Operator",
  "IO_Operator", "CRC_Tag", "OST_Tag", "ISC_Procedure", "Procedure_List",
  "Procedure", "Flow_Descriptor_List", "ISC_Action", "Action_List",
  "Action", "Action_Specification_List", "Action_Specification",
  "Option_Specification", "ISC_Illegal_Exit", "Exit_Instruction_List", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327,   328,   329,   330,   331,   332,   333,   334,
     335,   336,   337,   338,   339,   340,   341,   342,   343,   344,
     345,   346,   347,   348,   349,   350,   351,   352,   353,   354,
     355,   356,   357,   358,   359,   360,   361,   362,   363,   364,
     365,   366,   367,   368
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,   114,   115,   115,   115,   115,   115,   115,   115,   115,
     115,   115,   115,   115,   115,   115,   115,   115,   115,   115,
     115,   115,   115,   115,   116,   117,   117,   118,   119,   119,
     120,   120,   121,   121,   121,   122,   123,   124,   125,   126,
     127,   128,   129,   129,   129,   130,   131,   131,   132,   133,
     134,   135,   136,   137,   137,   137,   138,   139,   140,   141,
     142,   142,   143,   144,   144,   145,   145,   145,   145,   145,
     146,   146,   147,   147,   147,   147,   147,   147,   147,   147,
     147,   147,   147,   148,   149,   150,   151,   151,   151,   152,
     153,   153,   154,   155,   155,   155,   156,   156,   156,   156,
     156,   156,   156,   156,   156,   157,   157,   158,   159,   159,
     159,   159,   159,   159,   160,   162,   161,   163,   163,   164,
     164,   164,   165,   165,   165,   165,   165,   165,   165,   165,
     165,   165,   166,   166,   167,   168,   168,   168,   169,   170,
     170,   170,   171,   171,   172,   173,   173,   174,   175,   176,
     176,   177,   178,   179,   180,   181,   181,   182,   182,   183,
     184,   184,   185,   185,   185,   185,   185,   185,   185,   185,
     186,   186,   186,   186,   186,   186,   186,   187,   187,   188,
     188,   188,   188,   188,   189,   190,   191,   192,   192,   193,
     193,   194,   195,   195,   196,   197,   197,   198,   198,   198,
     198,   199,   199,   200,   201,   200,   202,   202,   202,   203,
     203,   203,   205,   204,   204,   206,   206,   207,   207,   208,
     208,   210,   209,   211,   211,   211,   211,   212,   212,   213,
     213,   213,   213,   214,   214,   214,   214,   215,   215,   215,
     216,   216,   216,   217,   218,   219,   219,   219,   219,   220,
     221,   222,   223,   224,   225,   226,   227,   227,   228,   228,
     228,   229,   229,   230,   231,   231,   232,   232,   232,   232,
     232,   233,   233,   234,   234,   234,   234,   234,   234,   234,
     234,   235,   235,   236,   237,   237
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     2,     2,     3,     3,     1,     3,
       1,     3,     1,     4,     1,     2,     2,     2,     2,     2,
       2,     2,     1,     3,     1,     4,     1,     3,     1,     2,
       2,     2,     2,     1,     3,     1,     1,     2,     2,     2,
       1,     3,     4,     1,     4,     1,     1,     1,     1,     1,
       1,     3,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     2,     2,     1,     3,     1,     4,
       1,     3,     7,     1,     4,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     5,     1,     1,
       1,     1,     1,     1,     2,     0,     7,     1,     3,     2,
       2,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     2,     2,     2,     1,     1,     1,     2,     1,
       3,     1,     1,     4,     3,     0,     1,     2,     2,     7,
       1,     2,     2,     2,     2,     1,     1,     1,     3,     2,
       1,     3,     1,     2,     3,     4,     2,     3,     2,     1,
       1,     2,     3,     4,     2,     3,     2,     3,     3,     1,
       1,     1,     1,     1,     2,     3,     2,     1,     2,     1,
       1,     6,     0,     2,     2,     1,     2,     4,     5,     5,
       6,     1,     3,     1,     0,     4,     1,     1,     1,     1,
       1,     1,     0,     4,     2,     2,     3,     1,     1,     1,
       3,     0,     4,     1,     2,     3,     2,     1,     2,     0,
       1,     2,     1,     1,     2,     3,     2,     2,     3,     6,
       1,     1,     3,     2,     2,     1,     1,     1,     1,     1,
       1,     1,     1,     2,     2,     2,     1,     3,     5,     6,
       1,     1,     3,     2,     1,     3,     5,     6,     6,     7,
       1,     1,     3,     1,     2,     3,     3,     4,     2,     3,
       2,     1,     1,     2,     1,     3
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint16 yydefact[] =
{
       0,    23,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   145,     0,     0,     0,     0,
       0,     0,     0,     2,     3,     4,     5,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,   122,   123,   124,   125,   126,   127,
     128,   129,   130,   131,    24,     0,    25,    35,    36,    37,
      38,    39,    40,    44,     0,    41,    42,    49,    50,    51,
      55,    56,    52,    53,    65,    69,     0,    66,    67,    68,
      59,    60,     0,    63,    84,    88,     0,    85,    86,    57,
      58,     0,   114,   119,   120,   121,   132,   133,   137,   136,
     135,   134,   141,   142,   138,   139,   146,     0,   147,   150,
       0,   148,     0,   169,   170,   159,   160,   162,   260,     0,
     255,   256,   270,     0,   263,   264,   284,   283,     1,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    32,
      34,     0,    30,     0,     0,   144,   156,   155,   151,     0,
       0,   174,   176,   171,     0,     0,     0,     0,   163,   166,
     168,     0,     0,     0,     0,     0,     0,     0,     0,    26,
       0,    27,    28,    48,     0,    46,    43,    54,     0,    61,
      82,    72,    73,    74,    75,    76,    77,    78,    79,    80,
      81,     0,    83,    70,     0,     0,    90,    87,     0,     0,
     115,     0,   140,     0,     0,     0,   182,   183,   180,   179,
     181,     0,   175,   172,   161,     0,   192,   184,   187,   190,
     189,     0,   186,   164,   167,     0,     0,   257,     0,     0,
       0,     0,   265,   285,     0,     0,    45,    64,     0,    62,
       0,    89,     0,     0,    31,     0,   143,   152,     0,   178,
     177,   173,     0,     0,     0,   188,   185,   165,   261,     0,
       0,   273,     0,   271,     0,     0,     0,    29,    47,    71,
      93,    95,     0,     0,    91,    33,     0,     0,     0,   203,
       0,     0,   201,     0,   193,     0,     0,     0,   258,     0,
     278,   281,   282,   274,   280,     0,   266,     0,     0,     0,
       0,     0,     0,   117,     0,   153,     0,   204,   241,     0,
     237,   240,     0,     0,     0,   197,     0,   219,   194,     0,
     262,   259,   279,   275,   276,   272,   268,   267,     0,     0,
      96,    97,    98,    99,   100,   101,   102,   103,   104,     0,
       0,     0,   116,     0,   149,     0,   243,   238,     0,   202,
     198,     0,   221,     0,   199,     0,   195,   277,   269,    94,
       0,     0,   118,     0,   157,   154,     0,   206,   250,   252,
     205,   208,   210,   211,   207,   209,   217,   218,     0,   242,
     200,   229,   220,   191,   196,   105,   106,    92,   108,   109,
     110,   111,   112,   113,   107,     0,   244,   212,   245,   246,
     247,   248,   249,   214,     0,   215,     0,   251,   232,   222,
     223,   227,   230,   158,     0,   216,   239,     0,   224,   226,
     233,   228,   231,   213,   253,   254,     0,   225,   236,   234,
     235
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,    32,    33,    34,    66,   181,   151,   152,    35,    36,
      37,    38,    39,    40,    41,    75,    76,   184,   185,    42,
      43,    44,    45,    82,    83,    46,    47,    48,    90,    91,
      92,    93,   201,   202,   203,    49,    50,    97,    98,   205,
     206,   282,   349,   397,   284,   404,    51,   102,   255,   314,
      52,    53,    54,    55,   111,    56,   114,   319,    57,   117,
      58,    59,   121,   122,   214,   288,   354,   158,   375,    60,
     125,   126,   127,   163,   221,   168,   169,   170,   227,   228,
     229,   264,   296,   365,   230,   291,   292,   355,   380,   381,
     382,   424,   383,   384,   326,   327,   391,   419,   420,   421,
     431,   293,   320,   321,   385,   414,   415,   386,   422,   387,
     428,   429,    61,   130,   131,   269,    62,   134,   135,   272,
     273,   304,    63,   137
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -326
static const yytype_int16 yypact[] =
{
       1,  -326,   125,    97,    96,   138,   142,   150,   155,   180,
      66,   183,   186,   190,    69,    87,   187,    29,   188,   189,
     184,   -24,    74,    28,   101,   193,   191,     2,   111,   114,
     115,   196,   236,  -326,   192,  -326,  -326,  -326,  -326,  -326,
    -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,
    -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,
    -326,  -326,  -326,  -326,  -326,   194,  -326,  -326,  -326,  -326,
    -326,  -326,  -326,  -326,   195,   197,  -326,  -326,  -326,  -326,
    -326,  -326,   198,  -326,  -326,  -326,   199,  -326,  -326,  -326,
     200,  -326,   202,  -326,  -326,  -326,   203,   201,  -326,  -326,
    -326,    20,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,
    -326,  -326,  -326,   204,   206,  -326,  -326,   166,  -326,  -326,
      -4,  -326,   207,  -326,    17,   208,  -326,    60,  -326,     3,
     209,  -326,  -326,   -15,   210,  -326,  -326,   211,  -326,    97,
      91,   214,   220,   221,   218,    87,   113,   223,   222,   216,
    -326,    72,  -326,   224,   225,  -326,  -326,  -326,  -326,   205,
      43,   182,  -326,   185,   111,   -14,   226,   -14,   151,   181,
    -326,   227,   146,   114,   228,   177,   -58,   115,   233,  -326,
      20,  -326,  -326,  -326,   136,  -326,  -326,  -326,   229,  -326,
    -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,
    -326,   156,  -326,  -326,   230,   232,   231,  -326,   235,    20,
    -326,   234,  -326,    -4,   237,   238,  -326,  -326,  -326,  -326,
    -326,   239,  -326,   212,  -326,   113,   213,   -14,  -326,  -326,
    -326,   -14,   -14,   181,  -326,   242,   241,  -326,   246,   243,
     244,   179,  -326,  -326,   157,   214,  -326,  -326,   113,  -326,
      -1,  -326,   249,   245,  -326,   247,  -326,  -326,   215,  -326,
    -326,  -326,    -8,   254,   217,  -326,   -14,  -326,  -326,   160,
     242,   -21,   161,  -326,   246,   246,   251,  -326,  -326,  -326,
     252,  -326,   255,   256,  -326,  -326,   258,    -4,   259,   257,
     -12,    -9,  -326,    -2,  -326,   263,   253,   242,  -326,   164,
     -50,  -326,  -326,    68,  -326,   246,  -326,   165,   168,   246,
     264,   132,   267,  -326,   169,  -326,   240,  -326,  -326,   268,
     248,   266,   270,    10,   265,  -326,   172,  -326,  -326,   271,
    -326,  -326,  -326,   -50,  -326,  -326,  -326,  -326,   173,   269,
    -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,   273,
     274,   277,  -326,    -3,  -326,    30,  -326,   272,   250,  -326,
    -326,   176,  -326,   281,  -326,   119,  -326,  -326,  -326,  -326,
      98,   159,  -326,   260,  -326,  -326,   275,  -326,  -326,  -326,
    -326,  -326,  -326,  -326,  -326,    89,  -326,  -326,   -12,  -326,
    -326,   -48,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,
    -326,  -326,  -326,  -326,  -326,   282,  -326,  -326,  -326,  -326,
    -326,  -326,  -326,  -326,   283,  -326,   261,  -326,  -326,  -326,
     276,   278,    30,  -326,   262,  -326,  -326,   120,   280,  -326,
     -48,  -326,  -326,  -326,  -326,  -326,   279,  -326,  -326,    30,
    -326
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -326,  -326,  -326,  -326,   149,  -326,   134,  -116,  -326,  -326,
    -326,  -326,  -326,  -326,  -326,  -326,   219,  -326,    82,  -326,
    -326,  -326,  -326,  -326,   284,  -326,  -326,  -326,  -326,   285,
    -326,  -326,  -326,   103,    83,  -326,  -326,  -326,   286,  -326,
    -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,  -326,
    -326,  -326,  -326,  -326,  -326,  -326,  -326,   -23,  -326,  -326,
    -326,  -326,  -326,  -326,  -326,  -326,  -326,  -207,  -326,  -326,
    -326,   170,  -202,  -129,  -326,  -326,   167,  -142,  -139,  -168,
    -326,  -326,  -326,  -326,  -211,  -326,    11,  -326,  -325,  -326,
    -326,  -326,  -326,   -53,    13,   -26,  -326,  -326,  -326,  -326,
    -326,    48,   -47,  -326,  -326,  -326,  -326,  -326,   -90,  -326,
    -326,   -86,  -326,  -326,   171,    73,  -326,  -326,   174,  -154,
      40,  -177,  -326,  -326
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint16 yytable[] =
{
     172,   115,     1,   119,   176,     2,   257,     3,     4,     5,
       6,     7,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,   182,   160,   113,   234,   232,   108,
      95,   160,   225,   268,   289,   240,   322,   280,   156,   373,
     324,   103,   104,   105,   376,   325,   377,   157,   374,   160,
     281,   241,   324,    20,   378,   417,   379,   360,   149,   265,
     301,   302,   150,   160,   265,    21,   418,    73,   268,    22,
      80,    96,    23,    24,    25,   226,    26,    27,   174,   120,
     315,   215,    28,   109,   318,   110,   290,   290,   300,   301,
     302,   267,   266,   254,   175,   330,   171,   432,   265,   161,
     162,   216,   112,   217,    74,   438,   218,    81,    29,    30,
      84,    85,   123,    31,   440,   128,   132,   209,   366,   210,
     307,   308,   376,   332,   377,    86,   334,   219,   220,   149,
      64,   212,   378,   150,   379,    65,   395,   180,    67,   113,
     396,    87,   303,   106,   107,    88,   165,   166,   167,   124,
      89,   190,   129,   133,   394,   338,   367,   340,   341,   342,
     343,   344,   345,   346,   347,   225,   393,   191,   192,   193,
     194,   195,   196,   197,   198,   199,   200,   333,   301,   302,
      68,   245,   407,   246,    69,   348,   408,   409,   410,   411,
     412,   378,    70,   379,   398,   399,   400,    71,   401,   402,
     403,   248,   209,   249,   277,   297,   305,   298,   306,   297,
     305,   331,   336,   305,   351,   337,   352,   363,   305,   364,
     368,   363,    72,   390,    78,   434,   435,    77,    79,    94,
     101,   116,    99,   100,   136,   118,   138,   139,   166,   236,
     155,   141,   142,   143,   140,   145,   148,   144,   146,   147,
     153,   154,   159,   164,   173,   177,   178,   183,    74,    81,
     188,   204,   208,   113,    96,   222,   211,   223,   231,   167,
     239,   243,   276,   235,   238,   250,   252,   253,   247,   251,
     124,   256,   258,   213,   271,   259,   260,   270,   179,   274,
     275,   283,   285,   286,   287,   261,   294,   309,   310,   329,
     311,   312,   313,   263,   316,   328,   339,   317,   295,   350,
     356,   358,   289,   406,   244,   362,   369,   225,   370,   371,
     353,   372,   388,   324,   423,   425,   427,   278,   262,   430,
     436,   279,   413,   359,   224,   233,   361,   392,   357,   323,
     439,   416,   437,   299,   237,   335,   389,     0,     0,     0,
       0,   242,   426,     0,     0,     0,   433,     0,   405,     0,
       0,   186,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   435,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   187,     0,     0,
     189,     0,     0,     0,   207
};

static const yytype_int16 yycheck[] =
{
     129,    24,     1,     1,   133,     4,   213,     6,     7,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,   140,    46,    38,   169,   167,     1,
       1,    46,    46,   235,    42,    93,    45,    38,    42,    42,
      42,    65,    66,    67,    92,    47,    94,    51,    51,    46,
      51,   109,    42,    52,   102,   103,   104,    47,    38,   227,
     110,   111,    42,    46,   232,    64,   391,     1,   270,    68,
       1,    42,    71,    72,    73,    89,    75,    76,    93,    77,
     287,    38,    81,    55,    96,    57,    95,    95,   109,   110,
     111,   233,   231,   209,   109,   297,    93,   422,   266,    82,
      83,    58,     1,    60,    38,   430,    63,    38,   107,   108,
      23,    24,     1,   112,   439,     1,     1,    45,   329,    47,
     274,   275,    92,   300,    94,    38,   303,    84,    85,    38,
       5,   154,   102,    42,   104,    38,    38,    46,    42,    38,
      42,    54,   271,    69,    70,    58,    86,    87,    88,    38,
      63,    38,    38,    38,   365,   309,   333,    25,    26,    27,
      28,    29,    30,    31,    32,    46,    47,    54,    55,    56,
      57,    58,    59,    60,    61,    62,    63,   109,   110,   111,
      42,    45,    93,    47,    42,    53,    97,    98,    99,   100,
     101,   102,    42,   104,    35,    36,    37,    42,    39,    40,
      41,    45,    45,    47,    47,    45,    45,    47,    47,    45,
      45,    47,    47,    45,    45,    47,    47,    45,    45,    47,
      47,    45,    42,    47,    38,   105,   106,    44,    38,    42,
      46,    38,    44,    44,    38,    44,     0,    45,    87,    93,
      74,    46,    45,    45,    50,    45,    45,    48,    46,    46,
      46,    45,    45,    45,    45,    45,    45,    43,    38,    38,
      42,    38,    46,    38,    42,    83,    42,    82,    42,    88,
      93,    38,    93,    46,    46,    45,    45,    42,    49,    47,
      38,    47,    45,    78,    38,    47,    47,    46,   139,    46,
      46,    42,    47,    46,    79,    83,    42,    46,    46,    46,
      45,    45,    44,    90,    45,    42,    42,    50,    91,    42,
      42,    45,    42,    38,   180,    50,    47,    46,    45,    45,
      80,    44,    50,    42,    42,    42,    50,   245,   225,    51,
      50,   248,   385,   322,   164,   168,   323,   363,    90,   291,
     430,   388,   428,   270,   173,   305,    96,    -1,    -1,    -1,
      -1,   177,    91,    -1,    -1,    -1,    94,    -1,    98,    -1,
      -1,   142,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   106,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   143,    -1,    -1,
     145,    -1,    -1,    -1,   148
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     1,     4,     6,     7,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      52,    64,    68,    71,    72,    73,    75,    76,    81,   107,
     108,   112,   115,   116,   117,   122,   123,   124,   125,   126,
     127,   128,   133,   134,   135,   136,   139,   140,   141,   149,
     150,   160,   164,   165,   166,   167,   169,   172,   174,   175,
     183,   226,   230,   236,     5,    38,   118,    42,    42,    42,
      42,    42,    42,     1,    38,   129,   130,    44,    38,    38,
       1,    38,   137,   138,    23,    24,    38,    54,    58,    63,
     142,   143,   144,   145,    42,     1,    42,   151,   152,    44,
      44,    46,   161,    65,    66,    67,    69,    70,     1,    55,
      57,   168,     1,    38,   170,   171,    38,   173,    44,     1,
      77,   176,   177,     1,    38,   184,   185,   186,     1,    38,
     227,   228,     1,    38,   231,   232,    38,   237,     0,    45,
      50,    46,    45,    45,    48,    45,    46,    46,    45,    38,
      42,   120,   121,    46,    45,    74,    42,    51,   181,    45,
      46,    82,    83,   187,    45,    86,    87,    88,   189,   190,
     191,    93,   187,    45,    93,   109,   187,    45,    45,   118,
      46,   119,   121,    43,   131,   132,   130,   138,    42,   143,
      38,    54,    55,    56,    57,    58,    59,    60,    61,    62,
      63,   146,   147,   148,    38,   153,   154,   152,    46,    45,
      47,    42,   171,    78,   178,    38,    58,    60,    63,    84,
      85,   188,    83,    82,   185,    46,    89,   192,   193,   194,
     198,    42,   192,   190,   191,    46,    93,   228,    46,    93,
      93,   109,   232,    38,   120,    45,    47,    49,    45,    47,
      45,    47,    45,    42,   121,   162,    47,   181,    45,    47,
      47,    83,   147,    90,   195,   193,   192,   191,   186,   229,
      46,    38,   233,   234,    46,    46,    93,    47,   132,   148,
      38,    51,   155,    42,   158,    47,    46,    79,   179,    42,
      95,   199,   200,   215,    42,    91,   196,    45,    47,   229,
     109,   110,   111,   187,   235,    45,    47,   233,   233,    46,
      46,    45,    45,    44,   163,   181,    45,    50,    96,   171,
     216,   217,    45,   215,    42,    47,   208,   209,    42,    46,
     186,    47,   235,   109,   235,   234,    47,    47,   233,    42,
      25,    26,    27,    28,    29,    30,    31,    32,    53,   156,
      42,    45,    47,    80,   180,   201,    42,    90,    45,   200,
      47,   208,    50,    45,    47,   197,   198,   235,    47,    47,
      45,    45,    44,    42,    51,   182,    92,    94,   102,   104,
     202,   203,   204,   206,   207,   218,   221,   223,    50,    96,
      47,   210,   209,    47,   198,    38,    42,   157,    35,    36,
      37,    39,    40,    41,   159,    98,    38,    93,    97,    98,
      99,   100,   101,   207,   219,   220,   216,   103,   202,   211,
     212,   213,   222,    42,   205,    42,    91,    50,   224,   225,
      51,   214,   202,    94,   105,   106,    50,   225,   202,   222,
     202
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (priv_data, YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (&yylval, YYLEX_PARAM)
#else
# define YYLEX yylex (&yylval)
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value, priv_data); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, bsdl_parser_priv_t *priv_data)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, priv_data)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    bsdl_parser_priv_t *priv_data;
#endif
{
  if (!yyvaluep)
    return;
  YYUSE (priv_data);
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, bsdl_parser_priv_t *priv_data)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, priv_data)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    bsdl_parser_priv_t *priv_data;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep, priv_data);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule, bsdl_parser_priv_t *priv_data)
#else
static void
yy_reduce_print (yyvsp, yyrule, priv_data)
    YYSTYPE *yyvsp;
    int yyrule;
    bsdl_parser_priv_t *priv_data;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       , priv_data);
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule, priv_data); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, bsdl_parser_priv_t *priv_data)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, priv_data)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    bsdl_parser_priv_t *priv_data;
#endif
{
  YYUSE (yyvaluep);
  YYUSE (priv_data);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (bsdl_parser_priv_t *priv_data);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */






/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (bsdl_parser_priv_t *priv_data)
#else
int
yyparse (priv_data)
    bsdl_parser_priv_t *priv_data;
#endif
#endif
{
  /* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;

  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 23:
#line 256 "bsdl_bison.y"
    {
                     Print_Error( priv_data, _("Unsupported BSDL construct found") );
                     BUMP_ERROR;
                     YYABORT;
                   }
    break;

  case 27:
#line 272 "bsdl_bison.y"
    { free( (yyvsp[(1) - (3)].str) ); }
    break;

  case 32:
#line 281 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 33:
#line 283 "bsdl_bison.y"
    { free( (yyvsp[(1) - (4)].str) ); }
    break;

  case 40:
#line 309 "bsdl_bison.y"
    { priv_data->jtag_ctrl->instr_len = (yyvsp[(2) - (2)].integer); }
    break;

  case 44:
#line 318 "bsdl_bison.y"
    {
                        Print_Error( priv_data,
                                     _("Error in Instruction_Opcode attribute statement") );
                        BUMP_ERROR;
                        YYABORT;
                      }
    break;

  case 45:
#line 326 "bsdl_bison.y"
    { add_instruction( priv_data, (yyvsp[(1) - (4)].str), (yyvsp[(3) - (4)].str) ); }
    break;

  case 46:
#line 329 "bsdl_bison.y"
    { (yyval.str) = (yyvsp[(1) - (1)].str); }
    break;

  case 47:
#line 331 "bsdl_bison.y"
    {
                        Print_Warning( priv_data,
                                       _("Multiple opcode patterns are not supported, first pattern will be used") );
                        (yyval.str) = (yyvsp[(1) - (3)].str);
                        free( (yyvsp[(3) - (3)].str) );
                      }
    break;

  case 48:
#line 339 "bsdl_bison.y"
    { (yyval.str) = (yyvsp[(1) - (1)].str); }
    break;

  case 49:
#line 344 "bsdl_bison.y"
    { free( (yyvsp[(2) - (2)].str) ); }
    break;

  case 50:
#line 349 "bsdl_bison.y"
    { free( (yyvsp[(2) - (2)].str) ); }
    break;

  case 51:
#line 354 "bsdl_bison.y"
    { free( (yyvsp[(2) - (2)].str) ); }
    break;

  case 55:
#line 363 "bsdl_bison.y"
    {
                        Print_Error( priv_data, _("Error in Opcode List") );
                        BUMP_ERROR;
                        YYABORT;
                      }
    break;

  case 56:
#line 370 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 57:
#line 375 "bsdl_bison.y"
    { priv_data->jtag_ctrl->idcode = (yyvsp[(2) - (2)].str); }
    break;

  case 58:
#line 380 "bsdl_bison.y"
    { priv_data->jtag_ctrl->usercode = (yyvsp[(2) - (2)].str); }
    break;

  case 62:
#line 390 "bsdl_bison.y"
    { ac_apply_assoc( priv_data ); }
    break;

  case 63:
#line 393 "bsdl_bison.y"
    { ac_set_register( priv_data, (yyvsp[(1) - (1)].str), 0 ); }
    break;

  case 64:
#line 395 "bsdl_bison.y"
    { ac_set_register( priv_data, (yyvsp[(1) - (4)].str), (yyvsp[(3) - (4)].integer) ); }
    break;

  case 65:
#line 398 "bsdl_bison.y"
    { (yyval.str) = strdup( "BOUNDARY" ); }
    break;

  case 66:
#line 400 "bsdl_bison.y"
    { (yyval.str) = strdup( "BYPASS" ); }
    break;

  case 67:
#line 402 "bsdl_bison.y"
    { (yyval.str) = strdup( "IDCODE" ); }
    break;

  case 68:
#line 404 "bsdl_bison.y"
    { (yyval.str) = strdup( "USERCODE" ); }
    break;

  case 69:
#line 406 "bsdl_bison.y"
    { (yyval.str) = strdup( "DEVICE_ID" ); }
    break;

  case 72:
#line 412 "bsdl_bison.y"
    { (yyval.str) = strdup( "BYPASS" ); }
    break;

  case 73:
#line 414 "bsdl_bison.y"
    { (yyval.str) = strdup( "CLAMP" ); }
    break;

  case 74:
#line 416 "bsdl_bison.y"
    { (yyval.str) = strdup( "EXTEST" ); }
    break;

  case 75:
#line 418 "bsdl_bison.y"
    { (yyval.str) = strdup( "HIGHZ" ); }
    break;

  case 76:
#line 420 "bsdl_bison.y"
    { (yyval.str) = strdup( "IDCODE" ); }
    break;

  case 77:
#line 422 "bsdl_bison.y"
    { (yyval.str) = strdup( "INTEST" ); }
    break;

  case 78:
#line 424 "bsdl_bison.y"
    { (yyval.str) = strdup( "PRELOAD" ); }
    break;

  case 79:
#line 426 "bsdl_bison.y"
    { (yyval.str) = strdup( "RUNBIST" ); }
    break;

  case 80:
#line 428 "bsdl_bison.y"
    { (yyval.str) = strdup( "SAMPLE" ); }
    break;

  case 81:
#line 430 "bsdl_bison.y"
    { (yyval.str) = strdup( "USERCODE" ); }
    break;

  case 82:
#line 432 "bsdl_bison.y"
    { (yyval.str) = (yyvsp[(1) - (1)].str); }
    break;

  case 83:
#line 435 "bsdl_bison.y"
    { ac_add_instruction( priv_data, (yyvsp[(1) - (1)].str) ); }
    break;

  case 84:
#line 441 "bsdl_bison.y"
    { priv_data->jtag_ctrl->bsr_len = (yyvsp[(2) - (2)].integer); }
    break;

  case 88:
#line 450 "bsdl_bison.y"
    {Print_Error( priv_data, _("Error in Boundary Cell description") );
                   BUMP_ERROR; YYABORT; }
    break;

  case 89:
#line 454 "bsdl_bison.y"
    { ci_append_cell_info( priv_data, (yyvsp[(1) - (4)].integer) ); }
    break;

  case 90:
#line 457 "bsdl_bison.y"
    { ci_no_disable( priv_data ); }
    break;

  case 92:
#line 462 "bsdl_bison.y"
    {
                    free( (yyvsp[(1) - (7)].str) );
                    ci_set_cell_spec( priv_data, (yyvsp[(5) - (7)].integer), (yyvsp[(7) - (7)].str) );
                  }
    break;

  case 93:
#line 468 "bsdl_bison.y"
    {
                    prt_add_name( priv_data, (yyvsp[(1) - (1)].str) );
                    prt_add_bit( priv_data );
                  }
    break;

  case 94:
#line 473 "bsdl_bison.y"
    {
                    prt_add_name( priv_data, (yyvsp[(1) - (4)].str) );
                    prt_add_range( priv_data, (yyvsp[(3) - (4)].integer), (yyvsp[(3) - (4)].integer) );
                  }
    break;

  case 95:
#line 478 "bsdl_bison.y"
    {
                    prt_add_name( priv_data, strdup( "*" ) );
                    prt_add_bit( priv_data );
                  }
    break;

  case 96:
#line 484 "bsdl_bison.y"
    { (yyval.integer) = INPUT; }
    break;

  case 97:
#line 486 "bsdl_bison.y"
    { (yyval.integer) = OUTPUT2; }
    break;

  case 98:
#line 488 "bsdl_bison.y"
    { (yyval.integer) = OUTPUT3; }
    break;

  case 99:
#line 490 "bsdl_bison.y"
    { (yyval.integer) = CONTROL; }
    break;

  case 100:
#line 492 "bsdl_bison.y"
    { (yyval.integer) = CONTROLR; }
    break;

  case 101:
#line 494 "bsdl_bison.y"
    { (yyval.integer) = INTERNAL; }
    break;

  case 102:
#line 496 "bsdl_bison.y"
    { (yyval.integer) = CLOCK; }
    break;

  case 103:
#line 498 "bsdl_bison.y"
    { (yyval.integer) = BIDIR; }
    break;

  case 104:
#line 500 "bsdl_bison.y"
    { (yyval.integer) = OBSERVE_ONLY; }
    break;

  case 105:
#line 503 "bsdl_bison.y"
    { (yyval.str) = (yyvsp[(1) - (1)].str); }
    break;

  case 106:
#line 505 "bsdl_bison.y"
    {
                    char *tmp;
                    tmp = (char *)malloc( 2 );
                    snprintf( tmp, 2, "%i", (yyvsp[(1) - (1)].integer) );
	            tmp[1] = '\0';
                    (yyval.str) = tmp;
                  }
    break;

  case 107:
#line 514 "bsdl_bison.y"
    { ci_set_cell_spec_disable( priv_data, (yyvsp[(1) - (5)].integer), (yyvsp[(3) - (5)].integer), (yyvsp[(5) - (5)].integer) ); }
    break;

  case 108:
#line 517 "bsdl_bison.y"
    { (yyval.integer) = Z; }
    break;

  case 109:
#line 519 "bsdl_bison.y"
    { (yyval.integer) = WEAK0; }
    break;

  case 110:
#line 521 "bsdl_bison.y"
    { (yyval.integer) = WEAK1; }
    break;

  case 111:
#line 523 "bsdl_bison.y"
    { (yyval.integer) = PULL0; }
    break;

  case 112:
#line 525 "bsdl_bison.y"
    { (yyval.integer) = PULL1; }
    break;

  case 113:
#line 527 "bsdl_bison.y"
    { (yyval.integer) = KEEPER; }
    break;

  case 115:
#line 534 "bsdl_bison.y"
    { bsdl_flex_set_bin_x( priv_data->scanner ); }
    break;

  case 117:
#line 538 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 118:
#line 540 "bsdl_bison.y"
    { free( (yyvsp[(3) - (3)].str) ); }
    break;

  case 119:
#line 545 "bsdl_bison.y"
    { priv_data->jtag_ctrl->conformance = CONF_1990; }
    break;

  case 120:
#line 547 "bsdl_bison.y"
    { priv_data->jtag_ctrl->conformance = CONF_1993; }
    break;

  case 121:
#line 549 "bsdl_bison.y"
    { priv_data->jtag_ctrl->conformance = CONF_2001; }
    break;

  case 137:
#line 573 "bsdl_bison.y"
    {
                        Print_Error( priv_data, _("Error in ISC_Pin_Behavior Definition") );
                        BUMP_ERROR;
                        YYABORT;
                      }
    break;

  case 141:
#line 585 "bsdl_bison.y"
    {
                          Print_Error( priv_data, _("Error in ISC_Fixed_System_Pins Definition") );
                          BUMP_ERROR;
                          YYABORT;
                        }
    break;

  case 142:
#line 592 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 143:
#line 594 "bsdl_bison.y"
    { free( (yyvsp[(1) - (4)].str) ); }
    break;

  case 146:
#line 601 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 147:
#line 605 "bsdl_bison.y"
    { free( (yyvsp[(2) - (2)].str) ); }
    break;

  case 150:
#line 612 "bsdl_bison.y"
    {
                    Print_Error( priv_data, _("Error in ISC_Security Definition") );
                    BUMP_ERROR;
                    YYABORT;
                  }
    break;

  case 169:
#line 646 "bsdl_bison.y"
    {
                           Print_Error( priv_data, _("Error in ISC_Flow Definition") );
                           BUMP_ERROR;
                           YYABORT;
                         }
    break;

  case 170:
#line 653 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 171:
#line 655 "bsdl_bison.y"
    { free( (yyvsp[(1) - (2)].str) ); }
    break;

  case 172:
#line 657 "bsdl_bison.y"
    { free( (yyvsp[(1) - (3)].str) ); }
    break;

  case 173:
#line 659 "bsdl_bison.y"
    { free( (yyvsp[(1) - (4)].str) ); }
    break;

  case 174:
#line 661 "bsdl_bison.y"
    { free( (yyvsp[(1) - (2)].str) ); }
    break;

  case 175:
#line 663 "bsdl_bison.y"
    { free( (yyvsp[(1) - (3)].str) ); }
    break;

  case 176:
#line 665 "bsdl_bison.y"
    { free( (yyvsp[(1) - (2)].str) ); }
    break;

  case 178:
#line 669 "bsdl_bison.y"
    { free( (yyvsp[(2) - (3)].str) ); }
    break;

  case 197:
#line 696 "bsdl_bison.y"
    { free( (yyvsp[(2) - (4)].str) ); }
    break;

  case 198:
#line 698 "bsdl_bison.y"
    { free( (yyvsp[(2) - (5)].str) ); }
    break;

  case 199:
#line 700 "bsdl_bison.y"
    { free( (yyvsp[(2) - (5)].str) ); }
    break;

  case 200:
#line 702 "bsdl_bison.y"
    { free( (yyvsp[(2) - (6)].str) ); }
    break;

  case 204:
#line 709 "bsdl_bison.y"
    { bsdl_flex_set_hex( priv_data->scanner ); }
    break;

  case 205:
#line 711 "bsdl_bison.y"
    { bsdl_flex_set_decimal( priv_data->scanner ); }
    break;

  case 206:
#line 714 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 212:
#line 723 "bsdl_bison.y"
    { bsdl_flex_set_hex( priv_data->scanner ); }
    break;

  case 213:
#line 725 "bsdl_bison.y"
    {
                           free( (yyvsp[(4) - (4)].str) );
                           bsdl_flex_set_decimal( priv_data->scanner );
                         }
    break;

  case 221:
#line 741 "bsdl_bison.y"
    { bsdl_flex_set_hex( priv_data->scanner ); }
    break;

  case 222:
#line 743 "bsdl_bison.y"
    { bsdl_flex_set_decimal( priv_data->scanner ); }
    break;

  case 241:
#line 769 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 242:
#line 771 "bsdl_bison.y"
    { free( (yyvsp[(3) - (3)].str) ); }
    break;

  case 244:
#line 776 "bsdl_bison.y"
    { free( (yyvsp[(2) - (2)].str) ); }
    break;

  case 245:
#line 779 "bsdl_bison.y"
    { bsdl_flex_set_decimal( priv_data->scanner ); }
    break;

  case 246:
#line 781 "bsdl_bison.y"
    { bsdl_flex_set_decimal( priv_data->scanner ); }
    break;

  case 247:
#line 783 "bsdl_bison.y"
    { bsdl_flex_set_decimal( priv_data->scanner ); }
    break;

  case 248:
#line 785 "bsdl_bison.y"
    { bsdl_flex_set_decimal( priv_data->scanner ); }
    break;

  case 258:
#line 806 "bsdl_bison.y"
    { free( (yyvsp[(1) - (5)].str) ); }
    break;

  case 259:
#line 808 "bsdl_bison.y"
    { free( (yyvsp[(1) - (6)].str) ); }
    break;

  case 260:
#line 810 "bsdl_bison.y"
    {
                         Print_Error( priv_data, _("Error in ISC_Procedure Definition") );
                         BUMP_ERROR;
                         YYABORT;
                       }
    break;

  case 266:
#line 826 "bsdl_bison.y"
    { free( (yyvsp[(1) - (5)].str) ); }
    break;

  case 267:
#line 828 "bsdl_bison.y"
    { free( (yyvsp[(1) - (6)].str) ); }
    break;

  case 268:
#line 830 "bsdl_bison.y"
    { free( (yyvsp[(1) - (6)].str) ); }
    break;

  case 269:
#line 832 "bsdl_bison.y"
    { free( (yyvsp[(1) - (7)].str) ); }
    break;

  case 270:
#line 834 "bsdl_bison.y"
    {
                              Print_Error( priv_data, _("Error in ISC_Action Definition") );
                              BUMP_ERROR;
                              YYABORT;
                            }
    break;

  case 273:
#line 844 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 274:
#line 846 "bsdl_bison.y"
    { free( (yyvsp[(1) - (2)].str) ); }
    break;

  case 275:
#line 848 "bsdl_bison.y"
    { free( (yyvsp[(1) - (3)].str) ); }
    break;

  case 276:
#line 850 "bsdl_bison.y"
    { free( (yyvsp[(1) - (3)].str) ); }
    break;

  case 277:
#line 852 "bsdl_bison.y"
    { free( (yyvsp[(1) - (4)].str) ); }
    break;

  case 278:
#line 854 "bsdl_bison.y"
    { free( (yyvsp[(1) - (2)].str) ); }
    break;

  case 279:
#line 856 "bsdl_bison.y"
    { free( (yyvsp[(1) - (3)].str) ); }
    break;

  case 280:
#line 858 "bsdl_bison.y"
    { free( (yyvsp[(1) - (2)].str) ); }
    break;

  case 284:
#line 866 "bsdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 285:
#line 868 "bsdl_bison.y"
    { free( (yyvsp[(3) - (3)].str) ); }
    break;


/* Line 1267 of yacc.c.  */
#line 2765 "bsdl_bison.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (priv_data, YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (priv_data, yymsg);
	  }
	else
	  {
	    yyerror (priv_data, YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval, priv_data);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp, priv_data);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (priv_data, YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, priv_data);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, priv_data);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 870 "bsdl_bison.y"
  /* End rules, begin programs  */
/*----------------------------------------------------------------------*/
static void Print_Error( bsdl_parser_priv_t *priv_data, const char *Errmess )
{
  bsdl_msg( priv_data->jtag_ctrl->proc_mode,
            BSDL_MSG_ERR, _("Line %d, %s.\n"),
            priv_data->lineno,
            Errmess );
}
/*----------------------------------------------------------------------*/
static void Print_Warning( bsdl_parser_priv_t *priv_data, const char *Warnmess )
{
  bsdl_msg( priv_data->jtag_ctrl->proc_mode,
            BSDL_MSG_WARN, _("Line %d, %s.\n"),
            priv_data->lineno,
            Warnmess );
}
/*----------------------------------------------------------------------*/
static void Give_Up_And_Quit( bsdl_parser_priv_t *priv_data )
{
  //Print_Error( priv_data, "Too many errors" );
  bsdl_flex_stop_buffer( priv_data->scanner );
}
/*----------------------------------------------------------------------*/
void yyerror( bsdl_parser_priv_t *priv_data, const char *error_string )
{
}


/*****************************************************************************
 * void bsdl_sem_init( bsdl_parser_priv_t *priv )
 *
 * Initializes storage elements in the private parser and jtag control
 * structures that are used for semantic purposes.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *
 * Returns
 *   void
 ****************************************************************************/
static void bsdl_sem_init( bsdl_parser_priv_t *priv )
{
  jtag_ctrl_t *jc = priv->jtag_ctrl;

  jc->instr_len   = -1;
  jc->bsr_len     = -1;
  jc->conformance = CONF_UNKNOWN;
  jc->idcode      = NULL;
  jc->usercode    = NULL;

  jc->instr_list = NULL;

  priv->ainfo.next       = NULL;
  priv->ainfo.reg        = NULL;
  priv->ainfo.instr_list = NULL;
  jc->ainfo_list         = NULL;

  priv->tmp_cell_info.next             = NULL;
  priv->tmp_cell_info.port_name        = NULL;
  priv->tmp_cell_info.basic_safe_value = NULL;
  jc->cell_info_first                  = NULL;
  jc->cell_info_last                   = NULL;

  priv->tmp_port_desc.names_list = NULL;
  priv->tmp_port_desc.next       = NULL;
}


/*****************************************************************************
 * void free_instr_list( struct instr_elem *il )
 *
 * Deallocates the given list of instr_elem.
 *
 * Parameters
 *   il : first instr_elem to deallocate
 *
 * Returns
 *   void
 ****************************************************************************/
static void free_instr_list( instr_elem_t *il )
{
  if (il)
  {
    if (il->instr)
      free( il->instr );
    if (il->opcode)
      free( il->opcode );
    free_instr_list( il->next );
    free( il );
  }
}


/*****************************************************************************
 * void free_ainfo_list( ainfo_elem_t *ai, int free_me )
 *
 * Deallocates the given list of ainfo_elem.
 *
 * Parameters
 *  ai      : first ainfo_elem to deallocate
 *  free_me : set to 1 to free memory for ai as well
 *
 * Returns
 *  void
 ****************************************************************************/
static void free_ainfo_list( ainfo_elem_t *ai, int free_me )
{
  if (ai)
  {
    if (ai->reg)
      free( ai->reg );

    free_instr_list( ai->instr_list );
    free_ainfo_list( ai->next, 1 );

    if (free_me)
      free( ai );
  }
}


/*****************************************************************************
 * void free_string_list( string_elem_t *sl )
 *
 * Deallocates the given list of string_elem items.
 *
 * Parameters
 *  sl : first string_elem to deallocate
 *
 * Returns
 *  void
 ****************************************************************************/
static void free_string_list( string_elem_t *sl) 
{
  if (sl)
  {
    if (sl->string)
      free( sl->string );
    free_string_list( sl->next );
    free( sl );
  }
}


/*****************************************************************************
 * void free_c_list( cell_info_t *ci, int free_me )
 *
 * Deallocates the given list of cell_info items.
 *
 * Parameters
 *  ci      : first cell_info item to deallocate
 *  free_me : 1 -> free memory for *ci as well
 *            0 -> don't free *ci memory
 *
 * Returns
 *  void
 ****************************************************************************/
static void free_ci_list( cell_info_t *ci, int free_me )
{
  if (ci)
  {
    free_ci_list( ci->next, 1 );

    if (ci->port_name)
      free( ci->port_name );

    if (ci->basic_safe_value)
      free( ci->basic_safe_value );

    if (free_me)
      free( ci );
  }
}


/*****************************************************************************
 * void bsdl_sem_deinit( bsdl_parser_priv_t *priv )
 *
 * Frees and deinitializes storage elements in the private parser and
 * jtag control structures that were filled by semantic rules.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *
 * Returns
 *   void
 ****************************************************************************/
static void bsdl_sem_deinit( bsdl_parser_priv_t *priv )
{
  jtag_ctrl_t *jc = priv->jtag_ctrl;

  if (jc->idcode)
  {
    free( jc->idcode );
    jc->idcode = NULL;
  }

  if (jc->usercode)
  {
    free( jc->usercode );
    jc->usercode = NULL;
  }

  /* free cell_info list */
  free_ci_list( jc->cell_info_first, 1 );
  jc->cell_info_first = jc->cell_info_last = NULL;
  free_ci_list( &(priv->tmp_cell_info), 0 );

  /* free instr_list */
  free_instr_list( jc->instr_list );
  jc->instr_list = NULL;

  /* free ainfo_list */
  free_ainfo_list( jc->ainfo_list, 1 );
  jc->ainfo_list = NULL;
  free_ainfo_list( &(priv->ainfo), 0 );

  /* free string list in temporary port descritor */
  free_string_list( priv->tmp_port_desc.names_list );
  priv->tmp_port_desc.names_list = NULL;
}


/*****************************************************************************
 * bsdl_parser_priv_t *bsdl_parser_init( jtag_ctrl_t *jtag_ctrl )
 *
 * Initializes storage elements in the private parser structure that are
 * used for parser maintenance purposes.
 * Subsequently calls initializer functions for the scanner and the semantic 
 * parts.
 *
 * Parameters
 *   jtag_ctrl : pointer to jtag control structure
 *
 * Returns
 *   pointer to private parser structure
 ****************************************************************************/
bsdl_parser_priv_t *bsdl_parser_init( jtag_ctrl_t *jtag_ctrl )
{
  bsdl_parser_priv_t *new_priv;

  if (!(new_priv = (bsdl_parser_priv_t *)malloc( sizeof( bsdl_parser_priv_t ) ))) {
    bsdl_msg( jtag_ctrl->proc_mode,
              BSDL_MSG_ERR, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
    return NULL;
  }

  new_priv->jtag_ctrl = jtag_ctrl;

  if (!(new_priv->scanner = bsdl_flex_init( jtag_ctrl->proc_mode ))) {
    free(new_priv);
    new_priv = NULL;
  }

  bsdl_sem_init( new_priv );

  return new_priv;
}


/*****************************************************************************
 * void bsdl_parser_deinit( bsdl_parser_priv_t *priv )
 *
 * Frees storage elements in the private parser structure that are
 * used for parser maintenance purposes.
 * Subsequently calls deinitializer functions for the scanner and the semantic
 * parts.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *
 * Returns
 *   void
 ****************************************************************************/
void bsdl_parser_deinit( bsdl_parser_priv_t *priv_data )
{
  bsdl_sem_deinit( priv_data );
  bsdl_flex_deinit( priv_data->scanner );
  free( priv_data );
}


/*****************************************************************************
 * void add_instruction( bsdl_parser_priv_t *priv, char *instr, char *opcode )
 *
 * Converts the instruction specification into a member of the main
 * list of instructions at priv->jtag_ctrl->instr_list.
 *
 * Parameters
 *   priv   : private data container for parser related tasks
 *   instr  : instruction name
 *   opcode : instruction opcode
 *
 * Returns
 *   void
 ****************************************************************************/
static void add_instruction( bsdl_parser_priv_t *priv, char *instr, char *opcode )
{
  instr_elem_t *new_instr;

  new_instr = (instr_elem_t *)malloc( sizeof( instr_elem_t ) );
  if (new_instr)
  {
    new_instr->next   = priv->jtag_ctrl->instr_list;
    new_instr->instr  = instr;
    new_instr->opcode = opcode;

    priv->jtag_ctrl->instr_list = new_instr;
  }
  else
    bsdl_msg( priv->jtag_ctrl->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}


/*****************************************************************************
 * void ac_set_register( bsdl_parser_priv_t *priv, char *reg, int reg_len )
 * Register Access management function
 *
 * Stores the register specification values for the current register access
 * specification in the temporary storage region for later usage.
 *
 * Parameters
 *   priv    : private data container for parser related tasks
 *   reg     : register name
 *   reg_len : optional register length
 *
 * Returns
 *   void
 ****************************************************************************/
static void ac_set_register( bsdl_parser_priv_t *priv, char *reg, int reg_len )
{
  ainfo_elem_t *tmp_ai = &(priv->ainfo);

  tmp_ai->reg     = reg;
  tmp_ai->reg_len = reg_len;
}


/*****************************************************************************
 * void ac_add_instruction( bsdl_parser_priv_t *priv, char *instr )
 * Register Access management function
 *
 * Appends the specified instruction to the list of instructions for the
 * current register access specification in the temporary storage region
 * for later usage.
 *
 * Parameters
 *   priv  : private data container for parser related tasks
 *   instr : instruction name
 *
 * Returns
 *   void
 ****************************************************************************/
static void ac_add_instruction( bsdl_parser_priv_t *priv, char *instr )
{
  ainfo_elem_t *tmp_ai = &(priv->ainfo);
  instr_elem_t *new_instr;

  new_instr = (instr_elem_t *)malloc( sizeof( instr_elem_t ) );
  if (new_instr)
  {
    new_instr->next   = tmp_ai->instr_list;
    new_instr->instr  = instr;
    new_instr->opcode = NULL;

    tmp_ai->instr_list = new_instr;
  }
  else
    bsdl_msg( priv->jtag_ctrl->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}


/*****************************************************************************
 * void ac_apply_assoc( bsdl_parser_priv_t *priv )
 * Register Access management function
 *
 * Appends the collected register access specification from the temporary
 * storage region to the main ainfo list.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *
 * Returns
 *   void
 ****************************************************************************/
static void ac_apply_assoc( bsdl_parser_priv_t *priv )
{
  jtag_ctrl_t  *jc = priv->jtag_ctrl;
  ainfo_elem_t *tmp_ai = &(priv->ainfo);
  ainfo_elem_t *new_ai;

  new_ai = (ainfo_elem_t *)malloc( sizeof( ainfo_elem_t ) );
  if (new_ai)
  {
    new_ai->next       = jc->ainfo_list;
    new_ai->reg        = tmp_ai->reg;
    new_ai->reg_len    = tmp_ai->reg_len;
    new_ai->instr_list = tmp_ai->instr_list;

    jc->ainfo_list = new_ai;
  }
  else
    bsdl_msg( jc->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );

  /* clean up obsolete temporary entries */
  tmp_ai->reg        = NULL;
  tmp_ai->reg_len    = 0;
  tmp_ai->instr_list = NULL;
}


/*****************************************************************************
 * void prt_add_name( bsdl_parser_priv_t *priv, char *name )
 * Port name management function
 *
 * Sets the name field of the temporary storage area for port description
 * (port_desc) to the parameter name.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *   name : base name of the port, memory get's free'd lateron
 *
 * Returns
 *   void
 ****************************************************************************/
static void prt_add_name( bsdl_parser_priv_t *priv, char *name )
{
  port_desc_t *pd = &(priv->tmp_port_desc);
  string_elem_t *new_string;

  new_string = (string_elem_t *)malloc( sizeof( string_elem_t ) );
  if (new_string)
  {
    new_string->next   = pd->names_list;
    new_string->string = name;

    pd->names_list = new_string;
  }
  else
    bsdl_msg( priv->jtag_ctrl->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}


/*****************************************************************************
 * void prt_add_bit( bsdl_parser_priv_t *priv )
 * Port name management function
 *
 * Sets the vector and index fields of the temporary storage area for port
 * description (port_desc) to non-vector information. The low and high indice
 * are set to equal numbers (exact value is irrelevant).
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *
 * Returns
 *   void
 ****************************************************************************/
static void prt_add_bit( bsdl_parser_priv_t *priv )
{
  port_desc_t *pd = &(priv->tmp_port_desc);

  pd->is_vector = 0;
  pd->low_idx   = 0;
  pd->high_idx  = 0;
}


/*****************************************************************************
 * void prt_add_range( bsdl_parser_priv_t *priv, int low, int high )
 * Port name management function
 *
 * Sets the vector and index fields of the temporary storage area for port
 * description (port_desc) to the specified vector information.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *   low  : low index of vector
 *   high : high index of vector
 *
 * Returns
 *   void
 ****************************************************************************/
static void prt_add_range( bsdl_parser_priv_t *priv, int low, int high )
{
  port_desc_t *pd = &(priv->tmp_port_desc);

  pd->is_vector = 1;
  pd->low_idx   = low;
  pd->high_idx  = high;
}


/*****************************************************************************
 * void ci_no_disable( bsdl_parser_priv_t *priv )
 * Cell Info management function
 *
 * Tracks that there is no disable term for the current cell info.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *
 * Returns
 *   void
 ****************************************************************************/
static void ci_no_disable( bsdl_parser_priv_t *priv )
{
  priv->tmp_cell_info.ctrl_bit_num = -1;
}


/*****************************************************************************
 * void ci_set_cell_spec_disable( bsdl_parser_priv_t *priv, int ctrl_bit_num,
 *                                int safe_value, int disable_value )
 * Cell Info management function
 *
 * Applies the disable specification of the current cell spec to the variables
 * for temporary storage of these information elements.
 *
 * Parameters
 *   priv          : private data container for parser related tasks
 *   ctrl_bit_num  : bit number of related control cell
 *   safe_value    : safe value for initialization of this cell
 *   disable_value : currently ignored
 *
 * Returns
 *   void
 ****************************************************************************/
static void ci_set_cell_spec_disable( bsdl_parser_priv_t *priv, int ctrl_bit_num,
                                      int safe_value, int disable_value )
{
  cell_info_t *ci = &(priv->tmp_cell_info);

  ci->ctrl_bit_num       = ctrl_bit_num;
  ci->disable_safe_value = safe_value;
  /* disable value is ignored at the moment */
}


/*****************************************************************************
 * void ci_set_cell_spec( bsdl_parser_priv_t *priv,
 *                        int function, char *safe_value )
 * Cell Info management function
 *
 * Sets the specified values of the current cell_spec (without disable term)
 * to the variables for temporary storage of these information elements.
 * The name of the related port is taken from the port_desc structure that
 * was filled in previously by the rule Port_Name.
 *
 * Parameters
 *   priv       : private data container for parser related tasks
 *   function   : cell function indentificator
 *   safe_value : safe value for initialization of this cell
 *
 * Returns
 *   void
 ****************************************************************************/
static void ci_set_cell_spec( bsdl_parser_priv_t *priv,
                              int function, char *safe_value )
{
  cell_info_t *ci     = &(priv->tmp_cell_info);
  port_desc_t *pd     = &(priv->tmp_port_desc);
  string_elem_t *name = priv->tmp_port_desc.names_list;
  char   *port_string;
  size_t  str_len, name_len;

  ci->cell_function    = function;
  ci->basic_safe_value = safe_value;

  /* handle indexed port name:
   - names of scalar ports are simply copied from the port_desc structure
     to the final string that goes into ci
   - names of vectored ports are expanded with their decimal index as
     collected earlier earlier in rule Port_Name
  */
  name_len = strlen( name->string );
  str_len = name_len + 1 + 10 + 1 + 1;
  if ((port_string = (char *)malloc( str_len )) != NULL)
  {
    if (pd->is_vector)
      snprintf( port_string, str_len-1, "%s(%d)", name->string, pd->low_idx );
    else
      strncpy( port_string, name->string, str_len-1 );
    port_string[str_len-1] = '\0';

    ci->port_name = port_string;
  }
  else
  {
    bsdl_msg( priv->jtag_ctrl->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
    ci->port_name = NULL;
  }

  free_string_list( priv->tmp_port_desc.names_list );
  priv->tmp_port_desc.names_list = NULL;
}


/*****************************************************************************
 * void ci_append_cell_info( bsdl_parser_priv_t *priv, int bit_num )
 * Cell Info management function
 *
 * Appends the temporary cell info to the global list of cell infos.
 *
 * Parameters
 *   priv    : private data container for parser related tasks
 *   bit_num : bit number of current cell
 *
 * Returns
 *   void
 ****************************************************************************/
static void ci_append_cell_info( bsdl_parser_priv_t *priv, int bit_num )
{
  cell_info_t *tmp_ci = &(priv->tmp_cell_info);
  cell_info_t *ci;
  jtag_ctrl_t *jc     = priv->jtag_ctrl;

  ci = (cell_info_t *)malloc( sizeof( cell_info_t ) );
  if (ci)
  {
    ci->next = NULL;
    if (jc->cell_info_last)
      jc->cell_info_last->next = ci;
    else
      jc->cell_info_first = ci;
    jc->cell_info_last = ci;

    ci->bit_num            = bit_num;
    ci->port_name          = tmp_ci->port_name;
    ci->cell_function      = tmp_ci->cell_function;
    ci->basic_safe_value   = tmp_ci->basic_safe_value;
    ci->ctrl_bit_num       = tmp_ci->ctrl_bit_num;
    ci->disable_safe_value = tmp_ci->disable_safe_value;

    tmp_ci->port_name        = NULL;
    tmp_ci->basic_safe_value = NULL;
  }
  else
    bsdl_msg( jc->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}


/*
 Local Variables:
 mode:C
 c-default-style:gnu
 indent-tabs-mode:nil
 End:
*/

