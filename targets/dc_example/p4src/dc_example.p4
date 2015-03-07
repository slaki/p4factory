#include "includes/headers.p4"
#include "includes/parser.p4"
#include "includes/p4features.h"
#include "includes/intrinsic.p4"
#include "includes/table_sizes.h"
#include "includes/ingress_metadata.p4"
#include "includes/egress_metadata.p4"
#include "includes/constants.h"

/* Define metadata variables for ingress and egress metadata */
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

action set_ifindex(ifindex, if_label) {
    modify_field(ingress_metadata.ifindex, ifindex);
    modify_field(ingress_metadata.if_label, if_label);
}

table port_mapping {
    reads {
        standard_metadata.ingress_port : exact;
    }
    actions {
        set_ifindex;
    }
    size : PORTMAP_TABLE_SIZE;
}

table port_vlan_mapping {
    reads {
        ingress_metadata.ifindex : exact;
        vlan_tag_[0] : valid;
        vlan_tag_[0].vid : exact;
        vlan_tag_[1] : valid;
        vlan_tag_[1].vid : exact;
    }

    action_profile: outer_bd_action_profile;
    size : PORT_VLAN_TABLE_SIZE;
}

action set_stp_state(stp_state) {
    modify_field(ingress_metadata.stp_state, stp_state);
}

table spanning_tree {
    reads {
        ingress_metadata.ifindex : exact;
        ingress_metadata.stp_group: exact;
    }
    actions {
        set_stp_state;
    }
    size : SPANNING_TREE_TABLE_SIZE;
}

action set_bd(outer_vlan_bd, vrf, rmac_group, 
        ipv4_unicast_enabled, 
        stp_group) {
    modify_field(ingress_metadata.vrf, vrf);
    modify_field(ingress_metadata.ipv4_unicast_enabled, ipv4_unicast_enabled);
    modify_field(ingress_metadata.outer_rmac_group, rmac_group);
    modify_field(ingress_metadata.bd, outer_vlan_bd);
    modify_field(ingress_metadata.stp_group, stp_group);
}

/*
* outer_bd is used to extract the tunnel termination 
*   actions
*/
action_profile outer_bd_action_profile {
    actions {
        set_bd;
    }
    size : OUTER_BD_TABLE_SIZE;
}

action set_outer_rmac_hit_flag() {
    modify_field(ingress_metadata.outer_rmac_hit, TRUE);
}

table outer_rmac {
    reads {
        ingress_metadata.outer_rmac_group : exact;
        ingress_metadata.lkp_mac_da : exact;
    }
    actions {
        nop;
        set_outer_rmac_hit_flag;
    }
    size : OUTER_ROUTER_MAC_TABLE_SIZE;
}

action set_tunnel_termination_flag() {
    modify_field(ingress_metadata.tunnel_terminate, TRUE);
}

table ipv4_dest_vtep {
    reads {
        ingress_metadata.vrf : exact;
        ingress_metadata.lkp_ipv4_da : exact;
        ingress_metadata.lkp_ip_proto : exact;
        ingress_metadata.lkp_l4_dport : exact;
    }
    actions {
        nop;
        set_tunnel_termination_flag;
    }
    size : DEST_TUNNEL_TABLE_SIZE;
}


action set_src_vtep_miss_flag() {
    modify_field(ingress_metadata.src_vtep_miss, TRUE);
}

action set_tunnel_lif(lif) {
    modify_field(ingress_metadata.tunnel_lif, lif);
}

table ipv4_src_vtep {
    reads {
        ingress_metadata.vrf : exact;
        ingress_metadata.lkp_ipv4_sa : exact;
    }
    actions {
        nop;
        set_tunnel_lif;
        set_src_vtep_miss_flag;
    }
    size : SRC_TUNNEL_TABLE_SIZE;
}



