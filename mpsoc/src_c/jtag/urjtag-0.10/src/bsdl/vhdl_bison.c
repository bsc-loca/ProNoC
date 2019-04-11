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
#define yyparse vhdlparse
#define yylex   vhdllex
#define yyerror vhdlerror
#define yylval  vhdllval
#define yychar  vhdlchar
#define yydebug vhdldebug
#define yynerrs vhdlnerrs


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




/* Copy the first part of user declarations.  */
#line 125 "vhdl_bison.y"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>

#include "bsdl_sysdep.h"

#include "bsdl_types.h"
#include "bsdl_msg.h"

/* interface to flex */
#include "vhdl_bison.h"
#include "vhdl_parser.h"

#ifdef DMALLOC
#include "dmalloc.h"
#endif

#define YYLEX_PARAM priv_data->scanner
int yylex (YYSTYPE *, void *);

#if 1
#define ERROR_LIMIT 15
#define BUMP_ERROR if (vhdl_flex_postinc_compile_errors( priv_data->scanner ) > ERROR_LIMIT) \
                          {Give_Up_And_Quit( priv_data );YYABORT;}
#else
#define BUMP_ERROR {Give_Up_And_Quit( priv_data );YYABORT;}
#endif

static void Init_Text( vhdl_parser_priv_t * );
static void Store_Text( vhdl_parser_priv_t *, char * );
static void Print_Error( vhdl_parser_priv_t *, const char * );
static void Give_Up_And_Quit( vhdl_parser_priv_t * );

/* VHDL semantic action interface */
static void vhdl_set_entity( vhdl_parser_priv_t *, char * );
static void vhdl_port_add_name( vhdl_parser_priv_t *, char * );
static void vhdl_port_add_bit( vhdl_parser_priv_t * );
static void vhdl_port_add_range( vhdl_parser_priv_t *, int, int );
static void vhdl_port_apply_port( vhdl_parser_priv_t * );

//static void set_attr_bool( vhdl_parser_priv_t *, char *, int );
static void set_attr_decimal( vhdl_parser_priv_t *, char *, int );
static void set_attr_string( vhdl_parser_priv_t *, char *, char * );
//static void set_attr_real( vhdl_parser_priv_t *, char *, char * );
//static void set_attr_const( vhdl_parser_priv_t *, char *, char * );

