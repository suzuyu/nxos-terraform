variable "vni" {}

variable "vrf" {}

variable "members" {}

variable "asn" {
  default = "65001"
}

variable "redistribute_route_map" {
  default = "permit-all-v4"
}
