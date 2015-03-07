#include "includes/headers.p4"
#include "includes/parser.p4"
#include "includes/p4features.h"
#include "includes/intrinsic.p4"
#include "includes/table_sizes.h"
#include "includes/constants.h"

/* Define metadata variables for ingress and egress metadata */
#include "includes/ingress_metadata.p4"
#include "includes/egress_metadata.p4"
metadata ingress_metadata_t ingress_metadata;
metadata egress_metadata_t egress_metadata;

action nop() {
}

action on_miss() {
}

/* Table to validate outer ethernet header */
#include "table_definitions/validate_outer_ethernet.p4"

/* Table to validate outer IP header */
#include "table_definitions/validate_outer_ipv4_packet.p4"

/* Port mapping table */
#include "table_definitions/port_mapping.p4"

/* Port VLAN mapping table */
#include "table_definitions/port_vlan_mapping.p4"

/* Spanning tree table */
#include "table_definitions/spanning_tree.p4"

/* Outer RMAC table */
#include "table_definitions/outer_rmac.p4"

/* IPv4 Dest VTEP table */
#include "table_definitions/ipv4_dest_vtep.p4"

/* IPv4 Src VTEP table */
#include "table_definitions/ipv4_src_vtep.p4"

/* Tunnel table */
#include "table_definitions/tunnel.p4"

/* BD table */
#include "table_definitions/bd.p4"

/* validate packet table */
#include "table_definitions/validate_packet.p4"

/* SMAC table */
#include "table_definitions/smac.p4"

/* DMAC table */
#include "table_definitions/dmac.p4"

/* RMAC table */
#include "table_definitions/rmac.p4"

/* MAC and IP ACL */
#include "table_definitions/mac_ip_acl.p4"

/* IP_RACL table */
#include "table_definitions/ip_racl.p4"

/* IP FIB tables, both lpm and ternary */
#include "table_definitions/ip_fib.p4"

/* fwd_result table */
#include "table_definitions/fwd_result.p4"

/* ecmp_group table */
#include "table_definitions/ecmp_group.p4"

/* next hop table */
#include "table_definitions/next_hop.p4"

/* LAG group table */
#include "table_definitions/lag_group.p4"

/* system_acl table */
#include "table_definitions/system_acl.p4"

/* learn_notify table */
#include "table_definitions/learn_notify.p4"

control ingress {

    /* Check to see the whole stage needs to be bypassed */
    if(ingress_metadata.ingress_bypass == FALSE) {

        /* validate the ethernet header */
        apply(validate_outer_ethernet);

        /* validate input packet and perform basic validations */
        if (valid(ipv4)) {
            apply(validate_outer_ipv4_packet);
        }

        /* input mapping - derive an ifindex */
        /*
         * skipping this lookup as phase 0 lookup will provide
         * an ifindex that maps all ports in a lag to a single value
         */
        apply(port_mapping);

        /* derive lif, bd */
        apply(port_vlan_mapping);

        if (ingress_metadata.stp_group != STP_GROUP_NONE) {
            apply(spanning_tree);
        }

#ifndef TUNNEL_DISABLE

        /* outer RMAC lookup for tunnel termination */
        apply(outer_rmac);

        /* src vtep table lookup */
        if (valid(ipv4)) {
            apply(ipv4_src_vtep);
        }

        if (ingress_metadata.lkp_pkt_type == L2_UNICAST) {
            /* check for ipv4 unicast tunnel termination  */
            if ((ingress_metadata.lkp_ip_type == IPTYPE_IPV4) and
                (ingress_metadata.ipv4_unicast_enabled == TRUE)) {
                apply(ipv4_dest_vtep);
            }
        }
#endif /* TUNNEL_DISABLE */

#ifndef TUNNEL_DISABLE
        /* perform tunnel termination */
        if ((ingress_metadata.src_vtep_miss == FALSE) and
            (((ingress_metadata.outer_rmac_hit == TRUE) and
              (ingress_metadata.tunnel_terminate == TRUE)) or
             ((ingress_metadata.lkp_pkt_type == L2_MULTICAST) and
              (ingress_metadata.tunnel_terminate == TRUE)))) {
            apply(tunnel);
        }
	else {
#endif /* TUNNEL_DISABLE */
            /* extract BD related parameters */
            apply(bd);
#ifndef TUNNEL_DISABLE
        }
#endif /* TUNNEL_DISABLE */

        /* validate packet */
        apply(validate_packet);

        /* l2 lookups */
        apply(smac);

        /* generate learn notify digest if permitted */
        apply(learn_notify);

#ifndef ACL_DISABLE
        /* port and vlan ACL */
        if (ingress_metadata.lkp_ip_type == IPTYPE_NONE) {
                apply(mac_acl);
        }
        else {
                if (ingress_metadata.lkp_ip_type == IPTYPE_IPV4) {
                    apply(ip_acl);
                }
        }
#endif /* ACL DISABLE */

        apply(rmac) {
                on_miss {
                    apply(dmac);
                }
                default {
                    if ((ingress_metadata.lkp_ip_type == IPTYPE_IPV4) and
                        (ingress_metadata.ipv4_unicast_enabled == TRUE)) {

#ifndef ACL_DISABLE
                        /* router ACL/PBR */
                        apply(ip_racl);
#endif /* ACL_DISABLE */

                        /* fib lookup */
                        apply(ipv4_fib) {
                            on_miss {
                                apply(ipv4_fib_lpm);
                            }
                        }
                    }
                }
        }
        /* merge the results and decide whice one to use */
        apply(fwd_result);

        /* resolve ecmp */
        if (ingress_metadata.ecmp_index != 0) {
            apply(ecmp_group);
        } else {
            /* resolve nexthop */
            apply(nexthop);
        }

        /* resolve final egress port for unicast traffic */
        apply(lag_group);

#ifndef ACL_DISABLE
        /* system acls */
        apply(system_acl);
#endif /* ACL_DISABLE */
    }
}

