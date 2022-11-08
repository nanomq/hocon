#include "hocon.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
    if (argc > 1) {
        cJSON *ret = hocon_parse(argv[1]);
        puts(cJSON_PrintUnformatted(ret));
    }
    return 0;

}