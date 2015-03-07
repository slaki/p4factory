action rewrite_tunnel_ipv4_dst(ip) {
    modify_field(ipv4.dstAddr, ip);
}

table tunnel_dst_rewrite {
    reads {
        egress_metadata.tunnel_dst_index : exact;
    }
    actions {
        rewrite_tunnel_ipv4_dst;
    }
    size : SRC_TUNNEL_TABLE_SIZE;
}
