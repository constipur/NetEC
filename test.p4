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
	}
}
metadata custom_metadata_t meta;

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

register r_xor{
	width : 16;
	instance_count : 32768;
}
blackbox stateful_alu s_xor{
	reg : r_xor;
	update_lo_1_value : register_lo ^ netec.data;
	output_value : alu_lo;
	output_dst : meta.res;
}
table t_xor{
	actions{a_xor;}
	default_action : a_xor();
}
action a_xor(){
	s_xor.execute_stateful_alu(netec.index);
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
	subtract(meta.cksum_compensate,netec.data,meta.res);
}
table t_send_res{
	actions{a_send_res;}
	default_action:a_send_res();
}
action a_send_res(){
	modify_field(udp.dstPort,20001);
	//subtract_from_field(udp.srcPort,meta.cksum_compensate);
	modify_field(netec.data,meta.res);
	modify_field(ig_intr_md_for_tm.ucast_egress_port,136);
}

control ingress {
	/*
	if(ig_intr_md.ingress_port == 128){
		apply(bypass1);}
	else if(ig_intr_md.ingress_port == 136){
		apply(bypass2);}
	*/

	if(valid(netec)){
		apply(t_xor);
		apply(t_finish);
		if(meta.flag_finish == 1){
			apply(t_cksum_compensate);
			apply(t_send_res);
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

