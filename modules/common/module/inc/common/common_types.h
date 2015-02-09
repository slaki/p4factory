/* @fixme top matter */

#ifndef _COMMON_TYPES_H_
#define _COMMON_TYPES_H_

#define COMPILER_REFERENCE(ref) (void) (ref)

typedef enum bfm_error_s {
    BFM_E_NONE=0,
    BFM_E_PARAM=-1,
    BFM_E_EXISTS=-2,
    BFM_E_UNKNOWN=-3,
    BFM_E_NOT_SUPPORTED=-4,
    BFM_E_NOT_FOUND=-5
} bfm_error_t;

#endif /* _COMMON_TYPES_H_ */
