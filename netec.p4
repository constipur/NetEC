
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
        data_16 : 32; 
        data_17 : 32; 
        data_18 : 32; 
        data_19 : 32; 
        data_20 : 32; 
        data_21 : 32; 
        data_22 : 32; 
        data_23 : 32; 
        data_24 : 32; 
        data_25 : 32; 
        data_26 : 32; 
        data_27 : 32; 
        data_28 : 32; 
        data_29 : 32; 
        data_30 : 32; 
        data_31 : 32; 
        data_32 : 32; 
        data_33 : 32; 
        data_34 : 32; 
        data_35 : 32; 
        data_36 : 32; 
        data_37 : 32; 
        data_38 : 32; 
        data_39 : 32; 
        data_40 : 32; 
        data_41 : 32; 
        data_42 : 32; 
        data_43 : 32; 
        data_44 : 32; 
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

	netec_meta.res_8;

	netec_meta.res_9;

	netec_meta.res_10;

	netec_meta.res_11;

	netec_meta.res_12;

	netec_meta.res_13;

	netec_meta.res_14;

	netec_meta.res_15;

	netec_meta.res_16;

	netec_meta.res_17;

	netec_meta.res_18;

	netec_meta.res_19;

	netec_meta.res_20;

	netec_meta.res_21;

	netec_meta.res_22;

	netec_meta.res_23;

	netec_meta.res_24;

	netec_meta.res_25;

	netec_meta.res_26;

	netec_meta.res_27;

	netec_meta.res_28;

	netec_meta.res_29;

	netec_meta.res_30;

	netec_meta.res_31;

	netec_meta.res_32;

	netec_meta.res_33;

	netec_meta.res_34;

	netec_meta.res_35;

	netec_meta.res_36;

	netec_meta.res_37;

	netec_meta.res_38;

	netec_meta.res_39;

	netec_meta.res_40;

	netec_meta.res_41;

	netec_meta.res_42;

	netec_meta.res_43;

	netec_meta.res_44;

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

    netec_meta.res_8;

    netec_meta.res_9;

    netec_meta.res_10;

    netec_meta.res_11;

    netec_meta.res_12;

    netec_meta.res_13;

    netec_meta.res_14;

    netec_meta.res_15;

    netec_meta.res_16;

    netec_meta.res_17;

    netec_meta.res_18;

    netec_meta.res_19;

    netec_meta.res_20;

    netec_meta.res_21;

    netec_meta.res_22;

    netec_meta.res_23;

    netec_meta.res_24;

    netec_meta.res_25;

    netec_meta.res_26;

    netec_meta.res_27;

    netec_meta.res_28;

    netec_meta.res_29;

    netec_meta.res_30;

    netec_meta.res_31;

    netec_meta.res_32;

    netec_meta.res_33;

    netec_meta.res_34;

    netec_meta.res_35;

    netec_meta.res_36;

    netec_meta.res_37;

    netec_meta.res_38;

    netec_meta.res_39;

    netec_meta.res_40;

    netec_meta.res_41;

    netec_meta.res_42;

    netec_meta.res_43;

    netec_meta.res_44;

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