action terminate_tunnel_inner_ipv4(bd, vrf,
        rmac_group, bd_label,
        uuc_mc_index, bcast_mc_index, umc_mc_index,
        ipv4_unicast_enabled, igmp_snooping_enabled)
        {
    modify_field(ingress_metadata.bd, bd);
    modify_field(ingress_metadata.vrf, vrf);
    modify_field(ingress_metadata.outer_dscp, ingress_metadata.lkp_ip_tc);
    // This implements tunnel in 'uniform' mode i.e. the TTL from the outer IP
    // header is copied into the header of decapsulated packet.
    // For decapsulation, the TTL in the outer IP header is copied to
    // ingress_metadata.lkp_ip_ttl in validate_outer_ipv4_packet action
    modify_field(ingress_metadata.outer_ttl, ingress_metadata.lkp_ip_ttl);
    add_to_field(ingress_metadata.outer_ttl, -1);

    modify_field(ingress_metadata.lkp_mac_sa, inner_ethernet.srcAddr);
    modify_field(ingress_metadata.lkp_mac_da, inner_ethernet.dstAddr);
    modify_field(ingress_metadata.lkp_ip_type, IPTYPE_IPV4);
    modify_field(ingress_metadata.lkp_ipv4_sa, inner_ipv4.srcAddr);
    modify_field(ingress_metadata.lkp_ipv4_da, inner_ipv4.dstAddr);
    modify_field(ingress_metadata.lkp_ip_proto, inner_ipv4.protocol);
    modify_field(ingress_metadata.lkp_ip_tc, inner_ipv4.diffserv);
    modify_field(ingress_metadata.lkp_l4_sport, ingress_metadata.lkp_inner_l4_sport);
    modify_field(ingress_metadata.lkp_l4_dport, ingress_metadata.lkp_inner_l4_dport);

    modify_field(ingress_metadata.ipv4_unicast_enabled, ipv4_unicast_enabled);
    modify_field(ingress_metadata.igmp_snooping_enabled, igmp_snooping_enabled);
    modify_field(ingress_metadata.rmac_group, rmac_group);
    modify_field(ingress_metadata.uuc_mc_index, uuc_mc_index);
    modify_field(ingress_metadata.umc_mc_index, umc_mc_index);
    modify_field(ingress_metadata.bcast_mc_index, bcast_mc_index);
    modify_field(ingress_metadata.bd_label, bd_label);
    modify_field(ingress_metadata.l3_length, inner_ipv4.totalLen);
}


table tunnel {
    reads {
        ingress_metadata.tunnel_vni : exact;
        ingress_metadata.tunnel_type : exact;
        inner_ipv4 : valid;
    }
    actions {
        terminate_tunnel_inner_ipv4;
    }
    size : VNID_MAPPING_TABLE_SIZE;
}

action set_bd_info(vrf, rmac_group, 
        bd_label, uuc_mc_index, bcast_mc_index, umc_mc_index,
        ipv4_unicast_enabled, 
        igmp_snooping_enabled, stp_group) {
    modify_field(ingress_metadata.vrf, vrf);
    modify_field(ingress_metadata.ipv4_unicast_enabled, ipv4_unicast_enabled);
    modify_field(ingress_metadata.igmp_snooping_enabled, igmp_snooping_enabled);
    modify_field(ingress_metadata.rmac_group, rmac_group);
    modify_field(ingress_metadata.uuc_mc_index, uuc_mc_index);
    modify_field(ingress_metadata.umc_mc_index, umc_mc_index);
    modify_field(ingress_metadata.bcast_mc_index, bcast_mc_index);
    modify_field(ingress_metadata.bd_label, bd_label);
    modify_field(ingress_metadata.stp_group, stp_group);
}

/*
* extract all the bridge domain parameters for non-tunneled
*   packets
*/
table bd {
    reads {
        ingress_metadata.bd : exact;
    }
    actions {
        set_bd_info;
    }
    size : BD_TABLE_SIZE;
}

action set_l2_multicast() {
    modify_field(ingress_metadata.l2_multicast, TRUE);
}

action set_src_is_link_local() {
    modify_field(ingress_metadata.src_is_link_local, TRUE);
}

action set_malformed_packet() {
}

table validate_packet {
    reads {
        ingress_metadata.lkp_mac_da : ternary;
        ingress_metadata.lkp_ipv4_da : ternary;
    }
    actions {
        nop;
        set_l2_multicast;
        set_src_is_link_local;
        set_malformed_packet;
    }
    size : VALIDATE_PACKET_TABLE_SIZE;
}

action smac_miss() {
    modify_field(ingress_metadata.l2_src_miss, TRUE);
}

action smac_hit(ifindex) {
    bit_xor(ingress_metadata.l2_src_move, ingress_metadata.ifindex, ifindex);
    add_to_field(ingress_metadata.egress_bd, 0);
}

table smac {
    reads {
        ingress_metadata.bd : exact;
        ingress_metadata.lkp_mac_sa : exact;
    }
    actions {
        nop;
        smac_miss;
        smac_hit;
    }
    size : SMAC_TABLE_SIZE;
}

action dmac_hit(ifindex) {
    modify_field(ingress_metadata.egress_ifindex, ifindex);
    modify_field(ingress_metadata.egress_bd, ingress_metadata.bd);
}

