# f1-lfsw01.cfg

## 1. Console での設定

`username admin` でログインして下記コマンドで zerotouch を止める

```sh
enable
zerotouch cancel
```

自動で再起動されるので待って、`username admin` でログインして下記コマンド(例)で管理ポートを設定する (IPは環境によって変更する)

```sh
enable
!
!
conf t
!
hostname f1-lfsw01
!
username admin secret arista
!
vrf instance MGMT
!
interface Management 1
vrf MGMT
ip address 192.168.129.63/24
ip route vrf MGMT 0.0.0.0/0 192.168.129.254
!
end
```

## 2. SSH での残り設定流しこみ

SSH でログインが可能になるので `ssh admin@192.168.129.63` でログインして残りの設定を流し込む

```sh
enable
!
conf t
!
service routing protocols model multi-agent
!
enable password arista
!
vlan 100
   name TENANT1-SERVER-SEG1
!
vlan 200
   name TENANT1-SERVER-SEG2
!
vrf instance TENANT1
!
interface Ethernet1
   description tenant1-server01 eth0
   switchport trunk allowed vlan 100
   switchport mode trunk
!
interface Ethernet2
   description tenant1-server03 eth0
   switchport mode trunk
!
interface Ethernet3
   description f1-spsw02 Eth1
   mtu 9214
   no switchport
   ip address 192.168.4.1/30
   ip ospf network point-to-point
   ip ospf area 0.0.0.0
!
interface Ethernet4
   description f1-spsw01 Eth1
   mtu 9214
   no switchport
   ip address 192.168.3.1/30
   ip ospf network point-to-point
   ip ospf area 0.0.0.0
!
interface Loopback0
   ip address 192.168.0.1/32
   ip ospf area 0.0.0.0
!
interface Loopback1
   ip address 192.168.1.1/32
   ip ospf area 0.0.0.0
!
interface Vlan100
   vrf TENANT1
   ip address virtual 172.16.0.254/24
!
interface Vlan200
   vrf TENANT1
   ip address virtual 172.16.1.254/24
!
interface Vxlan1
   vxlan source-interface Loopback1
   vxlan udp-port 4789
   vxlan vlan 100 vni 10100
   vxlan vlan 200 vni 10200
   vxlan vrf TENANT1 vni 19001
!
ip virtual-router mac-address 00:1c:73:00:09:99
!
ip routing
ip routing vrf TENANT1
!
router bgp 65001
   router-id 192.168.0.1
   no bgp default ipv4-unicast
   timers bgp 10 30
   neighbor RR peer group
   neighbor RR remote-as 65001
   neighbor RR update-source Loopback0
   neighbor RR send-community extended
   neighbor 192.168.0.253 peer group RR
   neighbor 192.168.0.254 peer group RR
   !
   vlan-aware-bundle L2VNI
      rd 65001:19000
      route-target both 65001:19000
      redistribute learned
      vlan 100-199
   !
   address-family evpn
      neighbor RR activate
   !
   vrf TENANT1
      rd 65001:19001
      route-target import 65001:19001
      route-target export 65001:19001
      router-id 192.168.0.1
      redistribute connected
      redistribute static
!
router ospf 1
   router-id 192.168.0.1
!
end
```

設定を保存して再起動する

```sh
copy running-config startup-config 

reload
```
