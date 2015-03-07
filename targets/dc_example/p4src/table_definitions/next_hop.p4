action set_nexthop_details(ifindex, bd) {
    modify_field(ingress_metadata.egress_ifindex, ifindex);
    modify_field(ingress_metadata.egress_bd, bd);
}

/*
 * If dest mac is not known, then unicast packet needs to be flooded in
 * egress BD
 */
action set_nexthop_details_for_post_routed_flood(bd, uuc_mc_index) {
    modify_field(intrinsic_metadata.eg_mcast_group, uuc_mc_index);
    modify_field(ingress_metadata.egress_bd, bd);
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