void yyerror( vhdl_parser_priv_t *, const char * );


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
#line 177 "vhdl_bison.y"
{
  int   integer;
  char *str;
}
/* Line 187 of yacc.c.  */
#line 320 "vhdl_bison.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 333 "vhdl_bison.c"

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
#define YYFINAL  6
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   310

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  81
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  65
/* YYNRULES -- Number of rules.  */
#define YYNRULES  145
/* YYNRULES -- Number of states.  */
#define YYNSTATES  328

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   335

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
      75,    76,    77,    78,    79,    80
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     7,    11,    13,    18,    20,    24,    26,
      36,    42,    44,    46,    50,    55,    57,    61,    63,    65,
      67,    69,    71,    73,    78,    82,    86,    88,    90,    93,
      96,    98,    99,   100,   109,   120,   122,   124,   127,   133,
     139,   152,   158,   164,   166,   168,   170,   172,   174,   176,
     180,   184,   190,   199,   208,   213,   215,   217,   221,   223,
     227,   231,   233,   235,   238,   243,   245,   247,   250,   253,
     258,   260,   262,   265,   266,   276,   278,   280,   283,   293,
     295,   297,   301,   309,   311,   313,   315,   317,   319,   321,
     323,   325,   327,   329,   331,   333,   335,   337,   339,   341,
     343,   345,   347,   349,   351,   353,   355,   357,   359,   360,
     361,   370,   379,   381,   383,   386,   388,   390,   392,   395,
     402,   405,   407,   409,   411,   413,   415,   417,   426,   428,
     430,   439,   452,   454,   456,   465,   474,   476,   480,   481,
     489,   491,   493,   496,   497,   507
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
      82,     0,    -1,    83,    84,    85,    -1,     3,    62,     8,
      -1,     1,    -1,    86,    87,    94,   125,    -1,     1,    -1,
      12,    62,    68,    -1,     1,    -1,     5,    70,    14,    72,
      11,    74,   138,    71,    68,    -1,     4,    70,    88,    71,
      68,    -1,     1,    -1,    89,    -1,    88,    68,    89,    -1,
      90,    72,    91,    92,    -1,    62,    -1,    90,    69,    62,
      -1,    21,    -1,    22,    -1,    23,    -1,    24,    -1,    25,
      -1,    26,    -1,    27,    70,    93,    71,    -1,    65,    28,
      65,    -1,    65,    29,    65,    -1,   139,    -1,    95,    -1,
      95,   139,    -1,    95,   111,    -1,     1,    -1,    -1,    -1,
       6,    62,    96,    75,    13,    68,    97,    98,    -1,    30,
      62,     8,    99,   108,    99,    12,    62,    68,   112,    -1,
       1,    -1,   100,    -1,    99,   100,    -1,     7,    62,    72,
     101,    68,    -1,    32,    62,     8,   102,    68,    -1,    32,
      38,     8,    35,    70,    36,    37,    73,    71,     9,    62,
      68,    -1,    33,    15,     8,    11,    68,    -1,    33,    77,
       8,    11,    68,    -1,     1,    -1,    62,    -1,    11,    -1,
      65,    -1,    77,    -1,     1,    -1,    70,   103,    71,    -1,
      70,   104,    71,    -1,    70,    19,    69,    20,    71,    -1,
      35,    70,    65,    28,    65,    71,     9,    62,    -1,    35,
      70,    65,    29,    65,    71,     9,    62,    -1,    34,   106,
      12,    34,    -1,     1,    -1,   105,    -1,   103,    69,   105,
      -1,    62,    -1,   104,    69,    62,    -1,    63,    58,    63,
      -1,     1,    -1,   107,    -1,   106,   107,    -1,    62,    72,
      62,    68,    -1,     1,    -1,   109,    -1,   108,   109,    -1,
      10,   110,    -1,    62,    72,    38,    68,    -1,     1,    -1,
     121,    -1,   111,   121,    -1,    -1,    30,    31,    62,     8,
     114,    12,    62,   113,    68,    -1,     1,    -1,   115,    -1,
     114,   115,    -1,    10,    62,    72,    38,    74,    70,   116,
      71,    68,    -1,     1,    -1,   117,    -1,   116,    69,   117,
      -1,    70,   118,    69,   119,    69,   120,    71,    -1,     1,
      -1,    39,    -1,    40,    -1,    41,    -1,    44,    -1,    42,
      -1,    43,    -1,    45,    -1,    47,    -1,    48,    -1,    78,
      -1,     1,    -1,    49,    -1,    50,    -1,    51,    -1,    52,
      -1,     1,    -1,    53,    -1,    54,    -1,    55,    -1,    56,
      -1,    57,    -1,    59,    -1,    60,    -1,     1,    -1,    -1,
      -1,     6,    62,   122,    75,    13,    68,   123,   124,    -1,
      30,    62,     8,   108,    12,    62,    68,   112,    -1,     1,
      -1,   126,    -1,   125,   126,    -1,     1,    -1,   127,    -1,
     129,    -1,    10,   128,    -1,    62,    72,    15,    74,   138,
      68,    -1,     7,   130,    -1,   131,    -1,   133,    -1,   134,
      -1,   136,    -1,   137,    -1,     1,    -1,    62,     9,    62,
      72,    18,     8,   132,    68,    -1,    16,    -1,    17,    -1,
      62,     9,    62,    72,     3,     8,    65,    68,    -1,    62,
       9,    62,    72,    18,     8,    70,    66,    69,   135,    71,
      68,    -1,    19,    -1,    20,    -1,    62,     9,    62,    72,
       3,     8,   138,    68,    -1,    62,     9,    62,    72,     3,
       8,    14,    68,    -1,    64,    -1,   138,    67,    64,    -1,
      -1,     6,   141,    75,    13,    68,   140,   142,    -1,    79,
      -1,    80,    -1,   143,   145,    -1,    -1,    30,   141,     8,
      95,   144,    99,    12,   141,    68,    -1,    30,    31,   141,
       8,    12,   141,    68,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   213,   213,   215,   217,   224,   228,   234,   236,   242,
     245,   246,   252,   253,   255,   258,   260,   263,   263,   263,
     263,   263,   265,   267,   269,   271,   274,   275,   276,   277,
     278,   285,   290,   284,   300,   303,   309,   310,   312,   314,
     316,   319,   320,   321,   327,   329,   330,   331,   332,   338,
     339,   340,   341,   344,   347,   348,   354,   355,   357,   359,
     362,   364,   370,   371,   373,   375,   381,   382,   384,   386,
     388,   394,   395,   398,   397,   400,   406,   407,   409,   412,
     418,   419,   421,   423,   429,   429,   429,   429,   429,   430,
     430,   430,   430,   431,   432,   438,   438,   438,   438,   439,
     445,   445,   445,   445,   445,   445,   445,   446,   453,   458,
     452,   468,   471,   475,   476,   477,   483,   484,   486,   488,
     493,   495,   496,   497,   498,   499,   500,   506,   514,   516,
     519,   525,   533,   533,   535,   541,   544,   550,   557,   556,
     567,   571,   576,   580,   578,   586
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "ENTITY", "PORT", "GENERIC", "USE",
  "ATTRIBUTE", "IS", "OF", "CONSTANT", "STRING", "END", "ALL",
  "PHYSICAL_PIN_MAP", "PIN_MAP_STRING", "TRUE", "FALSE", "SIGNAL", "LOW",
  "BOTH", "IN", "OUT", "INOUT", "BUFFER", "LINKAGE", "BIT", "BIT_VECTOR",
  "TO", "DOWNTO", "PACKAGE", "BODY", "TYPE", "SUBTYPE", "RECORD", "ARRAY",
  "POSITIVE", "RANGE", "CELL_INFO", "INPUT", "OUTPUT2", "OUTPUT3",
  "CONTROL", "CONTROLR", "INTERNAL", "CLOCK", "BIDIR", "BIDIR_IN",
  "BIDIR_OUT", "EXTEST", "SAMPLE", "INTEST", "RUNBIST", "PI", "PO", "UPD",
  "CAP", "X", "BIN_X_PATTERN", "ZERO", "ONE", "Z", "IDENTIFIER",
  "SINGLE_QUOTE", "QUOTED_STRING", "DECIMAL_NUMBER", "REAL_NUMBER",
  "CONCATENATE", "SEMICOLON", "COMMA", "LPAREN", "RPAREN", "COLON", "BOX",
  "COLON_EQUAL", "PERIOD", "ILLEGAL", "BSDL_EXTENSION", "OBSERVE_ONLY",
  "STD_1532_2001", "STD_1532_2002", "$accept", "BSDL_Program",
  "Begin_BSDL", "BSDL_Body", "End_BSDL", "VHDL_Generic", "VHDL_Port",
  "Port_Specifier_List", "Port_Specifier", "Port_List", "Function",
  "Scaler_Or_Vector", "Vector_Range", "VHDL_Use_Part", "Standard_Use",
  "@1", "@2", "Standard_Package", "Standard_Decls", "Standard_Decl",
  "Attribute_Type", "Type_Body", "ID_Bits", "ID_List", "ID_Bit",
  "Record_Body", "Record_Element", "Defered_Constants", "Defered_Constant",
  "Constant_Body", "VHDL_Use_List", "Package_Body", "@3", "Constant_List",
  "Cell_Constant", "Triples_List", "Triple", "Triple_Function",
  "Triple_Inst", "CAP_Data", "VHDL_Use", "@4", "@5", "User_Package",
  "VHDL_Elements", "VHDL_Element", "VHDL_Constant", "VHDL_Constant_Part",
  "VHDL_Attribute", "VHDL_Attribute_Types", "VHDL_Attr_Boolean", "Boolean",
  "VHDL_Attr_Decimal", "VHDL_Attr_Real", "Stop", "VHDL_Attr_String",
  "VHDL_Attr_PhysicalPinMap", "Quoted_String", "ISC_Use", "@6",
  "ISC_Packages", "ISC_Package", "ISC_Package_Header", "@7",
  "ISC_Package_Body", 0
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
     335
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    81,    82,    83,    83,    84,    84,    85,    85,    86,
      87,    87,    88,    88,    89,    90,    90,    91,    91,    91,
      91,    91,    92,    92,    93,    93,    94,    94,    94,    94,
      94,    96,    97,    95,    98,    98,    99,    99,   100,   100,
     100,   100,   100,   100,   101,   101,   101,   101,   101,   102,
     102,   102,   102,   102,   102,   102,   103,   103,   104,   104,
     105,   105,   106,   106,   107,   107,   108,   108,   109,   110,
     110,   111,   111,   113,   112,   112,   114,   114,   115,   115,
     116,   116,   117,   117,   118,   118,   118,   118,   118,   118,
     118,   118,   118,   118,   118,   119,   119,   119,   119,   119,
     120,   120,   120,   120,   120,   120,   120,   120,   122,   123,
     121,   124,   124,   125,   125,   125,   126,   126,   127,   128,
     129,   130,   130,   130,   130,   130,   130,   131,   132,   132,
     133,   134,   135,   135,   136,   137,   138,   138,   140,   139,
     141,   141,   142,   144,   143,   145
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     3,     3,     1,     4,     1,     3,     1,     9,
       5,     1,     1,     3,     4,     1,     3,     1,     1,     1,
       1,     1,     1,     4,     3,     3,     1,     1,     2,     2,
       1,     0,     0,     8,    10,     1,     1,     2,     5,     5,
      12,     5,     5,     1,     1,     1,     1,     1,     1,     3,
       3,     5,     8,     8,     4,     1,     1,     3,     1,     3,
       3,     1,     1,     2,     4,     1,     1,     2,     2,     4,
       1,     1,     2,     0,     9,     1,     1,     2,     9,     1,
       1,     3,     7,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     0,     0,
       8,     8,     1,     1,     2,     1,     1,     1,     2,     6,
       2,     1,     1,     1,     1,     1,     1,     8,     1,     1,
       8,    12,     1,     1,     8,     8,     1,     3,     0,     7,
       1,     1,     2,     0,     9,     7
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     4,     0,     0,     0,     0,     1,     6,     0,     0,
       0,     3,     0,     8,     0,     2,    11,     0,     0,     0,
       0,     0,    30,     0,     0,    27,    26,     0,     7,    15,
       0,    12,     0,    31,   140,   141,     0,   115,     0,     0,
       5,   113,   116,   117,     0,    29,    71,    28,     0,     0,
       0,     0,     0,     0,     0,   126,     0,   120,   121,   122,
     123,   124,   125,     0,   118,   114,   108,     0,    72,     0,
      13,    10,    16,    17,    18,    19,    20,    21,     0,     0,
       0,     0,     0,     0,   136,     0,    22,     0,    14,     0,
     138,     0,     0,     0,     0,     0,     0,    32,     0,     0,
       0,     0,   137,     9,     0,     0,     0,     0,   139,     0,
       0,     0,     0,   109,     0,     0,    23,    35,     0,    33,
       0,     0,   142,     0,     0,   119,     0,    24,    25,     0,
       0,     0,     0,     0,     0,   128,   129,     0,     0,   112,
       0,   110,     0,     0,   143,     0,   135,   130,   134,     0,
     127,     0,    43,     0,     0,     0,     0,    36,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
      66,     0,     0,   132,   133,     0,     0,     0,     0,     0,
       0,     0,    70,     0,    68,     0,    67,     0,     0,     0,
       0,    48,    45,    44,    46,    47,     0,     0,    55,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   145,   131,
       0,    38,     0,    65,     0,     0,    62,     0,    61,     0,
      58,     0,     0,     0,    56,    39,    41,    42,     0,     0,
     144,     0,     0,     0,     0,    63,     0,     0,     0,     0,
      49,     0,    50,    69,     0,    75,     0,   111,     0,     0,
      54,     0,     0,     0,    60,    57,    59,    34,     0,     0,
      64,     0,     0,    51,     0,     0,     0,     0,     0,     0,
       0,     0,    79,     0,     0,    76,     0,    52,    53,     0,
       0,    77,    40,     0,    73,     0,     0,     0,    74,     0,
      83,     0,     0,    80,    94,    84,    85,    86,    88,    89,
      87,    90,    91,    92,    93,     0,     0,     0,     0,    81,
      78,    99,    95,    96,    97,    98,     0,     0,   107,   100,
     101,   102,   103,   104,   105,   106,     0,    82
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     3,     4,     9,    15,    10,    18,    30,    31,    32,
      78,    88,   105,    24,    25,    53,   106,   119,   156,   157,
     196,   202,   222,   223,   224,   215,   216,   169,   170,   184,
      45,   247,   286,   274,   275,   292,   293,   305,   316,   326,
      46,    83,   126,   141,    40,    41,    42,    64,    43,    57,
      58,   138,    59,    60,   175,    61,    62,    85,    26,    98,
      36,   108,   109,   158,   122
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -159
static const yytype_int16 yypact[] =
{
     142,  -159,   -13,   109,   129,    66,  -159,  -159,    62,    11,
     132,  -159,   138,  -159,    96,  -159,  -159,    97,   101,    98,
      93,   106,  -159,    15,   107,   160,  -159,   158,  -159,  -159,
      69,  -159,    70,  -159,  -159,  -159,    99,  -159,    13,   110,
     131,  -159,  -159,  -159,    31,   165,  -159,  -159,   102,   106,
     105,   113,   104,   108,   164,  -159,   169,  -159,  -159,  -159,
    -159,  -159,  -159,   112,  -159,  -159,  -159,   117,  -159,   116,
    -159,  -159,  -159,  -159,  -159,  -159,  -159,  -159,    74,   168,
     114,   123,   171,   115,  -159,    64,  -159,   118,  -159,   119,
    -159,   120,   121,   176,   127,   125,   133,  -159,   166,    94,
     116,   126,  -159,  -159,    90,   128,    16,    75,  -159,   167,
     192,   193,    92,  -159,   139,   140,  -159,  -159,   141,  -159,
     194,   175,  -159,    -5,    17,  -159,    21,  -159,  -159,   199,
     202,    75,   143,   144,    95,  -159,  -159,   147,   146,  -159,
     148,  -159,    30,   153,  -159,   201,  -159,  -159,  -159,   149,
    -159,   208,  -159,   155,   -12,    -7,    89,  -159,    30,   207,
     137,   210,   150,   213,   215,   216,   217,    14,  -159,    89,
    -159,    20,    75,  -159,  -159,   156,   134,     2,   191,     1,
     218,   219,  -159,   159,  -159,    91,  -159,    75,   170,   172,
     173,  -159,  -159,  -159,  -159,  -159,   174,   162,  -159,    19,
     163,     6,   177,   178,   179,   190,   181,   180,  -159,  -159,
     182,  -159,   198,  -159,   183,     4,  -159,   184,  -159,   185,
    -159,   186,    78,    79,  -159,  -159,  -159,  -159,   188,   189,
    -159,    28,   200,   196,   205,  -159,   136,   221,   197,     9,
    -159,   203,  -159,  -159,    28,  -159,   220,  -159,   195,   204,
    -159,   187,   206,   209,  -159,  -159,  -159,  -159,   211,   212,
    -159,   214,   222,  -159,   228,   244,   250,   252,    18,   224,
     225,   226,  -159,   227,   103,  -159,   223,  -159,  -159,   229,
     230,  -159,  -159,   231,  -159,   232,   234,   233,  -159,     3,
    -159,     0,    82,  -159,  -159,  -159,  -159,  -159,  -159,  -159,
    -159,  -159,  -159,  -159,  -159,   235,     3,   237,     5,  -159,
    -159,  -159,  -159,  -159,  -159,  -159,   238,    29,  -159,  -159,
    -159,  -159,  -159,  -159,  -159,  -159,   239,  -159
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -159,  -159,  -159,  -159,  -159,  -159,  -159,  -159,   241,  -159,
    -159,  -159,  -159,  -159,   145,  -159,  -159,  -159,   -53,   -65,
    -159,  -159,  -159,  -159,    23,  -159,    48,   135,  -158,  -159,
    -159,    22,  -159,  -159,   -10,  -159,   -39,  -159,  -159,  -159,
     236,  -159,  -159,  -159,  -159,   242,  -159,  -159,  -159,  -159,
    -159,  -159,  -159,  -159,  -159,  -159,  -159,   -62,   245,  -159,
    -107,  -159,  -159,  -159,  -159
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint16 yytable[] =
{
     120,   294,   198,   191,   290,   213,   311,   218,   165,   132,
     218,   186,    13,   192,    55,   182,   234,   117,   186,   272,
     213,   152,   139,    14,   145,   219,   163,   153,   273,   245,
     318,   152,   187,   135,   136,   199,   200,   153,   112,   295,
     296,   297,   298,   299,   300,   301,   118,   302,   303,     5,
     164,   140,   154,   155,   312,   313,   314,   315,   246,    84,
     133,   134,   154,   155,   193,   188,   214,   194,   220,   221,
     166,   201,   221,   291,    11,    56,   183,    33,   304,   195,
     207,   214,   319,   320,   321,   322,   323,   137,   324,   325,
     152,   168,   152,    66,    34,    35,   153,   110,   153,   167,
      86,    87,    22,   206,   272,   171,   168,    23,    37,     6,
      34,    35,   111,   273,    38,   280,   185,    39,   114,   115,
     168,   154,   155,   154,   155,    73,    74,    75,    76,    77,
       7,    94,    12,    16,     8,    95,    17,    49,    38,    51,
      50,    39,    52,     1,   167,     2,   190,   239,   241,   240,
     242,   306,    19,   307,    34,    35,   173,   174,    20,    94,
     125,    28,    94,   148,   251,   252,    44,    21,    29,    48,
      27,    67,    63,    71,    54,    72,    69,    80,    81,    66,
      84,    89,    90,    79,    82,    91,    92,    97,    96,   101,
      93,   102,    99,   103,   113,   100,   107,   121,   104,   116,
     123,   124,   130,   129,   127,   128,   131,   142,   143,   159,
     151,   146,   147,   149,   150,    33,   161,   162,   160,   172,
     167,   178,   177,   179,   180,   181,   197,   189,   228,   203,
     204,   205,   212,   217,   232,   210,   268,   248,   208,   250,
     209,   253,   211,   229,   238,   225,   226,   227,   230,   236,
     231,   258,   261,   269,   237,   233,   243,   244,   249,   270,
     254,   271,   255,   235,   281,   256,   257,   309,   259,   285,
      47,   262,   260,   264,     0,   144,     0,     0,     0,     0,
     263,    68,    65,   265,     0,   266,   276,   277,   278,   279,
      70,   282,   284,   267,     0,     0,   176,     0,     0,     0,
       0,   283,   288,   289,   308,   310,   287,   317,     0,     0,
     327
};

static const yytype_int16 yycheck[] =
{
     107,     1,     1,     1,     1,     1,     1,     1,    15,    14,
       1,   169,     1,    11,     1,     1,    12,     1,   176,     1,
       1,     1,     1,    12,   131,    19,    38,     7,    10,     1,
       1,     1,    12,    16,    17,    34,    35,     7,   100,    39,
      40,    41,    42,    43,    44,    45,    30,    47,    48,    62,
      62,    30,    32,    33,    49,    50,    51,    52,    30,    64,
      65,   123,    32,    33,    62,   172,    62,    65,    62,    63,
      77,    70,    63,    70,     8,    62,    62,    62,    78,    77,
     187,    62,    53,    54,    55,    56,    57,    70,    59,    60,
       1,   156,     1,    62,    79,    80,     7,     3,     7,    10,
      26,    27,     1,    12,     1,   158,   171,     6,     1,     0,
      79,    80,    18,    10,     7,    12,   169,    10,    28,    29,
     185,    32,    33,    32,    33,    21,    22,    23,    24,    25,
       1,    67,    70,     1,     5,    71,     4,    68,     7,    69,
      71,    10,    72,     1,    10,     3,    12,    69,    69,    71,
      71,    69,    14,    71,    79,    80,    19,    20,    62,    67,
      68,    68,    67,    68,    28,    29,     6,    70,    62,    11,
      72,     6,    62,    68,    75,    62,    74,    13,     9,    62,
      64,    13,    68,    75,    72,    62,    15,    68,    70,    13,
      75,    64,    72,    68,    68,    74,    30,    30,    65,    71,
       8,     8,     8,    62,    65,    65,    31,     8,     6,     8,
      62,    68,    68,    66,    68,    62,     8,    62,    69,    12,
      10,     8,    72,     8,     8,     8,    35,    71,    38,    11,
      11,    72,    70,    70,    36,    62,     8,    37,    68,    34,
      68,    20,    68,    62,    58,    68,    68,    68,    68,    65,
      68,    31,    65,     9,    69,    72,    68,    68,    62,     9,
      63,     9,   239,   215,   274,    62,   244,   306,    73,    38,
      25,    65,    68,    62,    -1,   130,    -1,    -1,    -1,    -1,
      71,    45,    40,    71,    -1,    71,    62,    62,    62,    62,
      49,    68,    62,    71,    -1,    -1,   161,    -1,    -1,    -1,
      -1,    72,    68,    70,    69,    68,    74,    69,    -1,    -1,
      71
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     1,     3,    82,    83,    62,     0,     1,     5,    84,
      86,     8,    70,     1,    12,    85,     1,     4,    87,    14,
      62,    70,     1,     6,    94,    95,   139,    72,    68,    62,
      88,    89,    90,    62,    79,    80,   141,     1,     7,    10,
     125,   126,   127,   129,     6,   111,   121,   139,    11,    68,
      71,    69,    72,    96,    75,     1,    62,   130,   131,   133,
     134,   136,   137,    62,   128,   126,    62,     6,   121,    74,
      89,    68,    62,    21,    22,    23,    24,    25,    91,    75,
      13,     9,    72,   122,    64,   138,    26,    27,    92,    13,
      68,    62,    15,    75,    67,    71,    70,    68,   140,    72,
      74,    13,    64,    68,    65,    93,    97,    30,   142,   143,
       3,    18,   138,    68,    28,    29,    71,     1,    30,    98,
     141,    30,   145,     8,     8,    68,   123,    65,    65,    62,
       8,    31,    14,    65,   138,    16,    17,    70,   132,     1,
      30,   124,     8,     6,    95,   141,    68,    68,    68,    66,
      68,    62,     1,     7,    32,    33,    99,   100,   144,     8,
      69,     8,    62,    38,    62,    15,    77,    10,   100,   108,
     109,    99,    12,    19,    20,   135,   108,    72,     8,     8,
       8,     8,     1,    62,   110,    99,   109,    12,   141,    71,
      12,     1,    11,    62,    65,    77,   101,    35,     1,    34,
      35,    70,   102,    11,    11,    72,    12,   141,    68,    68,
      62,    68,    70,     1,    62,   106,   107,    70,     1,    19,
      62,    63,   103,   104,   105,    68,    68,    68,    38,    62,
      68,    68,    36,    72,    12,   107,    65,    69,    58,    69,
      71,    69,    71,    68,    68,     1,    30,   112,    37,    62,
      34,    28,    29,    20,    63,   105,    62,   112,    31,    73,
      68,    65,    65,    71,    62,    71,    71,    71,     8,     9,
       9,     9,     1,    10,   114,   115,    62,    62,    62,    62,
      12,   115,    68,    72,    62,    38,   113,    74,    68,    70,
       1,    70,   116,   117,     1,    39,    40,    41,    42,    43,
      44,    45,    47,    48,    78,   118,    69,    71,    69,   117,
      68,     1,    49,    50,    51,    52,   119,    69,     1,    53,
      54,    55,    56,    57,    59,    60,   120,    71
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
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, vhdl_parser_priv_t *priv_data)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, priv_data)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    vhdl_parser_priv_t *priv_data;
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
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, vhdl_parser_priv_t *priv_data)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, priv_data)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    vhdl_parser_priv_t *priv_data;
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
yy_reduce_print (YYSTYPE *yyvsp, int yyrule, vhdl_parser_priv_t *priv_data)
#else
static void
yy_reduce_print (yyvsp, yyrule, priv_data)
    YYSTYPE *yyvsp;
    int yyrule;
    vhdl_parser_priv_t *priv_data;
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
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, vhdl_parser_priv_t *priv_data)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, priv_data)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    vhdl_parser_priv_t *priv_data;
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
int yyparse (vhdl_parser_priv_t *priv_data);
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
yyparse (vhdl_parser_priv_t *priv_data)
#else
int
yyparse (priv_data)
    vhdl_parser_priv_t *priv_data;
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
        case 3:
