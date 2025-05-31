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
#include <stdint.h>

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
int   string_len = 0;
bool  null_in_string = false;
extern int curr_lineno;

extern int verbose_flag;
extern YYSTYPE cool_yylval;

/*  Add Your own definitions here*/

%}

/* Define names for regular expressions here. */

DARROW          =>
DIGIT		[0-9]
CHAR		[a-zA-Z]
NEWLINE		[\n]
WHITESPACE	[ \f\r\v\t]+
TRUE		t[rR][uU][eE]
FALSE		f[aA][lL][sS][eE]
INTEGER		{DIGIT}+
OBJID		[a-z][a-zA-Z0-9_]*
TYPEID		[A-Z][a-zA-Z0-9_]*
ASSIGN		<-
LE		<=

%x LINE_COMMENT
%x BLOCK_COMMENT
%x STRING

%%

"--"			{ BEGIN(LINE_COMMENT);	  }
<LINE_COMMENT>\n	{ BEGIN(0); curr_lineno++;}
<LINE_COMMENT>.		{ /* IGNORE */		  }

"*)"			{cool_yylval.error_msg = "Unmatched *)"; return(ERROR);}
"(*"			{ BEGIN(BLOCK_COMMENT);   }
<BLOCK_COMMENT>"*)"     { BEGIN(0);		  }
<BLOCK_COMMENT><<EOF>>	{ BEGIN(0);cool_yylval.error_msg = "EOF in comment";return(ERROR);}
<BLOCK_COMMENT>\n	{ curr_lineno++; 	  }
<BLOCK_COMMENT>.	{ /* IGNORE */		  }

{DARROW}		{ return (DARROW);	}
{ASSIGN}		{ return(ASSIGN);	}
{LE}			{ return(LE);		}


 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  */

(?i:class)		{ return(CLASS);	}
(?i:else)		{ return(ELSE);		}
(?i:fi)			{ return(FI); 		}
(?i:if)			{ return(IF); 		}
(?i:in)			{ return(IN); 		}
(?i:inherits)		{ return(INHERITS);	}
(?i:let)		{ return(LET); 		}
(?i:loop)		{ return(LOOP); 	}
(?i:pool)		{ return(POOL); 	}
(?i:then)		{ return(THEN); 	}
(?i:while)		{ return(WHILE);	}
(?i:case)		{ return(CASE);		}
(?i:esac)		{ return(ESAC);		}
(?i:of)			{ return(OF); 		}
(?i:new)		{ return(NEW);		}
{TRUE}			{ cool_yylval.boolean = 1; return (BOOL_CONST);  }
{FALSE}			{ cool_yylval.boolean = 0; return (BOOL_CONST);  }

"("			{ return('(');		}
")"			{ return ')'; 		}
"@"			{ return '@'; 		}
"~"			{ return '~'; 		}
","			{ return ','; 		}
";"			{ return ';'; 		}
":"			{ return ':'; 		}
"+"			{ return '+'; 		}
"-"			{ return '-'; 		}
"*"			{ return '*'; 		}
"/"			{ return '/'; 		}
"%"			{ return '%'; 		}
"."			{ return '.'; 		}
"<"			{ return '<'; 		}
"="			{ return '='; 		}
"{"			{ return '{'; 		}
"}"			{ return '}'; 		}


\"			{ 
			  BEGIN(STRING);
			  memset(string_buf, 0, MAX_STR_CONST);
			  string_len = 0;
			  string_buf_ptr = string_buf;
			  null_in_string = false;
			}
<STRING>\"		{ 
			  if (string_len > 1 && null_in_string){
				cool_yylval.error_msg = "String contains null character";
				BEGIN(0);
				return(ERROR);
			  }
			  
			  string_buf[string_len] = '\0';
			  cool_yylval.symbol = stringtable.add_string(string_buf);
			  BEGIN(0);
			  return(STR_CONST);
			}
<STRING><<EOF>>		{ 
			  cool_yylval.error_msg = "EOF in string constant";
			  BEGIN(0);
			  return(ERROR);
			}
<STRING>\\.		{
			  if (string_len >= MAX_STR_CONST - 1){
				cool_yylval.error_msg = "String constant too long";
				BEGIN(0);
				return(ERROR);
			  }
				
			  switch(yytext[1]) {
				case '\"': string_buf[string_len++] = '\"'; break;
				case '\\': string_buf[string_len++] = '\\'; break;
				case 'b' : string_buf[string_len++] = '\b'; break;
				case 'f' : string_buf[string_len++] = '\f'; break;
				case 'n' : string_buf[string_len++] = '\n'; break;
				case 't' : string_buf[string_len++] = '\t'; break;
				case '0' : string_buf[string_len++] = 0; 
					   null_in_string = true;
					   break;
				default  : string_buf[string_len++] = yytext[1];

			  }
			}
<STRING>\\\n		{ 
			  if (string_len >= MAX_STR_CONST - 1){
				cool_yylval.error_msg = "String constant too long";
				BEGIN(0);
				return(ERROR);
			  }
			  string_buf[string_len++] = '\n';
			  curr_lineno++;	
			}
<STRING>\n		{ 
			  curr_lineno++;
			  cool_yylval.error_msg = "Unterminated string constant";
			  BEGIN(0);
			  return(ERROR);
			}
<STRING>.		{
			  if (string_len >= MAX_STR_CONST - 1) {
				cool_yylval.error_msg = "String constant too long";
				BEGIN(0);
				return(ERROR);
			  }
			  string_buf[string_len++] = yytext[0];
			}

{INTEGER}		{ cool_yylval.symbol = inttable.add_string(yytext);return (INT_CONST);	}
{TYPEID}		{ cool_yylval.symbol = stringtable.add_string(yytext);return (TYPEID);}
{OBJID}			{cool_yylval.symbol = idtable.add_string(yytext);return (OBJECTID);}

{WHITESPACE}+		{ /* IGNORE */		}
{NEWLINE}		{ curr_lineno++;	}

 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */

.			{
			  cool_yylval.error_msg = yytext;
			  return(ERROR);
			}

%%
