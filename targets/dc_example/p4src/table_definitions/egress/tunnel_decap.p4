action decapsulate_vxlan_packet_inner_ipv4_udp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    copy_header(udp, inner_udp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_udp);
    remove_header(vxlan);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_vxlan_packet_inner_ipv4_tcp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    add_header(tcp);
    copy_header(tcp, inner_tcp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_tcp);
    remove_header(udp);
    remove_header(vxlan);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_geneve_packet_inner_ipv4_udp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    copy_header(udp, inner_udp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_udp);
    remove_header(genv);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_geneve_packet_inner_ipv4_tcp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    add_header(tcp);
    copy_header(tcp, inner_tcp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_tcp);
    remove_header(udp);
    remove_header(genv);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_nvgre_packet_inner_ipv4_udp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    copy_header(udp, inner_udp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_udp);
    remove_header(nvgre);
    remove_header(gre);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

action decapsulate_nvgre_packet_inner_ipv4_tcp() {
    copy_header(ethernet, inner_ethernet);
    add_header(ipv4);
    copy_header(ipv4, inner_ipv4);
    add_header(tcp);
    copy_header(tcp, inner_tcp);
    remove_header(inner_ethernet);
    remove_header(inner_ipv4);
    remove_header(inner_tcp);
    remove_header(nvgre);
    remove_header(gre);
    modify_field(ingress_metadata.ttl, ingress_metadata.outer_ttl);
}

table tunnel_decap {
    reads {
        ingress_metadata.tunnel_type : exact;
        inner_ipv4 : valid;
        inner_tcp : valid;
        inner_udp : valid;
    }
    actions {
        decapsulate_vxlan_packet_inner_ipv4_udp;
        decapsulate_vxlan_packet_inner_ipv4_tcp;
        decapsulate_geneve_packet_inner_ipv4_udp;
        decapsulate_geneve_packet_inner_ipv4_tcp;
        decapsulate_nvgre_packet_inner_ipv4_udp;
        decapsulate_nvgre_packet_inner_ipv4_tcp;
    }
    size : TUNNEL_DECAP_TABLE_SIZE;
}
