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

#ifndef MULTICAST_DISABLE
action replica_from_rid(bd) {
    modify_field(ingress_metadata.egress_bd, bd);
    modify_field(egress_metadata.replica, TRUE);
}

table rid {
    reads {
        intrinsic_metadata.replication_id : exact;
    }
    actions {
        nop;
        replica_from_rid;
    }
    size : RID_TABLE_SIZE;
}

#endif

action decapsulate_vxlan_packet_inner_ipv4_udp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    copy_header(udp, inner_udp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_udp);
    remove_header(vxlan);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_vxlan_packet_inner_ipv4_tcp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    add_header(tcp);
    copy_header(tcp, inner_tcp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_tcp);
    remove_header(udp);
    remove_header(vxlan);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_geneve_packet_inner_ipv4_udp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    copy_header(udp, inner_udp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_udp);
    remove_header(genv);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_geneve_packet_inner_ipv4_tcp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    add_header(tcp);
    copy_header(tcp, inner_tcp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_tcp);
    remove_header(udp);
    remove_header(genv);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_nvgre_packet_inner_ipv4_udp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    copy_header(udp, inner_udp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_udp);
    remove_header(nvgre);
    remove_header(gre);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_nvgre_packet_inner_ipv4_tcp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    add_header(tcp);
    copy_header(tcp, inner_tcp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_tcp);
    remove_header(nvgre);
    remove_header(gre);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

table tunnel_decap {
    reads {
        ingress_metadata.tunnel_type : exact;
        inner_ipv4 : valid;
        inner_tcp : valid;
        inner_udp : valid;
    }
    actions {
        decapsulate_vxlan_packet_inner_ipv4_udp;
        decapsulate_vxlan_packet_inner_ipv4_tcp;
        decapsulate_geneve_packet_inner_ipv4_udp;
        decapsulate_geneve_packet_inner_ipv4_tcp;
        decapsulate_nvgre_packet_inner_ipv4_udp;
        decapsulate_nvgre_packet_inner_ipv4_tcp;
    }
    size : TUNNEL_DECAP_TABLE_SIZE;
}

action set_egress_bd_properties(vnid ) {
    modify_field(egress_metadata.vnid, vnid);
}

table egress_bd_map {
    reads {
        ingress_metadata.egress_bd : exact;
    }
    actions {
        nop;
        set_egress_bd_properties;
    }
    size : EGRESS_VNID_MAPPING_TABLE_SIZE;
}

action set_l2_rewrite() {
    modify_field(egress_metadata.routed, FALSE);
}

action set_ipv4_unicast_rewrite(smac_idx, dmac) {
    modify_field(egress_metadata.smac_idx, smac_idx);
    modify_field(egress_metadata.mac_da, dmac);
    modify_field(egress_metadata.routed, TRUE);
    modify_field(ipv4.ttl, ingress_metadata.ttl);
}

field_list entropy_hash_fields {
    inner_ethernet.srcAddr;
    inner_ethernet.dstAddr;
    inner_ethernet.etherType;
    inner_ipv4.srcAddr;
    inner_ipv4.dstAddr;
    inner_ipv4.protocol;
}

field_list_calculation entropy_hash {
    input {
        entropy_hash_fields;
    }
    algorithm : crc16;
    output_width : 16;
}


action set_ipv4_vxlan_rewrite(outer_bd, tunnel_src_index, tunnel_dst_index,
        smac_idx, dmac) {
    modify_field(egress_metadata.bd, outer_bd);
    modify_field(egress_metadata.smac_idx, smac_idx);
    modify_field(egress_metadata.mac_da, dmac);
    modify_field(egress_metadata.tunnel_src_index, tunnel_src_index);
    modify_field(egress_metadata.tunnel_dst_index, tunnel_dst_index);
    modify_field(egress_metadata.routed, TRUE);
    modify_field(egress_metadata.tunnel_type, EGRESS_TUNNEL_TYPE_IPV4_VXLAN);
}

action set_ipv4_geneve_rewrite(outer_bd, tunnel_src_index, tunnel_dst_index,
        smac_idx, dmac) {
    modify_field(egress_metadata.bd, outer_bd);
    modify_field(egress_metadata.smac_idx, smac_idx);
    modify_field(egress_metadata.mac_da, dmac);
    modify_field(egress_metadata.tunnel_src_index, tunnel_src_index);
    modify_field(egress_metadata.tunnel_dst_index, tunnel_dst_index);
    modify_field(egress_metadata.routed, TRUE);
    modify_field(egress_metadata.tunnel_type, EGRESS_TUNNEL_TYPE_IPV4_GENEVE);
}

