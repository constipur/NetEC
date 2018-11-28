
// AUTOGEN
register r_xor_0{
	width : 16;
	instance_count : 262144;
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
	s_xor_0.execute_stateful_alu(netec.index);
}
         
control xor {
     
    apply(t_xor_0);
     
}
     
action fill_netec_fields(){
     
    modify_field(netec.data_0,netec_meta.res_0);
     
}
     
header_type netec_meta_t{
	fields{
		index : 16;
        temp : 16;
     
        res_0 : 16;
        temp_0 : 32;
         
    }
}
     

table t_get_log_0{
	actions{
		a_get_log_0;
	}
	default_action:a_get_log_0;
}
blackbox stateful_alu s_log_table_0{
	reg : r_log_table;
	update_lo_1_value:register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_0;
}
action a_get_log_0(){
	s_log_table_0.execute_stateful_alu(netec.data_0);
}
table t_log_add_0{
	actions{
		a_log_add_0;
	}
	default_action:a_log_add_0();
}
action a_log_add_0(){
	add_to_field(netec_meta.temp_0,meta.coeff);
}
table t_get_ilog_0{
	actions{
		a_get_ilog_0;
	}
	default_action:a_get_ilog_0;
}
blackbox stateful_alu s_ilog_table_0{
	reg : r_ilog_table;
	update_lo_1_value:register_lo;
	output_value : register_lo;
	output_dst : netec.data_0;
}
action a_get_ilog_0(){
	s_ilog_table_0.execute_stateful_alu(netec_meta.temp_0);
}

         
control gf_multiply {
     
        apply(t_get_log_0);
         
        apply(t_log_add_0);
		
        apply(t_record);
         
        if(netec.data_0 != 0)
            apply(t_get_ilog_0);
}
    
