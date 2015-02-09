#ifndef _PRIO_SCHEDULER_H
#define _PRIO_SCHEDULER_H

typedef struct prio_scheduler_s prio_scheduler_t;

prio_scheduler_t *prio_init(int size, int num_queues);

void prio_destroy(prio_scheduler_t *cb);

void prio_write(prio_scheduler_t *cb, void* elem, int queue_id);

void *prio_read(prio_scheduler_t *cb);

#endif
