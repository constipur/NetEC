#include <core.p4>
#include <tna.p4>

header resubmit_h {
    bit<16> current_16_bit_sum;
    bit<16> initial_csum;
}


struct metadata_t {
    bit<16> checksum;
    resubmit_h resubmit_hdr;
    bit<16> temp;
    bit<16> tcp_length;
    bit<16> ip_proto_16;
    bit<1> csum_1;
    bit<1> csum_2;
}



// ingress: advance(20) and parse payload, then put all parsed bits to 0
// egress: advance(120) and parse payload, then put all parsed bits to 0


// ---------------------------------------------------------------------------
// custom header
// ---------------------------------------------------------------------------

header payload_0_h {
    bit<16> c0;
    bit<16> c1;
    bit<16> c2;
}
header payload_1_h {//160B
    bit<128> c0; 
    bit<128> c1;
    bit<128> c2;
    bit<128> c3;
    bit<128> d0;
    bit<128> d1;
    bit<128> d2;
    bit<128> d3;
    bit<128> e0;
    bit<128> e1;
}


#include "common/util.p4"
#include "common/headers.p4"

struct custom_header_t {
    ethernet_h ethernet;
    ipv4_h ipv4;
    tcp_h tcp;
    payload_0_h payload_0;
    payload_1_h payload_1;
}



// ---------------------------------------------------------------------------
// Ingress parser
// ---------------------------------------------------------------------------
parser SwitchIngressParser(
        packet_in pkt,
        out custom_header_t hdr,
        out metadata_t ig_md,
        out ingress_intrinsic_metadata_t ig_intr_md) {
    Checksum() tcp_checksum;

    state start {
        pkt.extract(ig_intr_md);
        transition select(ig_intr_md.resubmit_flag) {
            1 : parse_resubmit;
            0 : parse_port_metadata;
        }
    }

    state parse_resubmit {
        pkt.extract(ig_md.resubmit_hdr);
        //ig_md.checksum = ig_md.resubmit_hdr.current_16_bit_sum;
        transition parse_ethernet;
    }

    state parse_port_metadata {
#if __TARGET_TOFINO__ == 2
        pkt.advance(192);
#else
        pkt.advance(64);
#endif
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4 : parse_ipv4;
            ETHERTYPE_ARP : accept;
            default : accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition parse_tcp;
    }

    state parse_tcp {
        pkt.extract(hdr.tcp);
        
        transition select(hdr.ipv4.total_len) {
            680: parse_tcp0;
            default : accept;
        }
    }
    
    
    state parse_tcp0 {
        ig_md.temp = 1;
        transition select(hdr.ipv4.diffserv){
            3 : parse_tcp02;
            4 : parse_6;
            5 : accept;
            6 : accept;
            7 : accept;
            default : parse_tcp01;
        }
    }

    state parse_tcp01 {
        pkt.advance(1280);//160B
        pkt.extract(hdr.payload_0);
        transition accept;
    }

    state parse_tcp02 {
        pkt.advance(1232);//154B
        pkt.extract(hdr.payload_0);//for the final advance to take effect
        transition accept;
    }

    state parse_6{
        pkt.extract(hdr.payload_0);
        transition accept;
    }
}


// ---------------------------------------------------------------------------
// Ingress control flow
// ---------------------------------------------------------------------------
control SwitchIngress(
        inout custom_header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_intr_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_intr_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_intr_tm_md) {
    
    action a_to_128() {
        ig_intr_tm_md.ucast_egress_port = 128;  
    }
    action a_to_144() {
        ig_intr_tm_md.ucast_egress_port = 144;
    }

    action a_test() {
        hdr.ipv4.ttl = 60;
        //hdr.ipv4.identification = 0x1;
        ig_md.tcp_length = hdr.ipv4.total_len - 20;
        ig_md.ip_proto_16 = 8w0x0 ++ hdr.ipv4.protocol;
        
    }
    table to_eg {
        key = {
            ig_intr_md.ingress_port : exact;
        }
        actions = {
            a_to_144;
            a_to_128;
        }
        size = 1;
        const entries = {
            128 : a_to_144();
            144 : a_to_128();
        }
        default_action = a_to_128;
    }
    
    action a_ttl() {
        hdr.ipv4.ttl = hdr.ipv4.ttl -1  ;
        ig_intr_dprsr_md.resubmit_type = 3w0;        
    }
    action a_set_resubmit (){
        ig_intr_dprsr_md.resubmit_type = 3w1;
    }

    action a_recirc() {
        ig_intr_tm_md.ucast_egress_port = 160;  
        //hdr.payload_0.setInvalid();
        hdr.ipv4.diffserv = hdr.ipv4.diffserv + 1;  
    }

    action a_recirc2() {
        ig_intr_tm_md.ucast_egress_port = 160;  
        hdr.payload_0.setInvalid();
        hdr.ipv4.diffserv = hdr.ipv4.diffserv + 1;
    }

    action a_part_one() {
        ig_intr_tm_md.ucast_egress_port = 160; 
        hdr.payload_0.setInvalid(); 
        hdr.payload_1.setValid();
        hdr.payload_1.e1 = 1;
        hdr.ipv4.diffserv = hdr.ipv4.diffserv + 1;
        ig_md.csum_2 = 1;
        ig_md.csum_1 = 0;
    }

    action a_part_two() {
        ig_intr_tm_md.ucast_egress_port = 128;  
        hdr.payload_0.setInvalid();
        hdr.payload_1.setValid();
        hdr.payload_1.e1 = 1;
        hdr.ipv4.diffserv = 0;
        ig_md.csum_1 = 1;
        ig_md.csum_2 = 0;
    }

    table ttl{
        key = {
            ig_intr_md.resubmit_flag : exact;
        }
        actions = {
            a_set_resubmit;
            a_ttl;
        }
        const entries = {
            0 : a_set_resubmit();
            1 : a_ttl();
        }
        default_action = a_ttl;
    }

    action a_set_0(){
        ig_md.checksum = 0;
    }
    action a_set_neg(){
        ig_md.checksum = ~hdr.tcp.checksum;
        //hdr.ipv4.identification = ~hdr.tcp.checksum;
    }
    table t_cksum{
        key = {
            hdr.ipv4.diffserv : exact;
        }
        actions = {
            a_set_0;
            a_set_neg;
        }
        const entries = {
            4 : a_set_0();
        }
        default_action = a_set_neg;
    }



    apply {
        to_eg.apply();
        a_test();

        t_cksum.apply();


        if(ig_md.temp == 1){
            if(hdr.ipv4.diffserv < 3)
            {
                a_recirc();
            }
            else if (hdr.ipv4.diffserv == 3){
                a_recirc2();
            }
            else if(hdr.ipv4.diffserv < 7){
                a_part_one();
            }else {
                a_part_two();
            }
        }


        /*
        if (hdr.tcp.urgent_ptr < 3){
            a_part_one();
        }
        else{
            a_part_two();
        }
        */


        /*
        ttl.apply();
        if(hdr.payload_1.isValid()){
            a_test();
        }*/
    }
}