#line 216 "vhdl_bison.y"
    { vhdl_set_entity( priv_data, (yyvsp[(2) - (3)].str) ); }
    break;

  case 4:
#line 218 "vhdl_bison.y"
    {
               Print_Error( priv_data, _("Improper Entity declaration") );
               Print_Error( priv_data, _("Check if source file is BSDL") );
               BUMP_ERROR; YYABORT; /* Probably not a BSDL source file */
             }
    break;

  case 6:
#line 229 "vhdl_bison.y"
    {
              Print_Error( priv_data, _("Syntax Error") );
              BUMP_ERROR; YYABORT;
            }
    break;

  case 7:
#line 235 "vhdl_bison.y"
    { free( (yyvsp[(2) - (3)].str) ); }
    break;

  case 8:
#line 237 "vhdl_bison.y"
    {
             Print_Error( priv_data, _("Syntax Error") );
             BUMP_ERROR; YYABORT;
           }
    break;

  case 11:
#line 247 "vhdl_bison.y"
    {
                        Print_Error( priv_data, _("Improper Port declaration") );
                        BUMP_ERROR; YYABORT;
                      }
    break;

  case 14:
#line 256 "vhdl_bison.y"
    { vhdl_port_apply_port( priv_data ); }
    break;

  case 15:
#line 259 "vhdl_bison.y"
    { vhdl_port_add_name( priv_data, (yyvsp[(1) - (1)].str) ); }
    break;

  case 16:
