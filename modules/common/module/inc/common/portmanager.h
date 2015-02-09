#ifndef _PORTMANAGER_H_
#define _PORTMANAGER_H_

/* Common port manager header file. */

#include <common/common_types.h>

typedef void (*bfm_packet_handler_vector_f)(uint32_t port_num,
                                            uint8_t *buffer,
                                            int length);

extern void
bfm_packet_handler_vector_set(bfm_packet_handler_vector_f fn);

extern bfm_error_t bfm_port_init(int port_count);
extern bfm_error_t bfm_port_finish(void);

extern bfm_error_t bfm_port_interface_add(char *ifname, uint32_t port_num,
					  char *sw_name, int dump_pcap);
extern bfm_error_t bfm_port_interface_remove(char *ifname);

extern bfm_error_t bfm_port_packet_emit(uint32_t port_num,
                                        uint16_t queue_id,
                                        uint8_t *data, int len);

extern void bfm_set_pcap_outdir( char *outdir_name );

#endif /* _PORTMANAGER_H_ */