action dmac_multicast_hit(mc_index) {
    modify_field(intrinsic_metadata.eg_mcast_group, mc_index);
    modify_field(ingress_metadata.egress_bd, ingress_metadata.bd);
}

action dmac_miss() {
    modify_field(intrinsic_metadata.eg_mcast_group, ingress_metadata.uuc_mc_index);
}

action dmac_redirect_nexthop(nexthop_index) {
    modify_field(ingress_metadata.l2_redirect, TRUE);
    modify_field(ingress_metadata.l2_nexthop, nexthop_index);
}

action dmac_redirect_ecmp(ecmp_index) {
    modify_field(ingress_metadata.l2_redirect, TRUE);
    modify_field(ingress_metadata.l2_ecmp, ecmp_index);
}

table dmac {
    reads {
        ingress_metadata.bd : exact;
        ingress_metadata.lkp_mac_da : exact;
    }
    actions {
        nop;
        dmac_hit;
        dmac_multicast_hit;
        dmac_miss;
        dmac_redirect_nexthop;
        dmac_redirect_ecmp;
    }
    size : DMAC_TABLE_SIZE;
    support_timeout: true;
}

action set_rmac_hit_flag() {
    modify_field(ingress_metadata.rmac_hit, TRUE);
}

table rmac {
    reads {
        ingress_metadata.rmac_group : exact;
        ingress_metadata.lkp_mac_da : exact;
    }
    actions {
        on_miss;
        set_rmac_hit_flag;
    }
    size : ROUTER_MAC_TABLE_SIZE;
}

action acl_log() {
}

action acl_deny() {
    modify_field(ingress_metadata.acl_deny, TRUE);
}

action acl_permit() {
}

action acl_redirect_nexthop(nexthop_index) {
    modify_field(ingress_metadata.acl_redirect, TRUE);
    modify_field(ingress_metadata.acl_nexthop, nexthop_index);
}

action acl_redirect_ecmp(ecmp_index) {
    modify_field(ingress_metadata.acl_redirect, TRUE);
    modify_field(ingress_metadata.acl_ecmp, ecmp_index);
}

table mac_acl {
    reads {
        ingress_metadata.if_label : ternary;
        ingress_metadata.bd_label : ternary;

        ingress_metadata.lkp_mac_sa : ternary;
        ingress_metadata.lkp_mac_da : ternary;
        ingress_metadata.lkp_mac_type : ternary;
    }
    actions {
        nop;
        acl_log;
        acl_deny;
        acl_permit;
    }
    size : INGRESS_MAC_ACL_TABLE_SIZE;
}

table ip_acl {
    reads {
        ingress_metadata.if_label : ternary;
        ingress_metadata.bd_label : ternary;

        ingress_metadata.lkp_ipv4_sa : ternary;
        ingress_metadata.lkp_ipv4_da : ternary;
        ingress_metadata.lkp_ip_proto : ternary;
        ingress_metadata.lkp_l4_sport : ternary;
        ingress_metadata.lkp_l4_dport : ternary;

        ingress_metadata.lkp_mac_type : ternary;
        ingress_metadata.msg_type : ternary; /* ICMP code */
        tcp : valid;
        tcp.flags : ternary;
        ingress_metadata.ttl : ternary;
    }
    actions {
        nop;
        acl_log;
        acl_deny;
        acl_permit;
        acl_redirect_nexthop;
        acl_redirect_ecmp;
    }
    size : INGRESS_IP_ACL_TABLE_SIZE;
}

action racl_log() {
}

action racl_deny() {
    modify_field(ingress_metadata.racl_deny, TRUE);
}

action racl_permit() {
}

action racl_redirect_nexthop(nexthop_index) {
    modify_field(ingress_metadata.racl_redirect, TRUE);
    modify_field(ingress_metadata.racl_nexthop, nexthop_index);
}

action racl_redirect_ecmp(ecmp_index) {
    modify_field(ingress_metadata.racl_redirect, TRUE);
    modify_field(ingress_metadata.racl_ecmp, ecmp_index);
}

table ip_racl {
    reads {
        ingress_metadata.bd_label : ternary;

        ingress_metadata.lkp_ipv4_sa : ternary;
        ingress_metadata.lkp_ipv4_da : ternary;
        ingress_metadata.lkp_ip_proto : ternary;
        ingress_metadata.lkp_l4_sport : ternary;
        ingress_metadata.lkp_l4_dport : ternary;
    }
    actions {
        nop;
        racl_log;
        racl_deny;
        racl_permit;
        racl_redirect_nexthop;
        racl_redirect_ecmp;
    }
    size : INGRESS_IP_RACL_TABLE_SIZE;
}


