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
