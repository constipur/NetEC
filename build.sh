#!/bin/bash
#created 2018.3 qiaoyi
#modified from wsh's script
#update 2018.11 qiaoyi to port from bf-sde-4-* to bf-sde-8-*
#update 2018.11 qiaoyi for NetEC

#build synproxy program

cd $SDE/pkgsrc/p4-build
make clean
echo 'clean done!'
./configure --prefix=$SDE_INSTALL --with-tofino enable_thrift=yes P4_PATH=$SDE/NetEC/main_netec.p4 P4_NAME=netec

make -j8
echo 'make done!'
make install
echo 'make install done!'
sed -e "s/TOFINO_SINGLE_DEVICE/netec/" $SDE/pkgsrc/p4-examples/tofino/tofino_single_device.conf.in > $SDE_INSTALL/share/p4/targets/tofino/netec.conf
echo 'conf done!'
