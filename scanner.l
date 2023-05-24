%{
#include <string.h>
#include "parser.h"

#define MAX_INCLUDE_DEPTH 10
YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];
int include_stack_ptr = 0;
int bcount = 0; // brace count
int count_brace(char *);
%}

/* %option debug */
%option noyywrap

/* the "incl" state is used for picking up the name
 * of an include file
 */
%x incl
%x inclr

Comment                 (("#"|"//")[^\n]*)
WhiteSpace              ([ \t\r\n]+)
Ignored                 {WhiteSpace}|{Comment}

EXP                     ([Ee][-+]?[0-9]+)
Letter                  [A-Za-z]
Unquoted                {Letter}[A-Za-z0-9_\.@%\-\|\\"]*
Quoted                  \"([^\"]|\\\")*\"

Hex                     [0-9A-Fa-f]
Escape                  ["\\bfnrt]
UnicodeEscape           u{Hex}{Hex}{Hex}{Hex}
Char                    ([^\"]|\\{Escape}|\\{UnicodeEscape})
String                  "{Char}*"
MultilineChar           ([^"]|"[^"]|""[^"]|\\{Escape}|\\{UnicodeEscape})
MultilineString         """{MultilineChar}*"""
Include                 [ \t]*include[ \t]*\"
IncludeFile             [ \t]*include[ \t]*file\([ \t]*\"
Includes                {Include}|{IncludeFile}

IncludeReq              [ \t]*include[ \t]*required\([ \t]*\"
IncludeFileReq          [ \t]*include[ \t]*required\([ \t]*file\([ \t]*\"
IncludesReq             {IncludeReq}|{IncludeFileReq}


Punctuator              [{}\[\],:=]

Variable                \$\{{Unquoted}\}
MaybeVar                \$\{\?{Unquoted}\}

Digit                   [0-9]
Sign                    [+\-]
Integer                 {Sign}?({Digit}+)
Decimal                 {Integer}\.?[0-9]*{EXP}?

Percent                 {Digit}+%
Bytesize                {Digit}+(kb|KB|mb|MB|gb|GB)
Duration                {Digit}+(d|D|h|H|m|M|s|S|us|ms|MS)

Null                    null
True                    true 
False                   false
Lcurly                  "{"
Rcurly                  "}"
Lbrac                   "["
Rbrac                   "]"
Comma                   ","


%%
{Ignored}
{Lcurly}                { return LCURLY; }
{Rcurly}                { return RCURLY; } 
{Lbrac}                 { return LBRAC; } 
{Rbrac}                 { return RBRAC; } 
{Comma}                 { return COMMA; } 
{Punctuator}            { return PUNCT;}
{True}                  { return VTRUE; } 
{False}                 { return VFALSE; }
{Null}                  { return VNULL; } 

{IncludesReq}           { BEGIN(inclr); bcount = count_brace(yytext);}
<inclr>[ \t]*            /* eat the whitespace */
<inclr>[^ \t\n\"\)]+    {  /* got the include file name */
                            {
                                int c;
                                while ((c = input()) && c != ')');
                            }

                            if (include_stack_ptr >= MAX_INCLUDE_DEPTH) {
                                fprintf(stderr, "Includes nested too deeply!");
                                exit(1);
                            }

                            include_stack[include_stack_ptr++] =
                                YY_CURRENT_BUFFER;

                            yyin = fopen(yytext, "r");

                            if (bcount == 2) {
                                int c = 0;
                                while ((c = input()) && c != ')');
                            }

                            if (!yyin) {
                                fprintf(stderr, "File %s is not exist!\n", yytext);
                                yyterminate();
                            } else {
                                yy_switch_to_buffer(
                                    yy_create_buffer(yyin, YY_BUF_SIZE));
                            }
                            BEGIN(INITIAL);

                        }
<inclr>.|\n                 {   fprintf(stderr, "Include error occured!\n"); yyterminate();}

{Includes}              { BEGIN(incl); bcount = count_brace(yytext); }
<incl>[ \t]*            /* eat the whitespace */
<incl>[^ \t\n\"]+       {  /* got the include file name */
                            {
                                int c;
                                while ((c = input()) && c != '"');
                            }

                            if (include_stack_ptr >= MAX_INCLUDE_DEPTH) {
                                fprintf(stderr, "Includes nested too deeply!\n");
                                exit(1);
                            }

                            include_stack[include_stack_ptr++] =
                                YY_CURRENT_BUFFER;

                            yyin = fopen(yytext, "r");

                            if (bcount == 1) {
                                int c = 0;
                                while ((c = input()) && c != ')');
                            }


                            if (!yyin) {
                                fprintf(stderr, "File %s is not exist!\n", yytext);
                                include_stack_ptr--;
                            } else {
                                yy_switch_to_buffer(
                                    yy_create_buffer(yyin, YY_BUF_SIZE));
                            }
                            BEGIN(INITIAL);

                        }
<incl>.|\n                 {   fprintf(stderr, "Include error occured!\n"); yyterminate();}
<<EOF>>                 {
                            if ( --include_stack_ptr < 0 )
                            {
                                yyterminate();
                            }
                            else
                            {
                               yy_delete_buffer(YY_CURRENT_BUFFER);
                               yy_switch_to_buffer(
                                 include_stack[include_stack_ptr]);
                            }
                        }
{Bytesize}              { yylval.strval = strdup(yytext); return BYTESIZE; }
{Percent}               { yylval.strval = strdup(yytext); return PERCENT; }
{Duration}              { yylval.strval = strdup(yytext); return DURATION; }
{Quoted}                { yylval.strval = strdup(yytext); return STRING; } 
{Unquoted}              { yylval.strval = strdup(yytext); return USTRING; } 
{Integer}               { yylval.intval  = atoll(yytext); return INTEGER; }
{Decimal}               { yylval.floatval = atof(yytext); return DECIMAL; } 
{MultilineString}       { /*TODO*/ printf("Multi line string: %s\n", yytext);}
{Variable}              { /*TODO*/ printf("Variable string: %s\n", yytext);}
{MaybeVar}              { /*TODO*/ printf("MaybeVar line string: %s\n", yytext);}
.                       { printf("Unrecognized %c\n", yytext[0]); }

%%

int count_brace(char *str)
{
  int count = 0;
  while (*str != '"') {
    str++;
    if (*str == '(')
      count++;
  }
  return count;
}