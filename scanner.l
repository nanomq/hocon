%{
#include <string.h>
#include "y.tab.h"

%}
/*%option debug*/ 
%option noyywrap


Comment             (("#"|"//")[^\n]*)
WhiteSpace          ([ \t\r]+)
Ignored             {WhiteSpace}|{Comment}

EXP ([Ee][-+]?[0-9]+)
Letter              [A-Za-z]
Unquoted            {Letter}[A-Za-z0-9_\.@%\-\|\\"]*

Punctuator          [{}\[\],:=]

Digit               [0-9]
Sign                [+\-]
Integer             {Sign}?({Digit}+)

Percent             {Digit}+%
Bytesize            {Digit}+(kb|KB|mb|MB|gb|GB)
Duration            {Digit}+(d|D|h|H|m|M|s|S|us|ms|MS)


%%
{Ignored}
"{" { return LCURLY; }
"}" { return RCURLY; } 
"[" { return LBRAC; } 
"]" { return RBRAC; } 
"," { return COMMA; } 
{Punctuator} {return PUNCT;}
"true" { return VTRUE; } 
"false" { return VFALSE; } 
"null" { return VNULL; } 
[ \t\r\n]+ { } 
{Bytesize} {  yylval.strval = strdup(yytext); return BYTESIZE; }
{Percent} {  yylval.strval = strdup(yytext); return PERCENT; }
{Duration} {  yylval.strval = strdup(yytext); return DURATION; }
\"[^"]*\" {  yylval.strval = strdup(yytext); return STRING; } 
\"([^\"]|\\\")*\" {  yylval.strval = strdup(yytext); return STRING; } 
{Unquoted} {  yylval.strval = strdup(yytext); return USTRING; } 
-?[0-9]+ { yylval.intval  = atoi(yytext); return INTEGER; } 
-?[0-9]+\.?[0-9]*{EXP}? { yylval.floatval = atof(yytext); return DECIMAL ; } 
.                 {printf("Unrecognized %c\n", yytext[0]); }

%%