action set_ipv4_nvgre_rewrite(outer_bd, tunnel_src_index, tunnel_dst_index,
        smac_idx, dmac) {
    modify_field(egress_metadata.bd, outer_bd);
    modify_field(egress_metadata.smac_idx, smac_idx);
    modify_field(egress_metadata.mac_da, dmac);
    modify_field(egress_metadata.tunnel_src_index, tunnel_src_index);
    modify_field(egress_metadata.tunnel_dst_index, tunnel_dst_index);
    modify_field(egress_metadata.routed, TRUE);
    modify_field(egress_metadata.tunnel_type, EGRESS_TUNNEL_TYPE_IPV4_NVGRE);
}

action set_ipv4_erspan_v2_rewrite(outer_bd, tunnel_src_index, tunnel_dst_index,
        smac_idx, dmac) {
    modify_field(egress_metadata.bd, outer_bd);
    modify_field(egress_metadata.smac_idx, smac_idx);
    modify_field(egress_metadata.mac_da, dmac);
    modify_field(egress_metadata.tunnel_src_index, tunnel_src_index);
    modify_field(egress_metadata.tunnel_dst_index, tunnel_dst_index);
    modify_field(egress_metadata.routed, TRUE);
    modify_field(egress_metadata.tunnel_type, EGRESS_TUNNEL_TYPE_IPV4_ERSPANV2);
}

table rewrite {
    reads {
        ingress_metadata.nexthop_index : exact;
    }
    actions {
        nop;
        set_l2_rewrite;
        set_ipv4_unicast_rewrite;
        set_ipv4_vxlan_rewrite;
        set_ipv4_geneve_rewrite;
        set_ipv4_nvgre_rewrite;
        set_ipv4_erspan_v2_rewrite;
    }
    size : NEXTHOP_TABLE_SIZE;
}

action f_copy_ipv4_to_inner() {
    add_header(inner_ethernet);
    copy_header(inner_ethernet, ethernet);
    add_header(inner_ipv4);
    copy_header(inner_ipv4, ipv4);
    modify_field(inner_ipv4.ttl, ingress_metadata.ttl);
    remove_header(ipv4);
}

action f_copy_ipv4_udp_to_inner() {
    f_copy_ipv4_to_inner();
    add_header(inner_udp);
    copy_header(inner_udp, udp);
    remove_header(udp);
}

action f_copy_ipv4_tcp_to_inner() {
    f_copy_ipv4_to_inner();
    add_header(inner_tcp);
    copy_header(inner_tcp, tcp);
    remove_header(tcp);
}

action f_insert_vxlan_header() {
    add_header(udp);
    add_header(vxlan);

    modify_field_with_hash_based_offset(udp.srcPort, 0, entropy_hash, 16384);
    modify_field(udp.dstPort, UDP_PORT_VXLAN);
    modify_field(udp.checksum, 0);
    modify_field(udp.length_, ingress_metadata.l3_length);
    add_to_field(udp.length_, 30); // 8+8+14

    modify_field(vxlan.flags, 0x8);
    modify_field(vxlan.vni, egress_metadata.vnid);
}

action f_insert_ipv4_header(proto) {
    add_header(ipv4);
    modify_field(ipv4.protocol, proto);
    modify_field(ipv4.ttl, ingress_metadata.ttl);
    modify_field(ipv4.version, 0x4);
    modify_field(ipv4.ihl, 0x5);
}

action ipv4_vxlan_inner_ipv4_udp_rewrite() {
    f_copy_ipv4_udp_to_inner();
    f_insert_vxlan_header();
    f_insert_ipv4_header(IP_PROTOCOLS_UDP);
    modify_field(ipv4.totalLen, ingress_metadata.l3_length);
    add_to_field(ipv4.totalLen, 50);
}

action ipv4_vxlan_inner_ipv4_tcp_rewrite() {
    f_copy_ipv4_tcp_to_inner();
    f_insert_vxlan_header();
    f_insert_ipv4_header(IP_PROTOCOLS_UDP);
    modify_field(ipv4.totalLen, ingress_metadata.l3_length);
    add_to_field(ipv4.totalLen, 50);
}

