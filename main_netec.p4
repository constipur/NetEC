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


#define NETEC_DN_PORT 20001

#define TCP_FLAG_SYN 0x02
#define TCP_FLAG_ACK 0x10
#define TCP_FLAG_SA 0x12
#define TCP_FLAG_PA 0x18

#define DN_COUNT 3

#define CLIENT_PORT 136
#define DN_PORT_1 128
#define DN_PORT_2 144
#define DN_PORT_3 152

// This is P4 sample source for basic_switching
#include "netec.p4"
#include "includes/headers.p4"
#include "includes/parser.p4"
#include <tofino/intrinsic_metadata.p4>
#include <tofino/stateful_alu_blackbox.p4>
#include <tofino/constants.p4>


header_type custom_metadata_t {
	fields {
		forward : 8;
		data : 8;
		res : 8 ;
		type_ : 16;
		index : 32;
		flag_finish : 1;
		cksum_compensate : 16;
		l4_proto : 16;
		ttl_length : 16;
		payload_csum : 16;
		coeff: 32;
		temp : 16;
		temp2 : 16;
		to_query : 16;
		/* for reading DN's initial SEQ# */
		sa_from_dn : 1;
		dn_init_seq : 32;
		dn_port_for_seq : 8;
		sa_finish : 1;
	}
}
metadata custom_metadata_t meta;
metadata netec_meta_t netec_meta;

action a_nop() {
}

action a_drop() {
    drop();
}

register r_finish{
	width : 8;
	instance_count : 65536;
}

table t_finish{
	actions{ a_finish; }
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
	actions{ a_cksum_compensate; }
	default_action : a_cksum_compensate();
}
action a_cksum_compensate(){
	modify_field(meta.l4_proto, ipv4.protocol);
	modify_field(netec_meta.index, netec.index);
	modify_field(netec_meta.type_, netec.type_);
	modify_field(meta.cksum_compensate, udp.length_); // The udp.length_ field mysteriously does not take affect.
}

table t_send_res{
	actions{ a_send_res; }
	default_action : a_send_res();
}
action a_send_res(){
	modify_field(ig_intr_md_for_tm.ucast_egress_port, CLIENT_PORT);
	fill_netec_fields();
}

//the coeff are logged
table t_get_coeff{
	reads {
		ipv4.srcAddr : exact;
	}
	actions{
		a_get_coeff; a_nop;
	}
	default_action : a_nop();
}


action a_get_coeff(coeff){
	modify_field(meta.coeff, coeff);
	modify_field(meta.temp, netec.data_0); // writing to ilog tables
	modify_field(meta.temp2, netec.index); // writing to log tables;
	modify_field(meta.index, netec.index);
}

table t_record{
	actions{
		a_record;
	}
	default_action : a_record();
}
action a_record(){
	modify_field(ipv4.identification, netec_meta.temp_1);
	// modify_field(ipv4.diffserv, netec_meta.temp_1);
}

/* prepare paras for calculation */
table t_prepare_paras{
	actions{ a_prepare_paras; }
	default_action : a_prepare_paras();
}
action a_prepare_paras(){
	modify_field(meta.index, netec.index);
}

/* multicast */
table t_multicast{
	actions{
		a_mcast;
	}
	default_action : a_mcast();
}
action a_mcast(){
	/* TODO: multi-group configurable multicast */
	modify_field(ig_intr_md_for_tm.mcast_grp_a, 666);
}

/* mark that we need to store the SEQ# */
table t_mark_sa_from_dn{
	actions{ a_mark_sa_from_dn; }
	default_action : a_mark_sa_from_dn();
}
action a_mark_sa_from_dn(){
	modify_field(meta.sa_from_dn, 1);
}

