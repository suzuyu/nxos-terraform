# env cml vni dualstack

## 概要

CML で構築された既存 EVPN+VXLAN 構築済み環境に Overlay を追加して IaC 管理する

`../vni/` 試験後に module (`"../../../modules/nxos_l3vni`, `"../../../modules/nxos_l2vni`) を DualStack 対応したので Overlay を IPv4 + IPv6 パラメータにして試したテスト設定を残す

## 概要図

![cml図](./images/nxos_vxlan_overlay_dualstack_cml図.png)

IPv6 を試す上で、すべてのサーバノードは `Ubuntu` ノードで作成している

leaf セットはどちらも vPC にしており、サーバは LACP で接続している

bdsw01 は使用してない (電源OFFにして試験している)

## CML 設定

下記ファイルが VNI 設定前の CML 設定ファイル

`../cml_yaml/leaf_spine/Leaf-Spine-Test4_VNI_Before.yaml`

設定後は下記の設定

`../cml_yaml/leaf_spine/Leaf-Spine-Test4_VNI_After.yaml`

## 設定パラメータ

`./terraform.tfvars`
