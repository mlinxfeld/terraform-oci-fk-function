resource "oci_objectstorage_bucket" "FoggyKitchenBucket" {
  compartment_id        = var.compartment_ocid
  namespace             = data.oci_objectstorage_namespace.oss_namespace.namespace
  object_events_enabled = true
  name                  = var.bucket_name
  access_type           = "NoPublicAccess"
}