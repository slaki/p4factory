action set_valid_outer_unicast_packet() {
    modify_field(ingress_metadata.lkp_pkt_type, L2_UNICAST);
    modify_field(ingress_metadata.lkp_mac_sa, ethernet.srcAddr);
    modify_field(ingress_metadata.lkp_mac_da, ethernet.dstAddr);
    modify_field(ingress_metadata.lkp_mac_type, ethernet.etherType);
}

action set_valid_outer_multicast_packet() {
    modify_field(ingress_metadata.lkp_pkt_type, L2_MULTICAST);
    modify_field(ingress_metadata.lkp_mac_sa, ethernet.srcAddr);
    modify_field(ingress_metadata.lkp_mac_da, ethernet.dstAddr);
    modify_field(ingress_metadata.lkp_mac_type, ethernet.etherType);
}

action set_valid_outer_broadcast_packet() {
    modify_field(ingress_metadata.lkp_pkt_type, L2_BROADCAST);
    modify_field(ingress_metadata.lkp_mac_sa, ethernet.srcAddr);
    modify_field(ingress_metadata.lkp_mac_da, ethernet.dstAddr);
    modify_field(ingress_metadata.lkp_mac_type, ethernet.etherType);
}

table validate_outer_ethernet {
    reads {
        ethernet.dstAddr : ternary;
    }
    actions {
        set_valid_outer_unicast_packet;
        set_valid_outer_multicast_packet;
        set_valid_outer_broadcast_packet;
    }
    size : VALIDATE_PACKET_TABLE_SIZE;
}