/* count how many SYN+ACK we have received */
register r_sa_count{
	width : 8;
	instance_count : 1;
}
table t_sa_count{
	actions{ a_sa_count; }
	default_action : a_sa_count();
}
action a_sa_count(){
	s_sa_count.execute_stateful_alu(0);
}
blackbox stateful_alu s_sa_count{
	reg : r_sa_count;
	condition_lo : register_lo < (DN_COUNT - 1);
	update_lo_1_predicate : condition_lo;
	update_lo_1_value : register_lo + 1;
	update_lo_2_predicate: not condition_lo;
	update_lo_2_value : 0;

	update_hi_1_predicate : condition_lo;
	update_hi_1_value : 0;
	update_hi_2_predicate: not condition_lo;
	update_hi_2_value : 1;

	output_value : alu_hi;
	output_dst : meta.sa_finish;
}

/* modify tcp.seq to 0 */
table t_seq_zero{
	actions{ a_seq_zero; }
	default_action : a_seq_zero();
}
action a_seq_zero(){
	modify_field(tcp.seqNo, 0);
}


/************************ BEHAVIOR ************************
 * packets from CLIENT to DN:
 * on SYN: 1) Multicast, establish connection with all DNs
 * on ACK/PSH+ACK: 1) Multicast to all DNs
 *                 2) [EGRESS] modify ACK# to match each DN's SEQ#
 *
 * packets from DN to CLIENT
 * on SYN+ACK: 1) [EGRESS] store SEQ# (difference between SEQ# & 0) of all DNs
 *             2) wait until all DNs to reply
 *             3) reply SYN+ACK to client with seq#0
 * on ACK(data): 1) if not index-expected, drop it
 *               2) if it's the 1st,
 *        calculate the calibrated SEQ# and store data
 *                  if it's the 2nd,
 *        data xor
 *                  if it's the 3rd,
 *        data xor and send out (with right SEQ#), index-expected++
 */

/**************************************************/
/**************** INGRESS pipeline ****************/
control ingress {

	if(tcp.dstPort == NETEC_DN_PORT){
		/* packets from client
		 * always multicast to all datanodes
		 */
		if(tcp.flags == TCP_FLAG_SYN){
			/* SYN
			 * do nothing
			 */
		}else{
			/* ACK or PSH+ACK
			 * do nothing in INGRESS
			 * [EGRESS] modify ACK# to match each DN's SEQ#
			 */
		}
		apply(t_multicast);
	}
	if(tcp.srcPort == NETEC_DN_PORT){
		/* packets from DNs */
		if(tcp.flags == TCP_FLAG_SA){
			/* SYN + ACK */
			apply(t_sa_count);
			if(meta.sa_finish == 1){
				apply(t_seq_zero);
			}
		}
		if(tcp.flags == TCP_FLAG_ACK and valid(netec)){
			if(netec.type_ == 0){
				/* data packets */
				apply(t_prepare_paras);
				xor();
				apply(t_finish);
				if(meta.flag_finish == 1){
					apply(t_send_res);
					apply(t_cksum_compensate);
				}
				else{
					apply(t_drop_table);
				}
			}
		}
	}

	/* UDP version */
	// if(valid(netec)){
	// 	apply(t_get_coeff);
	// 	/*
	// 	if(netec.data_0 != 0){
	// 		apply(t_get_log);
	// 		apply(t_log_add);
	// 		apply(t_get_ilog);
	// 		apply(t_record);
	// 	}
	// 	*/
	// 	gf_multiply();
	// 	/* data */
	// 	if(netec.type_ == 0){
	// 		xor();
	// 		apply(t_finish);
	// 		if(meta.flag_finish == 1){
	// 			apply(t_send_res);
	// 			apply(t_cksum_compensate);
	// 		}
	// 		else{
	// 			apply(t_drop_table);
	// 		}
	// 	}
	// }


}

/**************************************************/
/***** tables and actions for EGRESS pipeline *****/
/* use egress_port to identify target DN
 * in order to read target DN's SEQ#
 */
table t_use_target_as_dn_port{
	actions{ a_use_target_as_dn_port; }
	default_action : a_use_target_as_dn_port();
}
action a_use_target_as_dn_port(){
	modify_field(meta.dn_port_for_seq, eg_intr_md.egress_port);
}
/* use ingress_port to identify source DN
 * in order to read source DN's SEQ#
 */
