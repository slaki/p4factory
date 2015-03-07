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
