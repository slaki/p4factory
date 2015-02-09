#include <pthread.h>
#include <lg_utils/atomic_int.h>

int read_atomic_int(atomic_int_t* atom) {
  pthread_rwlock_rdlock(&(atom->lock));
  int ret = atom->value;
  pthread_rwlock_unlock(&(atom->lock));
  return ret;
}

void write_atomic_int(atomic_int_t* atom, const int value) {
  pthread_rwlock_wrlock(&(atom->lock));
  atom->value = value;
  pthread_rwlock_unlock(&(atom->lock));
}
