action egress_drop () {
    drop();
}

table egress_block {
    reads {
        standard_metadata.egress_port : exact;
        intrinsic_metadata.replication_id : exact;
    }
    actions {
        on_miss;
        egress_drop;
    }
    size : EGRESS_BLOCK_TABLE_SIZE;
}
