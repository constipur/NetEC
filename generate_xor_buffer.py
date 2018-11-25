# Autogen xor buffer tables and related modules

def main():
    count = 1
    for i in range(count):
        s = """
// AUTOGEN
register r_xor_%s{
	width : 16;
	instance_count : 262144;
}
blackbox stateful_alu s_xor_%s{
	reg : r_xor_%s;
	update_lo_1_value : register_lo ^ netec.data_%s;
	output_value : alu_lo;
	output_dst : meta.netec_res_%s;
}
table t_xor_%s{
	actions{a_xor_%s;}
	default_action : a_xor_%s();
}
action a_xor_%s(){
	s_xor_%s.execute_stateful_alu(netec.index);
}
        """ % (i,i,i,i,i,i,i,i,i,i)
        print s,
    print """
control xor {
    """
    for i in range (count):
        s = """
    apply(t_xor_%s);
    """ % (i)
        print s,
    print """
}
    """

    print """
action fill_netec_fields(){
    """
    for i in range(count):
        s = """
    modify_field(netec.data_%s,meta.netec_res_%s);
    """ % (i,i)
        print s,
    print """
}
    """





if __name__ == '__main__':
    main()

