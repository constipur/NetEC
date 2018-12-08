# NetEC - Simple TCP version

## Servers Set-up
10.0.0.3/101.6.30.128 (TOFINO port 136) as ***Java Client***

10.0.0.4/101.6.30.129 (TOFINO port 128) as ***Java Server*** on Port 20001

10.0.0.5/101.6.30.136 (TOFINO port 144) as ***Java Server*** on Port 20001

10.0.0.6/101.6.30.137 (TOFINO port 152) as ***Java Server*** on Port 20001

## Special Configuration
### 1. Disable TCP options on ***ALL 3 JAVA SERVERS***
Add lines below to disable TCP option (except for MSS)
```
net.ipv4.tcp_timestamps=0
net.ipv4.tcp_window_scaling=0
net.ipv4.tcp_sack=0
net.ipv4.tcp_fack=0
net.ipv4.tcp_syncookies=0
```
Activate the config above by ```sudo /sbin/sysctl -p```

### 2. Disable kernel TX offload on ***ALL 3 JAVA SERVERS***
```
sudo ethtool -K $IF_40GBE tx off
```

### 3. Modify adv_mss on ***ALL 4 HOSTS***
```
sudo ip route add/change 10.0.0.0/24 dev $IF_40GBE advmss 48
```

### 4. Set up arp table on ***ALL 4 HOSTS***
by *~/arp.sh*

### 5. Set up arp table entry for port connecting to TOFINO on ***JAVA CLIENT***
Here we use *10.0.0.10* (configurable in *BMPTransferClient.java*) as TOFINO's virtual IP address.

```
sudo arp -s 10.0.0.10 11:22:33:44:55:66
```

## Deployment
### 1. Compile and run P4 program on tofino (netec)
```
./run_switchd.sh -p netec
./run_p4_tests.sh -p netec -t NetEC/ctrl
```
### 2. Compile and run 3 JAVA SERVERS
```
javac BMPansferServer.java && javac BMPansferServer
```
### 2. Compile and start JAVA CLIENT
```
javac BMPansferClient.java && javac BMPansferClient
```
*SERVER_PORT*, *INPUT_FILE_NAME*, *PACKET_SIZE*, *FIELD_COUNT* can be configured in *BMPTransferServer.java*.
| Variable          | Default Value             | File Name            |
|-------------------|---------------------------|----------------------|
| *SERVER_ADDR*     | "10.0.0.10"               | BMPansferClient.java |
| *SERVER_PORT*     | 20001                     | BMPansferServer.java |
| *INPUT_FILE_NAME* | "/home/guest/qy/blue.bmp" | BMPansferServer.java |
| *PACKET_SIZE*     | 48                        | BMPansferServer.java |
| *FIELD_COUNT*     | 8                         | BMPansferServer.java |

***Special Notice***: *PACKET_SIZE* should be set to the same value as ADV_MSS.