#line 261 "vhdl_bison.y"
    { vhdl_port_add_name( priv_data, (yyvsp[(3) - (3)].str) ); }
    break;

  case 22:
#line 266 "vhdl_bison.y"
    { vhdl_port_add_bit( priv_data ); }
    break;

  case 24:
#line 270 "vhdl_bison.y"
    { vhdl_port_add_range( priv_data, (yyvsp[(1) - (3)].integer), (yyvsp[(3) - (3)].integer) ); }
    break;

  case 25:
#line 272 "vhdl_bison.y"
    { vhdl_port_add_range( priv_data, (yyvsp[(3) - (3)].integer), (yyvsp[(1) - (3)].integer) ); }
    break;

  case 30:
#line 279 "vhdl_bison.y"
    {
                  Print_Error( priv_data, _("Error in Package declaration(s)") );
                  BUMP_ERROR; YYABORT;
                }
    break;

  case 31:
#line 285 "vhdl_bison.y"
    {/* Parse Standard 1149.1 Package */
                  strcpy( priv_data->Package_File_Name, (yyvsp[(2) - (2)].str) );
                  free( (yyvsp[(2) - (2)].str) );
                }
    break;

  case 32:
#line 290 "vhdl_bison.y"
    {
                  priv_data->Reading_Package = 1;
                  vhdl_flex_switch_file( priv_data->scanner,
                                         priv_data->Package_File_Name );
                }
    break;

  case 33:
