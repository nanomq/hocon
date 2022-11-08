#include "hocon.h"
#include <stdlib.h>
#include <stdio.h>

extern FILE *yyin;


cJSON *hocon_parse(char *file)
{
    // yydebug = 1;
    if (!(yyin = fopen(file, "r"))) {
            perror((file));
            return NULL;
    }


   cJSON *jso = cJSON_CreateObject();
   int rv = yyparse(&jso);
   // printf("json : %s\n", cJSON_PrintUnformatted(jso));
   return jso;
}