resource "oci_artifacts_container_repository" "FoggyKitchenOCIR" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.ocir_repo_name}/${var.fk_fn_name}" 
  is_public      = false
}

resource "null_resource" "FoggyKitchenFnSetup" {
  depends_on = [oci_functions_application.FoggyKitchenFnApp, oci_artifacts_container_repository.FoggyKitchenOCIR]

  # provisioner "local-exec" {
  #  command = "echo '${var.ocir_user_password}' |  docker login ${local.ocir_docker_repository} --username ${local.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  # }

  provisioner "local-exec" {
    command = "fn build"
    working_dir = "functions/fkFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep ${var.fk_fn_name} | awk -F ' ' '{print $3}') ; docker tag $image ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    working_dir = "functions/fkFn"
  }

  provisioner "local-exec" {
    command = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    working_dir = "functions/fkFn"
  }

}