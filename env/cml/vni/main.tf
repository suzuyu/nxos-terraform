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
