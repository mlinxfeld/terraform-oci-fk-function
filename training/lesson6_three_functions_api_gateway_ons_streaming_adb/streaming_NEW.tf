module "fk_streaming" {
  source = "../../../terraform-oci-fk-streaming"

  compartment_ocid = var.compartment_ocid
  name             = "fk-fn-lesson6-streaming"
  stream_pool_name = "FoggyKitchenStreamPool"

  streams = {
    iot_data = {
      name               = "FoggyKitchenStream"
      partitions         = 1
      retention_in_hours = 24
    }
  }
}
