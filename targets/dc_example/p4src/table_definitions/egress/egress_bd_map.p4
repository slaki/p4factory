action set_egress_bd_properties(vnid ) {
    modify_field(egress_metadata.vnid, vnid);
}

table egress_bd_map {
    reads {
        ingress_metadata.egress_bd : exact;
    }
    actions {
        nop;
        set_egress_bd_properties;
    }
    size : EGRESS_VNID_MAPPING_TABLE_SIZE;
}
