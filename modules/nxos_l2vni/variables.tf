variable "vni" {}

# L2 のみの場合は description にのみ利用
variable "vrf" {}

variable "segment_name" {}

# L2 のみの場合は不要
variable "gateway_ip" {
  default = null
}

# L2 のみ, ipv4 のみの場合は不要
variable "gateway_ipv6" {
  default = null
}

variable "members" {}