// ---------------------------------------------------------------------------
// Ingress deparser
// ---------------------------------------------------------------------------
control SwitchIngressDeparser(
        packet_out pkt,
        inout custom_header_t hdr,
        in metadata_t ig_md,
        in ingress_intrinsic_metadata_for_deparser_t ig_intr_dprsr_md) {
    Resubmit() resubmit;

    Checksum() csum;
    Checksum() tcp_checksum;
    Checksum() ipv4_checksum;
    apply {
        /*
        if(ig_intr_dprsr_md.resubmit_type == 3w1){
            resubmit.emit(ig_md.resubmit_hdr);
            //return here
        } */


        if(ig_md.csum_1 == 1){
            hdr.tcp.checksum = tcp_checksum.update(
                {
                    hdr.ipv4.src_addr,
                    hdr.ipv4.dst_addr,
                    ig_md.ip_proto_16,
                    ig_md.tcp_length,
                    
                    hdr.tcp.src_port,
                    hdr.tcp.dst_port,
                    hdr.tcp.seq_no,
                    hdr.tcp.ack_no,
                    hdr.tcp.data_offset,
                    hdr.tcp.res,
                    hdr.tcp.flags,
                    hdr.tcp.window,
                    hdr.tcp.urgent_ptr,

                    hdr.payload_1.c0,
                    hdr.payload_1.c1,
                    hdr.payload_1.c2,
                    hdr.payload_1.c3,
                    hdr.payload_1.d0,
                    hdr.payload_1.d1,
                    hdr.payload_1.d2,
                    hdr.payload_1.d3,
                    hdr.payload_1.e0,
                    hdr.payload_1.e1,

                    ig_md.checksum
                }
            );
        }
        if(ig_md.csum_2 == 1){
            hdr.tcp.checksum = tcp_checksum.update({
                ig_md.checksum,
                hdr.payload_1.c0,
                hdr.payload_1.c1,
                hdr.payload_1.c2,
                hdr.payload_1.c3,
                hdr.payload_1.d0,
                hdr.payload_1.d1,
                hdr.payload_1.d2,
                hdr.payload_1.d3,
                hdr.payload_1.e0,
                hdr.payload_1.e1
            });
        }
        
        hdr.ipv4.hdr_checksum = ipv4_checksum.update(
                {hdr.ipv4.version,
                 hdr.ipv4.ihl,
                 hdr.ipv4.diffserv,
                 hdr.ipv4.total_len,
                 hdr.ipv4.identification,
                 hdr.ipv4.flags,
                 hdr.ipv4.frag_offset,
                 hdr.ipv4.ttl,
                 hdr.ipv4.protocol,
                 hdr.ipv4.src_addr,
                 hdr.ipv4.dst_addr});

        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ipv4);
        pkt.emit(hdr.tcp);
        pkt.emit(hdr.payload_1);
        pkt.emit(hdr.payload_0);
    
    }
}



// ---------------------------------------------------------------------------
// Egress parser
// ---------------------------------------------------------------------------
parser SwitchEgressParser(
        packet_in pkt,
        out custom_header_t hdr,
        out metadata_t eg_md,
        out egress_intrinsic_metadata_t eg_intr_md) {

    TofinoEgressParser() tofino_parser;

    state start {
        tofino_parser.apply(pkt, eg_intr_md);
        transition accept;
    }
}


Pipeline(SwitchIngressParser(),
         SwitchIngress(),
         SwitchIngressDeparser(),
         SwitchEgressParser(),
         EmptyEgress<custom_header_t, metadata_t>(),
         EmptyEgressDeparser<custom_header_t, metadata_t>()) pipe;

Switch(pipe) main;
