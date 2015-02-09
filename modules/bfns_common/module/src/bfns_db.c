#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>
#include <assert.h>
#include <bfns_common/bfns_db.h>

#define DB_CONNECT_TIMEOUT_SECS 1

typedef struct bfns_port_s {
  uint16_t port_num;
  char iface[64];
} bfns_port_t;

typedef struct bfns_config_s {
  char datapath_name[64];
  uint64_t dpid;
  bfns_tcp_over_ip_t listener;
} bfns_config_t;


bfns_db_cxt_t bfns_db_connect(char *ipv4, uint16_t port) {
  struct timeval timeout = { DB_CONNECT_TIMEOUT_SECS, 0 };
  redisContext *c = redisConnectWithTimeout(ipv4, port, timeout);
  if (c == NULL || c->err) {
    return NULL;
  }
  return c;
}

void bfns_db_free(bfns_db_cxt_t c){
  redisFree(c);
}

int bfns_db_has_datapath(bfns_db_cxt_t c,
			 const char *name) {
  redisReply *reply;
  reply = redisCommand(c, "EXISTS %s", name);
  int ret = (reply->integer == 1);
  freeReplyObject(reply);
  return ret;
}

int bfns_db_add_datapath(bfns_db_cxt_t c,
			 const char *name, uint64_t dpid) {
  if(bfns_db_has_datapath(c, name)) {
    return BFNSDB_ERROR_DATAPATH_EXISTS;
  }

  redisReply *reply;

  bfns_config_t bfns_config;
  memset(&bfns_config, 0, sizeof(bfns_config_t));
  strncpy(bfns_config.datapath_name, name, 64);
  bfns_config.dpid = dpid;

  reply = redisCommand(c, "SET %s %b", name,
		       (char *) &bfns_config, sizeof(bfns_config_t));
  freeReplyObject(reply);
  
  return 0;
}

int bfns_db_set_listener(bfns_db_cxt_t c,
			 const char *name,
			 bfns_tcp_over_ip_t *listener) {
  redisReply *reply1, *reply2;
  reply1 = redisCommand(c, "GET %s", name);
  if(!reply1->str) {
    freeReplyObject(reply1);
    return BFNSDB_ERROR_INVALID_DATAPATH;
  }

  bfns_config_t *bfns_config = (bfns_config_t *) reply1->str;
  memcpy(&bfns_config->listener, listener, sizeof(bfns_tcp_over_ip_t));

  reply2 = redisCommand(c, "SET %s %b", name,
			(char *) bfns_config, sizeof(bfns_config_t));
  freeReplyObject(reply1);
  freeReplyObject(reply2);
  
  return 0;
}

int bfns_db_get_listener(bfns_db_cxt_t c,
			 const char *name,
			 bfns_tcp_over_ip_t *listener) {
  redisReply *reply;
  reply = redisCommand(c, "GET %s", name);
  if(!reply->str) {
    freeReplyObject(reply);
    return BFNSDB_ERROR_INVALID_DATAPATH;
  }

  bfns_config_t *bfns_config = (bfns_config_t *) reply->str;
  memcpy(listener, &bfns_config->listener, sizeof(bfns_tcp_over_ip_t));

  freeReplyObject(reply);
  
  return 0;
}


static inline void get_ports_key(char *dest, const char *name) {
  sprintf(dest, ".%s.ports", name);
}

static inline void get_port_nums_key(char *dest, const char *name) {
  sprintf(dest, ".%s.port_nums", name);
}

static int has_port(bfns_db_cxt_t c,
		    const char *ports_key,
		    const char *iface) {
  redisReply *reply;
  reply = redisCommand(c, "HEXISTS %s %s", ports_key, iface);
  int ret = (reply->integer == 1);
  freeReplyObject(reply);
  return ret;
}

static int has_port_num(bfns_db_cxt_t c,
			const char *port_nums_key,
			uint16_t port_num) {
  redisReply *reply;
  reply = redisCommand(c, "SISMEMBER %s %d", port_nums_key, port_num);
  int ret = (reply->integer == 1);
  freeReplyObject(reply);
  return ret;
}

int bfns_db_has_port(bfns_db_cxt_t c,
		     const char *name, const char *iface) {
  char ports_key[128];
  get_ports_key(ports_key, name);

  if(!bfns_db_has_datapath(c, name)) { /* datapath does not exist */
    return 0;
  }
  
  return has_port(c, ports_key, iface);
}

