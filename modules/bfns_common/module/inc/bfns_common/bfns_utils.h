#ifndef _BFNS_UTILS_H_
#define _BFNS_UTILS_H_

#include <stdint.h>

#define BFNS_PROTO_IPV4 1
#define BFNS_PROTO_IPV6 2

typedef struct bfns_tcp_over_ip_s {
  int proto;
  char ip[128];
  uint16_t port;
} bfns_tcp_over_ip_t;

int parse_connection(const char *str,
		     bfns_tcp_over_ip_t *tcp_over_ip,
		     uint16_t default_port);

int sendall(int sckt, char *buf, int len);
int recvall(int sckt, char *buf, int len);

#endif
