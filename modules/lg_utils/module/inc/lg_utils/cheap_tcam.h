#ifndef _CHEAP_TCAM_H
#define _CHEAP_TCAM_H

#include <stdint.h>

#include <lg_utils/tommyhashlin.h>

typedef struct cheap_tcam_s cheap_tcam_t;

typedef int (*cheap_tcam_priority_fn)(const void *entry);
typedef int (*cheap_tcam_cmp_fn)(const void *key, const void *entry);

typedef tommy_hashlin_node cheap_tcam_node;

cheap_tcam_t *cheap_tcam_create(int key_size,
				cheap_tcam_priority_fn get_priority,
				cheap_tcam_cmp_fn cmp);

void cheap_tcam_destroy(cheap_tcam_t *tcam);

void cheap_tcam_insert(cheap_tcam_t *tcam,
		       uint8_t *mask,
		       uint8_t *key,
		       cheap_tcam_node *node,
		       void *data);

void *cheap_tcam_search(cheap_tcam_t *tcam, uint8_t *key);

void cheap_tcam_delete(cheap_tcam_t *tcam,
		       uint8_t *mask,
		       uint8_t *key,
		       cheap_tcam_node *node);
#endif
