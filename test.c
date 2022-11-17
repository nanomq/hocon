#include "hocon.h"
#include "string.h"
#include <stdio.h>

int main(int argc, char *argv[])
{
    if (argc > 1) {
        cJSON *ret = hocon_parse_file(argv[1]);
        char *str = cJSON_PrintUnformatted(ret);
        puts(str);
        cJSON_free(str);
        cJSON_Delete(ret);

    } else {
        fprintf(stderr, "Usage: test <your conf file>\n");
    }


    // char str[] = "abc=1";
    // hocon_parse_str(str, strlen(str));
    return 0;

}