/* RID table */
#include "table_definitions/rid.p4"

/* Tunnel decap table */
#include "table_definitions/tunnel_decap.p4"

/* egress_bd_map table */
#include "table_definitions/egress_bd_map.p4"

/* rewrite table */
#include "table_definitions/rewrite.p4"

/* tunnel_rewrite table */
#include "table_definitions/tunnel_rewrite.p4"

/* tunnel_src_rewrite table */
#include "table_definitions/tunnel_src_rewrite.p4"

/* tunnel_dst_rewrite table */
#include "table_definitions/tunnel_dst_rewrite.p4"

/* outer_mac table */
#include "table_definitions/outer_mac.p4"

/* egress_block table */
#include "table_definitions/egress_block.p4"

/* egress_vlan_xlate  table */
#include "table_definitions/egress_vlan_xlate.p4"

/* egress_system_acl table */
#include "table_definitions/egress_system_acl.p4"

/* cpu_rewrite table */
#include "table_definitions/cpu_rewrite.p4"

control egress {
    if (egress_metadata.egress_bypass == FALSE) {

#ifndef MULTICAST_DISABLE
        if(intrinsic_metadata.replication_id != 0) {
            /* set info from rid */
            apply(rid);
        }
#endif /* MULTICAST_DISABLE */

#ifndef TUNNEL_DISABLE
        /* perform tunnel decap */
        if (ingress_metadata.tunnel_terminate == TRUE) {
            if (egress_metadata.replica == FALSE) {
                apply(tunnel_decap);
            }
        }

        /* egress bd to vnid mapping */
        apply(egress_bd_map);
#endif /* TUNNEL_DISABLE */

        /* apply nexthop_index based packet rewrites */
        apply(rewrite);

#ifndef TUNNEL_DISABLE
        if (egress_metadata.tunnel_type != EGRESS_TUNNEL_TYPE_NONE) {
            /* tunnel rewrites */
            apply(tunnel_rewrite);

            /* rewrite tunnel src and dst ip */
            apply(tunnel_src_rewrite);
            apply(tunnel_dst_rewrite);
        }
#endif /* TUNNEL_DISABLE */

        /* rewrite source/destination mac if needed */
        if (egress_metadata.routed == TRUE) {
            apply(outer_mac);
        }

        apply(egress_block) {
	        on_miss {
                /* egress vlan translation */
                apply(egress_vlan_xlate);
            }
        }

#ifndef ACL_DISABLE
        /* apply egress acl */
        apply(egress_system_acl);
#endif /* ACL_DISABLE */

        apply(cpu_rewrite);
    }
}
