# nxos_l2vni

## 概要

[NX OS Provider](https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs) を使用した L2VNI の設定投入 module

下記を構築する

- vni 所属の vlan
  - 機器ごとに変更可能
- SVI
  - anycast gateway で設定する
    - dualstackの場合は `ipv6 nd suppress-ra` を設定する
- nve への vni 追加
  - ingress-replication で設定
- evpn へ vni 追加
  - import/export は auto で設定する

## 前提

- `feature nxapi` が機器側で設定済み
- Gateway になる SVI 作成で `gateway_ip` を指定する場合は所属 `vrf` を事前構築済みであること
  - L2VPN のみで `gateway_ip` は不要の場合は `vrf` の事前作成は不要。`vrf` パラメータは各種 description の名前としてのみ使用する
  - IPv6 でのゲートウェイは `gateway_ipv6` で指定する (option)
  - vrf 作成は `../nxos_l3vni` で構築可能
- AnyCast Gateway 設定済みであること
  - 例： `fabric forwarding anycast-gateway-mac 2020.0000.00aa`

## パラメータ例

### module 利用パラメータ

```tfvars
vni = 20200
vrf = "tenant2-vpc1"

segment_name = "server-seg1"
gateway_ip   = "172.17.0.254/24"
# gateway_ipv6 = "fd12::1/64"

members = {
  lfsw01 = {
    vlan = "200"
  }
  lfsw02 = {
    vlan = "200"
  }
  lfsw03 = {
    vlan = "20"
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
vlan 200
  name tenant2-vpc1-server-seg1
  vn-segment 20200
!
interface Vlan200
  description tenant2-vpc1-server-seg1
  no shutdown
  vrf member tenant2-vpc1
  ip address 172.17.0.254/24
  fabric forwarding mode anycast-gateway
!
interface nve1
  member vni 20200
    ingress-replication protocol bgp
!
evpn
  vni 20200 l2
    rd auto
    route-target import auto
    route-target export auto
!
end
```

```config:leaf3
conf t
!
vlan 20
  name tenant2-vpc1-server-seg1
  vn-segment 20200
!
interface Vlan20
  description tenant2-vpc1-server-seg1
  no shutdown
  vrf member tenant2-vpc1
  ip address 172.17.0.254/24
  fabric forwarding mode anycast-gateway
!
interface nve1
  member vni 20200
    ingress-replication protocol bgp
!
evpn
  vni 20200 l2
    rd auto
    route-target import auto
    route-target export auto
!
end
```

## 補足

nxos provider v0.5.8 時点では Interface への IPv6 設定モジュールが見当たらないため、REST モジュールでの対応をしている
