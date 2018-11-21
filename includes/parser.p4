
parser start {
	return  parse_ethernet;
}

#define ETHERTYPE_IPV4 0x0800

parser parse_ethernet {
	extract(ethernet);
	return select(latest.etherType) {
		ETHERTYPE_IPV4 : parse_ipv4;
		default: ingress;
	}
}

#define IP_PROT_TCP 0x06
#define IP_PROT_UDP 0x11

parser parse_ipv4 {
	extract(ipv4);
	return select(ipv4.protocol) {
		//IP_PROT_TCP : parse_tcp;
		IP_PROT_UDP : parse_udp;
		default: ingress;
	}
	
}

#define UDP_DPORT_NETEC 20000
parser parse_udp {
	extract(udp);
	set_metadata(meta.cksum_compensate,0);
	return select(udp.dstPort){
		UDP_DPORT_NETEC : parse_netec;
		default: ingress;
	}
}

parser parse_netec {
	extract(netec);
	return ingress;
}


