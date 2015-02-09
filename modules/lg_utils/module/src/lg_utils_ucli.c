/**************************************************************************//**
 *
 *
 *
 *****************************************************************************/
#include <lg_utils/lg_utils_config.h>

#if LG_UTILS_CONFIG_INCLUDE_UCLI == 1

#include <uCli/ucli.h>
#include <uCli/ucli_argparse.h>
#include <uCli/ucli_handler_macros.h>

static ucli_status_t
lg_utils_ucli_ucli__config__(ucli_context_t* uc)
{
    UCLI_HANDLER_MACRO_MODULE_CONFIG(lg_utils)
}

/* <auto.ucli.handlers.start> */
static ucli_command_handler_f lg_utils_ucli_ucli_handlers__[] =
{
    lg_utils_ucli_ucli__config__,
    NULL
};
/* <auto.ucli.handlers.end> */

static ucli_module_t
lg_utils_ucli_module__ =
    {
        "lg_utils_ucli",
        NULL,
        lg_utils_ucli_ucli_handlers__,
        NULL,
        NULL,
    };

ucli_node_t*
lg_utils_ucli_node_create(void)
{
    ucli_node_t* n;
    ucli_module_init(&lg_utils_ucli_module__);
    n = ucli_node_create("lg_utils", NULL, &lg_utils_ucli_module__);
    ucli_node_subnode_add(n, ucli_module_log_node_create("lg_utils"));
    return n;
}

#else
void*
lg_utils_ucli_node_create(void)
{
    return NULL;
}
#endif

