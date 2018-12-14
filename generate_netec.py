# Autogen xor buffer tables and related modules

def main():
    count = 45
    print """
header_type netec_t{
	fields {
        type_ : 16;
		index : 32;""",
    for i in range(count):
        print """
        data_%s : 32;""" % (i),
    print """
	}
}
header netec_t netec;
""",
    print """
field_list l4_with_netec_list_udp {
	ipv4.srcAddr;
    ipv4.dstAddr;
	meta.l4_proto;
	udp.srcPort;
	udp.dstPort;
	udp.length_;
	netec_meta.index;
	netec_meta.type_;
""",
    for i in range(count):
        print"""
	netec_meta.res_%s;
""" %(i),
    print """
	meta.cksum_compensate;
}""",
    print """
field_list l4_with_netec_list_tcp {
	ipv4.srcAddr;
    ipv4.dstAddr;
	meta.l4_proto;
    meta.tcpLength;
	tcp.srcPort;
	tcp.dstPort;
    tcp.seqNo;
    tcp.ackNo;
	tcp.dataOffset;
    tcp.res;
    tcp.flags;
	tcp.window;
	tcp.urgentPtr;
	netec_meta.index;
	netec_meta.type_;""",
    for i in range(count):
        print """
    netec_meta.res_%s;
""" %(i),
    print """
	meta.cksum_compensate;
}
field_list_calculation l4_with_netec_checksum {
    input {
        l4_with_netec_list_tcp;
    }
    algorithm : csum16;
    output_width : 16;
}

calculated_field tcp.checksum  {
	update l4_with_netec_checksum;
	verify l4_with_netec_checksum;
}""",
    for i in range(count):
        s = """
// AUTOGEN
register r_xor_%s{
	width : 16;
	instance_count : 65536;
}
blackbox stateful_alu s_xor_%s{
	reg : r_xor_%s;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ netec.data_%s;

    update_hi_1_value : register_lo ^ netec.data_%s;
	output_value : alu_hi;
	output_dst : netec_meta.res_%s;
}
table t_xor_%s{
	actions{a_xor_%s;}
	default_action : a_xor_%s();
}
action a_xor_%s(){
	s_xor_%s.execute_stateful_alu(meta.index);
}
""" % (i, i, i, i, i, i, i, i, i, i, i)
        print s,
    print """
control xor {
""",
    for i in range (count):
        s = """
    apply(t_xor_%s);""" % (i)
        print s,
    print """
}
""",

    print """
action fill_netec_fields(){
    """,
    for i in range(count):
        s = """
    modify_field(netec.data_%s, netec_meta.res_%s);
""" % (i, i)
        print s,
    print """
}
""",

    print """
header_type netec_meta_t{
	fields{
        type_ : 16;

		index : 32;
        temp : 16;
""",
    for i in range(count):
        print """
        res_%s : 32;
        // temp_%s : 32;
""" % (i, i),
    print """
    }
}
""",


if __name__ == '__main__':
    main()