#line 296 "vhdl_bison.y"
    {
                  priv_data->Reading_Package = 0;
                }
    break;

  case 34:
#line 302 "vhdl_bison.y"
    { free( (yyvsp[(2) - (10)].str) ); free( (yyvsp[(8) - (10)].str) ); }
    break;

  case 35:
#line 304 "vhdl_bison.y"
    {
                     Print_Error( priv_data, _("Error in Standard Package") );
                     BUMP_ERROR; YYABORT;
                   }
    break;

  case 38:
#line 313 "vhdl_bison.y"
    { free( (yyvsp[(2) - (5)].str) ); }
    break;

  case 39:
#line 315 "vhdl_bison.y"
    { free( (yyvsp[(2) - (5)].str) ); }
    break;

  case 40:
#line 318 "vhdl_bison.y"
    { free( (yyvsp[(11) - (12)].str) ); }
    break;

  case 43:
#line 322 "vhdl_bison.y"
    {
                   Print_Error( priv_data, _("Error in Standard Declarations") );
                   BUMP_ERROR; YYABORT;
                 }
    break;

  case 44:
#line 328 "vhdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 48:
#line 333 "vhdl_bison.y"
    {
                   Print_Error( priv_data, _("Error in Attribute type identification") );
                   BUMP_ERROR; YYABORT;
                 }
    break;

  case 52:
#line 343 "vhdl_bison.y"
    { free( (yyvsp[(8) - (8)].str) ); }
    break;

  case 53:
#line 346 "vhdl_bison.y"
    { free( (yyvsp[(8) - (8)].str) ); }
    break;

  case 55:
#line 349 "vhdl_bison.y"
    {
                   Print_Error( priv_data, _("Error in Type definition") );
                   BUMP_ERROR; YYABORT;
                 }
    break;

  case 58:
#line 358 "vhdl_bison.y"
    { free( (yyvsp[(1) - (1)].str) ); }
    break;

  case 59:
