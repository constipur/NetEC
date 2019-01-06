# Autogen xor buffer tables and related modules

def print_header_t(netec_header, data_max_width, total_data_width):
    # header name
    print """
header_type netec_t{
\tfields {"""
    # headers
    for (name, size) in netec_header:
        print "\t\t" + name + " : " + str(size) + ";"
    # datas
    available_data_width = total_data_width
    data_unit_count = 0
    while available_data_width > 0:
        data_width = min(data_max_width, available_data_width)
        print "\t\tdata_" + str(data_unit_count) + " : " + str(data_width) + ";"
        available_data_width = available_data_width - data_width
        data_unit_count = data_unit_count + 1
    # end
    print """
\t}
}
header netec_t netec;
"""
    return data_unit_count

def print_checksum(header, data_unit_count):
#     # udp
#     print """
# field_list l4_with_netec_list_udp {
# \tipv4.srcAddr;
# \tipv4.dstAddr;
# \t//TOFINO: A bug about alignments, the eight zeroes seem not working. We comment out the protocol field (often unchanged) to get around this bug. The TCP checksum now works fine.
# \t//8'0;
# \t//ipv4.protocol;
# \tmeta.l4_proto;
# \tudp.srcPort;
# \tudp.dstPort;
# \tudp.length_;
# \tnetec.offsetInBlock;
# \tnetec.index;
# \tnetec.tlastPacket;
# \tnetec.tdataLen;
# """
    # for i in range(count):
    #     print """\t%s;""" % netec_data_instance_name(i)

    # print """\tmeta.cksum_compensate;\n}"""

    # tcp
    print """
field_list l4_with_netec_list_tcp {
\tipv4.srcAddr;
\tipv4.dstAddr;
\tmeta.l4_proto;
\tmeta.tcpLength;
\ttcp.srcPort;
\ttcp.dstPort;
\ttcp.seqNo;
\ttcp.ackNo;
\ttcp.dataOffset;
\ttcp.res;
\ttcp.flags;
\ttcp.window;
\ttcp.urgentPtr;
\tsack1.nop1;
\tsack1.sack_l;
\tsack1.sack_r;
\tsack2.sack_l;
\tsack2.sack_r;
\tsack3.sack_l;
\tsack3.sack_r;"""

    # netec header
    for (name, size) in header:
        print "\tnetec." + name + ";"

    # netec data
    for i in range(data_unit_count):
        print "\tnetec.data_" + str(i) + ";"

    print "\n}"
    print """
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
}"""

def print_xor(data_max_width, total_data_width, data_unit_num):
    available_data_width = total_data_width
    i = 0
    for i in range(data_unit_num):
        data_width = min(data_max_width, available_data_width)
        meta_name = "netec.data_" + str(i)
        stage = 11 - (data_unit_num - i) / 4
        print """
// Calculation Unit %s
register r_xor_%s{
	width : %s;
	instance_count : 32768;
}
blackbox stateful_alu s_xor_%s{
	reg : r_xor_%s;
    condition_lo : meta.flag_finish == 1;
    update_lo_1_predicate : condition_lo; /* the third packet */
	update_lo_1_value : 0;
    update_lo_1_predicate : not condition_lo; /* the first/second packet */
	update_lo_1_value : register_lo ^ %s;

    update_hi_1_value : register_lo ^ %s;
	output_value : alu_hi;
	output_dst : %s;
}
@pragma stage %s
table t_xor_%s{
	actions{a_xor_%s;}
	default_action : a_xor_%s();
    size : 1;
}
action a_xor_%s(){
	s_xor_%s.execute_stateful_alu(netec.index);
}
""" % (i, i, data_width, i, i, meta_name, meta_name, meta_name, stage, i, i, i, i, i)
        available_data_width = available_data_width - data_width
    print """
control xor {"""
    for i in range (data_unit_num):
        print """\tapply(t_xor_%s);""" % (i)
    print "}"


def main():
    # packet size in byte
    packet_size = 128
    # calculation unit size in bit
    data_max_width = 32
    netec_header = (
        ("unimportant0", 32),
        ("unimportant1", 16),
        ("index", 16)
    )
    # calculate header length
    header_size = 0
    for (name, size) in netec_header:
        header_size += size / 8


    print """// AutoGen\n"""
    print """#define TCP_OPTION_MSS_COMPENSATE 0x0204%04X /* MSS %d */""" % (packet_size, packet_size)
    print """#define NETEC_IPV4_LENGTH %d /* NETEC %d + IPV4_HEADER 20 + TCP_HEADER 20 */""" % (packet_size + 40, packet_size)

    data_unit_count = print_header_t(netec_header, data_max_width, (packet_size - header_size) * 8)
    print_checksum(netec_header, data_unit_count)
    print_xor(data_max_width, (packet_size - header_size) * 8, data_unit_count)




if __name__ == '__main__':
    main()

