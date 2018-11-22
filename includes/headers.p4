
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

header_type netec_t{
	fields {
		index : 16 ;
		data_0 : 8;
		data_1 : 8;
		data_2 : 8;
		data_3 : 8;
		data_4 : 8;
		data_5 : 8;
		data_6 : 8;
		data_7 : 8;
		data_8 : 8;
		data_9 : 8;
		data_10 : 8;
		data_11 : 8;
		data_12 : 8;
		data_13 : 8;
		data_14 : 8;
		data_15 : 8;
	}
}
header netec_t netec;


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
        	res : 4;
        	flags : 3;
		ack: 1;
		psh: 1;
		rst: 1;
		syn: 1;
		fin: 1;		 
		window : 16;
		checksum : 16;
		urgentPtr : 16;
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
