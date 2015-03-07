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
