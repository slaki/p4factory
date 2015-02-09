/**************************************************************************//**
 *
 *
 *
 *****************************************************************************/
#include <bfns_common/bfns_common_config.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <AIM/aim.h>

int aim_main(int argc, char* argv[])
{
    printf("bfns_common Utest Is Empty\n");
    bfns_common_config_show(&aim_pvs_stdout);
    return 0;
}

