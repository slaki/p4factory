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
