# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs
terraform {
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = ">=0.5.8"
    }
  }
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bridge_domain
resource "nxos_bridge_domain" "main" {
  for_each     = var.members
  device       = each.key
  fabric_encap = "vlan-${each.value.vlan}"
  access_encap = "vxlan-${var.vni}"
  name         = "${var.vrf}-${var.segment_name}"
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/svi_interface
resource "nxos_svi_interface" "main" {
  for_each = { for k, v in var.members : k => v if var.gateway_ip != null }
  # for_each     = var.members
  device       = each.key
  interface_id = "vlan${each.value.vlan}"
  admin_state  = "up"
  description  = "${var.vrf}-${var.segment_name}"
  # mtu          = 9216

  depends_on = [
    nxos_bridge_domain.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/svi_interface_vrf
resource "nxos_svi_interface_vrf" "main" {
  for_each     = { for k, v in var.members : k => v if var.gateway_ip != null }
  device       = each.key
  interface_id = "vlan${each.value.vlan}"
  vrf_dn       = "sys/inst-${var.vrf}"

  depends_on = [
    nxos_svi_interface.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/hmm_interface
resource "nxos_hmm_interface" "main" {
  for_each     = { for k, v in var.members : k => v if var.gateway_ip != null }
  device       = each.key
  interface_id = "vlan${each.value.vlan}"
  admin_state  = "enabled"
  mode         = "anycastGW"

  depends_on = [
    nxos_svi_interface.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface
resource "nxos_ipv4_interface" "main" {
  for_each     = { for k, v in var.members : k => v if var.gateway_ip != null }
  device       = each.key
  vrf          = var.vrf
  interface_id = "vlan${each.value.vlan}"

  depends_on = [
    nxos_svi_interface.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface_address
resource "nxos_ipv4_interface_address" "main" {
  for_each     = { for k, v in var.members : k => v if var.gateway_ip != null }
  device       = each.key
  vrf          = var.vrf
  interface_id = "vlan${each.value.vlan}"
  address      = var.gateway_ip

  depends_on = [
    nxos_ipv4_interface.main,
  ]
}

# provider nx-os v0.5.8 時点で対応モジュールが見当たらなかったため REST で対応
# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest
resource "nxos_rest" "ipv6_dom" {
  for_each   = { for k, v in var.members : k => v if var.gateway_ipv6 != null }
  device     = each.key
  dn         = "sys/ipv6/inst"
  class_name = "ipv6Dom"
  content = {
    dn   = "sys/ipv6/inst/dom-default"
    name = "default"
    rn   = "dom-default"
  }

  depends_on = [
    nxos_hmm_interface.main,
  ]
}

# provider nxos v0.5.8 時点で対応モジュールが見当たらなかったため REST で対応
# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest
resource "nxos_rest" "ipv6_if" {
  for_each   = { for k, v in var.members : k => v if var.gateway_ipv6 != null }
  device     = each.key
  dn         = "sys/ipv6/inst/dom-default"
  class_name = "ipv6If"
  content = {
    autoconfig = "disabled"
    dn         = "sys/ipv6/inst/dom-default/if-[vlan${each.value.vlan}]"
    id         = "vlan${each.value.vlan}"
    rn         = "if-[vlan${each.value.vlan}]"
  }

  depends_on = [
    nxos_rest.ipv6_dom,
  ]
}

# provider nxos v0.5.8 時点で対応モジュールが見当たらなかったため REST で対応
# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest
resource "nxos_rest" "ipv6_addr" {
  for_each   = { for k, v in var.members : k => v if var.gateway_ipv6 != null }
  device     = each.key
  dn         = "sys/ipv6/inst/dom-default/if-[vlan${each.value.vlan}]/addr-[${var.gateway_ipv6}]"
  class_name = "ipv6Addr"
  content = {
    addr                  = var.gateway_ipv6
    aggregatePrefixLength = "unspecified"
    pref                  = "0"
    rn                    = "addr-[${var.gateway_ipv6}]"
    tag                   = "0"
    useBia                = "disabled"
  }

  depends_on = [
    nxos_rest.ipv6_dom,
    nxos_rest.ipv6_if,
  ]
}

# provider nxos v0.5.8 時点で対応モジュールが見当たらなかったため REST で対応
# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest
resource "nxos_rest" "ipv6_nd" {
  for_each   = { for k, v in var.members : k => v if var.gateway_ipv6 != null }
  device     = each.key
  dn         = "sys/nd/inst/dom-default"
  class_name = "ndIf"
  content = {
    ctrl = "suppress-ra"
    dn   = "sys/nd/inst/dom-default/if-[vlan${each.value.vlan}]"
    id   = "vlan${each.value.vlan}"
    rn   = "if-[vlan${each.value.vlan}]"
  }

  depends_on = [
    nxos_rest.ipv6_addr,
  ]
}


# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/nve_vni
resource "nxos_nve_vni" "main" {
  for_each      = var.members
  device        = each.key
  vni           = var.vni
  associate_vrf = false

  depends_on = [
    nxos_bridge_domain.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/nve_vni_ingress_replication
resource "nxos_nve_vni_ingress_replication" "main" {
  for_each = var.members
  device   = each.key
  vni      = var.vni
  protocol = "bgp"

  depends_on = [
    nxos_nve_vni.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/evpn_vni
resource "nxos_evpn_vni" "main" {
  for_each            = var.members
  device              = each.key
  encap               = "vxlan-${var.vni}"
  route_distinguisher = "rd:unknown:0:0"

  depends_on = [
    nxos_bridge_domain.main,
  ]
}

resource "nxos_evpn_vni_route_target_direction" "import" {
  for_each  = var.members
  device    = each.key
  encap     = "vxlan-${var.vni}"
  direction = "import"

  depends_on = [
    nxos_evpn_vni.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/evpn_vni_route_target
resource "nxos_evpn_vni_route_target" "import" {
  for_each     = var.members
  device       = each.key
  encap        = "vxlan-${var.vni}"
  direction    = "import"
  route_target = "route-target:unknown:0:0"

  depends_on = [
    nxos_evpn_vni_route_target_direction.import,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/evpn_vni_route_target_direction
resource "nxos_evpn_vni_route_target_direction" "export" {
  for_each  = var.members
  device    = each.key
  encap     = "vxlan-${var.vni}"
  direction = "export"
  depends_on = [
    nxos_evpn_vni.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/evpn_vni_route_target
resource "nxos_evpn_vni_route_target" "export" {
  for_each     = var.members
  device       = each.key
  encap        = "vxlan-${var.vni}"
  direction    = "export"
  route_target = "route-target:unknown:0:0"

  depends_on = [
    nxos_evpn_vni_route_target_direction.export,
  ]
}