#line 360 "vhdl_bison.y"
    { free( (yyvsp[(3) - (3)].str) ); }
    break;

  case 60:
#line 363 "vhdl_bison.y"
    { free( (yyvsp[(2) - (3)].str) ); }
    break;

  case 61:
#line 365 "vhdl_bison.y"
    {
                   Print_Error( priv_data, _("Error in Bit definition") );
                   BUMP_ERROR; YYABORT;
                 }
    break;

  case 64:
#line 374 "vhdl_bison.y"
    { free( (yyvsp[(1) - (4)].str) ); free( (yyvsp[(3) - (4)].str) ); }
    break;

  case 65:
#line 376 "vhdl_bison.y"
    {
                   Print_Error( priv_data, _("Error in Record Definition") );
                   BUMP_ERROR; YYABORT;
                 }
    break;

  case 69:
#line 387 "vhdl_bison.y"
    { free( (yyvsp[(1) - (4)].str) ); }
    break;

  case 70:
#line 389 "vhdl_bison.y"
    {
                      Print_Error( priv_data, _("Error in defered constant") );
                      BUMP_ERROR; YYABORT;
                    }
    break;

  case 73:
#line 398 "vhdl_bison.y"
    { free( (yyvsp[(3) - (7)].str) ); free( (yyvsp[(7) - (7)].str) ); }
    break;

  case 75:
#line 401 "vhdl_bison.y"
    {
                    Print_Error( priv_data, _("Error in Package Body definition") );
                    BUMP_ERROR; YYABORT;
                  }
    break;

  case 78:
#line 411 "vhdl_bison.y"
    { free( (yyvsp[(2) - (9)].str) ); }
    break;

  case 79:
#line 413 "vhdl_bison.y"
    {
                    Print_Error( priv_data, _("Error in Cell Constant definition") );
                    BUMP_ERROR; YYABORT;
                  }
    break;

  case 83:
#line 424 "vhdl_bison.y"
    {
                    Print_Error( priv_data, _("Error in Cell Data Record") );
                    BUMP_ERROR; YYABORT;
                  }
    break;

  case 94:
#line 433 "vhdl_bison.y"
    {
                    Print_Error( priv_data, _("Error in Cell_Type Function field") );
                    BUMP_ERROR; YYABORT;
                  }
    break;

  case 99:
#line 440 "vhdl_bison.y"
    {
                    Print_Error( priv_data, _("Error in BScan_Inst Instruction field") );
                    BUMP_ERROR; YYABORT;
                  }
    break;

  case 107:
#line 447 "vhdl_bison.y"
    {
                    Print_Error( priv_data, _("Error in Constant CAP data source field") );
                    BUMP_ERROR; YYABORT;
                  }
    break;

  case 108:
#line 453 "vhdl_bison.y"
    {/* Parse Standard 1149.1 Package */
                    strcpy(priv_data->Package_File_Name, (yyvsp[(2) - (2)].str));
                    free((yyvsp[(2) - (2)].str));
                   }
    break;

  case 109:
#line 458 "vhdl_bison.y"
    {
                     priv_data->Reading_Package = 1;
                     vhdl_flex_switch_file(priv_data->scanner,
                                           priv_data->Package_File_Name);
                   }
    break;

  case 110:
#line 464 "vhdl_bison.y"
    {
                     priv_data->Reading_Package = 0;
                   }
    break;

  case 111:
#line 470 "vhdl_bison.y"
    { free((yyvsp[(2) - (8)].str)); free((yyvsp[(6) - (8)].str)); }
    break;

  case 112:
#line 472 "vhdl_bison.y"
    {Print_Error(priv_data, _("Error in User-Defined Package declarations"));
                    BUMP_ERROR; YYABORT; }
    break;

  case 115:
#line 478 "vhdl_bison.y"
    {
                  Print_Error( priv_data, _("Unknown VHDL statement") );
                  BUMP_ERROR; YYABORT;
                }
    break;

  case 119:
#line 491 "vhdl_bison.y"
    { free( (yyvsp[(1) - (6)].str) ); }
    break;

  case 126:
#line 501 "vhdl_bison.y"
    {
                         Print_Error( priv_data, _("Error in Attribute specification") );
                         BUMP_ERROR; YYABORT;
                       }
    break;

  case 127:
#line 507 "vhdl_bison.y"
    { 
                       //set_attr_bool( priv_data, $1, $7 );
                       //free( $3 );
                       /* skip boolean attributes for the time being */
                       free( (yyvsp[(1) - (8)].str) ); free( (yyvsp[(3) - (8)].str) );
		     }
    break;

  case 128:
#line 515 "vhdl_bison.y"
    { (yyval.integer) = 1; }
    break;

  case 129:
#line 517 "vhdl_bison.y"
    { (yyval.integer) = 0; }
    break;

  case 130:
#line 520 "vhdl_bison.y"
    {
                      set_attr_decimal( priv_data, (yyvsp[(1) - (8)].str), (yyvsp[(7) - (8)].integer) );
                      free( (yyvsp[(3) - (8)].str) );
		    }
    break;

  case 131:
#line 526 "vhdl_bison.y"
    {
		     //set_attr_real( priv_data, $1, $8 );
		     //free( $3 );
                     /* skip real attributes for the time being */
                     free( (yyvsp[(1) - (12)].str) ); free( (yyvsp[(3) - (12)].str) ); free( (yyvsp[(8) - (12)].str) );
		   }
    break;

  case 134:
#line 536 "vhdl_bison.y"
    {
		     set_attr_string( priv_data, (yyvsp[(1) - (8)].str), strdup( priv_data->buffer ) );
		     free( (yyvsp[(3) - (8)].str) );
		   }
    break;

  case 135:
#line 542 "vhdl_bison.y"
    { free( (yyvsp[(1) - (8)].str) ); free( (yyvsp[(3) - (8)].str) ); }
    break;

  case 136:
#line 545 "vhdl_bison.y"
    {
                     Init_Text( priv_data );
                     Store_Text( priv_data, (yyvsp[(1) - (1)].str) );
                     free( (yyvsp[(1) - (1)].str) );
                   }
    break;

  case 137:
#line 551 "vhdl_bison.y"
    {
                     Store_Text( priv_data, (yyvsp[(3) - (3)].str) );
                     free( (yyvsp[(3) - (3)].str) );
                   }
    break;

  case 138:
#line 557 "vhdl_bison.y"
    {
               priv_data->Reading_Package = 1;
               vhdl_flex_switch_file( priv_data->scanner,
                                      priv_data->Package_File_Name );
             }
    break;

  case 139:
#line 563 "vhdl_bison.y"
    {
               priv_data->Reading_Package = 0;
             }
    break;

  case 140:
#line 568 "vhdl_bison.y"
    {
                 strcpy( priv_data->Package_File_Name, "STD_1532_2001" );
               }
    break;

  case 141:
