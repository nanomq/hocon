%{
#include <stdio.h>
#include <stdlib.h>
#include "cJSON.h"
#include "string.h"
#define YYDEBUG 1
extern int yylex();
extern FILE *yyin;

struct jso_kv {
        char *key;
        cJSON *val;
};

void yyerror(struct cJSON** jso, int *result, const char*);

%}

%parse-param {struct cJSON **jso} {int *result}


%union {
    int intval;
    double floatval;
    char *strval;
    struct cJSON *jsonval;
    struct jso_kv *jkval;
}


%token LCURLY RCURLY LBRAC RBRAC COMMA PUNCT
%token VTRUE VFALSE VNULL
%token <strval> STRING;
%token <strval> USTRING;
%token <strval> RSTRING;
%token <strval> BYTESIZE;
%token <strval> PERCENT;
%token <strval> DURATION;
%token <floatval> DECIMAL;
%token <intval> INTEGER;
%type <jsonval> value
%type <jsonval> values
%type <jkval> member
%type <jsonval> members
%type <jsonval> object
%type <jsonval> array
%type <jsonval> json



%%

json:
        | value {*result = 1024; *jso =  $1;}
        ;

value: object      { $$ = $1; /*printf("[OB]: %s\n", cJSON_PrintUnformatted($1));*/ }
        | array    { $$ = $1; /*printf("[AR]: %s\t", cJSON_PrintUnformatted($1));*/ }
        | STRING   { char *str = strdup($1); str++; int len = strlen(str); str[len-1] = '\0'; $$ = cJSON_CreateString(str); }
        | USTRING  { $$ = cJSON_CreateString($1); }
        | DECIMAL  { $$ = cJSON_CreateNumber($1); }
        | INTEGER  { $$ = cJSON_CreateNumber($1); }
        | VTRUE    { $$ = cJSON_CreateTrue(); }
        | VFALSE   { $$ = cJSON_CreateFalse(); }
        | VNULL    { $$ = cJSON_CreateNull(); }
        | BYTESIZE { $$ = cJSON_CreateString($1); }
        | DURATION { $$ = cJSON_CreateString($1); }
        | PERCENT  { $$ = cJSON_CreateString($1); }
        ;

object: LCURLY RCURLY            { /*printf("{}\n");*/ }
        | LCURLY members RCURLY  { $$ = $2; }
        | members                { $$ = $1; }
        ;

members: member                  { $$ = cJSON_CreateObject();  cJSON_AddItemToObject($$, $1->key, $1->val); /*printf("%s\t", cJSON_PrintUnformatted($$));*/}
        | members COMMA member   { cJSON_AddItemToObject($$, $3->key, $3->val); /*printf("%s\t", cJSON_PrintUnformatted($$));*/ }
        | members member   { cJSON_AddItemToObject($$, $2->key, $2->val); /*printf("%s\t", cJSON_PrintUnformatted($$));*/ }
        ;

member: STRING PUNCT value       { $$ = (struct jso_kv *) malloc(sizeof(struct jso_kv)); char *str = strdup($1); str++; int len = strlen(str); str[len-1] = '\0'; $$->key = str, $$->val = $3; /*printf("%s\n", cJSON_PrintUnformatted($3));*/ }
        | USTRING PUNCT value       { $$ = (struct jso_kv *) malloc(sizeof(struct jso_kv)); $$->key = $1, $$->val = $3; /*printf("%s\n", cJSON_PrintUnformatted($3));*/ }
        | USTRING LCURLY value RCURLY      { $$ = (struct jso_kv *) malloc(sizeof(struct jso_kv)); $$->key = $1, $$->val = $3; /*printf("%s\n", cJSON_PrintUnformatted($3));*/ }
        | USTRING LBRAC values RBRAC      { $$ = (struct jso_kv *) malloc(sizeof(struct jso_kv)); $$->key = $1, $$->val = $3; /*printf("%s\n", cJSON_PrintUnformatted($3));*/ }
        ;

array: LBRAC RBRAC               { /*printf("[]\n"); */}
        | LBRAC values RBRAC     { $$ = $2; /*printf("[values]\n");*/ }
        ;

values: value                    { $$ = cJSON_CreateArray(); cJSON_AddItemToArray($$, $1); /*printf("%s\n", cJSON_PrintUnformatted($1));*/ }
        | values COMMA value     { cJSON_AddItemToArray($$, $3); /*printf("%s\n", cJSON_PrintUnformatted($$));*/ }
        | values value     { cJSON_AddItemToArray($$, $2); /*printf("%s\n", cJSON_PrintUnformatted($$));*/}
        ;


%%


int main(int argc, char **argv) {
        // yydebug = 1;

        if (argc > 1) {
                if (!(yyin = fopen(argv[1], "r"))) {
                        perror((argv[1]));
                        return 1;
                }

        }

        int result = 0;
        cJSON *jso = cJSON_CreateObject();
        int rv = yyparse(&jso, &result);
        printf("json : %s\n", cJSON_PrintUnformatted(jso));

}

void yyerror(struct cJSON **jso, int *result, const char *s)
{
    fprintf(stderr, "error: %s\n", s);
}