action f_insert_genv_header() {
    add_header(udp);
    add_header(genv);

    modify_field_with_hash_based_offset(udp.srcPort, 0, entropy_hash, 16384);
    modify_field(udp.dstPort, UDP_PORT_GENV);
    modify_field(udp.checksum, 0);
    modify_field(udp.length_, ingress_metadata.l3_length);
    add_to_field(udp.length_, 30); // 8+8+14

    modify_field(genv.ver, 0);
    modify_field(genv.oam, 0);
    modify_field(genv.critical, 0);
    modify_field(genv.optLen, 0);
    modify_field(genv.protoType, 0x6558);
    modify_field(genv.vni, egress_metadata.vnid);
}

action ipv4_genv_inner_ipv4_udp_rewrite() {
    f_copy_ipv4_udp_to_inner();
    f_insert_genv_header();
    f_insert_ipv4_header(IP_PROTOCOLS_UDP);
    modify_field(ipv4.totalLen, ingress_metadata.l3_length);
    add_to_field(ipv4.totalLen, 50);
}

action ipv4_genv_inner_ipv4_tcp_rewrite() {
    f_copy_ipv4_tcp_to_inner();
    f_insert_genv_header();
    f_insert_ipv4_header(IP_PROTOCOLS_UDP);
    modify_field(ipv4.totalLen, ingress_metadata.l3_length);
    add_to_field(ipv4.totalLen, 50);
}

action f_insert_nvgre_header() {
    add_header(gre);
    add_header(nvgre);
    modify_field(gre.proto, 0x6558);
    modify_field(gre.K, 1);
    modify_field(gre.C, 0);
    modify_field(gre.S, 0);
    modify_field(nvgre.tni, egress_metadata.vnid);
}

action ipv4_nvgre_inner_ipv4_udp_rewrite() {
    f_copy_ipv4_udp_to_inner();
    f_insert_nvgre_header();
    f_insert_ipv4_header(IP_PROTOCOLS_GRE);
    modify_field(ipv4.totalLen, ingress_metadata.l3_length);
    add_to_field(ipv4.totalLen, 42);
}

action ipv4_nvgre_inner_ipv4_tcp_rewrite() {
    f_copy_ipv4_tcp_to_inner();
    f_insert_nvgre_header();
    f_insert_ipv4_header(IP_PROTOCOLS_GRE);
    modify_field(ipv4.totalLen, ingress_metadata.l3_length);
    add_to_field(ipv4.totalLen, 42);
}

action f_insert_erspan_v2_header() {
    add_header(gre);
    add_header(erspan_v2_header);
    modify_field(gre.proto, GRE_PROTOCOLS_ERSPAN_V2);
    modify_field(erspan_v2_header.version, 1);
    modify_field(erspan_v2_header.vlan, egress_metadata.vnid);
}

action ipv4_erspan_v2_inner_ipv4_udp_rewrite() {
    f_copy_ipv4_udp_to_inner();
    f_insert_erspan_v2_header();
    f_insert_ipv4_header(IP_PROTOCOLS_GRE);
    modify_field(ipv4.totalLen, ingress_metadata.l3_length);
    add_to_field(ipv4.totalLen, 46);
}

action ipv4_erspan_v2_inner_ipv4_tcp_rewrite() {
    f_copy_ipv4_tcp_to_inner();
    f_insert_erspan_v2_header();
    f_insert_ipv4_header(IP_PROTOCOLS_GRE);
    modify_field(ipv4.totalLen, ingress_metadata.l3_length);
    add_to_field(ipv4.totalLen, 46);
}


