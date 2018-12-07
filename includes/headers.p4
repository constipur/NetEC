
header_type ethernet_t {
	fields {
	dstAddr : 48;
	srcAddr : 48;
	etherType : 16;
	}
}
header ethernet_t ethernet;

header_type ipv4_t {
	fields {
	version : 4;
	ihl : 4;
	diffserv : 8;
	totalLen : 16;
	identification : 16;
	flags : 3;
	fragOffset : 13;
	ttl : 8;
	protocol : 8;
	hdrChecksum : 16;
	srcAddr : 32;
	dstAddr: 32;
	}
}
header_type udp_t {
    fields {
        srcPort : 16;
        dstPort : 16;
        length_ : 16;
        checksum : 16;
    }
}
header udp_t udp;


header ipv4_t ipv4;

field_list ipv4_checksum_list {
	ipv4.version;
	ipv4.ihl;
	ipv4.diffserv;
	ipv4.totalLen;
	ipv4.identification;
	ipv4.flags;
	ipv4.fragOffset;
	ipv4.ttl;
	ipv4.protocol;
	ipv4.srcAddr;
	ipv4.dstAddr;
}
field_list_calculation ipv4_checksum {
	input {
		ipv4_checksum_list;
	}
	algorithm : csum16;
	output_width : 16;
}

calculated_field ipv4.hdrChecksum  {
	verify ipv4_checksum;
	update ipv4_checksum;
}


header_type tcp_t {
	fields {
		srcPort : 16;
		dstPort : 16;
		seqNo : 32;
		ackNo : 32;
		dataOffset : 4;
        res : 6;
        flags : 6;
		window : 16;
		checksum : 16;
		urgentPtr : 16;
		// dirty implementation
		// tcp options
		option_nop : 16;
		option_ts : 80;
    }
}
header tcp_t tcp;

field_list udp_checksum_list {
        ipv4.srcAddr;
        ipv4.dstAddr;
		//TOFINO: A bug about alignments, the eight zeroes seem not working. We comment out the protocol field (often unchanged) to get around this bug. The TCP checksum now works fine.
        //8'0;
        //ipv4.protocol;
        //meta.tcpLength;
        udp.srcPort;
		udp.dstPort;
		udp.length_;
		meta.cksum_compensate;
		meta.cksum_compensate;
		meta.cksum_compensate;
		//netec.index;
		//netec.data;
        payload;
}

field_list_calculation udp_checksum {
    input {
        udp_checksum_list;
    }
    algorithm : csum16;
    output_width : 16;
}
/*
calculated_field udp.checksum {
	//TOFINO: We cannot add if here on tofino, neither can we do the "verify tcp_checksum" thing, because we cannot access payloads. On the other hand, we can verify ip checksums.
	update udp_checksum;
}
*/

