/**************************************************************************//**
 *
 *
 *
 *****************************************************************************/
#include <bfns_common/bfns_common_config.h>

#if BFNS_COMMON_CONFIG_INCLUDE_UCLI == 1

#include <uCli/ucli.h>
#include <uCli/ucli_argparse.h>
#include <uCli/ucli_handler_macros.h>

static ucli_status_t
bfns_common_ucli_ucli__config__(ucli_context_t* uc)
{
    UCLI_HANDLER_MACRO_MODULE_CONFIG(bfns_common)
}

/* <auto.ucli.handlers.start> */
/* <auto.ucli.handlers.end> */

static ucli_module_t
bfns_common_ucli_module__ =
    {
        "bfns_common_ucli",
        NULL,
        bfns_common_ucli_ucli_handlers__,
        NULL,
        NULL,
    };

ucli_node_t*
bfns_common_ucli_node_create(void)
{
    ucli_node_t* n;
    ucli_module_init(&bfns_common_ucli_module__);
    n = ucli_node_create("bfns_common", NULL, &bfns_common_ucli_module__);
    ucli_node_subnode_add(n, ucli_module_log_node_create("bfns_common"));
    return n;
}

#else
void*
bfns_common_ucli_node_create(void)
{
    return NULL;
}
#endif

