
header_type netec_t{
	fields {
        type_ : 16;
		index : 32; 
        data_0 : 32; 
        data_1 : 32; 
        data_2 : 32; 
        data_3 : 32; 
        data_4 : 32; 
        data_5 : 32; 
        data_6 : 32; 
        data_7 : 32; 
        data_8 : 32; 
        data_9 : 32; 
        data_10 : 32; 
        data_11 : 32; 
        data_12 : 32; 
        data_13 : 32; 
        data_14 : 32; 
        data_15 : 32; 
	}
}
header netec_t netec;

field_list l4_with_netec_list_udp {
	ipv4.srcAddr;
    ipv4.dstAddr;
	//TOFINO: A bug about alignments, the eight zeroes seem not working. We comment out the protocol field (often unchanged) to get around this bug. The TCP checksum now works fine.
    //8'0;
    //ipv4.protocol;
	meta.l4_proto;
	udp.srcPort;
	udp.dstPort;
	udp.length_;
	netec.index;
	netec.type_;

	netec.data_0; 
	netec.data_1; 
	netec.data_2; 
	netec.data_3; 
	netec.data_4; 
	netec.data_5; 
	netec.data_6; 
	netec.data_7; 
	netec.data_8; 
	netec.data_9; 
	netec.data_10; 
	netec.data_11; 
	netec.data_12; 
	netec.data_13; 
	netec.data_14; 
	netec.data_15; 
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
	netec.index;
	netec.type_; 
    netec.data_0; 
    netec.data_1; 
    netec.data_2; 
    netec.data_3; 
    netec.data_4; 
    netec.data_5; 
    netec.data_6; 
    netec.data_7; 
    netec.data_8; 
    netec.data_9; 
    netec.data_10; 
    netec.data_11; 
    netec.data_12; 
    netec.data_13; 
    netec.data_14; 
    netec.data_15; 
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
	width : 32;
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
	output_dst : netec.data_0;
}
table t_xor_0{
	actions{a_xor_0;}
	default_action : a_xor_0();
    size : 1;
}
action a_xor_0(){
	s_xor_0.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_1{
	width : 32;
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
	output_dst : netec.data_1;
}
table t_xor_1{
	actions{a_xor_1;}
	default_action : a_xor_1();
    size : 1;
}
action a_xor_1(){
	s_xor_1.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_2{
	width : 32;
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
	output_dst : netec.data_2;
}
table t_xor_2{
	actions{a_xor_2;}
	default_action : a_xor_2();
    size : 1;
}
action a_xor_2(){
	s_xor_2.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_3{
	width : 32;
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
	output_dst : netec.data_3;
}
table t_xor_3{
	actions{a_xor_3;}
	default_action : a_xor_3();
    size : 1;
}
action a_xor_3(){
	s_xor_3.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_4{
	width : 32;
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
	output_dst : netec.data_4;
}
table t_xor_4{
	actions{a_xor_4;}
	default_action : a_xor_4();
    size : 1;
}
action a_xor_4(){
	s_xor_4.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_5{
	width : 32;
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
	output_dst : netec.data_5;
}
table t_xor_5{
	actions{a_xor_5;}
	default_action : a_xor_5();
    size : 1;
}
action a_xor_5(){
	s_xor_5.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_6{
	width : 32;
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
	output_dst : netec.data_6;
}
table t_xor_6{
	actions{a_xor_6;}
	default_action : a_xor_6();
    size : 1;
}
action a_xor_6(){
	s_xor_6.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_7{
	width : 32;
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
	output_dst : netec.data_7;
}
table t_xor_7{
	actions{a_xor_7;}
	default_action : a_xor_7();
    size : 1;
}
action a_xor_7(){
	s_xor_7.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_8{
	width : 32;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_8{
	reg : r_xor_8;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_8;

    update_hi_1_value : register_lo ^ netec.data_8;
	output_value : alu_hi;
	output_dst : netec.data_8;
}
table t_xor_8{
	actions{a_xor_8;}
	default_action : a_xor_8();
    size : 1;
}
action a_xor_8(){
	s_xor_8.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_9{
	width : 32;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_9{
	reg : r_xor_9;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_9;

    update_hi_1_value : register_lo ^ netec.data_9;
	output_value : alu_hi;
	output_dst : netec.data_9;
}
table t_xor_9{
	actions{a_xor_9;}
	default_action : a_xor_9();
    size : 1;
}
action a_xor_9(){
	s_xor_9.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_10{
	width : 32;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_10{
	reg : r_xor_10;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_10;

    update_hi_1_value : register_lo ^ netec.data_10;
	output_value : alu_hi;
	output_dst : netec.data_10;
}
table t_xor_10{
	actions{a_xor_10;}
	default_action : a_xor_10();
    size : 1;
}
action a_xor_10(){
	s_xor_10.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_11{
	width : 32;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_11{
	reg : r_xor_11;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_11;

    update_hi_1_value : register_lo ^ netec.data_11;
	output_value : alu_hi;
	output_dst : netec.data_11;
}
table t_xor_11{
	actions{a_xor_11;}
	default_action : a_xor_11();
    size : 1;
}
action a_xor_11(){
	s_xor_11.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_12{
	width : 32;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_12{
	reg : r_xor_12;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_12;

    update_hi_1_value : register_lo ^ netec.data_12;
	output_value : alu_hi;
	output_dst : netec.data_12;
}
table t_xor_12{
	actions{a_xor_12;}
	default_action : a_xor_12();
    size : 1;
}
action a_xor_12(){
	s_xor_12.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_13{
	width : 32;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_13{
	reg : r_xor_13;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_13;

    update_hi_1_value : register_lo ^ netec.data_13;
	output_value : alu_hi;
	output_dst : netec.data_13;
}
table t_xor_13{
	actions{a_xor_13;}
	default_action : a_xor_13();
    size : 1;
}
action a_xor_13(){
	s_xor_13.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_14{
	width : 32;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_14{
	reg : r_xor_14;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_14;

    update_hi_1_value : register_lo ^ netec.data_14;
	output_value : alu_hi;
	output_dst : netec.data_14;
}
table t_xor_14{
	actions{a_xor_14;}
	default_action : a_xor_14();
    size : 1;
}
action a_xor_14(){
	s_xor_14.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_15{
	width : 32;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_15{
	reg : r_xor_15;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_15;

    update_hi_1_value : register_lo ^ netec.data_15;
	output_value : alu_hi;
	output_dst : netec.data_15;
}
table t_xor_15{
	actions{a_xor_15;}
	default_action : a_xor_15();
    size : 1;
}
action a_xor_15(){
	s_xor_15.execute_stateful_alu(meta.index);
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
    apply(t_xor_8); 
    apply(t_xor_9); 
    apply(t_xor_10); 
    apply(t_xor_11); 
    apply(t_xor_12); 
    apply(t_xor_13); 
    apply(t_xor_14); 
    apply(t_xor_15); 
}