#line 572 "vhdl_bison.y"
    {
                 strcpy( priv_data->Package_File_Name, "STD_1532_2002" );
               }
    break;

  case 143:
#line 580 "vhdl_bison.y"
    {
                       priv_data->Reading_Package = 1;
                     }
    break;


/* Line 1267 of yacc.c.  */
#line 2277 "vhdl_bison.c"
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


#line 589 "vhdl_bison.y"
  /* End rules, begin programs  */
/*****************************************************************************
 * void Init_Text( vhdl_parser_priv_t *priv )
 *
 * Allocates the internal test buffer if not already existing.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *
 * Returns
 *   void
 ****************************************************************************/
static void Init_Text( vhdl_parser_priv_t *priv )
{
  if (priv->len_buffer == 0)
  {
    priv->buffer = (char *)malloc( 160 );
    priv->len_buffer = 160;
  }
  priv->buffer[0] = '\0';
}


/*****************************************************************************
 * void Store_Text( vhdl_parser_priv_t *priv, char *Source )
 *
 * Appends the given String to the internal text buffer. The buffer
 * is extended if the string does not fit into the current size.
 *
 * Parameters
 *   priv   : private data container for parser related tasks
 *   String : pointer to string that is to be added to buffer
 *
 * Returns
 *   void
 ****************************************************************************/
static void Store_Text( vhdl_parser_priv_t *priv, char *Source )
{ /* Save characters from VHDL string in local string buffer.           */
  size_t req_len;
  char   *SourceEnd;

  SourceEnd = ++Source;   /* skip leading '"' */
  while (*SourceEnd && (*SourceEnd != '"') && (*SourceEnd != '\n'))
    SourceEnd++;
  /* terminate Source string with NUL character */
  *SourceEnd = '\0';

  req_len = strlen( priv->buffer ) + strlen( Source ) + 1;
  if (req_len > priv->len_buffer)
  {
    priv->buffer = (char *)realloc( priv->buffer, req_len );
    priv->len_buffer = req_len;
  }
  strcat( priv->buffer, Source );
}
/*----------------------------------------------------------------------*/
static void Print_Error( vhdl_parser_priv_t *priv_data, const char *Errmess )
{
  jtag_ctrl_t *jc = priv_data->jtag_ctrl;

  if (priv_data->Reading_Package)
    bsdl_msg( jc->proc_mode,
              BSDL_MSG_ERR, _("In Package %s, Line %d, %s.\n"),
              priv_data->Package_File_Name,
              vhdl_flex_get_lineno( priv_data->scanner ),
              Errmess );
  else
    bsdl_msg( jc->proc_mode,
              BSDL_MSG_ERR, _("Line %d, %s.\n"),
              vhdl_flex_get_lineno( priv_data->scanner ),
              Errmess );
}
/*----------------------------------------------------------------------*/
static void Give_Up_And_Quit( vhdl_parser_priv_t *priv_data )
{
  Print_Error( priv_data, _("Too many errors") );
}
/*----------------------------------------------------------------------*/
void yyerror( vhdl_parser_priv_t *priv_data, const char *error_string )
{
}


/*****************************************************************************
 * void vhdl_sem_init( vhdl_parser_priv_t *priv )
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
static void vhdl_sem_init( vhdl_parser_priv_t *priv )
{
  priv->tmp_port_desc.names_list = NULL;
  priv->tmp_port_desc.next       = NULL;

  priv->jtag_ctrl->port_desc = NULL;

  priv->jtag_ctrl->vhdl_elem_first = NULL;
  priv->jtag_ctrl->vhdl_elem_last  = NULL;
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
static void free_string_list( string_elem_t *sl )
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
 * void free_port_list( port_desc_t *pl, int free_me )
 *
 * Deallocates the given list of port_desc.
 *
 * Parameters
 *  pl      : first port_desc to deallocate
 *  free_me : set to 1 to free memory for ai as well
 *
 * Returns
 *  void
 ****************************************************************************/
static void free_port_list( port_desc_t *pl, int free_me )
{
  if (pl)
  {
    free_string_list( pl->names_list );
    free_port_list( pl->next, 1 );

    if (free_me)
      free( pl );
  }
}


/*****************************************************************************
 * void free_elem_list( vhdl_elem_t *el )
 *
 * Deallocates the given list of vhdl_elem items.
 *
 * Parameters
 *  el : first vhdl_elem to deallocate
 *
 * Returns
 *  void
 ****************************************************************************/
static void free_elem_list( vhdl_elem_t *el )
{
  if (el)
  {
    free_elem_list( el->next );

    if (el->name)
      free( el->name );

    if (el->payload)
      free( el->payload );
    free( el );
  }
}


/*****************************************************************************
 * void vhdl_sem_deinit( vhdl_parser_priv_t *priv )
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
static void vhdl_sem_deinit( vhdl_parser_priv_t *priv_data )
{
  port_desc_t *pd = priv_data->jtag_ctrl->port_desc;
  vhdl_elem_t *el = priv_data->jtag_ctrl->vhdl_elem_first;

  /* free port_desc list */
  free_port_list( pd, 1 );
  free_port_list( &(priv_data->tmp_port_desc), 0 );

  /* free VHDL element list */
  free_elem_list( el );

  priv_data->jtag_ctrl = NULL;
}


/*****************************************************************************
 * vhdl_parser_priv_t *vhdl_parser_init( FILE *f, jtag_ctrl_t *jtag_ctrl )
 *
 * Initializes storage elements in the private parser structure that are
 * used for parser maintenance purposes.
 * Subsequently calls initializer functions for the scanner and the semantic 
 * parts.
 *
 * Parameters
 *   f         : descriptor of file for scanning
 *   jtag_ctrl : pointer to jtag control structure
 *
 * Returns
 *   pointer to private parser structure
 ****************************************************************************/
