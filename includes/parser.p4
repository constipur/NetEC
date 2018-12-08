
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
		IP_PROT_TCP : parse_tcp;
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

/* server (sending data) port 20001 */
#define TCP_SPORT_NETEC NETEC_DN_PORT
parser parse_tcp {
	extract(tcp);
	set_metadata(meta.cksum_compensate, 0);
	return select(tcp.srcPort, tcp.flags){
		/* srcPort == 20001
		 * carrying data
		*/
		TCP_SPORT_NETEC, TCP_FLAG_ACK : parse_netec;
		TCP_SPORT_NETEC, TCP_FLAG_PA : parse_netec;
		TCP_SPORT_NETEC, TCP_FLAG_SA : ingress;
		default: ingress;
	}
}


parser parse_netec {
	extract(netec);
	return ingress;
}


