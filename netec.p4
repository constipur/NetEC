
header_type netec_t{
	fields {
        type_ : 16;
		index : 32; 
        data_0 : 16; 
        data_1 : 16; 
        data_2 : 16; 
        data_3 : 16; 
        data_4 : 16; 
        data_5 : 16; 
        data_6 : 16; 
        data_7 : 16; 
	}
}
header netec_t netec;

field_list l4_with_netec_list_udp {
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

	netec_meta.res_2;

	netec_meta.res_3;

	netec_meta.res_4;

	netec_meta.res_5;

	netec_meta.res_6;

	netec_meta.res_7;

	meta.cksum_compensate;
} 
field_list l4_with_netec_list_tcp {
	ipv4.srcAddr;
    ipv4.dstAddr;
	meta.l4_proto;
    meta.tcpLength;
	tcp.srcPort;
	tcp.dstPort;
    tcp.seqNo;
    tcp.ackNo;
	tcp.dataOffset;
    tcp.res;
    tcp.flags;
	tcp.window;
	tcp.urgentPtr;
	netec_meta.index;
	netec_meta.type_; 
    netec_meta.res_0;

    netec_meta.res_1;

    netec_meta.res_2;

    netec_meta.res_3;

    netec_meta.res_4;

    netec_meta.res_5;

    netec_meta.res_6;

    netec_meta.res_7;

	meta.cksum_compensate;
}
field_list_calculation l4_with_netec_checksum {
    input {
        l4_with_netec_list_tcp;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field tcp.checksum  {
	update l4_with_netec_checksum;
	verify l4_with_netec_checksum;
} 
// AUTOGEN
register r_xor_0{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_0{
	reg : r_xor_0;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_0;

    update_hi_1_value : register_lo ^ netec.data_0;
	output_value : alu_hi;
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
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_1;

    update_hi_1_value : register_lo ^ netec.data_1;
	output_value : alu_hi;
	output_dst : netec_meta.res_1;
}
table t_xor_1{
	actions{a_xor_1;}
	default_action : a_xor_1();
}
action a_xor_1(){
	s_xor_1.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_2{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_2{
	reg : r_xor_2;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_2;

    update_hi_1_value : register_lo ^ netec.data_2;
	output_value : alu_hi;
	output_dst : netec_meta.res_2;
}
table t_xor_2{
	actions{a_xor_2;}
	default_action : a_xor_2();
}
action a_xor_2(){
	s_xor_2.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_3{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_3{
	reg : r_xor_3;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_3;

    update_hi_1_value : register_lo ^ netec.data_3;
	output_value : alu_hi;
	output_dst : netec_meta.res_3;
}
table t_xor_3{
	actions{a_xor_3;}
	default_action : a_xor_3();
}
action a_xor_3(){
	s_xor_3.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_4{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_4{
	reg : r_xor_4;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_4;

    update_hi_1_value : register_lo ^ netec.data_4;
	output_value : alu_hi;
	output_dst : netec_meta.res_4;
}
table t_xor_4{
	actions{a_xor_4;}
	default_action : a_xor_4();
}
action a_xor_4(){
	s_xor_4.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_5{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_5{
	reg : r_xor_5;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_5;

    update_hi_1_value : register_lo ^ netec.data_5;
	output_value : alu_hi;
	output_dst : netec_meta.res_5;
}
table t_xor_5{
	actions{a_xor_5;}
	default_action : a_xor_5();
}
action a_xor_5(){
	s_xor_5.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_6{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_6{
	reg : r_xor_6;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_6;

    update_hi_1_value : register_lo ^ netec.data_6;
	output_value : alu_hi;
	output_dst : netec_meta.res_6;
}
table t_xor_6{
	actions{a_xor_6;}
	default_action : a_xor_6();
}
action a_xor_6(){
	s_xor_6.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_7{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_7{
	reg : r_xor_7;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_7;

    update_hi_1_value : register_lo ^ netec.data_7;
	output_value : alu_hi;
	output_dst : netec_meta.res_7;
}
table t_xor_7{
	actions{a_xor_7;}
	default_action : a_xor_7();
}
action a_xor_7(){
	s_xor_7.execute_stateful_alu(meta.index);
}

control xor {

    apply(t_xor_0); 
    apply(t_xor_1); 
    apply(t_xor_2); 
    apply(t_xor_3); 
    apply(t_xor_4); 
    apply(t_xor_5); 
    apply(t_xor_6); 
    apply(t_xor_7); 
}

action fill_netec_fields(){
     
    modify_field(netec.data_0, netec_meta.res_0);

    modify_field(netec.data_1, netec_meta.res_1);

    modify_field(netec.data_2, netec_meta.res_2);

    modify_field(netec.data_3, netec_meta.res_3);

    modify_field(netec.data_4, netec_meta.res_4);

    modify_field(netec.data_5, netec_meta.res_5);

    modify_field(netec.data_6, netec_meta.res_6);

    modify_field(netec.data_7, netec_meta.res_7);

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

        res_2 : 16;
        temp_2 : 32;

        res_3 : 16;
        temp_3 : 32;

        res_4 : 16;
        temp_4 : 32;

        res_5 : 16;
        temp_5 : 32;

        res_6 : 16;
        temp_6 : 32;

        res_7 : 16;
        temp_7 : 32;

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
	default_action : a_get_log_0;
}
blackbox stateful_alu s_log_table_0{
	reg : r_log_table_0;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value : meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_0;
}
action a_get_log_0(){
	s_log_table_0.execute_stateful_alu(netec.data_0);
}
table t_log_add_0{
    reads{
        netec.type_ : exact;
    }
	actions{
		a_log_add_0;
		a_log_mod_0;
	}
	default_action : a_log_add_0();
}
action a_log_add_0(){
	add_to_field(netec_meta.temp_0, meta.coeff);
}

action a_log_mod_0(){
    modify_field(netec_meta.temp_0, netec.index);
}
table t_get_ilog_0{
	actions{
		a_get_ilog_0;
	}
	default_action : a_get_ilog_0;
}
blackbox stateful_alu s_ilog_table_0{
	reg : r_ilog_table_0;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;
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
	default_action : a_get_log_1;
}
blackbox stateful_alu s_log_table_1{
	reg : r_log_table_1;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value : meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_1;
}
action a_get_log_1(){
	s_log_table_1.execute_stateful_alu(netec.data_1);
}
table t_log_add_1{
    reads{
        netec.type_ : exact;
    }
	actions{
		a_log_add_1;
		a_log_mod_1;
	}
	default_action : a_log_add_1();
}
action a_log_add_1(){
	add_to_field(netec_meta.temp_1, meta.coeff);
}

action a_log_mod_1(){
    modify_field(netec_meta.temp_1, netec.index);
}
table t_get_ilog_1{
	actions{
		a_get_ilog_1;
	}
	default_action : a_get_ilog_1;
}
blackbox stateful_alu s_ilog_table_1{
	reg : r_ilog_table_1;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec.data_1;
}
action a_get_ilog_1(){
	s_ilog_table_1.execute_stateful_alu(netec_meta.temp_1);
}



register r_log_table_2{
	width : 16;
	instance_count : 65536;
}
register r_ilog_table_2{
    width : 16;
    instance_count : 131072;
}

table t_get_log_2{
	actions{
		a_get_log_2;
	}
	default_action : a_get_log_2;
}
blackbox stateful_alu s_log_table_2{
	reg : r_log_table_2;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value : meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_2;
}
action a_get_log_2(){
	s_log_table_2.execute_stateful_alu(netec.data_2);
}
table t_log_add_2{
    reads{
        netec.type_ : exact;
    }
	actions{
		a_log_add_2;
		a_log_mod_2;
	}
	default_action : a_log_add_2();
}
action a_log_add_2(){
	add_to_field(netec_meta.temp_2, meta.coeff);
}

action a_log_mod_2(){
    modify_field(netec_meta.temp_2, netec.index);
}
table t_get_ilog_2{
	actions{
		a_get_ilog_2;
	}
	default_action : a_get_ilog_2;
}
blackbox stateful_alu s_ilog_table_2{
	reg : r_ilog_table_2;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec.data_2;
}
action a_get_ilog_2(){
	s_ilog_table_2.execute_stateful_alu(netec_meta.temp_2);
}



register r_log_table_3{
	width : 16;
	instance_count : 65536;
}
register r_ilog_table_3{
    width : 16;
    instance_count : 131072;
}

table t_get_log_3{
	actions{
		a_get_log_3;
	}
	default_action : a_get_log_3;
}
blackbox stateful_alu s_log_table_3{
	reg : r_log_table_3;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value : meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_3;
}
action a_get_log_3(){
	s_log_table_3.execute_stateful_alu(netec.data_3);
}
table t_log_add_3{
    reads{
        netec.type_ : exact;
    }
	actions{
		a_log_add_3;
		a_log_mod_3;
	}
	default_action : a_log_add_3();
}
action a_log_add_3(){
	add_to_field(netec_meta.temp_3, meta.coeff);
}

action a_log_mod_3(){
    modify_field(netec_meta.temp_3, netec.index);
}
table t_get_ilog_3{
	actions{
		a_get_ilog_3;
	}
	default_action : a_get_ilog_3;
}
blackbox stateful_alu s_ilog_table_3{
	reg : r_ilog_table_3;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec.data_3;
}
action a_get_ilog_3(){
	s_ilog_table_3.execute_stateful_alu(netec_meta.temp_3);
}



register r_log_table_4{
	width : 16;
	instance_count : 65536;
}
register r_ilog_table_4{
    width : 16;
    instance_count : 131072;
}

table t_get_log_4{
	actions{
		a_get_log_4;
	}
	default_action : a_get_log_4;
}
blackbox stateful_alu s_log_table_4{
	reg : r_log_table_4;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value : meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_4;
}
action a_get_log_4(){
	s_log_table_4.execute_stateful_alu(netec.data_4);
}
table t_log_add_4{
    reads{
        netec.type_ : exact;
    }
	actions{
		a_log_add_4;
		a_log_mod_4;
	}
	default_action : a_log_add_4();
}
action a_log_add_4(){
	add_to_field(netec_meta.temp_4, meta.coeff);
}

action a_log_mod_4(){
    modify_field(netec_meta.temp_4, netec.index);
}
table t_get_ilog_4{
	actions{
		a_get_ilog_4;
	}
	default_action : a_get_ilog_4;
}
blackbox stateful_alu s_ilog_table_4{
	reg : r_ilog_table_4;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec.data_4;
}
action a_get_ilog_4(){
	s_ilog_table_4.execute_stateful_alu(netec_meta.temp_4);
}



register r_log_table_5{
	width : 16;
	instance_count : 65536;
}
register r_ilog_table_5{
    width : 16;
    instance_count : 131072;
}

table t_get_log_5{
	actions{
		a_get_log_5;
	}
	default_action : a_get_log_5;
}
blackbox stateful_alu s_log_table_5{
	reg : r_log_table_5;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value : meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_5;
}
action a_get_log_5(){
	s_log_table_5.execute_stateful_alu(netec.data_5);
}
table t_log_add_5{
    reads{
        netec.type_ : exact;
    }
	actions{
		a_log_add_5;
		a_log_mod_5;
	}
	default_action : a_log_add_5();
}
action a_log_add_5(){
	add_to_field(netec_meta.temp_5, meta.coeff);
}

action a_log_mod_5(){
    modify_field(netec_meta.temp_5, netec.index);
}
table t_get_ilog_5{
	actions{
		a_get_ilog_5;
	}
	default_action : a_get_ilog_5;
}
blackbox stateful_alu s_ilog_table_5{
	reg : r_ilog_table_5;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec.data_5;
}
action a_get_ilog_5(){
	s_ilog_table_5.execute_stateful_alu(netec_meta.temp_5);
}



register r_log_table_6{
	width : 16;
	instance_count : 65536;
}
register r_ilog_table_6{
    width : 16;
    instance_count : 131072;
}

table t_get_log_6{
	actions{
		a_get_log_6;
	}
	default_action : a_get_log_6;
}
blackbox stateful_alu s_log_table_6{
	reg : r_log_table_6;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value : meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_6;
}
action a_get_log_6(){
	s_log_table_6.execute_stateful_alu(netec.data_6);
}
table t_log_add_6{
    reads{
        netec.type_ : exact;
    }
	actions{
		a_log_add_6;
		a_log_mod_6;
	}
	default_action : a_log_add_6();
}
action a_log_add_6(){
	add_to_field(netec_meta.temp_6, meta.coeff);
}

action a_log_mod_6(){
    modify_field(netec_meta.temp_6, netec.index);
}
table t_get_ilog_6{
	actions{
		a_get_ilog_6;
	}
	default_action : a_get_ilog_6;
}
blackbox stateful_alu s_ilog_table_6{
	reg : r_ilog_table_6;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec.data_6;
}
action a_get_ilog_6(){
	s_ilog_table_6.execute_stateful_alu(netec_meta.temp_6);
}



register r_log_table_7{
	width : 16;
	instance_count : 65536;
}
register r_ilog_table_7{
    width : 16;
    instance_count : 131072;
}

table t_get_log_7{
	actions{
		a_get_log_7;
	}
	default_action : a_get_log_7;
}
blackbox stateful_alu s_log_table_7{
	reg : r_log_table_7;
    condition_lo : netec.type_ == 1;
    update_lo_1_predicate: condition_lo;
	update_lo_1_value : meta.temp2;
    update_lo_2_predicate: not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec_meta.temp_7;
}
action a_get_log_7(){
	s_log_table_7.execute_stateful_alu(netec.data_7);
}
table t_log_add_7{
    reads{
        netec.type_ : exact;
    }
	actions{
		a_log_add_7;
		a_log_mod_7;
	}
	default_action : a_log_add_7();
}
action a_log_add_7(){
	add_to_field(netec_meta.temp_7, meta.coeff);
}

action a_log_mod_7(){
    modify_field(netec_meta.temp_7, netec.index);
}
table t_get_ilog_7{
	actions{
		a_get_ilog_7;
	}
	default_action : a_get_ilog_7;
}
blackbox stateful_alu s_ilog_table_7{
	reg : r_ilog_table_7;
    condition_lo: netec.type_ == 2;
    update_lo_1_predicate : condition_lo;
	update_lo_1_value : meta.temp;
    update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;
	output_value : register_lo;
	output_dst : netec.data_7;
}
action a_get_ilog_7(){
	s_ilog_table_7.execute_stateful_alu(netec_meta.temp_7);
}


control gf_multiply {
     apply(t_get_log_0);
     apply(t_get_log_1);
     apply(t_get_log_2);
     apply(t_get_log_3);
     apply(t_get_log_4);
     apply(t_get_log_5);
     apply(t_get_log_6);
     apply(t_get_log_7);
     apply(t_log_add_0);
     apply(t_log_add_1);
     apply(t_log_add_2);
     apply(t_log_add_3);
     apply(t_log_add_4);
     apply(t_log_add_5);
     apply(t_log_add_6);
     apply(t_log_add_7);
     
    if(netec.data_0 != 0)
        apply(t_get_ilog_0);
     
    if(netec.data_1 != 0)
        apply(t_get_ilog_1);
     
    if(netec.data_2 != 0)
        apply(t_get_ilog_2);
     
    if(netec.data_3 != 0)
        apply(t_get_ilog_3);
     
    if(netec.data_4 != 0)
        apply(t_get_ilog_4);
     
    if(netec.data_5 != 0)
        apply(t_get_ilog_5);
     
    if(netec.data_6 != 0)
        apply(t_get_ilog_6);
     
    if(netec.data_7 != 0)
        apply(t_get_ilog_7);
     
}
