/**************************************************************************//**
 *
 * @file
 * @brief bfns_common Configuration Header
 *
 * @addtogroup bfns_common-config
 * @{
 *
 *****************************************************************************/
#ifndef __BFNS_COMMON_CONFIG_H__
#define __BFNS_COMMON_CONFIG_H__

#ifdef GLOBAL_INCLUDE_CUSTOM_CONFIG
#include <global_custom_config.h>
#endif
#ifdef BFNS_COMMON_INCLUDE_CUSTOM_CONFIG
#include <bfns_common_custom_config.h>
#endif

/* <auto.start.cdefs(BFNS_COMMON_CONFIG_HEADER).header> */
#include <AIM/aim.h>
/**
 * BFNS_COMMON_CONFIG_INCLUDE_LOGGING
 *
 * Include or exclude logging. */


#ifndef BFNS_COMMON_CONFIG_INCLUDE_LOGGING
#define BFNS_COMMON_CONFIG_INCLUDE_LOGGING 1
#endif

/**
 * BFNS_COMMON_CONFIG_LOG_OPTIONS_DEFAULT
 *
 * Default enabled log options. */


#ifndef BFNS_COMMON_CONFIG_LOG_OPTIONS_DEFAULT
#define BFNS_COMMON_CONFIG_LOG_OPTIONS_DEFAULT AIM_LOG_OPTIONS_DEFAULT
#endif

/**
 * BFNS_COMMON_CONFIG_LOG_BITS_DEFAULT
 *
 * Default enabled log bits. */


#ifndef BFNS_COMMON_CONFIG_LOG_BITS_DEFAULT
#define BFNS_COMMON_CONFIG_LOG_BITS_DEFAULT AIM_LOG_BITS_DEFAULT
#endif

/**
 * BFNS_COMMON_CONFIG_LOG_CUSTOM_BITS_DEFAULT
 *
 * Default enabled custom log bits. */


#ifndef BFNS_COMMON_CONFIG_LOG_CUSTOM_BITS_DEFAULT
#define BFNS_COMMON_CONFIG_LOG_CUSTOM_BITS_DEFAULT 0
#endif

/**
 * BFNS_COMMON_CONFIG_PORTING_STDLIB
 *
 * Default all porting macros to use the C standard libraries. */


#ifndef BFNS_COMMON_CONFIG_PORTING_STDLIB
#define BFNS_COMMON_CONFIG_PORTING_STDLIB 1
#endif

/**
 * BFNS_COMMON_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS
 *
 * Include standard library headers for stdlib porting macros. */


#ifndef BFNS_COMMON_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS
#define BFNS_COMMON_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS BFNS_COMMON_CONFIG_PORTING_STDLIB
#endif

/**
 * BFNS_COMMON_CONFIG_INCLUDE_UCLI
 *
 * Include generic uCli support. */


#ifndef BFNS_COMMON_CONFIG_INCLUDE_UCLI
#define BFNS_COMMON_CONFIG_INCLUDE_UCLI 0
#endif



/**
 * All compile time options can be queried or displayed
 */

/** Configuration settings structure. */
typedef struct bfns_common_config_settings_s {
    /** name */
    const char* name;
    /** value */
    const char* value;
} bfns_common_config_settings_t;

/** Configuration settings table. */
/** bfns_common_config_settings table. */
extern bfns_common_config_settings_t bfns_common_config_settings[];

/**
 * @brief Lookup a configuration setting.
 * @param setting The name of the configuration option to lookup.
 */
const char* bfns_common_config_lookup(const char* setting);

/**
 * @brief Show the compile-time configuration.
 * @param pvs The output stream.
 */
int bfns_common_config_show(struct aim_pvs_s* pvs);

/* <auto.end.cdefs(BFNS_COMMON_CONFIG_HEADER).header> */

#include "bfns_common_porting.h"

#endif /* __BFNS_COMMON_CONFIG_H__ */
/* @} */
