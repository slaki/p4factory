/**************************************************************************//**
 *
 * @file
 * @brief lg_utils Porting Macros.
 *
 * @addtogroup lg_utils-porting
 * @{
 *
 *****************************************************************************/
#ifndef __LG_UTILS_PORTING_H__
#define __LG_UTILS_PORTING_H__


/* <auto.start.portingmacro(ALL).define> */
#if LG_UTILS_CONFIG_PORTING_INCLUDE_STDLIB_HEADERS == 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <memory.h>
#endif

#ifndef LG_UTILS_MALLOC
    #if defined(GLOBAL_MALLOC)
        #define LG_UTILS_MALLOC GLOBAL_MALLOC
    #elif LG_UTILS_CONFIG_PORTING_STDLIB == 1
        #define LG_UTILS_MALLOC malloc
    #else
        #error The macro LG_UTILS_MALLOC is required but cannot be defined.
    #endif
#endif

#ifndef LG_UTILS_FREE
    #if defined(GLOBAL_FREE)
        #define LG_UTILS_FREE GLOBAL_FREE
    #elif LG_UTILS_CONFIG_PORTING_STDLIB == 1
        #define LG_UTILS_FREE free
    #else
        #error The macro LG_UTILS_FREE is required but cannot be defined.
    #endif
#endif

#ifndef LG_UTILS_MEMSET
    #if defined(GLOBAL_MEMSET)
        #define LG_UTILS_MEMSET GLOBAL_MEMSET
    #elif LG_UTILS_CONFIG_PORTING_STDLIB == 1
        #define LG_UTILS_MEMSET memset
    #else
        #error The macro LG_UTILS_MEMSET is required but cannot be defined.
    #endif
#endif

#ifndef LG_UTILS_MEMCPY
    #if defined(GLOBAL_MEMCPY)
        #define LG_UTILS_MEMCPY GLOBAL_MEMCPY
    #elif LG_UTILS_CONFIG_PORTING_STDLIB == 1
        #define LG_UTILS_MEMCPY memcpy
    #else
        #error The macro LG_UTILS_MEMCPY is required but cannot be defined.
    #endif
#endif

#ifndef LG_UTILS_STRNCPY
    #if defined(GLOBAL_STRNCPY)
        #define LG_UTILS_STRNCPY GLOBAL_STRNCPY
    #elif LG_UTILS_CONFIG_PORTING_STDLIB == 1
        #define LG_UTILS_STRNCPY strncpy
    #else
        #error The macro LG_UTILS_STRNCPY is required but cannot be defined.
    #endif
#endif

#ifndef LG_UTILS_VSNPRINTF
    #if defined(GLOBAL_VSNPRINTF)
        #define LG_UTILS_VSNPRINTF GLOBAL_VSNPRINTF
    #elif LG_UTILS_CONFIG_PORTING_STDLIB == 1
        #define LG_UTILS_VSNPRINTF vsnprintf
    #else
        #error The macro LG_UTILS_VSNPRINTF is required but cannot be defined.
    #endif
#endif

#ifndef LG_UTILS_SNPRINTF
    #if defined(GLOBAL_SNPRINTF)
        #define LG_UTILS_SNPRINTF GLOBAL_SNPRINTF
    #elif LG_UTILS_CONFIG_PORTING_STDLIB == 1
        #define LG_UTILS_SNPRINTF snprintf
    #else
        #error The macro LG_UTILS_SNPRINTF is required but cannot be defined.
    #endif
#endif

#ifndef LG_UTILS_STRLEN
    #if defined(GLOBAL_STRLEN)
        #define LG_UTILS_STRLEN GLOBAL_STRLEN
    #elif LG_UTILS_CONFIG_PORTING_STDLIB == 1
        #define LG_UTILS_STRLEN strlen
    #else
        #error The macro LG_UTILS_STRLEN is required but cannot be defined.
    #endif
#endif

/* <auto.end.portingmacro(ALL).define> */


#endif /* __LG_UTILS_PORTING_H__ */
/* @} */
