module "fk_vcn" {
  source = "../../../terraform-oci-fk-vcn"

  compartment_ocid = var.compartment_ocid
  name             = "fk-fn-lesson6-vcn"
  vcn_cidr_blocks  = ["10.0.0.0/16"]
  dns_label        = "fkfnl6"

  create_internet_gateway = true
  create_nat_gateway      = true

  route_tables = {
    public = {
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "internet_gateway"
        }
      ]
    }
    private = {
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "nat_gateway"
        }
      ]
    }
  }

  security_lists = {
    api_gateway_public = {
      ingress_rules = [
        for port in var.httpx_ports : {
          protocol = "6"
          source   = "0.0.0.0/0"
          tcp_options = {
            min = port
            max = port
          }
        }
      ]
      egress_rules = [
        {
          protocol    = "6"
          destination = "0.0.0.0/0"
        }
      ]
    }
    functions_private = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "10.0.0.0/16"
        }
      ]
      egress_rules = [
        {
          protocol    = "6"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }

  subnets = {
    apigw_public = {
      cidr_block                 = "10.0.1.0/24"
      display_name               = "fk-fn-lesson6-apigw-public"
      dns_label                  = "apigwpub"
      route_table_key            = "public"
      security_list_keys         = ["api_gateway_public"]
      prohibit_public_ip_on_vnic = false
    }
    functions_private = {
      cidr_block                 = "10.0.2.0/24"
      display_name               = "fk-fn-lesson6-functions-private"
      dns_label                  = "fnpriv"
      route_table_key            = "private"
      security_list_keys         = ["functions_private"]
      prohibit_internet_ingress  = true
      prohibit_public_ip_on_vnic = true
    }
  }
}
