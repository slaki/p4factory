header_type egress_metadata_t {
    fields {
        smac_idx : 9;                          /* index into source mac table */
        bd : BD_BIT_WIDTH;                     /* egress inner bd */
        replica : 1;                           /* is this a replica */
        vnid : 24;                             /* tunnel vnid */
        mac_da : 48;                           /* final mac da */
        routed : 1;                            /* is this replica routed */

        mtu_check_fail : 1;                    /* MTU check failed */

        tunnel_type : 4;                       /* type of tunnel */
        tunnel_src_index : 9;                  /* index to tunnel src ip */
        tunnel_dst_index : 14;                 /* index to tunnel dst ip */

        drop_reason : 8;                       /* drop reason */
        egress_bypass : 1;                     /* skip the entire egress pipeline */
    }
}
