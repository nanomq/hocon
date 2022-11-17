#include "hocon.h"
#include "string.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
    if (argc > 1) {
        cJSON *ret = hocon_parse_file(argv[1]);
        puts(cJSON_PrintUnformatted(ret));
    }


    char str[] = "abc=1";
    hocon_parse_str(str, strlen(str));
    return 0;

}