
// AUTOGEN
register r_xor_0{
	width : 16;
	instance_count : 262144;
}
blackbox stateful_alu s_xor_0{
	reg : r_xor_0;
	update_lo_1_value : register_lo ^ netec.data_0;
	output_value : alu_lo;
	output_dst : meta.netec_res_0;
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
    

    modify_field(netec.data_0,meta.netec_res_0);
     
}
    
