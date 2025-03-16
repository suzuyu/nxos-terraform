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
  name         = "${var.vrf}-l3vni"
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf
resource "nxos_vrf" "main" {
  for_each = var.members
  device   = each.key
  name     = var.vrf
  encap    = "vxlan-${var.vni}"
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_routing
resource "nxos_vrf_routing" "main" {
  for_each            = var.members
  device              = each.key
  vrf                 = var.vrf
  route_distinguisher = "rd:unknown:0:0"

  depends_on = [
    nxos_vrf.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_address_family
resource "nxos_vrf_address_family" "main" {
  for_each       = var.members
  device         = each.key
  vrf            = var.vrf
  address_family = "ipv4-ucast"

  depends_on = [
    nxos_vrf_routing.main,
  ]
}
# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_address_family
resource "nxos_vrf_address_family" "main_ipv6" {
  for_each       = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device         = each.key
  vrf            = var.vrf
  address_family = "ipv6-ucast"

  depends_on = [
    nxos_vrf_routing.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_address_family
resource "nxos_vrf_route_target_address_family" "main" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"

  depends_on = [
    nxos_vrf_address_family.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_address_family
resource "nxos_vrf_route_target_address_family" "main_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "ipv6-ucast"

  depends_on = [
    nxos_vrf_address_family.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction
resource "nxos_vrf_route_target_direction" "import" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"
  direction                   = "import"

  depends_on = [
    nxos_vrf_route_target_address_family.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction
resource "nxos_vrf_route_target_direction" "import_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "ipv6-ucast"
  direction                   = "import"

  depends_on = [
    nxos_vrf_route_target_address_family.main,
  ]
}


# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target
resource "nxos_vrf_route_target" "import" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"
  direction                   = "import"
  route_target                = "route-target:unknown:0:0"

  depends_on = [
    nxos_vrf_route_target_direction.import,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target
resource "nxos_vrf_route_target" "import_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "ipv6-ucast"
  direction                   = "import"
  route_target                = "route-target:unknown:0:0"

  depends_on = [
    nxos_vrf_route_target_direction.import,
  ]
}


# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction
resource "nxos_vrf_route_target_direction" "export" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"
  direction                   = "export"

  depends_on = [
    nxos_vrf_route_target_address_family.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction
resource "nxos_vrf_route_target_direction" "export_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "ipv6-ucast"
  direction                   = "export"

  depends_on = [
    nxos_vrf_route_target_address_family.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target
resource "nxos_vrf_route_target" "export" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "ipv4-ucast"
  direction                   = "export"
  route_target                = "route-target:unknown:0:0"

  depends_on = [
    nxos_vrf_route_target_direction.export,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target
resource "nxos_vrf_route_target" "export_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "ipv6-ucast"
  direction                   = "export"
  route_target                = "route-target:unknown:0:0"

  depends_on = [
    nxos_vrf_route_target_direction.export,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_address_family
resource "nxos_vrf_route_target_address_family" "main_evpn" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"

  depends_on = [
    nxos_vrf_address_family.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_address_family
resource "nxos_vrf_route_target_address_family" "main_evpn_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "l2vpn-evpn"

  depends_on = [
    nxos_vrf_address_family.main,
  ]
}


# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction
resource "nxos_vrf_route_target_direction" "import_evpn" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "import"

  depends_on = [
    nxos_vrf_route_target_address_family.main_evpn,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction
resource "nxos_vrf_route_target_direction" "import_evpn_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "import"

  depends_on = [
    nxos_vrf_route_target_address_family.main_evpn_ipv6,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target
resource "nxos_vrf_route_target" "import_evpn" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "import"
  route_target                = "route-target:unknown:0:0"

  depends_on = [
    nxos_vrf_route_target_direction.import_evpn,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target
resource "nxos_vrf_route_target" "import_evpn_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "import"
  route_target                = "route-target:unknown:0:0"

  depends_on = [
    nxos_vrf_route_target_direction.import_evpn_ipv6,
  ]
}



# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction
resource "nxos_vrf_route_target_direction" "export_evpn" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "export"

  depends_on = [
    nxos_vrf_route_target_address_family.main_evpn,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target_direction
resource "nxos_vrf_route_target_direction" "export_evpn_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "export"

  depends_on = [
    nxos_vrf_route_target_address_family.main_evpn_ipv6,
  ]
}


# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target
resource "nxos_vrf_route_target" "export_evpn" {
  for_each                    = var.members
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv4-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "export"
  route_target                = "route-target:unknown:0:0"

  depends_on = [
    nxos_vrf_route_target_direction.export_evpn,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/vrf_route_target
resource "nxos_vrf_route_target" "export_evpn_ipv6" {
  for_each                    = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device                      = each.key
  vrf                         = var.vrf
  address_family              = "ipv6-ucast"
  route_target_address_family = "l2vpn-evpn"
  direction                   = "export"
  route_target                = "route-target:unknown:0:0"

  depends_on = [
    nxos_vrf_route_target_direction.export_evpn_ipv6,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/svi_interface
resource "nxos_svi_interface" "main" {
  for_each     = var.members
  device       = each.key
  interface_id = "vlan${each.value.vlan}"
  admin_state  = "up"
  description  = var.vrf
  # mtu          = 9216

  depends_on = [
    nxos_bridge_domain.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/svi_interface_vrf
resource "nxos_svi_interface_vrf" "main" {
  for_each     = var.members
  device       = each.key
  interface_id = "vlan${each.value.vlan}"
  vrf_dn       = "sys/inst-${var.vrf}"
  depends_on = [
    nxos_svi_interface.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/ipv4_interface
resource "nxos_ipv4_interface" "main" {
  for_each     = var.members
  device       = each.key
  vrf          = var.vrf
  interface_id = "vlan${each.value.vlan}"
  forward      = "enabled"

  depends_on = [
    nxos_svi_interface.main,
  ]
}

# provider nxos v0.5.8 時点で対応モジュールが見当たらなかったため REST で対応
# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest
resource "nxos_rest" "ipv6_dom" {
  for_each   = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device     = each.key
  dn         = "sys/ipv6/inst"
  class_name = "ipv6Dom"
  content = {
    dn   = "sys/ipv6/inst/dom-default"
    name = "default"
    rn   = "dom-default"
  }

  depends_on = [
    nxos_svi_interface.main,
  ]
}

# provider nxos v0.5.8 時点で対応モジュールが見当たらなかったため REST で対応
# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/rest
resource "nxos_rest" "ipv6_use_link_local_addr" {
  for_each   = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device     = each.key
  dn         = "sys/ipv6/inst/dom-default"
  class_name = "ipv6If"
  content = {
    autoconfig       = "disabled"
    dn               = "sys/ipv6/inst/dom-default/if-[vlan${each.value.vlan}]"
    id               = "vlan${each.value.vlan}"
    rn               = "if-[vlan${each.value.vlan}]"
    useLinkLocalAddr = "enabled"
  }

  depends_on = [
    nxos_rest.ipv6_dom,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/nve_vni
resource "nxos_nve_vni" "main" {
  for_each      = var.members
  device        = each.key
  vni           = var.vni
  associate_vrf = true

  depends_on = [
    nxos_bridge_domain.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_vrf
resource "nxos_bgp_vrf" "main" {
  for_each = var.members
  device   = each.key
  asn      = var.asn
  name     = var.vrf

  depends_on = [
    nxos_vrf.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_address_family
resource "nxos_bgp_address_family" "main" {
  for_each       = var.members
  device         = each.key
  asn            = var.asn
  vrf            = var.vrf
  address_family = "ipv4-ucast"

  depends_on = [
    nxos_bgp_vrf.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_address_family
resource "nxos_bgp_address_family" "main_ipv6" {
  for_each       = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device         = each.key
  asn            = var.asn
  vrf            = var.vrf
  address_family = "ipv6-ucast"

  depends_on = [
    nxos_bgp_vrf.main,
  ]
}


# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_route_redistribution
resource "nxos_bgp_route_redistribution" "main" {
  for_each          = var.members
  device            = each.key
  asn               = var.asn
  vrf               = var.vrf
  address_family    = "ipv4-ucast"
  protocol          = "direct"
  protocol_instance = "none"
  route_map         = var.redistribute_route_map

  depends_on = [
    nxos_bgp_address_family.main,
  ]
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs/resources/bgp_route_redistribution
resource "nxos_bgp_route_redistribution" "main_ipv6" {
  for_each          = { for k, v in var.members : k => v if var.dualstack_enable == true }
  device            = each.key
  asn               = var.asn
  vrf               = var.vrf
  address_family    = "ipv6-ucast"
  protocol          = "direct"
  protocol_instance = "none"
  route_map         = var.redistribute_route_map_v6

  depends_on = [
    nxos_bgp_address_family.main,
  ]
}
