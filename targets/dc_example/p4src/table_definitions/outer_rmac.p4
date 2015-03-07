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
