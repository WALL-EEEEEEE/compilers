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
#include<stdlib.h>
#include <iostream>
#include <string.h>

using namespace std;
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
//Macro for reading from source file
#define YY_INPUT(buf,result,max_size) \
	if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
		YY_FATAL_ERROR( "read() in flex scanner failed");

int yy_error(const char* msg);
char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;
extern int verbose_flag;
extern YYSTYPE cool_yylval;

int yy_error(const char* err_msg) {
    fprintf(stderr,"%s\n", err_msg);
    return 1;
}

/*
 *  Add Your own definitions here
 */
%}

%x STRING COMMENT
%option yylineno
%option stack

DIGIT [0-9]
ID    [0-9a-zA-Z_]+
TRUE  t(?i:rue)
FALSE f(?i:alse)
NEW   (?i:new)
CLASS (?i:class)
INHERITS (?i:inherits)
ELSE  (?i:else)
IF    (?i:if)
FI    (?i:fi)
THEN  (?i:then)
IN    (?i:in)
LET   (?i:let)
LOOP  (?i:loop)
POOL  (?i:pool)
WHILE (?i:while)
CASE  (?i:case)
ESAC  (?i:esac)
OF    (?i:of)
DARROW "=>"
ISVOID (?i:isvoid)
ASSIGN "<-"
NOT    (?i:not)
LE     "<="
LET_STMT ""
VALID_SYMBOL [{}();,:.+\-*/~<=@]
SPACE [ \t\f\v]
NEWLINE [\n\r]
INVALID_SYMBOL .

%%

"--"[^\n\r]*    /* sweep one line comments */

{SPACE}+   /** Eat up all spaces **/

{NEWLINE} /** Eat up empty new line **/

\"    string_buf_ptr=string_buf; BEGIN(STRING);

<STRING>\" {
    curr_lineno = yylineno;
    *string_buf_ptr++='\0';
    if(strlen(string_buf) >= MAX_STR_CONST) {
        cool_yylval.error_msg = "String constant too long";
        BEGIN(INITIAL);
        return ERROR;
    } 
    cool_yylval.symbol = inttable.add_string(string_buf);
    BEGIN(INITIAL);
    return STR_CONST;
}


<STRING>.*\0[^\n\"]*\"? {
    //printf("---->%s<----\n", yytext);
    curr_lineno = yylineno;
    cool_yylval.error_msg = "String contains null character";
    BEGIN(INITIAL);
    return ERROR;
}


<STRING><<EOF>> {
    curr_lineno = yylineno;
    cool_yylval.error_msg = "EOF in string constant";
    BEGIN(INITIAL);
    return ERROR;
}
<STRING>{
    \\n *string_buf_ptr++='\n';
    \\b   *string_buf_ptr++='\b';
    \\f   *string_buf_ptr++='\f';
    \\t   *string_buf_ptr++='\t';
    \\\n   *string_buf_ptr++='\n';
    \\.   *string_buf_ptr++=yytext[1];
} 

<STRING>[^\"\\]*\n {
    curr_lineno = yylineno;
    cool_yylval.error_msg = "Unterminated string constant";
    BEGIN(INITIAL);
    return ERROR;
}

<STRING>[^\"\\\0\n]+ {
    char* yy_text_ptr = yytext;
    while(*yy_text_ptr) {
        *string_buf_ptr++ = *yy_text_ptr++;
    }
}

"(*"  yy_push_state(COMMENT);

<COMMENT>{
    [^\\*)]*"(*" {
        //printf("Enter a new comment state\n");
        yy_push_state(COMMENT);
    }
    \\. 
    [^*\\]+ {
       //printf("Elimiate1: %s\n", yytext);
    }
    [*]+[^*\\)]*  {
       //printf("Elimiate2: %s\n", yytext);
    }
    <<EOF>>  {
        curr_lineno = yylineno;
        cool_yylval.error_msg = "EOF in comment";
        BEGIN(INITIAL);
        return ERROR;
    }
    "*"+")"  {
        //printf("Encounter: ---->%s<---- in lineno:%d, comment state exit.\n", yytext, yylineno);
        yy_pop_state();
    }
}

"*"+")" {
    curr_lineno = yylineno;
    cool_yylval.error_msg = "Unmatched *)";
    return ERROR;
} 

{TRUE} {
    curr_lineno = yylineno;
    cool_yylval.boolean = true;
    return BOOL_CONST;
}

{FALSE} {
    curr_lineno = yylineno;
    cool_yylval.boolean = false;
    return BOOL_CONST;
}

{CLASS} {
    curr_lineno = yylineno;
    return CLASS;
}

{NEW} {
    curr_lineno = yylineno;
    return NEW;
}

{INHERITS} {
    curr_lineno = yylineno;
    return INHERITS;
}

{ELSE} {
    curr_lineno = yylineno;
    return ELSE;
}

{IF} {
    curr_lineno = yylineno;
    return IF;
}
{FI} {
    curr_lineno = yylineno;
    return FI;
}

{THEN} {
    curr_lineno = yylineno;
    return THEN;
}

{IN} {
    curr_lineno = yylineno;
    return IN;
}

{LET} {
    curr_lineno = yylineno;
    return LET;
}

{LOOP} {
    curr_lineno = yylineno;
    return LOOP;
}

{POOL} {
    curr_lineno = yylineno;
    return POOL;
}

{WHILE} {
    curr_lineno = yylineno;
    return WHILE;
}

{CASE} {
    curr_lineno = yylineno;
    return CASE;
}

{ESAC} {
    curr_lineno = yylineno;
    return ESAC;
}
{OF} {
    curr_lineno = yylineno;
    return OF;
}
{DARROW} {
    curr_lineno = yylineno;
    return DARROW;
}

{ISVOID} {
    curr_lineno = yylineno;
    return ISVOID;
}
{ASSIGN} {
    curr_lineno = yylineno;
    return ASSIGN;
}
{NOT} {
    curr_lineno = yylineno;
    return NOT;
}
{LE} {
    curr_lineno = yylineno;
    return LE;
}

{VALID_SYMBOL} {
    curr_lineno = yylineno;
    return yytext[0];
}

{DIGIT}+ {
    cool_yylval.symbol = inttable.add_string(yytext);
    curr_lineno = yylineno;
    return INT_CONST;
}

[A-Z]{ID}* {
    cool_yylval.symbol = inttable.add_string(yytext);
    curr_lineno = yylineno;
    return TYPEID;
}

[a-z]{ID}* {
    cool_yylval.symbol = inttable.add_string(yytext);
    curr_lineno = yylineno;
    return OBJECTID;
}
. {
    cool_yylval.error_msg = yytext;
    curr_lineno = yylineno;
    return ERROR;
}



 /*
  * Keywords are case-insensitive except for the values true and false,
  * which must begin with a lower-case letter.
  *
 */


 /*
  *  String constants (C syntax)
  *  Escape sequence \c is accepted for all characters c. Except for 
  *  \n \t \b \f, the result is c.
  *
  */
%%
