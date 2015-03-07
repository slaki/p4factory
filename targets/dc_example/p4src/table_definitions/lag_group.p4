field_list lag_hash_fields {
    ingress_metadata.lkp_mac_sa;
    ingress_metadata.lkp_mac_da;
    ingress_metadata.lkp_mac_type;
    ingress_metadata.lkp_ipv4_sa;
    ingress_metadata.lkp_ipv4_da;
    ingress_metadata.lkp_ip_proto;
    ingress_metadata.lkp_l4_sport;
    ingress_metadata.lkp_l4_dport;
}

field_list_calculation lag_hash {
    input {
        lag_hash_fields;
    }
    algorithm : crc16;
    output_width : LAG_BIT_WIDTH;
}

action_selector lag_selector {
    selection_key : lag_hash;
}

action set_lag_port(port) {
    modify_field(standard_metadata.egress_spec, port);
}

action_profile lag_action_profile {
    actions {
        nop;
        set_lag_port;
    }
    size : LAG_GROUP_TABLE_SIZE;
    selector : lag_selector;
}

table lag_group {
    reads {
        ingress_metadata.egress_ifindex : exact;
    }
    action_profile: lag_action_profile;
    size : LAG_SELECT_TABLE_SIZE;
}
