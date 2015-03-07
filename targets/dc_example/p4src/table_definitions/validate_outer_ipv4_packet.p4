action set_valid_outer_ipv4_packet() {
    modify_field(ingress_metadata.lkp_ip_type, IPTYPE_IPV4);
    modify_field(ingress_metadata.lkp_ipv4_sa, ipv4.srcAddr);
    modify_field(ingress_metadata.lkp_ipv4_da, ipv4.dstAddr);
    modify_field(ingress_metadata.lkp_ip_proto, ipv4.protocol);
    modify_field(ingress_metadata.lkp_ip_tc, ipv4.diffserv);
    modify_field(ingress_metadata.lkp_ip_ttl, ipv4.ttl);
    modify_field(ingress_metadata.l3_length, ipv4.totalLen);
}

action set_malformed_outer_ipv4_packet() {
}

table validate_outer_ipv4_packet {
    reads {
        ipv4.version : exact;
        ipv4.ihl : exact;
        ipv4.ttl : exact;
        ipv4.srcAddr : ternary;
        ipv4.dstAddr : ternary;
    }
    actions {
        set_valid_outer_ipv4_packet;
        set_malformed_outer_ipv4_packet;
    }
    size : VALIDATE_PACKET_TABLE_SIZE;
}
