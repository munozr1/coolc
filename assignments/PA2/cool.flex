/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */

%{

#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */

#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */

#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */

#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;
extern int curr_lineno;

extern int verbose_flag;
extern YYSTYPE cool_yylval;

/*  Add Your own definitions here*/

%}

/* Define names for regular expressions here. */

DARROW          =>
DIGIT		[0-9]
NEWLINE		[\n]
WHITESPACE	[ \t]
TRUE		t[rR][uU][eE]
FALSE		f[aA][lL][sS][eE]

%%

 /*
  * TODO
	"ISVOID"		{ return(ISVOID); }
	"STR_CONST"		{ return(STR_CONST); }
	"INT_CONST"		{ return(INT_CONST); }
	"BOOL_CONST"		{ return(BOOL_CONST); }
	"TYPEID"		{ return(TYPEID); }
	"OBJECTID"		{ return(OBJECTID); }
	"ASSIGN"		{ return(ASSIGN); }
	"NOT"		{ return(NOT); }
	"LE"		{ return(LE); }
	"ERROR"		{ return(ERROR); }
	"SELF_TYPE" 		{ return(SELF_TYPE);	}
  */


 /*
  *  The multiple-character operators.
  */

{DARROW}		{ return (DARROW);	}
{TRUE}			{ cool_yylval.boolean = 1;return (BOOL_CONST);  }
{FALSE}			{ cool_yylval.boolean = 0;return (BOOL_CONST);  }
"class"			{ return(CLASS);	}
"else"			{ return(ELSE);		}
"fi"			{ return(FI); 		}
"if"			{ return(IF); 		}
"in"			{ return(IN); 		}
"inherits"		{ return(INHERITS); 	}
"let"			{ return(LET); 		}
"loop"			{ return(LOOP); 	}
"pool"			{ return(POOL); 	}
"then"			{ return(THEN); 	}
"while"			{ return(WHILE); 	}
"case"			{ return(CASE); 	}
"esac"			{ return(ESAC); 	}
"of"			{ return(OF); 		}
"new" 			{ return(NEW); 		}


{WHITESPACE}+
{NEWLINE}		{ ++curr_lineno;	}
.			{ 
				cool_yylval.error_msg = "TODO";
				return(ERROR);	
			}

 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */


%%
