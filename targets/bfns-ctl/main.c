#include <getopt.h>
#include <stdio.h>
#include <unistd.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <bfns_common/ctl_messages.h>
#include <bfns_common/bfns_db.h>
#include <bfns_common/bfns_utils.h>

static char *datapath_name = "bfns";
static char *bfnsdb_str = NULL;

static void help(void)
{
  fprintf(stderr, "usage: bfns-ctl COMMAND [ARG..]\n");
  fprintf(stderr, " help: show this message\n");
  fprintf(stderr, " show: print information about each datapath\n");
  fprintf(stderr, " add-port INTERFACE [PORT_NUM]: add a port to the datapath\n");
  fprintf(stderr, " del-port INTERFACE: delete a port from the datapath\n");
}

static void
parse_options(int argc, char **argv)
{
  while (1) {
    int option_index = 0;
    /* Options without short equivalents */
    enum long_opts {
      OPT_START = 256,
      OPT_DATAPATH,
      OPT_BFNSDB,
    };
    static struct option long_options[] = {
      {"help", no_argument, 0, 'h' },
      /* Undocumented options */
      {"datapath", required_argument, 0, OPT_DATAPATH },
      {"bfnsdb", required_argument, 0, OPT_BFNSDB },
      {0, 0, 0, 0 }
    };
    int c = getopt_long(argc, argv, "h",
			long_options, &option_index);
    if (c == -1) {
      break;
    }
    switch (c) {
    case OPT_DATAPATH:
      datapath_name = strdup(optarg);
      break;
    case OPT_BFNSDB:
      bfnsdb_str = strdup(optarg);
      break;
    case 'h':
    case '?':
      help();
      exit(c == '?');
    }
  }
}

static bfns_db_cxt_t connect_to_bfnsdb(bfns_tcp_over_ip_t *bfnsdb_addr) {
  bfns_db_cxt_t c = bfns_db_connect(bfnsdb_addr->ip, bfnsdb_addr->port);
  if(!c) {
    fprintf(stderr, "Could not connect to BFNS DB\n");
    return c;
  }
  fprintf(stderr, "Connected to BFNS DB\n");
  return c;
}

static void print_bfnsdb_error(int error_code) {
  switch(error_code){
  case 0:
    break;
  case BFNSDB_ERROR_INVALID_DATAPATH:
    fprintf(stderr, "OVSDB: invalid datapath\n");
    break;
  case BFNSDB_ERROR_DATAPATH_EXISTS:
    fprintf(stderr, "OVSDB: datapath already exists\n");
    break;
  case BFNSDB_ERROR_INVALID_PORT:
    fprintf(stderr, "OVSDB: invalid port\n");
    break;
  case BFNSDB_ERROR_PORT_EXISTS:
    fprintf(stderr, "OVSDB: port already exists\n");
    break;
  default:
    fprintf(stderr, "OVSDB: unknown error code\n");
  }
}

static int connect_to_switch(bfns_tcp_over_ip_t *listener_addr) {
  int sockfd;
  struct sockaddr_in servaddr;

  sockfd = socket(AF_INET,SOCK_STREAM,0);
  if(sockfd < 0) return -1;

  memset(&servaddr, 0, sizeof(servaddr));
  servaddr.sin_family = AF_INET;
  inet_pton(AF_INET, listener_addr->ip, &servaddr.sin_addr.s_addr);
  servaddr.sin_port = htons(listener_addr->port);

  if(connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr)) < 0)
    return -1;

  return sockfd;
}

static int get_listener_addr(bfns_db_cxt_t c, const char *datapath,
			     bfns_tcp_over_ip_t *listener_addr) {
  if(bfns_db_get_listener(c, datapath, listener_addr)) {
    return -1;
  }
  return 0;
}

static uint64_t gen_rand_uint64() {
  int r1 = rand();
  int r2 = rand();
  return (((uint64_t) r1) << 32) | ((uint64_t) r2);
}

static int add_port(bfns_db_cxt_t c,
		    const char *datapath, const char *iface, uint16_t port_num) {
  if(!bfns_db_has_datapath(c, datapath)) {
    fprintf(stderr, "Invalid datapath name\n");
    return -1;
  }
  if(!port_num) {
    bfns_db_get_first_port_num(c, datapath, &port_num);
  }

  fprintf(stderr, "Adding interface %s as port %u to datapath %s\n",
	  iface, port_num, datapath);

  int status;

  bfns_tcp_over_ip_t listener_addr;
  status = get_listener_addr(c, datapath, &listener_addr);
  if(status) {
    print_bfnsdb_error(status);
    return -1;
  }

  if(bfns_db_has_port(c, datapath, iface)) {
    fprintf(stderr, "Port already attached to switch\n");
    return -1;
  }
  if(bfns_db_has_port_num(c, datapath, port_num)) {
    fprintf(stderr, "Port num already used by switch\n");
    return -1;
  }

  int switchfd = connect_to_switch(&listener_addr);
  if(switchfd < 0) {
    fprintf(stderr, "Could not connect to switch\n");
    return -1;
  }

  fprintf(stderr, "Connected to switch\n");

  ctl_msg_add_port_t msg;
  msg.code = CTL_MSG_ADD_PORT_CODE;
  uint64_t request_id = gen_rand_uint64();
  msg.request_id = request_id;
  strncpy(msg.iface, iface, sizeof(msg.iface));
  msg.port_num = port_num;

  int sent = sendall(switchfd, (char *) &msg, sizeof(msg));
  if(sent != sizeof(msg)) {
    fprintf(stderr, "Wrong number of bytes sent\n");
    return -1;
  }

  ctl_msg_status_t reply;
  int received = recvall(switchfd, (char *) &reply, sizeof(reply));
    if(received != sizeof(reply)) {
    fprintf(stderr, "Wrong number of bytes received\n");
    return -1;
  }

  assert(request_id == reply.request_id);
  assert(reply.code == CTL_MSG_STATUS);

  if(reply.status != CTL_MSG_STATUS_SUCCESS) {
    fprintf(stderr, "Request was not processed correctly by the switch\n");
    return -1;
  }

  close(switchfd);

  status = bfns_db_add_port(c, datapath, iface, port_num);
  if(status) {
    print_bfnsdb_error(status);
    return -1;
  }
  return 0;
}