table t_use_src_as_dn_port{
	actions{ a_use_src_as_dn_port; }
	default_action : a_use_src_as_dn_port();
}
action a_use_src_as_dn_port(){
	modify_field(meta.dn_port_for_seq, ig_intr_md.ingress_port);
}
/* write DN's SEQ# if TCP SYN+ACK
 * read initial SEQ# if not SYN+ACK
 */
table t_dn_rs_seq{
	reads{
		/* ND's port number */
		meta.dn_port_for_seq : exact;
	}
	actions{ a_dn_rs_seq; a_nop; }
	default_action : a_nop();
}
action a_dn_rs_seq(dn_index){
	s_rs_seq.execute_stateful_alu(dn_index);
}
register r_dn_rs_seq{
	width : 32;
	instance_count : DN_COUNT; /* the number of DNs */
}
blackbox stateful_alu s_rs_seq{
	reg : r_dn_rs_seq;
	condition_lo : meta.sa_from_dn == 1;
	/* if TCP SYN+ACK from DN, store seq# */
	update_lo_1_predicate : condition_lo;
	update_lo_1_value : tcp.seqNo;
	/* else, read only */
	update_lo_2_predicate : not condition_lo;
	update_lo_2_value : register_lo;

	output_value : alu_lo;
	output_dst : meta.dn_init_seq;
}
/* modify ACK# for packets from client to DNs */
table t_modify_ack_to_DNs{
	actions{ a_modify_ack_to_DNs; }
	default_action : a_modify_ack_to_DNs();
}
action a_modify_ack_to_DNs(){
	add_to_field(tcp.ackNo, meta.dn_init_seq);
}
/* modify SEQ# for packets from DNs to client */
table t_modify_seq_to_client{
	actions{ a_modify_seq_to_client; }
	default_action : a_modify_seq_to_client();
}
action a_modify_seq_to_client(){
	subtract_from_field(tcp.seqNo, meta.dn_init_seq);
}

table t_drop_table {
	actions {
		a_drop;
	}
	default_action : a_drop();
	size : 1;
}
table t_modify_ip{
	reads{
		eg_intr_md.egress_port : exact;
	}
	actions{ a_modify_ip; a_drop; }
	default_action : a_drop();
	size : 32;
}
action a_modify_ip(ip, mac){
	modify_field(ipv4.dstAddr, ip);
	modify_field(ethernet.dstAddr, mac);
}

/*************************************************/
/**************** EGRESS pipeline ****************/
control egress {
	/***************** store or read DNs' SEQ# *****************/
	/* if packets from DNs */
	if(tcp.srcPort == NETEC_DN_PORT){
		/* packets from DNs */
		if(tcp.flags == TCP_FLAG_SA){
			/* SYN + ACK */
			/* mark that we need to store the SEQ# */
			apply(t_mark_sa_from_dn);
		}
	}
	/* SEQ# of DNs */
	if(tcp.dstPort == NETEC_DN_PORT){
		/* from client */
		apply(t_use_target_as_dn_port);
	}else if(tcp.srcPort == NETEC_DN_PORT){
		/* from DNs */
		apply(t_use_src_as_dn_port);
	}
	/* read/store SEQ#
	 * read when packets are from client (read all three of them)
	 *   or when the packet is from DNs and is not SYN+ACK
	 * store when the packet is from DNs and is SYN+ACK
	 */
	apply(t_dn_rs_seq);
	/* modify ACK# to match each DN's SEQ# when multicasting */
	if(tcp.dstPort == NETEC_DN_PORT and tcp.flags != TCP_FLAG_SYN){
		/* packets from client, needs to modify ACK# */
		apply(t_modify_ack_to_DNs);
	}
	/* modify SEQ# to match initial SEQ#(0) when sending data */
	if(meta.flag_finish == 1){
		apply(t_modify_seq_to_client);
	}

	/* modify dst_ip and dst_mac
	 * according to egress port
	 */
	apply(t_modify_ip);
}


