#ifndef HOCON_H
#define HOCON_H
#include "parser.h"
#include "cJSON.h"

cJSON *hocon_parse(char *file);

#endif