// AUTOGEN
register r_xor_8{
	width : 16;
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
	output_dst : netec_meta.res_8;
}
table t_xor_8{
	actions{a_xor_8;}
	default_action : a_xor_8();
}
action a_xor_8(){
	s_xor_8.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_9{
	width : 16;
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
	output_dst : netec_meta.res_9;
}
table t_xor_9{
	actions{a_xor_9;}
	default_action : a_xor_9();
}
action a_xor_9(){
	s_xor_9.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_10{
	width : 16;
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
	output_dst : netec_meta.res_10;
}
table t_xor_10{
	actions{a_xor_10;}
	default_action : a_xor_10();
}
action a_xor_10(){
	s_xor_10.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_11{
	width : 16;
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
	output_dst : netec_meta.res_11;
}
table t_xor_11{
	actions{a_xor_11;}
	default_action : a_xor_11();
}
action a_xor_11(){
	s_xor_11.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_12{
	width : 16;
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
	output_dst : netec_meta.res_12;
}
table t_xor_12{
	actions{a_xor_12;}
	default_action : a_xor_12();
}
action a_xor_12(){
	s_xor_12.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_13{
	width : 16;
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
	output_dst : netec_meta.res_13;
}
table t_xor_13{
	actions{a_xor_13;}
	default_action : a_xor_13();
}
action a_xor_13(){
	s_xor_13.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_14{
	width : 16;
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
	output_dst : netec_meta.res_14;
}
table t_xor_14{
	actions{a_xor_14;}
	default_action : a_xor_14();
}
action a_xor_14(){
	s_xor_14.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_15{
	width : 16;
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
	output_dst : netec_meta.res_15;
}
table t_xor_15{
	actions{a_xor_15;}
	default_action : a_xor_15();
}
action a_xor_15(){
	s_xor_15.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_16{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_16{
	reg : r_xor_16;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_16;

    update_hi_1_value : register_lo ^ netec.data_16;
	output_value : alu_hi;
	output_dst : netec_meta.res_16;
}
table t_xor_16{
	actions{a_xor_16;}
	default_action : a_xor_16();
}
action a_xor_16(){
	s_xor_16.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_17{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_17{
	reg : r_xor_17;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_17;

    update_hi_1_value : register_lo ^ netec.data_17;
	output_value : alu_hi;
	output_dst : netec_meta.res_17;
}
table t_xor_17{
	actions{a_xor_17;}
	default_action : a_xor_17();
}
action a_xor_17(){
	s_xor_17.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_18{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_18{
	reg : r_xor_18;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_18;

    update_hi_1_value : register_lo ^ netec.data_18;
	output_value : alu_hi;
	output_dst : netec_meta.res_18;
}
table t_xor_18{
	actions{a_xor_18;}
	default_action : a_xor_18();
}
action a_xor_18(){
	s_xor_18.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_19{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_19{
	reg : r_xor_19;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_19;

    update_hi_1_value : register_lo ^ netec.data_19;
	output_value : alu_hi;
	output_dst : netec_meta.res_19;
}
table t_xor_19{
	actions{a_xor_19;}
	default_action : a_xor_19();
}
action a_xor_19(){
	s_xor_19.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_20{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_20{
	reg : r_xor_20;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_20;

    update_hi_1_value : register_lo ^ netec.data_20;
	output_value : alu_hi;
	output_dst : netec_meta.res_20;
}
table t_xor_20{
	actions{a_xor_20;}
	default_action : a_xor_20();
}
action a_xor_20(){
	s_xor_20.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_21{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_21{
	reg : r_xor_21;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_21;

    update_hi_1_value : register_lo ^ netec.data_21;
	output_value : alu_hi;
	output_dst : netec_meta.res_21;
}
table t_xor_21{
	actions{a_xor_21;}
	default_action : a_xor_21();
}
action a_xor_21(){
	s_xor_21.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_22{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_22{
	reg : r_xor_22;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_22;

    update_hi_1_value : register_lo ^ netec.data_22;
	output_value : alu_hi;
	output_dst : netec_meta.res_22;
}
table t_xor_22{
	actions{a_xor_22;}
	default_action : a_xor_22();
}
action a_xor_22(){
	s_xor_22.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_23{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_23{
	reg : r_xor_23;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_23;

    update_hi_1_value : register_lo ^ netec.data_23;
	output_value : alu_hi;
	output_dst : netec_meta.res_23;
}
table t_xor_23{
	actions{a_xor_23;}
	default_action : a_xor_23();
}
action a_xor_23(){
	s_xor_23.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_24{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_24{
	reg : r_xor_24;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_24;

    update_hi_1_value : register_lo ^ netec.data_24;
	output_value : alu_hi;
	output_dst : netec_meta.res_24;
}
table t_xor_24{
	actions{a_xor_24;}
	default_action : a_xor_24();
}
action a_xor_24(){
	s_xor_24.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_25{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_25{
	reg : r_xor_25;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_25;

    update_hi_1_value : register_lo ^ netec.data_25;
	output_value : alu_hi;
	output_dst : netec_meta.res_25;
}
table t_xor_25{
	actions{a_xor_25;}
	default_action : a_xor_25();
}
action a_xor_25(){
	s_xor_25.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_26{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_26{
	reg : r_xor_26;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_26;

    update_hi_1_value : register_lo ^ netec.data_26;
	output_value : alu_hi;
	output_dst : netec_meta.res_26;
}
table t_xor_26{
	actions{a_xor_26;}
	default_action : a_xor_26();
}
action a_xor_26(){
	s_xor_26.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_27{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_27{
	reg : r_xor_27;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_27;

    update_hi_1_value : register_lo ^ netec.data_27;
	output_value : alu_hi;
	output_dst : netec_meta.res_27;
}
table t_xor_27{
	actions{a_xor_27;}
	default_action : a_xor_27();
}
action a_xor_27(){
	s_xor_27.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_28{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_28{
	reg : r_xor_28;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_28;

    update_hi_1_value : register_lo ^ netec.data_28;
	output_value : alu_hi;
	output_dst : netec_meta.res_28;
}
table t_xor_28{
	actions{a_xor_28;}
	default_action : a_xor_28();
}
action a_xor_28(){
	s_xor_28.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_29{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_29{
	reg : r_xor_29;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_29;

    update_hi_1_value : register_lo ^ netec.data_29;
	output_value : alu_hi;
	output_dst : netec_meta.res_29;
}
table t_xor_29{
	actions{a_xor_29;}
	default_action : a_xor_29();
}
action a_xor_29(){
	s_xor_29.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_30{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_30{
	reg : r_xor_30;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_30;

    update_hi_1_value : register_lo ^ netec.data_30;
	output_value : alu_hi;
	output_dst : netec_meta.res_30;
}
table t_xor_30{
	actions{a_xor_30;}
	default_action : a_xor_30();
}
action a_xor_30(){
	s_xor_30.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_31{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_31{
	reg : r_xor_31;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_31;

    update_hi_1_value : register_lo ^ netec.data_31;
	output_value : alu_hi;
	output_dst : netec_meta.res_31;
}
table t_xor_31{
	actions{a_xor_31;}
	default_action : a_xor_31();
}
action a_xor_31(){
	s_xor_31.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_32{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_32{
	reg : r_xor_32;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_32;

    update_hi_1_value : register_lo ^ netec.data_32;
	output_value : alu_hi;
	output_dst : netec_meta.res_32;
}
table t_xor_32{
	actions{a_xor_32;}
	default_action : a_xor_32();
}
action a_xor_32(){
	s_xor_32.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_33{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_33{
	reg : r_xor_33;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_33;

    update_hi_1_value : register_lo ^ netec.data_33;
	output_value : alu_hi;
	output_dst : netec_meta.res_33;
}
table t_xor_33{
	actions{a_xor_33;}
	default_action : a_xor_33();
}
action a_xor_33(){
	s_xor_33.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_34{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_34{
	reg : r_xor_34;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_34;

    update_hi_1_value : register_lo ^ netec.data_34;
	output_value : alu_hi;
	output_dst : netec_meta.res_34;
}
table t_xor_34{
	actions{a_xor_34;}
	default_action : a_xor_34();
}
action a_xor_34(){
	s_xor_34.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_35{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_35{
	reg : r_xor_35;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_35;

    update_hi_1_value : register_lo ^ netec.data_35;
	output_value : alu_hi;
	output_dst : netec_meta.res_35;
}
table t_xor_35{
	actions{a_xor_35;}
	default_action : a_xor_35();
}
action a_xor_35(){
	s_xor_35.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_36{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_36{
	reg : r_xor_36;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_36;

    update_hi_1_value : register_lo ^ netec.data_36;
	output_value : alu_hi;
	output_dst : netec_meta.res_36;
}
table t_xor_36{
	actions{a_xor_36;}
	default_action : a_xor_36();
}
action a_xor_36(){
	s_xor_36.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_37{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_37{
	reg : r_xor_37;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_37;

    update_hi_1_value : register_lo ^ netec.data_37;
	output_value : alu_hi;
	output_dst : netec_meta.res_37;
}
table t_xor_37{
	actions{a_xor_37;}
	default_action : a_xor_37();
}
action a_xor_37(){
	s_xor_37.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_38{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_38{
	reg : r_xor_38;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_38;

    update_hi_1_value : register_lo ^ netec.data_38;
	output_value : alu_hi;
	output_dst : netec_meta.res_38;
}
table t_xor_38{
	actions{a_xor_38;}
	default_action : a_xor_38();
}
action a_xor_38(){
	s_xor_38.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_39{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_39{
	reg : r_xor_39;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_39;

    update_hi_1_value : register_lo ^ netec.data_39;
	output_value : alu_hi;
	output_dst : netec_meta.res_39;
}
table t_xor_39{
	actions{a_xor_39;}
	default_action : a_xor_39();
}
action a_xor_39(){
	s_xor_39.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_40{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_40{
	reg : r_xor_40;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_40;

    update_hi_1_value : register_lo ^ netec.data_40;
	output_value : alu_hi;
	output_dst : netec_meta.res_40;
}
table t_xor_40{
	actions{a_xor_40;}
	default_action : a_xor_40();
}
action a_xor_40(){
	s_xor_40.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_41{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_41{
	reg : r_xor_41;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_41;

    update_hi_1_value : register_lo ^ netec.data_41;
	output_value : alu_hi;
	output_dst : netec_meta.res_41;
}
table t_xor_41{
	actions{a_xor_41;}
	default_action : a_xor_41();
}
action a_xor_41(){
	s_xor_41.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_42{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_42{
	reg : r_xor_42;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_42;

    update_hi_1_value : register_lo ^ netec.data_42;
	output_value : alu_hi;
	output_dst : netec_meta.res_42;
}
table t_xor_42{
	actions{a_xor_42;}
	default_action : a_xor_42();
}
action a_xor_42(){
	s_xor_42.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_43{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_43{
	reg : r_xor_43;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_43;

    update_hi_1_value : register_lo ^ netec.data_43;
	output_value : alu_hi;
	output_dst : netec_meta.res_43;
}
table t_xor_43{
	actions{a_xor_43;}
	default_action : a_xor_43();
}
action a_xor_43(){
	s_xor_43.execute_stateful_alu(meta.index);
}

// AUTOGEN
register r_xor_44{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_44{
	reg : r_xor_44;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_44;

    update_hi_1_value : register_lo ^ netec.data_44;
	output_value : alu_hi;
	output_dst : netec_meta.res_44;
}
table t_xor_44{
	actions{a_xor_44;}
	default_action : a_xor_44();
}
action a_xor_44(){
	s_xor_44.execute_stateful_alu(meta.index);
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
    apply(t_xor_16); 
    apply(t_xor_17); 
    apply(t_xor_18); 
    apply(t_xor_19); 
    apply(t_xor_20); 
    apply(t_xor_21); 
    apply(t_xor_22); 
    apply(t_xor_23); 
    apply(t_xor_24); 
    apply(t_xor_25); 
    apply(t_xor_26); 
    apply(t_xor_27); 
    apply(t_xor_28); 
    apply(t_xor_29); 
    apply(t_xor_30); 
    apply(t_xor_31); 
    apply(t_xor_32); 
    apply(t_xor_33); 
    apply(t_xor_34); 
    apply(t_xor_35); 
    apply(t_xor_36); 
    apply(t_xor_37); 
    apply(t_xor_38); 
    apply(t_xor_39); 
    apply(t_xor_40); 
    apply(t_xor_41); 
    apply(t_xor_42); 
    apply(t_xor_43); 
    apply(t_xor_44); 
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

    modify_field(netec.data_8, netec_meta.res_8);

    modify_field(netec.data_9, netec_meta.res_9);

    modify_field(netec.data_10, netec_meta.res_10);

    modify_field(netec.data_11, netec_meta.res_11);

    modify_field(netec.data_12, netec_meta.res_12);

    modify_field(netec.data_13, netec_meta.res_13);

    modify_field(netec.data_14, netec_meta.res_14);

    modify_field(netec.data_15, netec_meta.res_15);

    modify_field(netec.data_16, netec_meta.res_16);

    modify_field(netec.data_17, netec_meta.res_17);

    modify_field(netec.data_18, netec_meta.res_18);

    modify_field(netec.data_19, netec_meta.res_19);

    modify_field(netec.data_20, netec_meta.res_20);

    modify_field(netec.data_21, netec_meta.res_21);

    modify_field(netec.data_22, netec_meta.res_22);

    modify_field(netec.data_23, netec_meta.res_23);

    modify_field(netec.data_24, netec_meta.res_24);

    modify_field(netec.data_25, netec_meta.res_25);

    modify_field(netec.data_26, netec_meta.res_26);

    modify_field(netec.data_27, netec_meta.res_27);

    modify_field(netec.data_28, netec_meta.res_28);

    modify_field(netec.data_29, netec_meta.res_29);

    modify_field(netec.data_30, netec_meta.res_30);

    modify_field(netec.data_31, netec_meta.res_31);

    modify_field(netec.data_32, netec_meta.res_32);

    modify_field(netec.data_33, netec_meta.res_33);

    modify_field(netec.data_34, netec_meta.res_34);

    modify_field(netec.data_35, netec_meta.res_35);

    modify_field(netec.data_36, netec_meta.res_36);

    modify_field(netec.data_37, netec_meta.res_37);

    modify_field(netec.data_38, netec_meta.res_38);

    modify_field(netec.data_39, netec_meta.res_39);

    modify_field(netec.data_40, netec_meta.res_40);

    modify_field(netec.data_41, netec_meta.res_41);

    modify_field(netec.data_42, netec_meta.res_42);

    modify_field(netec.data_43, netec_meta.res_43);

    modify_field(netec.data_44, netec_meta.res_44);

}

header_type netec_meta_t{
	fields{
        type_ : 16;

		index : 32;
        temp : 16;

        res_0 : 32;
        // temp_0 : 32;

        res_1 : 32;
        // temp_1 : 32;

        res_2 : 32;
        // temp_2 : 32;

        res_3 : 32;
        // temp_3 : 32;

        res_4 : 32;
        // temp_4 : 32;

        res_5 : 32;
        // temp_5 : 32;

        res_6 : 32;
        // temp_6 : 32;

        res_7 : 32;
        // temp_7 : 32;

        res_8 : 32;
        // temp_8 : 32;

        res_9 : 32;
        // temp_9 : 32;

        res_10 : 32;
        // temp_10 : 32;

        res_11 : 32;
        // temp_11 : 32;

        res_12 : 32;
        // temp_12 : 32;

        res_13 : 32;
        // temp_13 : 32;

        res_14 : 32;
        // temp_14 : 32;

        res_15 : 32;
        // temp_15 : 32;

        res_16 : 32;
        // temp_16 : 32;

        res_17 : 32;
        // temp_17 : 32;

        res_18 : 32;
        // temp_18 : 32;

        res_19 : 32;
        // temp_19 : 32;

        res_20 : 32;
        // temp_20 : 32;

        res_21 : 32;
        // temp_21 : 32;

        res_22 : 32;
        // temp_22 : 32;

        res_23 : 32;
        // temp_23 : 32;

        res_24 : 32;
        // temp_24 : 32;

        res_25 : 32;
        // temp_25 : 32;

        res_26 : 32;
        // temp_26 : 32;

        res_27 : 32;
        // temp_27 : 32;

        res_28 : 32;
        // temp_28 : 32;

        res_29 : 32;
        // temp_29 : 32;

        res_30 : 32;
        // temp_30 : 32;

        res_31 : 32;
        // temp_31 : 32;

        res_32 : 32;
        // temp_32 : 32;

        res_33 : 32;
        // temp_33 : 32;

        res_34 : 32;
        // temp_34 : 32;

        res_35 : 32;
        // temp_35 : 32;

        res_36 : 32;
        // temp_36 : 32;

        res_37 : 32;
        // temp_37 : 32;

        res_38 : 32;
        // temp_38 : 32;

        res_39 : 32;
        // temp_39 : 32;

        res_40 : 32;
        // temp_40 : 32;

        res_41 : 32;
        // temp_41 : 32;

        res_42 : 32;
        // temp_42 : 32;

        res_43 : 32;
        // temp_43 : 32;

        res_44 : 32;
        // temp_44 : 32;

    }
}
