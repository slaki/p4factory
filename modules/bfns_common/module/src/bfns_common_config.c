/**************************************************************************//**
 *
 *
 *
 *****************************************************************************/
#include <bfns_common/bfns_common_config.h>

/* <auto.start.cdefs(BFNS_COMMON_CONFIG_HEADER).source> */
#define __bfns_common_config_STRINGIFY_NAME(_x) #_x
#define __bfns_common_config_STRINGIFY_VALUE(_x) __bfns_common_config_STRINGIFY_NAME(_x)
bfns_common_config_settings_t bfns_common_config_settings[] =
{
#ifdef BFNS_COMMON_CONFIG_INCLUDE_LOGGING
    { __bfns_common_config_STRINGIFY_NAME(BFNS_COMMON_CONFIG_INCLUDE_LOGGING), __bfns_common_config_STRINGIFY_VALUE(BFNS_COMMON_CONFIG_INCLUDE_LOGGING) },
#else
{ BFNS_COMMON_CONFIG_INCLUDE_LOGGING(__bfns_common_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef BFNS_COMMON_CONFIG_LOG_OPTIONS_DEFAULT
    { __bfns_common_config_STRINGIFY_NAME(BFNS_COMMON_CONFIG_LOG_OPTIONS_DEFAULT), __bfns_common_config_STRINGIFY_VALUE(BFNS_COMMON_CONFIG_LOG_OPTIONS_DEFAULT) },
#else
{ BFNS_COMMON_CONFIG_LOG_OPTIONS_DEFAULT(__bfns_common_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef BFNS_COMMON_CONFIG_LOG_BITS_DEFAULT
    { __bfns_common_config_STRINGIFY_NAME(BFNS_COMMON_CONFIG_LOG_BITS_DEFAULT), __bfns_common_config_STRINGIFY_VALUE(BFNS_COMMON_CONFIG_LOG_BITS_DEFAULT) },
#else
{ BFNS_COMMON_CONFIG_LOG_BITS_DEFAULT(__bfns_common_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef BFNS_COMMON_CONFIG_LOG_CUSTOM_BITS_DEFAULT
    { __bfns_common_config_STRINGIFY_NAME(BFNS_COMMON_CONFIG_LOG_CUSTOM_BITS_DEFAULT), __bfns_common_config_STRINGIFY_VALUE(BFNS_COMMON_CONFIG_LOG_CUSTOM_BITS_DEFAULT) },
#else
{ BFNS_COMMON_CONFIG_LOG_CUSTOM_BITS_DEFAULT(__bfns_common_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef BFNS_COMMON_CONFIG_PORTING_STDLIB
    { __bfns_common_config_STRINGIFY_NAME(BFNS_COMMON_CONFIG_PORTING_STDLIB), __bfns_common_config_STRINGIFY_VALUE(BFNS_COMMON_CONFIG_PORTING_STDLIB) },
#else
{ BFNS_COMMON_CONFIG_PORTING_STDLIB(__bfns_common_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef BFNS_COMMON_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS
    { __bfns_common_config_STRINGIFY_NAME(BFNS_COMMON_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS), __bfns_common_config_STRINGIFY_VALUE(BFNS_COMMON_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS) },
#else
{ BFNS_COMMON_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS(__bfns_common_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef BFNS_COMMON_CONFIG_INCLUDE_UCLI
    { __bfns_common_config_STRINGIFY_NAME(BFNS_COMMON_CONFIG_INCLUDE_UCLI), __bfns_common_config_STRINGIFY_VALUE(BFNS_COMMON_CONFIG_INCLUDE_UCLI) },
#else
{ BFNS_COMMON_CONFIG_INCLUDE_UCLI(__bfns_common_config_STRINGIFY_NAME), "__undefined__" },
#endif
    { NULL, NULL }
};
#undef __bfns_common_config_STRINGIFY_VALUE
#undef __bfns_common_config_STRINGIFY_NAME

const char*
bfns_common_config_lookup(const char* setting)
{
    int i;
    for(i = 0; bfns_common_config_settings[i].name; i++) {
        if(strcmp(bfns_common_config_settings[i].name, setting)) {
            return bfns_common_config_settings[i].value;
        }
    }
    return NULL;
}

int
bfns_common_config_show(struct aim_pvs_s* pvs)
{
    int i;
    for(i = 0; bfns_common_config_settings[i].name; i++) {
        aim_printf(pvs, "%s = %s\n", bfns_common_config_settings[i].name, bfns_common_config_settings[i].value);
    }
    return i;
}

/* <auto.end.cdefs(BFNS_COMMON_CONFIG_HEADER).source> */

