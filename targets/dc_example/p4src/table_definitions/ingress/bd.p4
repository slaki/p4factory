action set_bd_info(vrf, rmac_group, 
        bd_label, uuc_mc_index, bcast_mc_index, umc_mc_index,
        ipv4_unicast_enabled, 
        igmp_snooping_enabled, stp_group) {
    modify_field(ingress_metadata.vrf, vrf);
    modify_field(ingress_metadata.ipv4_unicast_enabled, ipv4_unicast_enabled);
    modify_field(ingress_metadata.igmp_snooping_enabled, igmp_snooping_enabled);
    modify_field(ingress_metadata.rmac_group, rmac_group);
    modify_field(ingress_metadata.uuc_mc_index, uuc_mc_index);
    modify_field(ingress_metadata.umc_mc_index, umc_mc_index);
    modify_field(ingress_metadata.bcast_mc_index, bcast_mc_index);
    modify_field(ingress_metadata.bd_label, bd_label);
    modify_field(ingress_metadata.stp_group, stp_group);
}

/*
* extract all the bridge domain parameters for non-tunneled
*   packets
*/
table bd {
    reads {
        ingress_metadata.bd : exact;
    }
    actions {
        set_bd_info;
    }
    size : BD_TABLE_SIZE;
}
