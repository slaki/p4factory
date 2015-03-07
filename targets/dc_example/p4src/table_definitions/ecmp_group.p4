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

action set_ecmp_nexthop_details(ifindex, bd, nhop_index) {
    modify_field(ingress_metadata.egress_ifindex, ifindex);
    modify_field(ingress_metadata.egress_bd, bd);
    modify_field(ingress_metadata.nexthop_index, nhop_index);
}

action set_ecmp_nexthop_details_for_post_routed_flood(bd, uuc_mc_index, nhop_index) {
    modify_field(intrinsic_metadata.eg_mcast_group, uuc_mc_index);
    modify_field(ingress_metadata.egress_bd, bd);
    modify_field(ingress_metadata.nexthop_index, nhop_index);
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
