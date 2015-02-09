/**************************************************************************//**
 *
 * @file
 * @brief bfns_common Porting Macros.
 *
 * @addtogroup bfns_common-porting
 * @{
 *
 *****************************************************************************/
#ifndef __BFNS_COMMON_PORTING_H__
#define __BFNS_COMMON_PORTING_H__


/* <auto.start.portingmacro(ALL).define> */
#if BFNS_COMMON_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS == 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <memory.h>
#endif

#ifndef BFNS_COMMON_MALLOC
    #if defined(GLOBAL_MALLOC)
        #define BFNS_COMMON_MALLOC GLOBAL_MALLOC
    #elif BFNS_COMMON_CONFIG_PORTING_STDLIB == 1
        #define BFNS_COMMON_MALLOC malloc
    #else
        #error The macro BFNS_COMMON_MALLOC is required but cannot be defined.
    #endif
#endif

#ifndef BFNS_COMMON_FREE
    #if defined(GLOBAL_FREE)
        #define BFNS_COMMON_FREE GLOBAL_FREE
    #elif BFNS_COMMON_CONFIG_PORTING_STDLIB == 1
        #define BFNS_COMMON_FREE free
    #else
        #error The macro BFNS_COMMON_FREE is required but cannot be defined.
    #endif
#endif

#ifndef BFNS_COMMON_MEMSET
    #if defined(GLOBAL_MEMSET)
        #define BFNS_COMMON_MEMSET GLOBAL_MEMSET
    #elif BFNS_COMMON_CONFIG_PORTING_STDLIB == 1
        #define BFNS_COMMON_MEMSET memset
    #else
        #error The macro BFNS_COMMON_MEMSET is required but cannot be defined.
    #endif
#endif

#ifndef BFNS_COMMON_MEMCPY
    #if defined(GLOBAL_MEMCPY)
        #define BFNS_COMMON_MEMCPY GLOBAL_MEMCPY
    #elif BFNS_COMMON_CONFIG_PORTING_STDLIB == 1
        #define BFNS_COMMON_MEMCPY memcpy
    #else
        #error The macro BFNS_COMMON_MEMCPY is required but cannot be defined.
    #endif
#endif

#ifndef BFNS_COMMON_STRNCPY
    #if defined(GLOBAL_STRNCPY)
        #define BFNS_COMMON_STRNCPY GLOBAL_STRNCPY
    #elif BFNS_COMMON_CONFIG_PORTING_STDLIB == 1
        #define BFNS_COMMON_STRNCPY strncpy
    #else
        #error The macro BFNS_COMMON_STRNCPY is required but cannot be defined.
    #endif
#endif

#ifndef BFNS_COMMON_VSNPRINTF
    #if defined(GLOBAL_VSNPRINTF)
        #define BFNS_COMMON_VSNPRINTF GLOBAL_VSNPRINTF
    #elif BFNS_COMMON_CONFIG_PORTING_STDLIB == 1
        #define BFNS_COMMON_VSNPRINTF vsnprintf
    #else
        #error The macro BFNS_COMMON_VSNPRINTF is required but cannot be defined.
    #endif
#endif

#ifndef BFNS_COMMON_SNPRINTF
    #if defined(GLOBAL_SNPRINTF)
        #define BFNS_COMMON_SNPRINTF GLOBAL_SNPRINTF
    #elif BFNS_COMMON_CONFIG_PORTING_STDLIB == 1
        #define BFNS_COMMON_SNPRINTF snprintf
    #else
        #error The macro BFNS_COMMON_SNPRINTF is required but cannot be defined.
    #endif
#endif

#ifndef BFNS_COMMON_STRLEN
    #if defined(GLOBAL_STRLEN)
        #define BFNS_COMMON_STRLEN GLOBAL_STRLEN
    #elif BFNS_COMMON_CONFIG_PORTING_STDLIB == 1
        #define BFNS_COMMON_STRLEN strlen
    #else
        #error The macro BFNS_COMMON_STRLEN is required but cannot be defined.
    #endif
#endif

/* <auto.end.portingmacro(ALL).define> */


#endif /* __BFNS_COMMON_PORTING_H__ */
/* @} */