vhdl_parser_priv_t *vhdl_parser_init( FILE *f, jtag_ctrl_t *jtag_ctrl )
{
  vhdl_parser_priv_t *new_priv;

  if (!(new_priv = (vhdl_parser_priv_t *)malloc( sizeof( vhdl_parser_priv_t ) )))
  {
    bsdl_msg( jtag_ctrl->proc_mode,
              BSDL_MSG_ERR, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
    return NULL;
  }

  new_priv->jtag_ctrl = jtag_ctrl;

  new_priv->Reading_Package = 0;
  new_priv->buffer          = NULL;
  new_priv->len_buffer      = 0;

  if (!(new_priv->scanner = vhdl_flex_init( f, jtag_ctrl->proc_mode )))
  {
    free( new_priv );
    new_priv = NULL;
  }

  vhdl_sem_init( new_priv );

  return new_priv;
}


/*****************************************************************************
 * void vhdl_parser_deinit( vhdl_parser_priv_t *priv )
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
void vhdl_parser_deinit( vhdl_parser_priv_t *priv_data )
{
  if (priv_data->buffer)
  {
    free( priv_data->buffer );
    priv_data->buffer = NULL;
  }

  vhdl_sem_deinit( priv_data );
  vhdl_flex_deinit( priv_data->scanner );
  free( priv_data );
}

/*****************************************************************************
 * void vhdl_set_entity( vhdl_parser_priv_t *priv, char *entityname )
 *
 * Applies the entity name from BSDL as the part name.
 *
 * Parameters
 *   priv       : private data container for parser related tasks
 *   entityname : entity name string, memory gets free'd
 *
 * Returns
 *   void
 ****************************************************************************/
static void vhdl_set_entity( vhdl_parser_priv_t *priv, char *entityname )
{
  if (priv->jtag_ctrl->proc_mode & BSDL_MODE_INSTR_EXEC)
  {
    strncpy( priv->jtag_ctrl->part->part, entityname, MAXLEN_PART );
    priv->jtag_ctrl->part->part[MAXLEN_PART] = '\0';
  }

  free( entityname );
}

/*****************************************************************************
 * void vhdl_port_add_name( vhdl_parser_priv_t *priv, char *name )
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
static void vhdl_port_add_name( vhdl_parser_priv_t *priv, char *name )
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
 * void vhdl_port_add_bit( vhdl_parser_priv_t *priv )
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
static void vhdl_port_add_bit( vhdl_parser_priv_t *priv )
{
  port_desc_t *pd = &(priv->tmp_port_desc);

  pd->is_vector = 0;
  pd->low_idx   = 0;
  pd->high_idx  = 0;
}


/*****************************************************************************
 * void vhdl_port_add_range( vhdl_parser_priv_t *priv, int low, int high )
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
static void vhdl_port_add_range( vhdl_parser_priv_t *priv, int low, int high )
{
  port_desc_t *pd = &(priv->tmp_port_desc);

  pd->is_vector = 1;
  pd->low_idx   = low;
  pd->high_idx  = high;
}

/*****************************************************************************
 * void vhdl_port_apply_port( vhdl_parser_priv_t *priv )
 * Port name management function
 *
 * Applies the current temporary port description to the final list
 * of port descriptions.
 *
 * Parameters
 *   priv : private data container for parser related tasks
 *
 * Returns
 *   void
 ****************************************************************************/
static void vhdl_port_apply_port( vhdl_parser_priv_t *priv )
{
  port_desc_t *tmp_pd = &(priv->tmp_port_desc);
  port_desc_t *pd = (port_desc_t *)malloc( sizeof( port_desc_t ) );

  if (pd)
  {
    /* insert at top of list */
    pd->next = priv->jtag_ctrl->port_desc;
    priv->jtag_ctrl->port_desc = pd;

    /* copy information from temporary port descriptor */
    pd->names_list = tmp_pd->names_list;
    pd->is_vector  = tmp_pd->is_vector;
    pd->low_idx    = tmp_pd->low_idx;
    pd->high_idx   = tmp_pd->high_idx;

    /* and reset temporary port descriptor */
    tmp_pd->names_list = NULL;
    tmp_pd->next       = NULL;
  }
  else
    bsdl_msg( priv->jtag_ctrl->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}

static void add_elem( vhdl_parser_priv_t *priv, vhdl_elem_t *el )
{
  jtag_ctrl_t *jc = priv->jtag_ctrl;

  el->next = NULL;
  if (jc->vhdl_elem_last)
    jc->vhdl_elem_last->next = el;
  jc->vhdl_elem_last = el;

  if (!jc->vhdl_elem_first)
    jc->vhdl_elem_first = el;

  el->line = vhdl_flex_get_lineno( priv->scanner );
}

#if 0
static void set_attr_bool( vhdl_parser_priv_t *priv, char *name, int value )
{
  vhdl_elem_t *el = (vhdl_elem_t *)malloc( sizeof( vhdl_elem_t ) );

  if (el)
  {
    el->type = VET_ATTRIBUTE_BOOL;
    el->name = name;
    el->payload.bool = value;

    add_elem( priv, el );
  }
  else
    bsdl_msg( BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}
#endif

static void set_attr_decimal( vhdl_parser_priv_t *priv, char *name, int value )
{
  vhdl_elem_t *el = (vhdl_elem_t *)malloc( sizeof( vhdl_elem_t ) );
  char *string = (char *)malloc( 10 );

  if (el && string)
  {
    el->type = VET_ATTRIBUTE_DECIMAL;
    el->name = name;
    snprintf( string, 10, "%d", value );
    el->payload = string;

    add_elem( priv, el );
  }
  else
    bsdl_msg( priv->jtag_ctrl->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}

static void set_attr_string( vhdl_parser_priv_t *priv, char *name, char *string )
{
  vhdl_elem_t *el = (vhdl_elem_t *)malloc( sizeof( vhdl_elem_t ) );

  /* skip certain attributes */
  if (   (strcasecmp( name, "DESIGN_WARNING" ) == 0)
      || (strcasecmp( name, "BOUNDARY_CELLS" ) == 0)
      || (strcasecmp( name, "INSTRUCTION_SEQUENCE" ) == 0)
      || (strcasecmp( name, "INSTRUCTION_USAGE" ) == 0)
      || (strcasecmp( name, "ISC_DESIGN_WARNING" ) == 0))
  {
    free( name );
    free( string );
    free( el );
    return;
  }

  if (el)
  {
    el->type    = VET_ATTRIBUTE_STRING;
    el->name    = name;
    el->payload = string;

    add_elem(priv, el);
  }
  else
    bsdl_msg( priv->jtag_ctrl->proc_mode,
              BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}

#if 0
static void set_attr_real( vhdl_parser_priv_t *priv, char *name, char *string )
{
  vhdl_elem_t *el = (vhdl_elem_t *)malloc( sizeof( vhdl_elem_t ) );

  if (el)
  {
    el->type = VET_ATTRIBUTE_REAL;
    el->name = name;
    el->payload.real = string;

    add_elem( priv, el );
  }
  else
    bsdl_msg( BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}
#endif

#if 0
static void set_attr_const( vhdl_parser_priv_t *priv, char *name, char *string )
{
  vhdl_elem_t *el = (vhdl_elem_t *)malloc( sizeof( vhdl_elem_t ) );

  if (el)
  {
    el->type    = VET_CONSTANT;
    el->name    = name;
    el->payload = string;

    add_elem( priv, el );
  }
  else
    bsdl_msg( BSDL_MSG_FATAL, _("Out of memory, %s line %i\n"), __FILE__, __LINE__ );
}
#endif


/*
 Local Variables:
 mode:C
 c-default-style:gnu
 indent-tabs-mode:nil
 End:
*/

