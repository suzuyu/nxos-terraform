
l3vni_map = {
  vni_9001 = {
    vni              = 9001
    vrf              = "controller-vpc1"
    dualstack_enable = true
    members = {
      lfsw01 = {
        vlan = "3000"
      }
      lfsw02 = {
        vlan = "3000"
      }
    }
  }
  vni_19001 = {
    vni              = 19001
    vrf              = "tenant1-vpc1"
    dualstack_enable = true
    members = {
      lfsw01 = {
        vlan = "3001"
      }
      lfsw02 = {
        vlan = "3001"
      }
      lfsw03 = {
        vlan = "3001"
      }
      lfsw04 = {
        vlan = "3001"
      }
    }
  }
  vni_29001 = {
    vni              = 29001
    vrf              = "tenant2-vpc1"
    dualstack_enable = true
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
      lfsw04 = {
        vlan = "3002"
      }
    }
  }
}

l2vni_map = {
  vni_100 = {
    vni = 100
    vrf = "controller-vpc1"

    segment_name = "seg1"
    gateway_ip   = "100.64.0.254/24"
    gateway_ipv6 = "fd12:0:0:1::1/64"
    members = {
      lfsw01 = {
        vlan = "2001"
      }
      lfsw02 = {
        vlan = "2001"
      }
    }
  }
  vni_10100 = {
    vni = 10100
    vrf = "tenant1-vpc1"

    segment_name = "server-seg1"
    gateway_ip   = "172.16.0.254/24"
    gateway_ipv6 = "fd21:0:0:1::1/64"
    members = {
      lfsw01 = {
        vlan = "100"
      }
      lfsw02 = {
        vlan = "100"
      }
      lfsw03 = {
        vlan = "10"
      }
      lfsw04 = {
        vlan = "10"
      }
    }
  }
  vni_10101 = {
    vni = 10101
    vrf = "tenant1-vpc1"

    segment_name = "server-seg2"
    gateway_ip   = "172.16.1.254/24"
    gateway_ipv6 = "fd21:0:0:2::1/64"
    members = {
      lfsw03 = {
        vlan = "11"
      }
      lfsw04 = {
        vlan = "11"
      }
    }
  }
  vni_20200 = {
    vni = 20200
    vrf = "tenant2-vpc1"

    segment_name = "server-seg1"
    gateway_ip   = "172.17.0.254/24"
    gateway_ipv6 = "fd22:0:0:1::1/64"
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
      lfsw04 = {
        vlan = "20"
      }
    }
  }
}
