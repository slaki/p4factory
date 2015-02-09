header_type intrinsic_metadata_t {
    fields {
        eg_mcast_group : 16; // multicast group id (key for the mcast replication table)
        replication_id : 16; // Replication ID for multicast
        lf_field_list : 32; // Learn filter field list
    }
}

metadata intrinsic_metadata_t intrinsic_metadata;

#define EGSPEC_UCAST_CPU_PORT 0xFF00000000
#define EGSPEC_NULL_PORT 0x0000000000
