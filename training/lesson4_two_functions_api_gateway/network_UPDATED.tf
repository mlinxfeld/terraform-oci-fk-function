resource "oci_core_virtual_network" "FoggyKitchenVCN" {
  cidr_block     = "10.0.0.0/16"
  dns_label      = "FoggyKitchenVCN"
  compartment_id = var.compartment_ocid
  display_name   = "FoggyKitchenVCN"
}

resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway" {
    compartment_id = var.compartment_ocid
    display_name   = "FoggyKitchenInternetGateway"
    vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
}

resource "oci_core_nat_gateway" "FoggyKitchenNATGateway" {
    compartment_id = var.compartment_ocid
    display_name   = "FoggyKitchenNATGateway"
    vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
}

resource "oci_core_route_table" "FoggyKitchenRouteTableViaIGW" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
    display_name   = "FoggyKitchenRouteTableViaIGW"
    
    route_rules {
        destination = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = oci_core_internet_gateway.FoggyKitchenInternetGateway.id
    }
}

resource "oci_core_route_table" "FoggyKitchenRouteTableViaNAT" {
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
    display_name   = "FoggyKitchenRouteTableViaNAT"
    
    route_rules {
        destination = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = oci_core_nat_gateway.FoggyKitchenNATGateway.id
    }
}

resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions1" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN.id
  display_name   = "FoggyKitchenDHCPOptions1"

  options {
    type = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type = "SearchDomain"
    search_domain_names = [ "foggykitchen.com" ]
  }
}

resource "oci_core_security_list" "FoggyKitchenSecurityList" {
    compartment_id = var.compartment_ocid
    display_name = "FoggyKitchenSecurityList"
    vcn_id = oci_core_virtual_network.FoggyKitchenVCN.id
    
    egress_security_rules {
        protocol = "6"
        destination = "0.0.0.0/0"
    }
    
    dynamic "ingress_security_rules" {
    for_each = var.httpx_ports
    content {
        protocol = "6"
        source = "0.0.0.0/0"
        tcp_options {
            max = ingress_security_rules.value
            min = ingress_security_rules.value
            }
        }
    }

    ingress_security_rules {
        protocol = "6"
        source = "10.0.0.0/16"
    }
}

resource "oci_core_subnet" "FoggyKitchenPublicSubnet" {
  cidr_block        = "10.0.1.0/24"
  display_name      = "FoggyKitchenPublicSubnet"
  dns_label         = "FoggyKitchenN1"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id    = oci_core_route_table.FoggyKitchenRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids = [oci_core_security_list.FoggyKitchenSecurityList.id]
}

resource "oci_core_subnet" "FoggyKitchenPrivateSubnet" {
  cidr_block                 = "10.0.2.0/24"
  display_name               = "FoggyKitchenPrivateSubnet"
  dns_label                  = "FoggyKitchenN2"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.FoggyKitchenVCN.id
  route_table_id             = oci_core_route_table.FoggyKitchenRouteTableViaNAT.id
  dhcp_options_id            = oci_core_dhcp_options.FoggyKitchenDhcpOptions1.id
  security_list_ids          = [oci_core_security_list.FoggyKitchenSecurityList.id]
  prohibit_public_ip_on_vnic = true
}
