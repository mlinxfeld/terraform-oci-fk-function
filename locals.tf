# OCIR repo name & namespace

locals {
  ocir_docker_repository = join("", [lower(lookup(data.oci_identity_regions.oci_regions.regions[0], "key")), ".ocir.io"])
  ocir_namespace         = lookup(data.oci_objectstorage_namespace.os_namespace, "namespace")
  fn_source_dir          = var.use_my_fn ? "${path.module}/.generated/${var.fk_fn_name}" : "${path.module}/functions/fkFn"
}
