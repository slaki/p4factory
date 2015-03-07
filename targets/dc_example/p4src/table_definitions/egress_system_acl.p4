action egress_redirect_to_cpu() {
}

table egress_system_acl {
    reads {
        egress_metadata.mtu_check_fail : ternary;
    }
    actions {
        nop;
        egress_redirect_to_cpu;
    }
    size : EGRESS_SYSTEM_ACL_TABLE_SIZE;
}
