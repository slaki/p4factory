action fib_hit_nexthop(nexthop_index) {
    modify_field(ingress_metadata.fib_hit, TRUE);
    modify_field(ingress_metadata.fib_nexthop, nexthop_index);
}

action fib_hit_ecmp(ecmp_index) {
    modify_field(ingress_metadata.fib_hit, TRUE);
    modify_field(ingress_metadata.fib_ecmp, ecmp_index);
}

table ipv4_fib_lpm {
    reads {
        ingress_metadata.vrf : exact;
        ingress_metadata.lkp_ipv4_da : lpm;
    }
    actions {
        fib_hit_nexthop;
        fib_hit_ecmp;
    }
    size : IPV4_LPM_TABLE_SIZE;
}

table ipv4_fib {
    reads {
        ingress_metadata.vrf : exact;
        ingress_metadata.lkp_ipv4_da : exact;
    }
    actions {
        on_miss;
        fib_hit_nexthop;
        fib_hit_ecmp;
    }
    size : IPV4_HOST_TABLE_SIZE;
}
