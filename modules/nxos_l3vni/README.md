# nxos_l3vni

## 概要

[NX OS Provider](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs) を使用した L3VNI の設定投入 module

下記を構築する

- vni 所属の vlan
  - 機器ごとに変更可能
- vni 所属の vrf
  - import/export は bouth auto で設定する
- SVI
  - vrf と ip forward で設定する
- nve への vni 追加
  - associate-vrf で設定
- router bgp へ vrf の追加と direct 再配送
  - AS は `65001` で設定する. `variables.tf` の default 設定もしくは呼び出し時に変更可能
  - `permit-all-v4` という route-map で許可する(要事前設定).  `variables.tf` の default 設定もしくは呼び出し時に変更可能

## 前提

- `feature nxapi` が機器側で設定済み
- VPN+VXLAN でアンダーレイとコントールプレーンの構築が構築済み
  - `router bgp` を l2vpn evpn で構築済み
    - AS は 65001 が前提. `variables.tf` の default 設定もしくは呼び出し時に変更可能
  - `interface nve1` を構築済み
  - direct (connected) の IP を再配送するために `route-map` が設定済みであること
    - `permit-all-v4` という route-map が前提で `variables.tf` の default 設定もしくは呼び出し時に変更可能
      - 設定例は下記
        - `ip prefix-list all-v4 seq 10 permit 0.0.0.0/0 ge 1 le 32`
        - `route-map permit-all-v4 permit 100`
        - `match ip address prefix-list all-v4`
    - IPv6 の場合も IPv4 同様な route-map を前提にしている
      - 設定例は下記
        - `ipv6 prefix-list all-v6 seq 10 permit 0::/0 ge 1 le 128`
        - `route-map permit-all-v6 permit 100`
        - `match ipv6 address prefix-list all-v6`

## パラメータ例

### module 利用パラメータ

```tfvars
vni = 29001
vrf = "tenant2-vpc1"
# dualstack_enable = true
members = {
  lfsw01 = {
    vlan = "3002"
  }
  lfsw02 = {
    vlan = "3002"
  }
  lfsw03 = {
    vlan = "3002"
  }
}
```

### Provider 設定例

```tf
provider "nxos" {
  username = "admin"
  password = "cisco"
  devices = [
    {
      name = "lfsw01"
      url  = "https://192.168.129.51"
    },
    {
      name = "lfsw02"
      url  = "https://192.168.129.52"
    },
    {
      name = "lfsw03"
      url  = "https://192.168.129.53"
    },
  ]
}
```

## 投入 Config CLI 例

上記パラメータで設定される設定の CLI での例

```config:leaf1_2
conf t
!
vlan 3002
  name tenant2-vpc1-l3vni
  vn-segment 29001
!
vrf context tenant2-vpc1
  vni 29001
  rd auto
  address-family ipv4 unicast
    route-target both auto
    route-target both auto evpn
!
interface Vlan3002
  no shutdown
  vrf member tenant2-vpc1
  ip forward
!
interface nve1
  member vni 29001 associate-vrf
!
router bgp 65001
  vrf tenant2-vpc1
    address-family ipv4 unicast
      redistribute direct route-map permit-all-v4
!
end
```

## 補足

nxos provider v0.5.8 時点では Interface への IPv6 設定モジュールが見当たらないため、REST モジュールでの対応をしている
