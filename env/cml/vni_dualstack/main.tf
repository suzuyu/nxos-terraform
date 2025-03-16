# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs
terraform {
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "=0.5.8"
    }
  }
}

# https://registry.terraform.io/providers/CiscoDevNet/nxos/latest/docs
provider "nxos" {
  username = "admin"
  password = "cisco"
  devices = [
    {
      name = "lfsw01"
      url  = "https://192.168.129.71"
    },
    {
      name = "lfsw02"
      url  = "https://192.168.129.72"
    },
    {
      name = "lfsw03"
      url  = "https://192.168.129.73"
    },
    {
      name = "lfsw04"
      url  = "https://192.168.129.74"
    },
  ]
}
