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
