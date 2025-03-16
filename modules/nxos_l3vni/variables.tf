variable "vni" {}

variable "vrf" {}

variable "members" {}

variable "asn" {
  default = "65001"
}

variable "redistribute_route_map" {
  default = "permit-all-v4"
}

# IPv4 IPv6 DualStack 時には true に設定(デフォルトfalse)
variable "dualstack_enable" {
  default = false
}

variable "redistribute_route_map_v6" {
  default = "permit-all-v6"
}