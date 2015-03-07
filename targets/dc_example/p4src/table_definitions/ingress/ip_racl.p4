action racl_log() {
}

action racl_deny() {
    modify_field(ingress_metadata.racl_deny, TRUE);
}

action racl_permit() {
}

action racl_redirect_nexthop(nexthop_index) {
    modify_field(ingress_metadata.racl_redirect, TRUE);
    modify_field(ingress_metadata.racl_nexthop, nexthop_index);
}

action racl_redirect_ecmp(ecmp_index) {
    modify_field(ingress_metadata.racl_redirect, TRUE);
    modify_field(ingress_metadata.racl_ecmp, ecmp_index);
}

table ip_racl {
    reads {
        ingress_metadata.bd_label : ternary;

        ingress_metadata.lkp_ipv4_sa : ternary;
        ingress_metadata.lkp_ipv4_da : ternary;
        ingress_metadata.lkp_ip_proto : ternary;
        ingress_metadata.lkp_l4_sport : ternary;
        ingress_metadata.lkp_l4_dport : ternary;
    }
    actions {
        nop;
        racl_log;
        racl_deny;
        racl_permit;
        racl_redirect_nexthop;
        racl_redirect_ecmp;
    }
    size : INGRESS_IP_RACL_TABLE_SIZE;
}
