data "oci_objectstorage_namespace" "os_namespace" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_regions" "oci_regions" {
  
  filter {
    name = "name" 
    values = [var.region]
  }

}