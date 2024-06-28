data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid
  filter {
    name   = "is_home_region"
    values = [true]
  }
}

data "oci_identity_regions" "oci_regions" {
  provider   = oci.homeregion
  filter {
    name   = "name"
    values = [var.region]
  }
}

data "oci_streaming_stream_pool" "FoggyKitchenStreamPool" {
    stream_pool_id = "${oci_streaming_stream_pool.FoggyKitchenStreamPool.id}"
}

data "oci_objectstorage_namespace" "oss_namespace" {
  compartment_id = var.compartment_ocid
}

