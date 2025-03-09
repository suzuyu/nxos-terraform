# f1-spsw01.cfg

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
hostname f1-spsw02
!
username admin secret arista
!
vrf instance MGMT
!
interface Management 1
vrf MGMT
ip address 192.168.129.62/24
ip route vrf MGMT 0.0.0.0/0 192.168.129.254
!
end
```

## 2. SSH での残り設定流しこみ

SSH でログインが可能になるので `ssh admin@192.168.129.62` でログインして残りの設定を流し込む

```sh
enable
!
conf t
!
enable password arista
!
interface Ethernet1
   description f1-lfsw01 Eth3
   mtu 9214
   no switchport
   ip address 192.168.4.2/30
   ip ospf network point-to-point
   ip ospf area 0.0.0.0
!
interface Ethernet2
   description f1-lfsw02 Eth3
   shutdown
   mtu 9214
   no switchport
   ip address 192.168.4.6/30
   ip ospf network point-to-point
   ip ospf area 0.0.0.0
!
interface Ethernet3
   description f1-bdsw01 Eth3
   mtu 9214
   no switchport
   ip address 192.168.4.10/30
   ip ospf network point-to-point
   ip ospf area 0.0.0.0
!
interface Ethernet4
   description f1-bdsw02 Eth4
   mtu 9214
   no switchport
   ip address 192.168.4.14/30
   ip ospf network point-to-point
   ip ospf area 0.0.0.0
!
interface Loopback0
   ip address 192.168.0.253/32
   ip ospf area 0.0.0.0
!
ip routing
!
router bgp 65001
   router-id 192.168.0.253
   no bgp default ipv4-unicast
   timers bgp 10 30
   bgp cluster-id 0.0.0.1
   neighbor VTEP peer group
   neighbor VTEP remote-as 65001
   neighbor VTEP update-source Loopback0
   neighbor VTEP route-reflector-client
   neighbor VTEP send-community extended
   neighbor 192.168.0.1 peer group VTEP
   neighbor 192.168.0.2 peer group VTEP
   neighbor 192.168.0.3 peer group VTEP
   neighbor 192.168.0.4 peer group VTEP
   !
   address-family evpn
      neighbor VTEP activate
!
router ospf 1
   router-id 192.168.0.253
!
end
```

設定を保存して再起動する

```sh
copy running-config startup-config 

reload
```