action fib_hit_nexthop(nexthop_index) {
    modify_field(ingress_metadata.fib_hit, TRUE);
    modify_field(ingress_metadata.fib_nexthop, nexthop_index);
}

action fib_hit_ecmp(ecmp_index) {
    modify_field(ingress_metadata.fib_hit, TRUE);
    modify_field(ingress_metadata.fib_ecmp, ecmp_index);
}

table ipv4_fib_lpm {
    reads {
        ingress_metadata.vrf : exact;
        ingress_metadata.lkp_ipv4_da : lpm;
    }
    actions {
        fib_hit_nexthop;
        fib_hit_ecmp;
    }
    size : IPV4_LPM_TABLE_SIZE;
}

table ipv4_fib {
    reads {
        ingress_metadata.vrf : exact;
        ingress_metadata.lkp_ipv4_da : exact;
    }
    actions {
        on_miss;
        fib_hit_nexthop;
        fib_hit_ecmp;
    }
    size : IPV4_HOST_TABLE_SIZE;
}

action set_l2_redirect_action() {
    modify_field(ingress_metadata.nexthop_index, ingress_metadata.l2_nexthop);
    modify_field(ingress_metadata.ecmp_index, ingress_metadata.l2_ecmp);
    modify_field(ingress_metadata.ttl, ingress_metadata.lkp_ip_ttl);
}

action set_acl_redirect_action() {
    modify_field(ingress_metadata.nexthop_index, ingress_metadata.acl_nexthop);
    modify_field(ingress_metadata.ecmp_index, ingress_metadata.acl_ecmp);
}

action set_racl_redirect_action() {
    modify_field(ingress_metadata.nexthop_index, ingress_metadata.racl_nexthop);
    modify_field(ingress_metadata.ecmp_index, ingress_metadata.racl_ecmp);
    modify_field(ingress_metadata.routed, TRUE);
    modify_field(ingress_metadata.ttl, ingress_metadata.lkp_ip_ttl);
    add_to_field(ingress_metadata.ttl, -1);
}

action set_fib_redirect_action() {
    modify_field(ingress_metadata.nexthop_index, ingress_metadata.fib_nexthop);
    modify_field(ingress_metadata.ecmp_index, ingress_metadata.fib_ecmp);
    modify_field(ingress_metadata.routed, TRUE);
    modify_field(ingress_metadata.ttl, ingress_metadata.lkp_ip_ttl);
    add_to_field(ingress_metadata.ttl, -1);
}

table fwd_result {
    reads {
        ingress_metadata.l2_redirect : ternary;
        ingress_metadata.acl_redirect : ternary;
        ingress_metadata.racl_redirect : ternary;
        ingress_metadata.fib_hit : ternary;
    }
    actions {
        nop;
        set_l2_redirect_action;
        set_acl_redirect_action;
        set_racl_redirect_action;
        set_fib_redirect_action;
    }
    size : FWD_RESULT_TABLE_SIZE;
}

field_list l3_hash_fields {
    ingress_metadata.lkp_ipv4_sa;
    ingress_metadata.lkp_ipv4_da;
    ingress_metadata.lkp_ip_proto;
    ingress_metadata.lkp_l4_sport;
    ingress_metadata.lkp_l4_dport;
}

field_list_calculation ecmp_hash {
    input {
        l3_hash_fields;
    }
    algorithm : crc16;
    output_width : ECMP_BIT_WIDTH;
}

action_selector ecmp_selector {
    selection_key : ecmp_hash;
}

action_profile ecmp_action_profile {
    actions {
        nop;
        set_ecmp_nexthop_details;
        set_ecmp_nexthop_details_for_post_routed_flood;
    }
    size : ECMP_SELECT_TABLE_SIZE;
    selector : ecmp_selector;
}

table ecmp_group {
    reads {
        ingress_metadata.ecmp_index : exact;
    }
    action_profile: ecmp_action_profile;
    size : ECMP_GROUP_TABLE_SIZE;
}

action set_nexthop_details(ifindex, bd) {
    modify_field(ingress_metadata.egress_ifindex, ifindex);
    modify_field(ingress_metadata.egress_bd, bd);
}

