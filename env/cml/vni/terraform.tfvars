
l3vni_map = {
  vni_29001 = {
    vni = 29001
    vrf = "tenant2-vpc1"
    members = {
      lfsw01 = {
        vlan = "3002"
      }
      lfsw02 = {
        vlan = "3002"
      }
      lfsw03 = {
        vlan = "3002"
      }
    }
  }
}

l2vni_map = {
  vni_20200 = {
    vni = 20200
    vrf = "tenant2-vpc1"

    segment_name = "server-seg1"
    gateway_ip   = "172.17.0.254/24"
    members = {
      lfsw01 = {
        vlan = "200"
      }
      lfsw02 = {
        vlan = "200"
      }
      lfsw03 = {
        vlan = "20"
      }
    }
  }
}
