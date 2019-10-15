################################################################################
# BAREFOOT NETWORKS CONFIDENTIAL & PROPRIETARY
#
# Copyright (c) 2018-2019 Barefoot Networks, Inc.

# All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains the property of
# Barefoot Networks, Inc. and its suppliers, if any. The intellectual and
# technical concepts contained herein are proprietary to Barefoot Networks,
# Inc.
# and its suppliers and may be covered by U.S. and Foreign Patents, patents in
# process, and are protected by trade secret or copyright law.
# Dissemination of this information or reproduction of this material is
# strictly forbidden unless prior written permission is obtained from
# Barefoot Networks, Inc.
#
# No warranty, explicit or implicit is provided, unless granted under a
# written agreement with Barefoot Networks, Inc.
#
#
###############################################################################

import logging
import time

from ptf import config
import ptf.testutils as testutils
from bfruntime_base_tests import BfRuntimeTest
import bfrt_grpc.bfruntime_pb2 as bfruntime_pb2

logger = logging.getLogger('Test')
if not len(logger.handlers):
    logger.addHandler(logging.StreamHandler())

swports = []
for device, port, ifname in config["interfaces"]:
    swports.append(port)
    swports.sort()
    print(device, port, ifname)

if swports == []:
    swports = range(9)

fp_ports = ["1/0","2/0","3/0", "4/0"]

class NotATest(BfRuntimeTest):
    def setUp(self):
        client_id = 0
        p4_name = "tna_advance"
        BfRuntimeTest.setUp(self, client_id, p4_name)
        try:
            for fpPort in fp_ports:
                port, chnl = fpPort.split("/")
                devPort = \
                    self.pal.pal_port_front_panel_port_to_dev_port_get(0,
                                                                    int(port),
                                                                    int(chnl))
                self.devPorts.append(devPort)

            if test_param_get('setup') == True or (test_param_get('setup') != True
                and test_param_get('cleanup') != True):

                # add and enable the platform ports
                for i in self.devPorts:
                    self.pal.pal_port_add(0, i,
                                        pal_port_speed_t.BF_SPEED_40G,
                                        pal_fec_type_t.BF_FEC_TYP_NONE)
                    self.pal.pal_port_enable(0, i)
                self.conn_mgr.complete_operations(self.sess_hdl)
        except Exception as e:
            print(e)
            pass
        print("SetUp Finished!")

    def runTest(self):
        ig_port = swports[1]
        eg_port = swports[2]
        smac = '11:33:55:77:99:00'
        smac_mask = 'ff:ff:ff:ff:ff:ff'
        dmac = '00:11:22:33:44:55'

        while(True):
            pass

        # Get bfrt_info and set it as part of the test
        # self.set_bfrt_info(self.parse_bfrt_info(self.get_bfrt_info("tna_operations")))
