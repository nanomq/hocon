%{
#include <stdio.h>
#include "cJSON.h"
#include "cvector.h"
#include <string.h>
#include <stdlib.h>
// #define YYDEBUG 1

extern int yylex();
struct jso_kv {
        char *key;
        cJSON *val;
};


extern void jso_kv_free(struct jso_kv *kv);
extern struct jso_kv *jso_kv_new(char *key, struct cJSON *val);
extern char *remove_white_space(char *str);
extern char *remove_escape(char *str);
extern void yyerror(struct cJSON** jso, const char*);
extern int hocon_parse(int argc, char **argv);

%}

%parse-param {struct cJSON **jso}


%union {
    double intval;
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

%destructor { jso_kv_free($$); }  member
%destructor { cJSON_Delete($$); } members value values
%destructor { free($$); } STRING USTRING BYTESIZE DURATION PERCENT

%%

json:  value {*jso =  $1;}
        | error
        ;

value: object      { $$ = $1;}
        | array    { $$ = $1;}
        | STRING   { 
                        char *str = remove_escape($1);
                        free($1);
                        $$ = cJSON_CreateString(str); 
                        free(str);
                   }
        | USTRING  { $$ = cJSON_CreateString($1); free($1);}
        | DECIMAL  { $$ = cJSON_CreateNumber($1); }
        | INTEGER  { $$ = cJSON_CreateNumber($1); }
        | VTRUE    { $$ = cJSON_CreateTrue(); }
        | VFALSE   { $$ = cJSON_CreateFalse(); }
        | VNULL    { $$ = cJSON_CreateNull(); }
        | BYTESIZE { $$ = cJSON_CreateString($1); free($1);}
        | DURATION { $$ = cJSON_CreateString($1); free($1);}
        | PERCENT  { $$ = cJSON_CreateString($1); free($1);}
        ;

object: LCURLY RCURLY           { $$ = NULL; printf("{}\n");}
        | LCURLY members RCURLY { $$ = $2; }
        | members               { $$ = $1; }
        ;

members: member                 { 
                                        $$ = cJSON_CreateObject();  
                                        if (NULL != $1->val)
                                                cJSON_AddItemToObject($$, $1->key, $1->val); 
                                        jso_kv_free($1);
                                }
        | members COMMA member  { cJSON_AddItemToObject($$, $3->key, $3->val); jso_kv_free($3);}
        | members member        { cJSON_AddItemToObject($$, $2->key, $2->val); jso_kv_free($2);}
        ;

member: STRING PUNCT value              { 

                                                char *str = remove_escape($1);
                                                free($1);
                                                $$ = jso_kv_new(str, $3);
                                        }
        | USTRING PUNCT value           { $$ = jso_kv_new(remove_white_space($1), $3);}
        | USTRING LCURLY value RCURLY   { $$ = jso_kv_new(remove_white_space($1), $3);}
        | USTRING LBRAC values RBRAC    { $$ = jso_kv_new(remove_white_space($1), $3);}
        ;

array: LBRAC RBRAC               { $$ = NULL; printf("[]\n");}
        | LBRAC values RBRAC     { $$ = $2;}
        ;

values: value                    { $$ = cJSON_CreateArray(); cJSON_AddItemToArray($$, $1);}
        | values COMMA value     { cJSON_AddItemToArray($$, $3);}
        | values value     { cJSON_AddItemToArray($$, $2);}
        ;


%%


void jso_kv_free(struct jso_kv* kv)
{
        if (NULL != kv) {
                if (NULL != kv->key) {
                        free(kv->key); 
                }
                free(kv);
        }
}

struct jso_kv* jso_kv_new(char *key, struct cJSON *val)
{
        struct jso_kv *kv = (struct jso_kv *) malloc(sizeof(struct jso_kv)); 
        kv->key = key;
        kv->val = val;
        return kv;
}

char *remove_white_space(char *str)
{
        while (' ' == *str || '\t' == *str) {
                str++;
        }

        char *ret = str;
        str = str + strlen(str);
        
        while (' ' == *str || '\t' == *str || '\0' == *str) {
                str--;
        }
        *(str+1) = '\0';
        return ret;
}

char *remove_escape(char *str)
{
        str++;
        char *ret = NULL;
        while ('\0' != *str) {
                if ('\\' != *str) {
                        cvector_push_back(ret, *str);
                }
                str++;
        }
        cvector_pop_back(ret);
        cvector_push_back(ret, '\0');
        char *res = strdup(ret);
        cvector_free(ret);
        return res;
}



void yyerror(struct cJSON **jso, const char *s)
{
        fprintf(stderr, "Parser %s\n", s);
}
