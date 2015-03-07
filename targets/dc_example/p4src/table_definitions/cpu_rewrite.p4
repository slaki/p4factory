action set_cpu_tx_rewrite() {
    modify_field(ethernet.etherType, cpu_header.etherType);
    remove_header(cpu_header);
}

action set_cpu_rx_rewrite() {
    add_header(cpu_header);
    modify_field(cpu_header.etherType, ethernet.etherType);
    modify_field(cpu_header.ingress_lif, standard_metadata.ingress_port);
}

table cpu_rewrite {
    reads {
        standard_metadata.egress_port : ternary;
        standard_metadata.ingress_port : ternary;
    }
    actions {
        nop;
        set_cpu_tx_rewrite;
        set_cpu_rx_rewrite;
    }
    size : CPU_REWRITE_TABLE_SIZE;
}
