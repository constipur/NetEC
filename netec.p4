
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
         
// AUTOGEN
register r_xor_1{
	width : 16;
	instance_count : 262144;
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
	s_xor_1.execute_stateful_alu(netec.index);
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
		index : 16;
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
    instance_count : 131072;
}

table t_get_log_0{
	actions{
		a_get_log_0;
	}
	default_action:a_get_log_0;
}
blackbox stateful_alu s_log_table_0{
	reg : r_log_table_0;
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
	reg : r_ilog_table_0;
	update_lo_1_value:register_lo;
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
    instance_count : 131072;
}

table t_get_log_1{
	actions{
		a_get_log_1;
	}
	default_action:a_get_log_1;
}
blackbox stateful_alu s_log_table_1{
	reg : r_log_table_1;
	update_lo_1_value:register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_1;
}
action a_get_log_1(){
	s_log_table_1.execute_stateful_alu(netec.data_1);
}
table t_log_add_1{
	actions{
		a_log_add_1;
	}
	default_action:a_log_add_1();
}
action a_log_add_1(){
	add_to_field(netec_meta.temp_1,meta.coeff);
}
table t_get_ilog_1{
	actions{
		a_get_ilog_1;
	}
	default_action:a_get_ilog_1;
}
blackbox stateful_alu s_ilog_table_1{
	reg : r_ilog_table_1;
	update_lo_1_value:register_lo;
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
         
        if(netec.data_0 != 0)
            apply(t_get_ilog_0);
         
        if(netec.data_1 != 0)
            apply(t_get_ilog_1);
         
}
    
