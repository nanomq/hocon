#include "hocon.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

extern FILE *yyin;

static cJSON *
path_expression_parse_core(cJSON *parent, cJSON *jso)
{
	jso       = cJSON_DetachItemFromObject(parent, jso->string);
	char *str = strdup(jso->string);
	char *p   = str;
	char *p_a = str + strlen(str);

	char t[128] = { 0 };
	while (NULL != (p = strrchr(str, '.'))) {
		cJSON *jso_new = cJSON_CreateObject();
		// cJSON *jso_new = NULL;

		// a.b.c: {object}
		// c ==> create json object jso(c, jso)
		*p = '_';
		strncpy(t, p + 1, p_a - p);
		// cJSON_AddItemToObject(jso_new, t, jso);
		cJSON_AddItemToObject(
		    jso_new, t, jso); // cJSON_Duplicate(jso, cJSON_True));
		memset(t, 0, 128);
		// jso_new = json(c, jso)
		// cJSON_Delete(jso);
		jso     = jso_new;
		jso_new = NULL;
		p_a     = --p;
	}

	strncpy(t, str, p_a - str + 1);
	cJSON_AddItemToObject(parent, t, jso);
	// memset(t, 0, 128);
	// cJSON_DeleteItemFromObject(parent, str);

	free(str);
	return parent;
}

// {"bridge.sqlite":{"enable":false,"disk_cache_size":102400,"mounted_file_path":"/tmp/","flush_mem_threshold":100,"resend_interval":5000}}
// {"bridge":{"sqlite":{"enable":false,"disk_cache_size":102400,"mounted_file_path":"/tmp/","flush_mem_threshold":100,"resend_interval":5000}}}

// level-order traversal
// find key bridge.sqlite
// create object sqlite with object value
// insert object bridge with sqlite
// delete bridge.sqlite

static cJSON *
path_expression_parse(cJSON *jso)
{
	cJSON *parent = jso;
	cJSON *child  = jso->child;

	while (child) {
		if (child->child) {
			path_expression_parse(child);
		}
		if (NULL != child->string &&
		    NULL != strchr(child->string, '.')) {
			path_expression_parse_core(parent, child);
			child = parent->child;
		} else {
			child = child->next;
		}
	}

	return jso;
}


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