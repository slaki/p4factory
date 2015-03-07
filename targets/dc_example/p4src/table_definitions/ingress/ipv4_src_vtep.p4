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
