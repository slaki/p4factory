/* #define constants that are used elsewhere */

/* Boolean */
#define FALSE                                  0
#define TRUE                                   1

/* Packet types */
#define L2_UNICAST                             1
#define L2_MULTICAST                           2
#define L2_BROADCAST                           4

/* IP types */
#define IPTYPE_NONE                            0
#define IPTYPE_IPV4                            1

/* Egress tunnel types */
#define EGRESS_TUNNEL_TYPE_NONE                0
#define EGRESS_TUNNEL_TYPE_IPV4_VXLAN          1
#define EGRESS_TUNNEL_TYPE_IPV4_GENEVE         2
#define EGRESS_TUNNEL_TYPE_IPV4_NVGRE          3
#define EGRESS_TUNNEL_TYPE_IPV4_ERSPANV2       4

#define VRF_BIT_WIDTH                          12
#define BD_BIT_WIDTH                           16
#define ECMP_BIT_WIDTH                         10
#define LAG_BIT_WIDTH                          8
#define IFINDEX_BIT_WIDTH                      10

#define STP_GROUP_NONE                         0

/* Egress spec */
#define CPU_PORT                               250

/* Learning Recievers */
#define MAC_LEARN_RECIEVER      1024
