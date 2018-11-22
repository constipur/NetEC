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
		
		netec_index : 16;
		netec_data_0 : 8;
		netec_data_1 : 8;
		netec_data_2 : 8;
		netec_data_3 : 8;
		netec_data_4 : 8;
		netec_data_5 : 8;
		netec_data_6 : 8;
		netec_data_7 : 8;
		netec_data_8 : 8;
		netec_data_9 : 8;
		netec_data_10 : 8;
		netec_data_11 : 8;
		netec_data_12: 8;
		netec_data_13 : 8;
		netec_data_14 : 8;
		netec_data_15 : 8;

		netec_res_0 : 8;
		netec_res_1 : 8;
		netec_res_2 : 8;
		netec_res_3 : 8;
		netec_res_4 : 8;
		netec_res_5 : 8;
		netec_res_6 : 8;
		netec_res_7 : 8;
		netec_res_8 : 8;
		netec_res_9 : 8;
		netec_res_10 : 8;
		netec_res_11 : 8;
		netec_res_12: 8;
		netec_res_13 : 8;
		netec_res_14 : 8;
		netec_res_15 : 8;
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
	meta.netec_res_1;
	meta.netec_res_2;
	meta.netec_res_3;
	meta.netec_res_4;
	meta.netec_res_5;
	meta.netec_res_6;
	meta.netec_res_7;
	meta.netec_res_8;
	meta.netec_res_9;
	meta.netec_res_10;
	meta.netec_res_11;
	meta.netec_res_12;
	meta.netec_res_13;
	meta.netec_res_14;
	meta.netec_res_15;
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
	condition_lo : register_lo < 1;
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


control ingress {
	/*
	if(ig_intr_md.ingress_port == 128){
		apply(bypass1);}
	else if(ig_intr_md.ingress_port == 136){
		apply(bypass2);}
	*/

	if(valid(netec)){
		//apply(t_xor);
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

