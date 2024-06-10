resource "oci_streaming_stream_pool" "FoggyKitchenStreamPool" {
    compartment_id = var.compartment_ocid
    name = "FoggyKitchenStreamPool"
}

resource "oci_streaming_stream" "FoggyKitchenStream" {
    name = "FoggyKitchenStream"
    partitions = 1
    stream_pool_id = oci_streaming_stream_pool.FoggyKitchenStreamPool.id
}