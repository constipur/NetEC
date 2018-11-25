/*
Copyright 2013-present Barefoot Networks, Inc. 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

// This is P4 sample source for basic_switching
#include "xor_buffer.p4"
#include "includes/headers.p4"
#include "includes/parser.p4"
#include <tofino/intrinsic_metadata.p4>
#include <tofino/stateful_alu_blackbox.p4>
#include <tofino/constants.p4>

header_type custom_metadata_t {
	fields {
		forward:8;
		data:8;
		res:8 ;
		index:16;
		flag_finish : 1;
		cksum_compensate : 16;
		l4_proto:16;
		ttl_length:16;
		payload_csum : 16;
		coeff: 32;
		temp : 32;
		to_query : 16;

		netec_index : 16;
		// netec_data_0 : 16;
		// netec_data_1 : 16;
		// netec_data_2 : 16;
		// netec_data_3 : 16;
		// netec_data_4 : 16;
		// netec_data_5 : 16;
		// netec_data_6 : 16;
		// netec_data_7 : 16;
		// netec_data_8 : 16;
		// netec_data_9 : 16;
		// netec_data_10 : 16;
		// netec_data_11 : 16;
		// netec_data_12: 16;
		// netec_data_13 : 16;
		// netec_data_14 : 16;
		// netec_data_15 : 16;


		netec_res_0 : 16;
		// netec_res_1 : 16;
		// netec_res_2 : 16;
		// netec_res_3 : 16;
		// netec_res_4 : 16;
		// netec_res_5 : 16;
		// netec_res_6 : 16;
		// netec_res_7 : 16;
		// netec_res_8 : 16;
		// netec_res_9 : 16;
		// netec_res_10 : 16;
		// netec_res_11 : 16;
		// netec_res_12: 16;
		// netec_res_13 : 16;
		// netec_res_14 : 16;
		// netec_res_15 : 16;
	}
}
metadata custom_metadata_t meta;



field_list l4_with_netec_list {
	ipv4.srcAddr;
    ipv4.dstAddr;
	meta.l4_proto;
	udp.srcPort;
	udp.dstPort; 
	udp.length_;
	meta.netec_index;
	meta.netec_res_0;
	// meta.netec_res_1;
	// meta.netec_res_2;
	// meta.netec_res_3;
	// meta.netec_res_4;
	// meta.netec_res_5;
	// meta.netec_res_6;
	// meta.netec_res_7;
	// meta.netec_res_8;
	// meta.netec_res_9;
	// meta.netec_res_10;
	// meta.netec_res_11;
	// meta.netec_res_12;
	// meta.netec_res_13;
	// meta.netec_res_14;
	// meta.netec_res_15;
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

action set_egr(egress_spec) {
    modify_field(ig_intr_md_for_tm.ucast_egress_port, egress_spec);
}

action nop() {
}

action _drop() {
    drop();
}

table forward {
    reads {
        ethernet.dstAddr : exact;
    }
    actions {
        set_egr; nop;
    }
}

table bypass1 {
	actions{bypass1_action;}
	default_action : bypass1_action();
}
action bypass1_action(){
	//modify_field(ig_intr_md_for_tm.mcast_grp_a, 666);
	modify_field(ig_intr_md_for_tm.ucast_egress_port,136);
}
table bypass2 {
	actions{bypass2_action;}
	default_action : bypass2_action();
}
action bypass2_action(){
	modify_field(ig_intr_md_for_tm.ucast_egress_port,128);
	//modify_field(ig_intr_md_for_tm.mcast_grp_a, 666);
}


register r_finish{
	width : 8;
	instance_count : 65536;
}

table t_finish{
	actions{a_finish;}
	default_action : a_finish();
}
blackbox stateful_alu s_finish{
	reg : r_finish;
	condition_lo : register_lo < 2;
	update_lo_1_predicate : condition_lo;
	update_lo_1_value : register_lo + 1;
	update_lo_2_predicate: not condition_lo;
	update_lo_2_value : 0;

	update_hi_1_predicate : condition_lo;
	update_hi_1_value : 0;
	update_hi_2_predicate: not condition_lo;
	update_hi_2_value : 1;

	output_value : alu_hi;
	output_dst : meta.flag_finish;

}
action a_finish(){
	s_finish.execute_stateful_alu(netec.index);
}
table t_cksum_compensate{
	actions{a_cksum_compensate;}
	default_action : a_cksum_compensate();
}
action a_cksum_compensate(){
	//fill_meta_netec_fields();
	modify_field(meta.l4_proto,ipv4.protocol);
	modify_field(meta.netec_index,netec.index);
	modify_field(meta.cksum_compensate,udp.length_);//The udp.length_ field mysteriously does not take affect.
}



table t_send_res{
	actions{a_send_res;}
	default_action:a_send_res();
}
action a_send_res(){
	modify_field(udp.dstPort,20001);
	modify_field(ig_intr_md_for_tm.ucast_egress_port,136);
	fill_netec_fields();
}

//the coeff are logged
table t_get_coeff{
	reads {
		ipv4.srcAddr:exact;
	}
	actions{
		a_get_coeff;nop;
	}
	default_action:nop();
}

action a_get_coeff(coeff){
	modify_field(meta.coeff,coeff);
	modify_field(ipv4.diffserv,coeff);
}

table t_get_log{
	actions{
		a_get_log;
	}
	default_action:a_get_log;
}
register r_log_table{
	width : 16;
	instance_count : 65536;
}

blackbox stateful_alu s_log_table{
	reg : r_log_table;
	update_lo_1_value:register_lo;
	output_value : register_lo;
	output_dst : meta.temp;
}
action a_get_log(){
	s_log_table.execute_stateful_alu(netec.data_0);
}

table t_record{
	actions{
		a_record;
	}
	default_action:a_record();
}

action a_record(){
	modify_field(ipv4.identification,netec.data_0);
}

table t_log_zero{
	actions{
		a_log_zero;
	}
	default_action:a_log_zero();
}

action a_log_zero(){
	modify_field(meta.temp,0);
}


table t_log_add{
	actions{
		a_log_add;
	}
	default_action:a_log_add();
}
action a_log_add(){
	add_to_field(meta.temp,meta.coeff);
}


table t_get_ilog{
	actions{
		a_get_ilog;
	}
	default_action:a_get_ilog;
}
register r_ilog_table{
	width : 16;
	instance_count : 131072;
}

blackbox stateful_alu s_ilog_table{
	reg : r_ilog_table;
	update_lo_1_value:register_lo;
	output_value : register_lo;
	output_dst : netec.data_0;
}
action a_get_ilog(){
	s_ilog_table.execute_stateful_alu(meta.temp);
}


control ingress {
	/*
	if(ig_intr_md.ingress_port == 128){
		apply(bypass1);}
	else if(ig_intr_md.ingress_port == 136){
		apply(bypass2);}
	*/

	if(valid(netec)){
		apply(t_get_coeff);
		if(netec.data_0 != 0){
			apply(t_get_log);
			apply(t_log_add);
			apply(t_get_ilog);
			apply(t_record);
		}
		xor();
		apply(t_finish);
		if(meta.flag_finish == 1){
			apply(t_send_res);
			apply(t_cksum_compensate);
		}	
		else{
			apply(drop_table);
		}
	}
	
}

table drop_table {
	actions { 
		_drop;
	}
	default_action:_drop();
	size : 1;
}
table t_modify_ip{
	reads {eg_intr_md.egress_port : exact;}
	actions{a_modify_ip;_drop;}
	default_action : _drop();
	size : 32;
}
action a_modify_ip(ip,mac){
	modify_field(ipv4.dstAddr,ip);
	modify_field(ethernet.dstAddr,mac);
}


control egress {
	apply(t_modify_ip);
}

