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
#define YYLSP_NEEDED 1

/* Substitute the variable and function names.  */
#define yyparse svfparse
#define yylex   svflex
#define yyerror svferror
#define yylval  svflval
#define yychar  svfchar
#define yydebug svfdebug
#define yynerrs svfnerrs
#define yylloc svflloc

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




/* Copy the first part of user declarations.  */
#line 33 "svf_bison.y"

#include <stdio.h>
#include <stdlib.h>

#include "svf.h"

/* interface to flex */
#include "svf_bison.h"
#define YYLEX_PARAM priv_data->scanner
int yylex (YYSTYPE *, YYLTYPE *, void *);

#define YYERROR_VERBOSE


void yyerror(YYLTYPE *, parser_priv_t *priv_data, chain_t *, const char *);

static void svf_free_ths_params(struct ths_params *);


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
#line 52 "svf_bison.y"
{
  int    token;
  double dvalue;
  char  *cvalue;
  int    ivalue;
  struct tdval tdval;
  struct tcval *tcval;
}
/* Line 187 of yacc.c.  */
#line 252 "svf_bison.c"
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


/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 277 "svf_bison.c"

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
	 || (defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL \
	     && defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
    YYLTYPE yyls;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE) + sizeof (YYLTYPE)) \
      + 2 * YYSTACK_GAP_MAXIMUM)

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
#define YYFINAL  4
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   145

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  63
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  17
/* YYNRULES -- Number of rules.  */
#define YYNRULES  68
/* YYNRULES -- Number of states.  */
#define YYNSTATES  119

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   314

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      61,    62,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    60,
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
      55,    56,    57,    58,    59
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint8 yyprhs[] =
{
       0,     0,     3,     4,     7,    10,    14,    18,    21,    26,
      31,    36,    44,    48,    55,    61,    66,    71,    76,    81,
      86,    90,    91,    94,    97,   100,   103,   106,   108,   110,
     112,   114,   115,   117,   120,   123,   124,   126,   130,   131,
     135,   136,   139,   141,   143,   145,   147,   149,   151,   153,
     155,   157,   159,   161,   163,   165,   167,   169,   171,   172,
     175,   176,   180,   182,   184,   186,   188,   190,   192
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int8 yyrhs[] =
{
      64,     0,    -1,    -1,    64,    65,    -1,     1,     0,    -1,
       9,    68,    60,    -1,     8,    68,    60,    -1,    10,    60,
      -1,    10,     4,    11,    60,    -1,    24,     4,    66,    60,
      -1,    25,     4,    66,    60,    -1,    31,    61,    79,     3,
      77,    62,    60,    -1,    30,     6,    60,    -1,    40,    69,
      70,    71,    74,    60,    -1,    40,    69,    72,    74,    60,
      -1,    26,     4,    66,    60,    -1,    27,     4,    66,    60,
      -1,    12,    76,    68,    60,    -1,    28,     4,    66,    60,
      -1,    29,     4,    66,    60,    -1,    19,    78,    60,    -1,
      -1,    66,    67,    -1,    15,     5,    -1,    16,     5,    -1,
      17,     5,    -1,    18,     5,    -1,    13,    -1,    14,    -1,
      53,    -1,    46,    -1,    -1,    68,    -1,     4,    43,    -1,
       4,    44,    -1,    -1,    72,    -1,     4,    42,    73,    -1,
      -1,    41,     4,    42,    -1,    -1,    45,    68,    -1,    56,
      -1,    59,    -1,    54,    -1,    57,    -1,    58,    -1,    55,
      -1,    49,    -1,    52,    -1,    47,    -1,    50,    -1,    51,
      -1,    48,    -1,    46,    -1,    53,    -1,    13,    -1,    14,
      -1,    -1,    76,    75,    -1,    -1,    77,    79,     3,    -1,
      20,    -1,    21,    -1,    22,    -1,    23,    -1,    32,    -1,
      33,    -1,    34,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,    84,    84,    86,    87,    99,   104,   109,   114,   119,
     128,   137,   144,   152,   167,   182,   197,   212,   220,   235,
     250,   260,   262,   266,   271,   276,   281,   288,   289,   290,
     291,   295,   296,   303,   309,   318,   323,   327,   335,   338,
     345,   346,   353,   354,   355,   356,   357,   358,   359,   360,
     361,   362,   363,   364,   365,   366,   367,   368,   373,   377,
     390,   392,   396,   397,   398,   399,   403,   404,   405
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "SVF_EOF", "error", "$undefined", "IDENTIFIER", "NUMBER", "HEXA_NUM",
  "VECTOR_STRING", "EMPTY", "ENDDR", "ENDIR", "FREQUENCY", "HZ", "STATE",
  "RESET", "IDLE", "TDI", "TDO", "MASK", "SMASK", "TRST", "ON", "OFF", "Z",
  "ABSENT", "HDR", "HIR", "SDR", "SIR", "TDR", "TIR", "PIO", "PIOMAP",
  "IN", "OUT", "INOUT", "H", "L", "U", "D", "X", "RUNTEST", "MAXIMUM",
  "SEC", "TCK", "SCK", "ENDSTATE", "IRPAUSE", "IRSHIFT", "IRUPDATE",
  "IRSELECT", "IREXIT1", "IREXIT2", "IRCAPTURE", "DRPAUSE", "DRSHIFT",
  "DRUPDATE", "DRSELECT", "DREXIT1", "DREXIT2", "DRCAPTURE", "';'", "'('",
  "')'", "$accept", "line", "svf_statement", "ths_param_list",
  "ths_opt_param", "stable_state", "runtest_run_state_opt",
  "runtest_clk_count", "runtest_time_opt", "runtest_time",
  "runtest_max_time_opt", "runtest_end_state_opt", "all_states",
  "path_states", "piomap_rec", "trst_mode", "direction", 0
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
      59,    40,    41
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    63,    64,    64,    64,    65,    65,    65,    65,    65,
      65,    65,    65,    65,    65,    65,    65,    65,    65,    65,
      65,    66,    66,    67,    67,    67,    67,    68,    68,    68,
      68,    69,    69,    70,    70,    71,    71,    72,    73,    73,
      74,    74,    75,    75,    75,    75,    75,    75,    75,    75,
      75,    75,    75,    75,    75,    75,    75,    75,    76,    76,
      77,    77,    78,    78,    78,    78,    79,    79,    79
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     0,     2,     2,     3,     3,     2,     4,     4,
       4,     7,     3,     6,     5,     4,     4,     4,     4,     4,
       3,     0,     2,     2,     2,     2,     2,     1,     1,     1,
       1,     0,     1,     2,     2,     0,     1,     3,     0,     3,
       0,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     0,     2,
       0,     3,     1,     1,     1,     1,     1,     1,     1
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     0,     0,     4,     1,     0,     0,     0,    58,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    31,     3,
      27,    28,    30,    29,     0,     0,     0,     7,     0,    62,
      63,    64,    65,     0,    21,    21,    21,    21,    21,    21,
       0,     0,    32,     0,     6,     5,     0,    56,    57,    54,
      50,    53,    48,    51,    52,    49,    55,    44,    47,    42,
      45,    46,    43,     0,    59,    20,     0,     0,     0,     0,
       0,     0,    12,    66,    67,    68,     0,     0,    35,    40,
       8,    17,     0,     0,     0,     0,     9,    22,    10,    15,
      16,    18,    19,    60,    38,    33,    34,     0,    40,    36,
       0,     0,    23,    24,    25,    26,     0,     0,    37,     0,
      41,    14,     0,     0,     0,    13,    11,    61,    39
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     2,    19,    66,    87,    24,    43,    78,    98,    79,
     108,   101,    64,    28,   106,    33,    76
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -24
static const yytype_int16 yypact[] =
{
      55,     4,    88,   -24,   -24,    46,    46,    -3,   -24,    31,
      17,    45,    57,    62,    71,    73,    67,    26,    46,   -24,
     -24,   -24,   -24,   -24,    18,    29,    79,   -24,   -11,   -24,
     -24,   -24,   -24,    33,   -24,   -24,   -24,   -24,   -24,   -24,
      44,   -23,   -24,    87,   -24,   -24,    48,    49,    50,    51,
     -24,   -24,   -24,   -24,   -24,   -24,    65,   -24,   -24,   -24,
     -24,   -24,   -24,    66,   -24,   -24,   -10,    -2,     2,     8,
      12,    16,   -24,   -24,   -24,   -24,   102,    27,   123,    61,
     -24,   -24,   124,   125,   127,   128,   -24,   -24,   -24,   -24,
     -24,   -24,   -24,   -24,    93,   -24,   -24,    94,    61,   -24,
      46,    75,   -24,   -24,   -24,   -24,    69,   133,   -24,    78,
     -24,   -24,    80,   136,    99,   -24,   -24,   -24,   -24
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -24,   -24,   -24,    85,   -24,    -6,   -24,   -24,   -24,    64,
     -24,    47,   -24,   -24,   -24,   -24,    37
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -31
static const yytype_int8 yytable[] =
{
      25,    26,    47,    48,     3,    82,    83,    84,    85,    73,
      74,    75,    42,    82,    83,    84,    85,    82,    83,    84,
      85,    34,    63,    82,    83,    84,    85,    82,    83,    84,
      85,    82,    83,    84,    85,    49,    50,    51,    52,    53,
      54,    55,    56,    57,    58,    59,    60,    61,    62,    35,
      86,    29,    30,    31,    32,    -2,     1,    27,    88,    20,
      21,    36,    89,    -2,    -2,    -2,    37,    -2,    90,    94,
      95,    96,    91,    40,    -2,    38,    92,    39,    44,    -2,
      -2,    -2,    -2,    -2,    -2,    -2,    -2,    41,     4,    45,
      46,    77,    22,    65,   110,    -2,     5,     6,     7,    23,
       8,    73,    74,    75,    72,    93,   100,     9,    80,   -27,
     -28,   -30,    10,    11,    12,    13,    14,    15,    16,    17,
      67,    68,    69,    70,    71,   -29,    81,    97,    18,   102,
     103,   112,   104,   105,   107,   111,    94,   114,   115,   117,
     116,   118,    99,   113,     0,   109
};

static const yytype_int8 yycheck[] =
{
       6,     4,    13,    14,     0,    15,    16,    17,    18,    32,
      33,    34,    18,    15,    16,    17,    18,    15,    16,    17,
      18,     4,    28,    15,    16,    17,    18,    15,    16,    17,
      18,    15,    16,    17,    18,    46,    47,    48,    49,    50,
      51,    52,    53,    54,    55,    56,    57,    58,    59,     4,
      60,    20,    21,    22,    23,     0,     1,    60,    60,    13,
      14,     4,    60,     8,     9,    10,     4,    12,    60,    42,
      43,    44,    60,     6,    19,     4,    60,     4,    60,    24,
      25,    26,    27,    28,    29,    30,    31,    61,     0,    60,
      11,     4,    46,    60,   100,    40,     8,     9,    10,    53,
      12,    32,    33,    34,    60,     3,    45,    19,    60,    60,
      60,    60,    24,    25,    26,    27,    28,    29,    30,    31,
      35,    36,    37,    38,    39,    60,    60,     4,    40,     5,
       5,    62,     5,     5,    41,    60,    42,     4,    60,     3,
      60,    42,    78,   106,    -1,    98
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     1,    64,     0,     0,     8,     9,    10,    12,    19,
      24,    25,    26,    27,    28,    29,    30,    31,    40,    65,
      13,    14,    46,    53,    68,    68,     4,    60,    76,    20,
      21,    22,    23,    78,     4,     4,     4,     4,     4,     4,
       6,    61,    68,    69,    60,    60,    11,    13,    14,    46,
      47,    48,    49,    50,    51,    52,    53,    54,    55,    56,
      57,    58,    59,    68,    75,    60,    66,    66,    66,    66,
      66,    66,    60,    32,    33,    34,    79,     4,    70,    72,
      60,    60,    15,    16,    17,    18,    60,    67,    60,    60,
      60,    60,    60,     3,    42,    43,    44,     4,    71,    72,
      45,    74,     5,     5,     5,     5,    77,    41,    73,    74,
      68,    60,    62,    79,     4,    60,    60,     3,    42
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
      yyerror (&yylloc, priv_data, chain, YY_("syntax error: cannot back up")); \
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
# define YYLEX yylex (&yylval, &yylloc, YYLEX_PARAM)
#else
# define YYLEX yylex (&yylval, &yylloc)
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
		  Type, Value, Location, priv_data, chain); \
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
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp, parser_priv_t *priv_data, chain_t *chain)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, yylocationp, priv_data, chain)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    YYLTYPE const * const yylocationp;
    parser_priv_t *priv_data;
    chain_t *chain;
#endif
{
  if (!yyvaluep)
    return;
  YYUSE (yylocationp);
  YYUSE (priv_data);
  YYUSE (chain);
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
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, YYLTYPE const * const yylocationp, parser_priv_t *priv_data, chain_t *chain)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, yylocationp, priv_data, chain)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    YYLTYPE const * const yylocationp;
    parser_priv_t *priv_data;
    chain_t *chain;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  YY_LOCATION_PRINT (yyoutput, *yylocationp);
  YYFPRINTF (yyoutput, ": ");
  yy_symbol_value_print (yyoutput, yytype, yyvaluep, yylocationp, priv_data, chain);
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
yy_reduce_print (YYSTYPE *yyvsp, YYLTYPE *yylsp, int yyrule, parser_priv_t *priv_data, chain_t *chain)
#else
static void
yy_reduce_print (yyvsp, yylsp, yyrule, priv_data, chain)
    YYSTYPE *yyvsp;
    YYLTYPE *yylsp;
    int yyrule;
    parser_priv_t *priv_data;
    chain_t *chain;
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
		       , &(yylsp[(yyi + 1) - (yynrhs)])		       , priv_data, chain);
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, yylsp, Rule, priv_data, chain); \
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
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, YYLTYPE *yylocationp, parser_priv_t *priv_data, chain_t *chain)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, yylocationp, priv_data, chain)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    YYLTYPE *yylocationp;
    parser_priv_t *priv_data;
    chain_t *chain;
