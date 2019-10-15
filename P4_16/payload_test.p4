#include <core.p4>
#include <tna.p4>
#include "common/util.p4"
#include "common/headers.p4"

struct metadata_t {
    bit<16> checksum;
    bit<16> temp;
    bit<1> resubmitted;
}

// ingress: advance(20) and parse payload, then put all parsed bits to 0
// egress: advance(120) and parse payload, then put all parsed bits to 0


// ---------------------------------------------------------------------------
// custom header
// ---------------------------------------------------------------------------
const ip_protocol_t IP_PROTOCOLS_MY_PAYLOAD = 99;
header payload_0_h {
    bit<32> c0;
    bit<32> c1;
    bit<32> c2;
    bit<32> c3;
}
header payload_1_h {
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
    bit<128> e2;
    bit<128> e3;
}


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
    
    Checksum<bit<16>>(HashAlgorithm_t.CSUM16) csum;
    TofinoIngressParser() tofino_parser;

    state start {
        tofino_parser.apply(pkt, ig_intr_md);
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
      
        transition select(hdr.ipv4.total_len) {
            1500: parse_tcp;
            default : accept;
        }
    }

    state parse_tcp {
        pkt.extract(hdr.tcp);
        //csum.subtract({hdr.tcp.urgent_ptr});
        //csum.add({hdr.tcp.checksum});
        //csum.subtract({hdr.tcp.dst_port});
        //ig_md.checksum = csum.get();
        transition accept;
    }

    state parse_my_payload {
        //pkt.advance(1536); // 300 bytes
        pkt.extract(hdr.payload_1);
        //csum.subtract({hdr.payload_1.c0});
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

    apply {
        to_eg.apply();
        ttl.apply();
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
    Checksum<bit<16>>(HashAlgorithm_t.CSUM16) csum;
    Checksum<bit<16>>(HashAlgorithm_t.CSUM16) ipv4_checksum;
    apply {
        /* only send out headers, not bridging metadata */
        
        //hdr.tcp.checksum = csum.update({hdr.tcp.dst_port,ig_md.checksum});
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



        if(ig_intr_dprsr_md.resubmit_type == 3w1){
            resubmit.emit();
        } 

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
