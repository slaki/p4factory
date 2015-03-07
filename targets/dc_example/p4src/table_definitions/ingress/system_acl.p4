action redirect_to_cpu() {
    modify_field(standard_metadata.egress_spec, CPU_PORT);
    modify_field(intrinsic_metadata.eg_mcast_group, 0);
}

action copy_to_cpu() {
    clone_ingress_pkt_to_egress(CPU_PORT);
}

action drop_packet() {
    modify_field(intrinsic_metadata.eg_mcast_group, 0);
    drop();
}

table system_acl {
    reads {
        ingress_metadata.if_label : ternary;
        ingress_metadata.bd_label : ternary;

        /* ip acl */
        ingress_metadata.lkp_ipv4_sa : ternary;
        ingress_metadata.lkp_ipv4_da : ternary;
        ingress_metadata.lkp_ip_proto : ternary;

        /* mac acl */
        ingress_metadata.lkp_mac_sa : ternary;
        ingress_metadata.lkp_mac_da : ternary;
        ingress_metadata.lkp_mac_type : ternary;

        /* drop reasons */
        ingress_metadata.acl_deny : ternary;
        ingress_metadata.racl_deny: ternary;

        /* other checks, routed link_local packet, l3 same if check, expired ttl */
        ingress_metadata.src_vtep_miss : ternary;
        ingress_metadata.routed : ternary;
        ingress_metadata.src_is_link_local : ternary;
        ingress_metadata.ttl : ternary;
        ingress_metadata.stp_state : ternary;
        ingress_metadata.control_frame: ternary;

        /* egress information */
        standard_metadata.egress_spec : ternary;
    }
    actions {
        nop;
        redirect_to_cpu;
        copy_to_cpu;
        drop_packet;
    }
    size : SYSTEM_ACL_SIZE;
}
