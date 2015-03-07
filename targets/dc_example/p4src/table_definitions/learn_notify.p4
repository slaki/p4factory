field_list mac_learn_digest {
    ingress_metadata.bd;
    ingress_metadata.lkp_mac_sa;
    ingress_metadata.ifindex;
}

action generate_learn_notify() {
    generate_digest(MAC_LEARN_RECIEVER, mac_learn_digest);
}

table learn_notify {
    reads {
        ingress_metadata.l2_src_miss : ternary;
        ingress_metadata.l2_src_move : ternary;
        ingress_metadata.stp_state : ternary;
    }
    actions {
        nop;
        generate_learn_notify;
    }
    size : LEARN_NOTIFY_TABLE_SIZE;
}
