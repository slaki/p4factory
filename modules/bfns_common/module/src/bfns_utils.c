#include <bfns_common/bfns_utils.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <arpa/inet.h>

/* just for ipv4 now */
/* TODO */
int
parse_connection(const char *str,
		 bfns_tcp_over_ip_t *tcp_over_ip,
		 uint16_t default_port)
{
  char buf[128];
  char *strtok_state = NULL;
  char *ip, *port_str;
  struct sockaddr_in sa;
  strncpy(buf, str, sizeof(buf));
  strtok_state = buf;
  ip = strtok_r(NULL, ":/", &strtok_state);
  tcp_over_ip->proto = BFNS_PROTO_IPV4;
  if (ip == NULL) {
    fprintf(stderr, "Controller spec \"%s\" missing IP address\n", str);
    return -1;
  } else if (inet_pton(AF_INET, ip, &sa) != 1) {
    fprintf(stderr, "Could not parse IP address \"%s\"\n", ip);
    return -1;
  } else {
    strncpy(tcp_over_ip->ip, ip, sizeof(tcp_over_ip->ip));
  }
  port_str = strtok_r(NULL, ":/", &strtok_state);
  if (port_str == NULL) {
    tcp_over_ip->port = default_port;
  } else {
    char *endptr;
    long port = strtol(port_str, &endptr, 0);
    if (*port_str == '\0' || *endptr != '\0') {
      fprintf(stderr, "Could not parse port \"%s\"\n", port_str);
      return -1;
    } else if (port <= 0 || port > 65535) {
      fprintf(stderr, "Invalid port \"%s\"\n", port_str);
      return -1;
    } else {
      tcp_over_ip->port = atoi(port_str);
    }
  }
  return 0;
}

int sendall(int sckt, char *buf, int len)
{
  int total = 0;        // how many bytes we've sent
  int n;

  while(total < len) {
    n = send(sckt, buf + total, len - total, 0);
    if (n == -1) return -1;
    total += n;
  }

  return total;
} 

int recvall(int sckt, char *buf, int len) {
  int total = 0;
  int n;

  while(total < len) {
    n = recv(sckt, buf + total, len - total, 0);
    if(n == -1) return -1;
    if(n == 0) break;
    total += n;
  }

  return total;
}