int bfns_db_has_port_num(bfns_db_cxt_t c,
			 const char *name, uint16_t port_num) {
  char port_nums_key[128];
  get_port_nums_key(port_nums_key, name);

  if(!bfns_db_has_datapath(c, name)) { /* datapath does not exist */
    return 0;
  }
  
  return has_port_num(c, port_nums_key, port_num);
}

int bfns_db_add_port(bfns_db_cxt_t c,
		     const char *name, const char *iface, uint16_t port_num) {
  redisReply *reply;
  char ports_key[128];
  char port_nums_key[128];
  get_ports_key(ports_key, name);
  get_port_nums_key(port_nums_key, name);

  if(!bfns_db_has_datapath(c, name)) { /* datapath does not exist */
    return BFNSDB_ERROR_INVALID_DATAPATH;
  }
  
  if(has_port(c, ports_key, iface)) { /* port exists */
    return BFNSDB_ERROR_PORT_EXISTS;
  }

  if(has_port_num(c, port_nums_key, port_num)) { /* port num taken */
    return BFNSDB_ERROR_PORT_NUM_TAKEN;
  }

  bfns_port_t bfns_port;
  memset(&bfns_port, 0, sizeof(bfns_port_t));
  bfns_port.port_num = port_num;
  strncpy(bfns_port.iface, iface, 64);

  reply = redisCommand(c, "HSET %s %s %b", ports_key, iface, &bfns_port, sizeof(bfns_port_t));
  assert(reply->integer == 1);
  freeReplyObject(reply);

  reply = redisCommand(c, "SADD %s %d", port_nums_key, port_num);
  assert(reply->integer == 1);
  freeReplyObject(reply);

  return 0;
}

int bfns_db_del_port(bfns_db_cxt_t c,
		     const char *name, const char *iface) {
  redisReply *reply;
  char ports_key[128];
  char port_nums_key[128];
  get_ports_key(ports_key, name);
  get_port_nums_key(port_nums_key, name);

  if(!bfns_db_has_datapath(c, name)) { /* datapath does not exist */
    return BFNSDB_ERROR_INVALID_DATAPATH;
  }
  
  if(!has_port(c, ports_key, iface)) { /* port invalid */
    return BFNSDB_ERROR_INVALID_PORT;
  }

  reply = redisCommand(c, "HGET %s %s", ports_key, iface);
  bfns_port_t *bfns_port = (bfns_port_t *) reply->str;
  uint16_t port_num = bfns_port->port_num;
  freeReplyObject(reply);

  reply = redisCommand(c, "HDEL %s %s", ports_key, iface);
  assert(reply->integer == 1);
  freeReplyObject(reply);

  reply = redisCommand(c, "SREM %s %d", port_nums_key, port_num);
  assert(reply->integer == 1);
  freeReplyObject(reply);

  return 0;
}

int bfns_db_del_datapath(bfns_db_cxt_t c,
			 const char *name) {
  redisReply *reply;
  int success;
  char ports_key[128];
  char port_nums_key[128];
  get_ports_key(ports_key, name);
  get_port_nums_key(port_nums_key, name);

  reply = redisCommand(c, "DEL %s", name);
  success = (reply->integer == 1);
  freeReplyObject(reply);
  if (!success) return BFNSDB_ERROR_INVALID_DATAPATH;

  reply = redisCommand(c, "DEL %s", ports_key);
  freeReplyObject(reply);

  reply = redisCommand(c, "DEL %s", port_nums_key);
  freeReplyObject(reply);
  
  return 0;
}

int bfns_db_get_first_port_num(bfns_db_cxt_t c,
			       const char *name,
			       uint16_t *port_num) {
  redisReply *reply;

  if(!bfns_db_has_datapath(c, name)) { /* datapath does not exist */
    return BFNSDB_ERROR_INVALID_DATAPATH;
  }

  char port_nums_key[128];
  get_port_nums_key(port_nums_key, name);

  *port_num = 0;
  int found = 1;
  while(found) {
    (*port_num)++;
    reply = redisCommand(c, "SISMEMBER %s %d", port_nums_key, *port_num);
    found = reply->integer;
    freeReplyObject(reply); 
  }
  
  return 0;
}

int bfns_db_flush(bfns_db_cxt_t c) {
  redisReply *reply;
  reply = redisCommand(c, "FLUSHDB");
  freeReplyObject(reply);
  return 0;
}
