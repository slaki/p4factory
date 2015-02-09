#ifndef _CHEAP_TRIE_H
#define _CHEAP_TRIE_H

#include <stdint.h>

typedef struct cheap_trie_s cheap_trie_t;

cheap_trie_t *cheap_trie_create(int key_width_bytes);

void cheap_trie_destroy(cheap_trie_t *t);

void cheap_trie_insert(cheap_trie_t *trie,
		       uint8_t *prefix, int width,
		       void *data);

void *cheap_trie_get(cheap_trie_t *trie, uint8_t *key);

void *cheap_trie_delete(cheap_trie_t *trie, uint8_t *prefix, int width);

void cheap_trie_print(cheap_trie_t *trie);

#endif
