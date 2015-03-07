#ifndef MULTICAST_DISABLE
action replica_from_rid(bd) {
    modify_field(ingress_metadata.egress_bd, bd);
    modify_field(egress_metadata.replica, TRUE);
}

table rid {
    reads {
        intrinsic_metadata.replication_id : exact;
    }
    actions {
        nop;
        replica_from_rid;
    }
    size : RID_TABLE_SIZE;
}

#endif
