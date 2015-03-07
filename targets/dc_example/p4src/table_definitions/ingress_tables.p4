/* Table to validate outer ethernet header */
#include "ingress/validate_outer_ethernet.p4"

/* Table to validate outer IP header */
#include "ingress/validate_outer_ipv4_packet.p4"

/* Port mapping table */
#include "ingress/port_mapping.p4"

/* Port VLAN mapping table */
#include "ingress/port_vlan_mapping.p4"

/* Spanning tree table */
#include "ingress/spanning_tree.p4"

/* Outer RMAC table */
#include "ingress/outer_rmac.p4"

/* IPv4 Dest VTEP table */
#include "ingress/ipv4_dest_vtep.p4"

/* IPv4 Src VTEP table */
#include "ingress/ipv4_src_vtep.p4"

/* Tunnel table */
#include "ingress/tunnel.p4"

/* BD table */
#include "ingress/bd.p4"

/* validate packet table */
#include "ingress/validate_packet.p4"

/* SMAC table */
#include "ingress/smac.p4"

/* DMAC table */
#include "ingress/dmac.p4"

/* RMAC table */
#include "ingress/rmac.p4"

/* MAC and IP ACL */
#include "ingress/mac_ip_acl.p4"

/* IP_RACL table */
#include "ingress/ip_racl.p4"

/* IP FIB tables, both lpm and ternary */
#include "ingress/ip_fib.p4"

/* fwd_result table */
#include "ingress/fwd_result.p4"

/* ecmp_group table */
#include "ingress/ecmp_group.p4"

/* next hop table */
#include "ingress/next_hop.p4"

/* LAG group table */
#include "ingress/lag_group.p4"

/* system_acl table */
#include "ingress/system_acl.p4"

/* learn_notify table */
#include "ingress/learn_notify.p4"


