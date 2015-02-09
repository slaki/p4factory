/**************************************************************************//**
 *
 *
 *
 *****************************************************************************/
#include <lg_utils/lg_utils_config.h>

/* <auto.start.cdefs(LG_UTILS_CONFIG_HEADER).source> */
#define __lg_utils_config_STRINGIFY_NAME(_x) #_x
#define __lg_utils_config_STRINGIFY_VALUE(_x) __lg_utils_config_STRINGIFY_NAME(_x)
lg_utils_config_settings_t lg_utils_config_settings[] =
{
#ifdef LG_UTILS_CONFIG_INCLUDE_LOGGING
    { __lg_utils_config_STRINGIFY_NAME(LG_UTILS_CONFIG_INCLUDE_LOGGING), __lg_utils_config_STRINGIFY_VALUE(LG_UTILS_CONFIG_INCLUDE_LOGGING) },
#else
{ LG_UTILS_CONFIG_INCLUDE_LOGGING(__lg_utils_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef LG_UTILS_CONFIG_LOG_OPTIONS_DEFAULT
    { __lg_utils_config_STRINGIFY_NAME(LG_UTILS_CONFIG_LOG_OPTIONS_DEFAULT), __lg_utils_config_STRINGIFY_VALUE(LG_UTILS_CONFIG_LOG_OPTIONS_DEFAULT) },
#else
{ LG_UTILS_CONFIG_LOG_OPTIONS_DEFAULT(__lg_utils_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef LG_UTILS_CONFIG_LOG_BITS_DEFAULT
    { __lg_utils_config_STRINGIFY_NAME(LG_UTILS_CONFIG_LOG_BITS_DEFAULT), __lg_utils_config_STRINGIFY_VALUE(LG_UTILS_CONFIG_LOG_BITS_DEFAULT) },
#else
{ LG_UTILS_CONFIG_LOG_BITS_DEFAULT(__lg_utils_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef LG_UTILS_CONFIG_LOG_CUSTOM_BITS_DEFAULT
    { __lg_utils_config_STRINGIFY_NAME(LG_UTILS_CONFIG_LOG_CUSTOM_BITS_DEFAULT), __lg_utils_config_STRINGIFY_VALUE(LG_UTILS_CONFIG_LOG_CUSTOM_BITS_DEFAULT) },
#else
{ LG_UTILS_CONFIG_LOG_CUSTOM_BITS_DEFAULT(__lg_utils_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef LG_UTILS_CONFIG_PORTING_STDLIB
    { __lg_utils_config_STRINGIFY_NAME(LG_UTILS_CONFIG_PORTING_STDLIB), __lg_utils_config_STRINGIFY_VALUE(LG_UTILS_CONFIG_PORTING_STDLIB) },
#else
{ LG_UTILS_CONFIG_PORTING_STDLIB(__lg_utils_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef LG_UTILS_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS
    { __lg_utils_config_STRINGIFY_NAME(LG_UTILS_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS), __lg_utils_config_STRINGIFY_VALUE(LG_UTILS_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS) },
#else
{ LG_UTILS_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS(__lg_utils_config_STRINGIFY_NAME), "__undefined__" },
#endif
#ifdef LG_UTILS_CONFIG_INCLUDE_UCLI
    { __lg_utils_config_STRINGIFY_NAME(LG_UTILS_CONFIG_INCLUDE_UCLI), __lg_utils_config_STRINGIFY_VALUE(LG_UTILS_CONFIG_INCLUDE_UCLI) },
#else
{ LG_UTILS_CONFIG_INCLUDE_UCLI(__lg_utils_config_STRINGIFY_NAME), "__undefined__" },
#endif
    { NULL, NULL }
};
#undef __lg_utils_config_STRINGIFY_VALUE
#undef __lg_utils_config_STRINGIFY_NAME

const char*
lg_utils_config_lookup(const char* setting)
{
    int i;
    for(i = 0; lg_utils_config_settings[i].name; i++) {
        if(strcmp(lg_utils_config_settings[i].name, setting)) {
            return lg_utils_config_settings[i].value;
        }
    }
    return NULL;
}

int
lg_utils_config_show(struct aim_pvs_s* pvs)
{
    int i;
    for(i = 0; lg_utils_config_settings[i].name; i++) {
        aim_printf(pvs, "%s = %s\n", lg_utils_config_settings[i].name, lg_utils_config_settings[i].value);
    }
    return i;
}

/* <auto.end.cdefs(LG_UTILS_CONFIG_HEADER).source> */