#endif
{
  YYUSE (yyvaluep);
  YYUSE (yylocationp);
  YYUSE (priv_data);
  YYUSE (chain);

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
int yyparse (parser_priv_t *priv_data, chain_t *chain);
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
yyparse (parser_priv_t *priv_data, chain_t *chain)
#else
int
yyparse (priv_data, chain)
    parser_priv_t *priv_data;
    chain_t *chain;
#endif
#endif
{
  /* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;
/* Location data for the look-ahead symbol.  */
YYLTYPE yylloc;

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

  /* The location stack.  */
  YYLTYPE yylsa[YYINITDEPTH];
  YYLTYPE *yyls = yylsa;
  YYLTYPE *yylsp;
  /* The locations where the error started and ended.  */
  YYLTYPE yyerror_range[2];

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N), yylsp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;
  YYLTYPE yyloc;

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
  yylsp = yyls;
#if YYLTYPE_IS_TRIVIAL
  /* Initialize the default location before parsing starts.  */
  yylloc.first_line   = yylloc.last_line   = 1;
  yylloc.first_column = yylloc.last_column = 0;
#endif

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
	YYLTYPE *yyls1 = yyls;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yyls1, yysize * sizeof (*yylsp),
		    &yystacksize);
	yyls = yyls1;
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
	YYSTACK_RELOCATE (yyls);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;
      yylsp = yyls + yysize - 1;

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
  *++yylsp = yylloc;
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

  /* Default location.  */
  YYLLOC_DEFAULT (yyloc, (yylsp - yylen), yylen);
  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 5:
#line 100 "svf_bison.y"
    {
      svf_endxr(priv_data, generic_ir, (yyvsp[(2) - (3)].token));
    }
    break;

  case 6:
#line 105 "svf_bison.y"
    {
      svf_endxr(priv_data, generic_dr, (yyvsp[(2) - (3)].token));
    }
    break;

  case 7:
#line 110 "svf_bison.y"
    {
        svf_frequency(chain, 0.0);
      }
    break;

  case 8:
#line 115 "svf_bison.y"
    {
        svf_frequency(chain, (yyvsp[(2) - (4)].dvalue));
      }
    break;

  case 9:
#line 120 "svf_bison.y"
    {
        struct ths_params *p = &(priv_data->parser_params.ths_params);

        p->number = (yyvsp[(2) - (4)].dvalue);
        svf_hxr(generic_dr, p);
        svf_free_ths_params(p);
      }
    break;

  case 10:
#line 129 "svf_bison.y"
    {
        struct ths_params *p = &(priv_data->parser_params.ths_params);

        p->number = (yyvsp[(2) - (4)].dvalue);
        svf_hxr(generic_ir, p);
        svf_free_ths_params(p);
      }
    break;

  case 11:
#line 138 "svf_bison.y"
    {
        printf("PIOMAP not implemented\n");
        yyerror(&(yyloc), priv_data, chain, "PIOMAP");
        YYERROR;
      }
    break;

  case 12:
#line 145 "svf_bison.y"
    {
        free((yyvsp[(2) - (3)].cvalue));
        printf("PIO not implemented\n");
        yyerror(&(yyloc), priv_data, chain, "PIO");
        YYERROR;
      }
    break;

  case 13:
#line 153 "svf_bison.y"
    {
        struct runtest *rt = &(priv_data->parser_params.runtest);

        rt->run_state = (yyvsp[(2) - (6)].token);
        rt->run_count = (yyvsp[(3) - (6)].tdval).dvalue;
        rt->run_clk   = (yyvsp[(3) - (6)].tdval).token;
        rt->end_state = (yyvsp[(5) - (6)].token);

        if (!svf_runtest(chain, priv_data, rt)) {
          yyerror(&(yyloc), priv_data, chain, "RUNTEST");
          YYERROR;
        }
      }
    break;

  case 14:
#line 168 "svf_bison.y"
    {
        struct runtest *rt = &(priv_data->parser_params.runtest);

        rt->run_state = (yyvsp[(2) - (5)].token);
        rt->run_count = 0;
        rt->run_clk   = 0;
        rt->end_state = (yyvsp[(4) - (5)].token);

        if (!svf_runtest(chain, priv_data, rt)) {
          yyerror(&(yyloc), priv_data, chain, "RUNTEST");
          YYERROR;
        }
      }
    break;

  case 15:
#line 183 "svf_bison.y"
    {
        struct ths_params *p = &(priv_data->parser_params.ths_params);
        int result;

        p->number = (yyvsp[(2) - (4)].dvalue);
        result = svf_sxr(chain, priv_data, generic_dr, p, &(yyloc));
        svf_free_ths_params(p);

        if (!result) {
          yyerror(&(yyloc), priv_data, chain, "SDR");
          YYERROR;
        }
      }
    break;

  case 16:
#line 198 "svf_bison.y"
    {
        struct ths_params *p = &(priv_data->parser_params.ths_params);
        int result;

        p->number = (yyvsp[(2) - (4)].dvalue);
        result = svf_sxr(chain, priv_data, generic_ir, p, &(yyloc));
        svf_free_ths_params(p);

        if (!result) {
          yyerror(&(yyloc), priv_data, chain, "SIR");
          YYERROR;
        }
      }
    break;

  case 17:
#line 213 "svf_bison.y"
    {
        if (!svf_state(chain, priv_data, &(priv_data->parser_params.path_states), (yyvsp[(3) - (4)].token))) {
          yyerror(&(yyloc), priv_data, chain, "STATE");
          YYERROR;
        }
      }
    break;

  case 18:
#line 221 "svf_bison.y"
    {
        struct ths_params *p = &(priv_data->parser_params.ths_params);
        int result;

        p->number = (yyvsp[(2) - (4)].dvalue);
        result = svf_txr(generic_dr, p);
        svf_free_ths_params(p);

        if (!result) {
          yyerror(&(yyloc), priv_data, chain, "TDR");
          YYERROR;
        }
      }
    break;

  case 19:
#line 236 "svf_bison.y"
    {
        struct ths_params *p = &(priv_data->parser_params.ths_params);
        int result;

        p->number = (yyvsp[(2) - (4)].dvalue);
        result = svf_txr(generic_ir, p);
        svf_free_ths_params(p);

        if (!result) {
          yyerror(&(yyloc), priv_data, chain, "TIR");
          YYERROR;
        }
      }
    break;

  case 20:
#line 251 "svf_bison.y"
    {
      if (!svf_trst(chain, priv_data, (yyvsp[(2) - (3)].token))) {
        yyerror(&(yyloc), priv_data, chain, "TRST");
        YYERROR;
      }
    }
    break;

  case 23:
#line 267 "svf_bison.y"
    {
                priv_data->parser_params.ths_params.tdi = (yyvsp[(2) - (2)].cvalue);
              }
    break;

  case 24:
#line 272 "svf_bison.y"
    {
                priv_data->parser_params.ths_params.tdo = (yyvsp[(2) - (2)].cvalue);
              }
    break;

  case 25:
#line 277 "svf_bison.y"
    {
                priv_data->parser_params.ths_params.mask = (yyvsp[(2) - (2)].cvalue);
              }
    break;

  case 26:
#line 282 "svf_bison.y"
    {
                priv_data->parser_params.ths_params.smask = (yyvsp[(2) - (2)].cvalue);
              }
    break;

  case 31:
#line 295 "svf_bison.y"
    { (yyval.token) = 0; }
    break;

  case 32:
#line 297 "svf_bison.y"
    {
                (yyval.token) = (yyvsp[(1) - (1)].token);
              }
    break;

  case 33:
