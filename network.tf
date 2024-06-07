resource "oci_core_virtual_network" "FoggyKitchenVCN" {
  count          = var.use_my_fn_network ? 0 : 1  
  cidr_block     = var.VCN-CIDR
  dns_label      = "FoggyKitchenVCN"
  compartment_id = var.compartment_ocid
  display_name   = "FoggyKitchenVCN"
}

resource "oci_core_internet_gateway" "FoggyKitchenInternetGateway" {
    count          = var.use_my_fn_network ? 0 : 1  
    compartment_id = var.compartment_ocid
    display_name   = "FoggyKitchenInternetGateway"
    vcn_id         = oci_core_virtual_network.FoggyKitchenVCN[0].id
}

resource "oci_core_route_table" "FoggyKitchenRouteTableViaIGW" {
    count          = var.use_my_fn_network ? 0 : 1 
    compartment_id = var.compartment_ocid
    vcn_id         = oci_core_virtual_network.FoggyKitchenVCN[0].id
    display_name   = "FoggyKitchenRouteTableViaIGW"
    
    route_rules {
        destination = "0.0.0.0/0"
        destination_type  = "CIDR_BLOCK"
        network_entity_id = oci_core_internet_gateway.FoggyKitchenInternetGateway[0].id
    }
}

resource "oci_core_dhcp_options" "FoggyKitchenDhcpOptions1" {
  count          = var.use_my_fn_network ? 0 : 1   
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.FoggyKitchenVCN[0].id
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

resource "oci_core_subnet" "FoggyKitchenPublicSubnet" {
  count           = var.use_my_fn_network ? 0 : 1   
  cidr_block      = var.fnsubnet-CIDR
  display_name    = "FoggyKitchenPublicSubnet"
  dns_label       = "FoggyKitchenN1"
  compartment_id  = var.compartment_ocid
  vcn_id          = oci_core_virtual_network.FoggyKitchenVCN[0].id
  route_table_id  = oci_core_route_table.FoggyKitchenRouteTableViaIGW[0].id
  dhcp_options_id = oci_core_dhcp_options.FoggyKitchenDhcpOptions1[0].id
}

