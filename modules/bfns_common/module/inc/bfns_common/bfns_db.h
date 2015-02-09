#ifndef _BFNS_DB_H_
#define _BFNS_DB_H_

#include <hiredis/hiredis.h>
#include "bfns_utils.h"

#define BFNSDB_DEFAULT_PORT 6379

#define BFNSDB_SUCCESS 0
#define BFNSDB_ERROR_INVALID_DATAPATH 10
#define BFNSDB_ERROR_DATAPATH_EXISTS 11
#define BFNSDB_ERROR_INVALID_PORT 20
#define BFNSDB_ERROR_PORT_EXISTS 21
#define BFNSDB_ERROR_PORT_NUM_TAKEN 30

typedef redisContext *bfns_db_cxt_t;

bfns_db_cxt_t bfns_db_connect(char *ipv4, uint16_t port);
void bfns_db_free(bfns_db_cxt_t c);

int bfns_db_has_datapath(bfns_db_cxt_t c, const char *name);

int bfns_db_add_datapath(bfns_db_cxt_t c,
			 const char *name, uint64_t dpid);

int bfns_db_del_datapath(bfns_db_cxt_t c,
			 const char *name);

int bfns_db_set_listener(bfns_db_cxt_t c,
			 const char *name,
			 bfns_tcp_over_ip_t *listener);

int bfns_db_get_listener(bfns_db_cxt_t c,
			 const char *name,
			 bfns_tcp_over_ip_t *listener);

int bfns_db_add_port(bfns_db_cxt_t c,
		     const char *name, const char *iface, uint16_t port_num);

int bfns_db_del_port(bfns_db_cxt_t c,
		     const char *name, const char *iface);

int bfns_db_has_port(bfns_db_cxt_t c,
		     const char *name, const char *iface);

int bfns_db_has_port_num(bfns_db_cxt_t c,
			 const char *name, uint16_t port_num);

int bfns_db_get_first_port_num(bfns_db_cxt_t c,
			       const char *name,
			       uint16_t *port_num);

int bfns_db_flush(bfns_db_cxt_t c);

#endif
