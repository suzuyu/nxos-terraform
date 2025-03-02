variable "vni" {}

# L2 のみの場合は description にのみ利用
variable "vrf" {}

variable "segment_name" {}

# L2 のみの場合は不要
variable "gateway_ip" {
  default = null
}

variable "members" {}
