action set_ifindex(ifindex, if_label) {
    modify_field(ingress_metadata.ifindex, ifindex);
    modify_field(ingress_metadata.if_label, if_label);
}

table port_mapping {
    reads {
        standard_metadata.ingress_port : exact;
    }
    actions {
        set_ifindex;
    }
    size : PORTMAP_TABLE_SIZE;
}
