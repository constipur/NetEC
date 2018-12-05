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
#include "netec.p4"
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
		type_:16;
		index:32;
		flag_finish : 1;
		cksum_compensate : 16;
		l4_proto:16;
		ttl_length:16;
		payload_csum : 16;
		coeff: 32;
		temp : 16;
		temp2 : 16;
		to_query : 16;		

		direction : 8;
	}
}
metadata custom_metadata_t meta;
metadata netec_meta_t netec_meta;

action nop() {
}

action _drop() {
    drop();
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
	modify_field(meta.l4_proto,ipv4.protocol);
	modify_field(netec_meta.index,netec.index);
	modify_field(netec_meta.type_,netec.type_);
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
	modify_field(meta.temp,netec.data_0);//writing to ilog tables
	modify_field(meta.temp2,netec.index);//writing to log tables;
	modify_field(meta.index,netec.index);
}

table t_record{
	actions{
		a_record;
	}
	default_action:a_record();
}
action a_record(){
	modify_field(ipv4.identification,netec_meta.temp_1);
	//modify_field(ipv4.diffserv,netec_meta.temp_1);
}

table t_direction_check{
	reads{
		ipv4.srcAddr:exact;
	}
	actions{
		a_multicast;
		a_aggregate;
		nop;
	}
	default_action : nop();
}

action a_multicast(grp_id){
	modify_field(ig_intr_md_for_tm.mcast_grp_a,grp_id);
	modify_field(meta.direction,1);
}

action a_aggregate(){
	modify_field(meta.direction,2);
}


control ingress {
	/*
	if(ig_intr_md.ingress_port == 128){
		apply(bypass1);}
	else if(ig_intr_md.ingress_port == 136){
		apply(bypass2);}
	*/
	apply(t_direction_check_table);
	if(meta.direction == 2){
		

	}


	if(valid(netec)){
		apply(t_get_coeff);
		/*
		if(netec.data_0 != 0){
			apply(t_get_log);
			apply(t_log_add);
			apply(t_get_ilog);
			apply(t_record);
		}
		*/
	
		gf_multiply();
		if(netec.type_ == 0){
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


