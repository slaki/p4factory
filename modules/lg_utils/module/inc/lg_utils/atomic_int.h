#ifndef ATOMIC_INT_H_
#define ATOMIC_INT_H_

typedef struct atomic_int_s {
  pthread_rwlock_t lock;
  int value;;
} atomic_int_t;

int read_atomic_int(atomic_int_t* atom);

void write_atomic_int(atomic_int_t* atom, const int value);

#endif // ATOMIC_INT_H_