#line 304 "svf_bison.y"
    {
                (yyval.tdval).token  = (yyvsp[(2) - (2)].token);
                (yyval.tdval).dvalue = (yyvsp[(1) - (2)].dvalue);
              }
    break;

  case 34:
#line 310 "svf_bison.y"
    {
                (yyval.tdval).token  = (yyvsp[(2) - (2)].token);
                (yyval.tdval).dvalue = (yyvsp[(1) - (2)].dvalue);
              }
    break;

  case 35:
#line 318 "svf_bison.y"
    {
                priv_data->parser_params.runtest.min_time = 0.0;
                priv_data->parser_params.runtest.max_time = 0.0;
              }
    break;

  case 37:
#line 328 "svf_bison.y"
    {
                priv_data->parser_params.runtest.min_time = (yyvsp[(1) - (3)].dvalue);
              }
    break;

  case 38:
#line 335 "svf_bison.y"
    {
                priv_data->parser_params.runtest.max_time = 0.0;
              }
    break;

  case 39:
#line 339 "svf_bison.y"
    {
                priv_data->parser_params.runtest.max_time = (yyvsp[(2) - (3)].dvalue);
              }
    break;

  case 40:
#line 345 "svf_bison.y"
    { (yyval.token) = 0; }
    break;

  case 41:
#line 347 "svf_bison.y"
    {
                (yyval.token) = (yyvsp[(2) - (2)].token);
              }
    break;

  case 58:
#line 373 "svf_bison.y"
    {
                priv_data->parser_params.path_states.num_states = 0;
              }
    break;

  case 59:
#line 378 "svf_bison.y"
    {
                struct path_states *ps = &(priv_data->parser_params.path_states);

                if (ps->num_states < MAX_PATH_STATES) {
                  ps->states[ps->num_states] = (yyvsp[(2) - (2)].token);
                  ps->num_states++;
                } else
                  printf("Error %s: maximum number of %d path states reached.\n",
                        "svf", MAX_PATH_STATES);
              }
    break;


/* Line 1267 of yacc.c.  */
#line 1931 "svf_bison.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;
  *++yylsp = yyloc;

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
      yyerror (&yylloc, priv_data, chain, YY_("syntax error"));
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
	    yyerror (&yylloc, priv_data, chain, yymsg);
	  }
	else
	  {
	    yyerror (&yylloc, priv_data, chain, YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }

  yyerror_range[0] = yylloc;

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
		      yytoken, &yylval, &yylloc, priv_data, chain);
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

  yyerror_range[0] = yylsp[1-yylen];
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

      yyerror_range[0] = *yylsp;
      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp, yylsp, priv_data, chain);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;

  yyerror_range[1] = yylloc;
  /* Using YYLLOC is tempting, but would change the location of
     the look-ahead.  YYLOC is available though.  */
  YYLLOC_DEFAULT (yyloc, (yyerror_range - 1), 2);
  *++yylsp = yyloc;

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
  yyerror (&yylloc, priv_data, chain, YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, &yylloc, priv_data, chain);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, yylsp, priv_data, chain);
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


#line 408 "svf_bison.y"



void
yyerror(YYLTYPE *locp, parser_priv_t *priv_data, chain_t *chain, const char *error_string)
{
  printf("Error occurred for SVF command %s.\n", error_string);
}


static void
svf_free_ths_params(struct ths_params *params)
{
  params->number = 0.0;

  if (params->tdi) {
    free(params->tdi);
    params->tdi = NULL;
  }
  if (params->tdo) {
    free(params->tdo);
    params->tdo = NULL;
  }
  if (params->mask) {
    free(params->mask);
    params->mask = NULL;
  }
  if (params->smask) {
    free(params->smask);
    params->smask = NULL;
  }
}


int
svf_bison_init(parser_priv_t *priv_data, FILE *f, int num_lines, int print_progress)
{
  const struct svf_parser_params params = {
    {0.0, NULL, NULL, NULL, NULL},
    {{}, 0},
    {0, 0.0, 0, 0, 0, 0}
  };

  priv_data->parser_params = params;

  if ((priv_data->scanner = svf_flex_init(f, num_lines, print_progress)) == NULL)
    return 0;
  else
    return 1;
}


void
svf_bison_deinit(parser_priv_t *priv_data)
{
  svf_flex_deinit(priv_data->scanner);
}