static int del_port(bfns_db_cxt_t c,
		    const char *datapath, const char *iface) {
  if(!bfns_db_has_datapath(c, datapath)) {
    fprintf(stderr, "Invalid datapath name\n");
    return -1;
  }
  fprintf(stderr, "Deleting interface %s from datapath %s\n",
	  iface, datapath);

  int status;

  bfns_tcp_over_ip_t listener_addr;
  status = get_listener_addr(c, datapath, &listener_addr);
  if(status) {
    print_bfnsdb_error(status);
    return -1;
  }

  if(!bfns_db_has_port(c, datapath, iface)) {
    fprintf(stderr, "Port not attached to switch\n");
    return -1;
  }

  int switchfd = connect_to_switch(&listener_addr);
  if(switchfd < 0) {
    fprintf(stderr, "Could not connect to switch\n");
    return -1;
  }

  fprintf(stderr, "Connected to switch\n");

  ctl_msg_del_port_t msg;
  msg.code = CTL_MSG_DEL_PORT_CODE;
  uint64_t request_id = gen_rand_uint64();
  msg.request_id = request_id;
  strncpy(msg.iface, iface, sizeof(msg.iface));

  int sent = sendall(switchfd, (char *) &msg, sizeof(msg));
  if(sent != sizeof(msg)) {
    fprintf(stderr, "Wrong number of bytes sent\n");
    return -1;
  }

  ctl_msg_status_t reply;
  int received = recvall(switchfd, (char *) &reply, sizeof(reply));
    if(received != sizeof(reply)) {
    fprintf(stderr, "Wrong number of bytes received\n");
    return -1;
  }

  assert(request_id == reply.request_id);
  assert(reply.code == CTL_MSG_STATUS);

  if(reply.status != CTL_MSG_STATUS_SUCCESS) {
    fprintf(stderr, "Request was not processed correctly by the switch\n");
    return -1;
  }

  close(switchfd);

  status = bfns_db_del_port(c, datapath, iface);
  if(status) {
    print_bfnsdb_error(status);
    return -1;
  }
  return 0;
}

static int show() {
  fprintf(stderr, "Not implemented yet\n");
  return -1;
}

int main(int argc, char *argv[]) {
  srand (time(NULL));

  parse_options(argc, argv);

  bfns_tcp_over_ip_t bfnsdb_addr;

  if(!bfnsdb_str) {
    fprintf(stderr, "No bfnsdb address specified, using 127.0.0.1:%u\n",
	    BFNSDB_DEFAULT_PORT);
    parse_connection("127.0.0.1", &bfnsdb_addr, BFNSDB_DEFAULT_PORT);
  }
  else {
    if(parse_connection(bfnsdb_str, &bfnsdb_addr, BFNSDB_DEFAULT_PORT) != 0)
      return -1;
    fprintf(stderr, "Bfnsdb address is %s:%u\n",
	    bfnsdb_addr.ip, bfnsdb_addr.port);
    free(bfnsdb_str);
  }

  bfns_db_cxt_t c = connect_to_bfnsdb(&bfnsdb_addr);
  if(!c) return -1;

  argc -= optind;
  argv += optind;

  if (argc < 1) {
    help();
    return 1;
  }
  const char *cmd = argv[0];

  if (!strcmp(cmd, "help")) {
    help();
  } else if (!strcmp(cmd, "show")) {
    show();
  } else if (!strcmp(cmd, "add-port")) {
    if (argc != 3 && argc != 2) {
      fprintf(stderr, "Wrong number of arguments for the %s command (try help)\n", cmd);
      return 1;
    }
    uint16_t port = 0;
    if (argc == 3) {
      port = strtoll(argv[2], NULL, 10);
    }
    add_port(c, datapath_name, argv[1], port);
  } else if (!strcmp(cmd, "del-port")) {
    if (argc != 2) {
      fprintf(stderr, "Wrong number of arguments for the %s command (try help)\n", cmd);
      return 1;
    }
    del_port(c, datapath_name, argv[1]);
  } else {
    fprintf(stderr, "Unknown command '%s' (try help)\n", cmd);
    return 1;
  }

  return 0;
}

