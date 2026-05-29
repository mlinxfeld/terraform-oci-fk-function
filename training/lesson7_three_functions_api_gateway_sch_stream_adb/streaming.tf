module "fk_streaming" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-streaming.git?ref=v0.1.0"

  compartment_ocid = var.compartment_ocid
  name             = "fk-fn-lesson7-streaming"
  stream_pool_name = "FoggyKitchenStreamPool"

  streams = {
    iot_data = {
      name               = "FoggyKitchenStream"
      partitions         = 1
      retention_in_hours = 24
    }
  }
}
