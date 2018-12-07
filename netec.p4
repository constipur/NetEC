
header_type netec_t{
	fields {
		type_ : 16;
		index : 32 ;
     
		data_0 : 16;
         
		data_1 : 16;
         
	}
}
header netec_t netec;
     
field_list l4_with_netec_list {
	ipv4.srcAddr;
    ipv4.dstAddr;
	meta.l4_proto;
	udp.srcPort;
	udp.dstPort; 
	udp.length_;
	netec_meta.index;
	netec_meta.type_;
     
	netec_meta.res_0;
     
	netec_meta.res_1;
     
	meta.cksum_compensate;
}
field_list_calculation l4_with_netec_checksum {
    input {
        l4_with_netec_list;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field udp.checksum  {
	update l4_with_netec_checksum;
} 
// AUTOGEN
register r_xor_0{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_0{
	reg : r_xor_0;
	update_lo_1_value : register_lo ^ netec.data_0;
	output_value : alu_lo;
	output_dst : netec_meta.res_0;
}
table t_xor_0{
	actions{a_xor_0;}
	default_action : a_xor_0();
}
action a_xor_0(){
	s_xor_0.execute_stateful_alu(meta.index);
}
         
// AUTOGEN
register r_xor_1{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_1{
	reg : r_xor_1;
	update_lo_1_value : register_lo ^ netec.data_1;
	output_value : alu_lo;
	output_dst : netec_meta.res_1;
}
table t_xor_1{
	actions{a_xor_1;}
	default_action : a_xor_1();
}
action a_xor_1(){
	s_xor_1.execute_stateful_alu(meta.index);
}
         
control xor {
     
    apply(t_xor_0);
     
    apply(t_xor_1);
     
}
     
action fill_netec_fields(){
     
    modify_field(netec.data_0,netec_meta.res_0);
     
    modify_field(netec.data_1,netec_meta.res_1);
     
}
     
header_type netec_meta_t{
	fields{
        type_ : 16;

		index : 32;
        temp : 16;
     
        res_0 : 16;
        temp_0 : 32;
         
        res_1 : 16;
        temp_1 : 32;
         
    }
}
     

register r_log_table_0{
	width : 16;
	instance_count : 65536;
}
register r_ilog_table_0{
    width : 16;
    instance_count : 65536;
}

table t_get_log_0{
	actions{
		a_get_log_0;
	}
	default_action:a_get_log_0;
}
blackbox stateful_alu s_log_table_0{
	reg : r_log_table_0;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value:meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value:register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_0;
}
action a_get_log_0(){
	s_log_table_0.execute_stateful_alu(netec.data_0);
}
table t_log_add_0{
    reads{
        netec.type_:exact;
    }
	actions{
		a_log_add_0;
		a_log_mod_0;
	}
	default_action:a_log_add_0();
}
action a_log_add_0(){
	add_to_field(netec_meta.temp_0,meta.coeff);
}

action a_log_mod_0(){
    modify_field(netec_meta.temp_0,netec.index);
}
table t_ilog_index_0{
    reads{
        netec_meta.temp_0 : lpm;
        netec.type_:exact;
    }
    actions {
        a_ilog_index_subtract_0;
        a_ilog_index_zero_0;
        nop;
    }
    default_action:nop;
}
action a_ilog_index_subtract_0(){
    subtract_from_field(netec_meta.temp_0,65535);
}
action a_ilog_index_zero_0(){
    modify_field(netec.data_0,0);
}

table t_get_ilog_0{
	actions{
		a_get_ilog_0;
	}
	default_action:a_get_ilog_0;
}
blackbox stateful_alu s_ilog_table_0{
	reg : r_ilog_table_0;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value:register_lo;
	output_value : register_lo;
	output_dst : netec.data_0;
}
action a_get_ilog_0(){
	s_ilog_table_0.execute_stateful_alu(netec_meta.temp_0);
}

         

register r_log_table_1{
	width : 16;
	instance_count : 65536;
}
register r_ilog_table_1{
    width : 16;
    instance_count : 65536;
}

table t_get_log_1{
	actions{
		a_get_log_1;
	}
	default_action:a_get_log_1;
}
blackbox stateful_alu s_log_table_1{
	reg : r_log_table_1;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value:meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value:register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_1;
}
action a_get_log_1(){
	s_log_table_1.execute_stateful_alu(netec.data_1);
}
table t_log_add_1{
    reads{
        netec.type_:exact;
    }
	actions{
		a_log_add_1;
		a_log_mod_1;
	}
	default_action:a_log_add_1();
}
action a_log_add_1(){
	add_to_field(netec_meta.temp_1,meta.coeff);
}

action a_log_mod_1(){
    modify_field(netec_meta.temp_1,netec.index);
}
table t_ilog_index_1{
    reads{
        netec_meta.temp_1 : lpm;
        netec.type_:exact;
    }
    actions {
        a_ilog_index_subtract_1;
        a_ilog_index_zero_1;
        nop;
    }
    default_action:nop;
}
action a_ilog_index_subtract_1(){
    subtract_from_field(netec_meta.temp_1,65535);
}
action a_ilog_index_zero_1(){
    modify_field(netec.data_1,0);
}

table t_get_ilog_1{
	actions{
		a_get_ilog_1;
	}
	default_action:a_get_ilog_1;
}
blackbox stateful_alu s_ilog_table_1{
	reg : r_ilog_table_1;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value:register_lo;
	output_value : register_lo;
	output_dst : netec.data_1;
}
action a_get_ilog_1(){
	s_ilog_table_1.execute_stateful_alu(netec_meta.temp_1);
}

         
control gf_multiply {
     
        apply(t_get_log_0);
         
        apply(t_get_log_1);
         
        apply(t_log_add_0);
         
        apply(t_log_add_1);
         
        apply(t_ilog_index_0);
         
        apply(t_ilog_index_1);
         
        if(netec.data_0 != 0)
            apply(t_get_ilog_0);
         
        if(netec.data_1 != 0)
            apply(t_get_ilog_1);
         
}
    
