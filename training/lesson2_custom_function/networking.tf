module "fk_vcn" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-vcn.git?ref=v0.1.0"

  compartment_ocid = var.compartment_ocid
  name             = "FoggyKitchenFunctionVCN"
  vcn_cidr_blocks  = ["10.0.0.0/16"]
  dns_label        = "fkfnvcn"

  create_internet_gateway = true

  route_tables = {
    public = {
      display_name = "FoggyKitchenFunctionPublicRouteTable"
      route_rules = [
        {
          description        = "Traffic to the internet"
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "internet_gateway"
        }
      ]
    }
  }

  subnets = {
    functions_public = {
      display_name               = "FoggyKitchenFunctionPublicSubnet"
      cidr_block                 = "10.0.1.0/24"
      dns_label                  = "fnpub"
      route_table_key            = "public"
      prohibit_public_ip_on_vnic = false
    }
  }
}
