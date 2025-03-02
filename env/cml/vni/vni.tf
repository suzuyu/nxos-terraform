module "l3vni" {
  source   = "../../../modules/nxos_l3vni"
  for_each = var.l3vni_map

  vni = each.value.vni
  vrf = each.value.vrf

  members = each.value.members
}

module "l2vni" {
  source   = "../../../modules/nxos_l2vni"
  for_each = var.l2vni_map

  vni = each.value.vni
  vrf = each.value.vrf

  segment_name = each.value.segment_name
  gateway_ip   = each.value.gateway_ip

  members = each.value.members

  depends_on = [
    module.l3vni,
  ]
}

# Save 対象のリスト作成
locals {
  l2vni_devices = flatten([
    for k, v in var.l2vni_map : [
      for k, v in v.members : k
    ]
  ])

  l3vni_devices = flatten([
    for k, v in var.l3vni_map : [
      for k, v in v.members : k
    ]
  ])
}

# 機器で設定の保存 (`copy running-config startup-config`)
# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/save_config
resource "nxos_save_config" "main" {
  for_each = toset(concat(local.l2vni_devices, local.l3vni_devices))

  device   = each.value

  depends_on = [
    module.l2vni,
    module.l3vni,
  ]
}