action set_ecmp_nexthop_details(ifindex, bd, nhop_index) {
    modify_field(ingress_metadata.egress_ifindex, ifindex);
    modify_field(ingress_metadata.egress_bd, bd);
    modify_field(ingress_metadata.nexthop_index, nhop_index);
}

/*
 * If dest mac is not known, then unicast packet needs to be flooded in
 * egress BD
 */
action set_nexthop_details_for_post_routed_flood(bd, uuc_mc_index) {
    modify_field(intrinsic_metadata.eg_mcast_group, uuc_mc_index);
    modify_field(ingress_metadata.egress_bd, bd);
}

action set_ecmp_nexthop_details_for_post_routed_flood(bd, uuc_mc_index, nhop_index) {
    modify_field(intrinsic_metadata.eg_mcast_group, uuc_mc_index);
    modify_field(ingress_metadata.egress_bd, bd);
    modify_field(ingress_metadata.nexthop_index, nhop_index);
}

table nexthop {
    reads {
        ingress_metadata.nexthop_index : exact;
    }
    actions {
        nop;
        set_nexthop_details;
        set_nexthop_details_for_post_routed_flood;
    }
    size : NEXTHOP_TABLE_SIZE;
}

field_list lag_hash_fields {
    ingress_metadata.lkp_mac_sa;
    ingress_metadata.lkp_mac_da;
    ingress_metadata.lkp_mac_type;
    ingress_metadata.lkp_ipv4_sa;
    ingress_metadata.lkp_ipv4_da;
    ingress_metadata.lkp_ip_proto;
    ingress_metadata.lkp_l4_sport;
    ingress_metadata.lkp_l4_dport;
}

field_list_calculation lag_hash {
    input {
        lag_hash_fields;
    }
    algorithm : crc16;
    output_width : LAG_BIT_WIDTH;
}

action_selector lag_selector {
    selection_key : lag_hash;
}

action set_lag_port(port) {
    modify_field(standard_metadata.egress_spec, port);
}

action_profile lag_action_profile {
    actions {
        nop;
        set_lag_port;
    }
    size : LAG_GROUP_TABLE_SIZE;
    selector : lag_selector;
}

table lag_group {
    reads {
        ingress_metadata.egress_ifindex : exact;
    }
    action_profile: lag_action_profile;
    size : LAG_SELECT_TABLE_SIZE;
}

action redirect_to_cpu() {
    modify_field(standard_metadata.egress_spec, CPU_PORT);
    modify_field(intrinsic_metadata.eg_mcast_group, 0);
}

action copy_to_cpu() {
    clone_ingress_pkt_to_egress(CPU_PORT);
}

action drop_packet() {
    modify_field(intrinsic_metadata.eg_mcast_group, 0);
    drop();
}

table system_acl {
    reads {
        ingress_metadata.if_label : ternary;
        ingress_metadata.bd_label : ternary;

        /* ip acl */
        ingress_metadata.lkp_ipv4_sa : ternary;
        ingress_metadata.lkp_ipv4_da : ternary;
        ingress_metadata.lkp_ip_proto : ternary;

        /* mac acl */
        ingress_metadata.lkp_mac_sa : ternary;
        ingress_metadata.lkp_mac_da : ternary;
        ingress_metadata.lkp_mac_type : ternary;

        /* drop reasons */
        ingress_metadata.acl_deny : ternary;
        ingress_metadata.racl_deny: ternary;

        /* other checks, routed link_local packet, l3 same if check, expired ttl */
        ingress_metadata.src_vtep_miss : ternary;
        ingress_metadata.routed : ternary;
        ingress_metadata.src_is_link_local : ternary;
        ingress_metadata.ttl : ternary;
        ingress_metadata.stp_state : ternary;
        ingress_metadata.control_frame: ternary;

        /* egress information */
        standard_metadata.egress_spec : ternary;
    }
    actions {
        nop;
        redirect_to_cpu;
        copy_to_cpu;
        drop_packet;
    }
    size : SYSTEM_ACL_SIZE;
}

field_list mac_learn_digest {
    ingress_metadata.bd;
    ingress_metadata.lkp_mac_sa;
    ingress_metadata.ifindex;
}

action generate_learn_notify() {
    generate_digest(MAC_LEARN_RECIEVER, mac_learn_digest);
}

table learn_notify {
    reads {
        ingress_metadata.l2_src_miss : ternary;
        ingress_metadata.l2_src_move : ternary;
        ingress_metadata.stp_state : ternary;
    }
    actions {
        nop;
        generate_learn_notify;
    }
    size : LEARN_NOTIFY_TABLE_SIZE;
}

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


