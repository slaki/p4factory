action set_bd(outer_vlan_bd, vrf, rmac_group, 
        ipv4_unicast_enabled, 
        stp_group) {
    modify_field(ingress_metadata.vrf, vrf);
    modify_field(ingress_metadata.ipv4_unicast_enabled, ipv4_unicast_enabled);
    modify_field(ingress_metadata.outer_rmac_group, rmac_group);
    modify_field(ingress_metadata.bd, outer_vlan_bd);
    modify_field(ingress_metadata.stp_group, stp_group);
}

/*
* outer_bd is used to extract the tunnel termination 
*   actions
*/
action_profile outer_bd_action_profile {
    actions {
        set_bd;
    }
    size : OUTER_BD_TABLE_SIZE;
}

table port_vlan_mapping {
    reads {
        ingress_metadata.ifindex : exact;
        vlan_tag_[0] : valid;
        vlan_tag_[0].vid : exact;
        vlan_tag_[1] : valid;
        vlan_tag_[1].vid : exact;
    }

    action_profile: outer_bd_action_profile;
    size : PORT_VLAN_TABLE_SIZE;
}
