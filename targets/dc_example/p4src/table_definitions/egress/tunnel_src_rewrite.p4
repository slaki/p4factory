action rewrite_tunnel_ipv4_src(ip) {
    modify_field(ipv4.srcAddr, ip);
}

table tunnel_src_rewrite {
    reads {
        egress_metadata.tunnel_src_index : exact;
    }
    actions {
        rewrite_tunnel_ipv4_src;
    }
    size : DEST_TUNNEL_TABLE_SIZE;
}