table tunnel_rewrite {
    reads {
        egress_metadata.tunnel_type : exact;
        ipv4 : valid;
        tcp : valid;
        udp : valid;
    }
    actions {
/*
 * These actions encapsulate a packet.
 * Sequence of modifications in each action is:
 * 1. Add inner L3/L4 header. The type of these headers should be same as that
 *    of the packet being encapsulated.
 * 2. Copy outer L3/L4 headers to inner L3/L4 headers.
 * 3. Remove outer L3/L4 headers.
 * 4. Add outer L3 header and encapsulation header.
 * For each encapsulation type, we need 8 actions to handle 8 different
 * combinations:
 * Outer L3 (IPv4) X Inner L3 (IPv4) X Inner L4 (TCP/UDP)
 */
        ipv4_vxlan_inner_ipv4_udp_rewrite;
        ipv4_vxlan_inner_ipv4_tcp_rewrite;
        ipv4_genv_inner_ipv4_udp_rewrite;
        ipv4_genv_inner_ipv4_tcp_rewrite;
        ipv4_nvgre_inner_ipv4_udp_rewrite;
        ipv4_nvgre_inner_ipv4_tcp_rewrite;
        ipv4_erspan_v2_inner_ipv4_udp_rewrite;
        ipv4_erspan_v2_inner_ipv4_tcp_rewrite;
    }
    size : TUNNEL_REWRITE_TABLE_SIZE;
}

action rewrite_tunnel_ipv4_src(ip) {
    modify_field(ipv4.srcAddr, ip);
}

table tunnel_src_rewrite {
    reads {
        egress_metadata.tunnel_src_index : exact;
    }
    actions {
        rewrite_tunnel_ipv4_src;
    }
    size : DEST_TUNNEL_TABLE_SIZE;
}

action rewrite_tunnel_ipv4_dst(ip) {
    modify_field(ipv4.dstAddr, ip);
}

table tunnel_dst_rewrite {
    reads {
        egress_metadata.tunnel_dst_index : exact;
    }
    actions {
        rewrite_tunnel_ipv4_dst;
    }
    size : SRC_TUNNEL_TABLE_SIZE;
}

action rewrite_unicast_mac(smac) {
    modify_field(ethernet.srcAddr, smac);
    modify_field(ethernet.dstAddr, egress_metadata.mac_da);
}

action rewrite_multicast_mac(smac) {
    modify_field(ethernet.srcAddr, smac);
    modify_field(ethernet.dstAddr, 0x01005E000000);
    modify_field(ethernet.dstAddr, ipv4.dstAddr, 0x7FFFFF);
    add_to_field(ipv4.ttl, -1);
}

table outer_mac {
    reads {
        egress_metadata.smac_idx : exact;
        ipv4.dstAddr : ternary;
    }
    actions {
        nop;
        rewrite_unicast_mac;
        rewrite_multicast_mac;
    }
    size : SOURCE_MAC_TABLE_SIZE;
}

action set_egress_packet_vlan_tagged(vlan_id) {
    add_header(vlan_tag_[0]);
    modify_field(vlan_tag_[0].vid, vlan_id);
}

action set_egress_packet_vlan_untagged() {
    remove_header(vlan_tag_[0]);
}


action egress_drop () {
    drop();
}

table egress_block {
    reads {
        standard_metadata.egress_port : exact;
        intrinsic_metadata.replication_id : exact;
    }
    actions {
        on_miss;
        egress_drop;
    }
    size : EGRESS_BLOCK_TABLE_SIZE;
}

table egress_vlan_xlate {
    reads {
        standard_metadata.egress_port : exact;
        egress_metadata.bd : exact;
    }
    actions {
        nop;
        set_egress_packet_vlan_tagged;
        set_egress_packet_vlan_untagged;
    }
    size : EGRESS_VLAN_XLATE_TABLE_SIZE;
}

action egress_redirect_to_cpu() {
}

table egress_system_acl {
    reads {
        egress_metadata.mtu_check_fail : ternary;
    }
    actions {
        nop;
        egress_redirect_to_cpu;
    }
    size : EGRESS_SYSTEM_ACL_TABLE_SIZE;
}

action set_cpu_tx_rewrite() {
    modify_field(ethernet.etherType, cpu_header.etherType);
    remove_header(cpu_header);
}

action set_cpu_rx_rewrite() {
    add_header(cpu_header);
    modify_field(cpu_header.etherType, ethernet.etherType);
    modify_field(cpu_header.ingress_lif, standard_metadata.ingress_port);
}

table cpu_rewrite {
    reads {
        standard_metadata.egress_port : ternary;
        standard_metadata.ingress_port : ternary;
    }
    actions {
        nop;
        set_cpu_tx_rewrite;
        set_cpu_rx_rewrite;
    }
    size : CPU_REWRITE_TABLE_SIZE;
}

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


