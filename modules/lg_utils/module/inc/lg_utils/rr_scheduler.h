#ifndef _RR_SCHEDULER_H
#define _RR_SCHEDULER_H

typedef struct rr_scheduler_s rr_scheduler_t;

rr_scheduler_t *rr_init(int size, int num_queues);

void rr_destroy(rr_scheduler_t *rr);

void rr_write(rr_scheduler_t *rr, void* elem, int queue_id);

void *rr_read(rr_scheduler_t *rr);

#endif
