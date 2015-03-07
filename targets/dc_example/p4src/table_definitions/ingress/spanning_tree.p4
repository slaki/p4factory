action set_stp_state(stp_state) {
    modify_field(ingress_metadata.stp_state, stp_state);
}

table spanning_tree {
    reads {
        ingress_metadata.ifindex : exact;
        ingress_metadata.stp_group: exact;
    }
    actions {
        set_stp_state;
    }
    size : SPANNING_TREE_TABLE_SIZE;
}
