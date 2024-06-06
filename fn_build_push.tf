resource "oci_artifacts_container_repository" "FoggyKitchenOCIR" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.ocir_repo_name}/${var.fk_fn_name}" 
  is_public      = false
}

resource "null_resource" "FoggyKitchenFnSetup" {
  count = var.use_my_fn ? 0 : 1
  depends_on = [oci_functions_application.FoggyKitchenFnApp, oci_artifacts_container_repository.FoggyKitchenOCIR]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${local.ocir_docker_repository} --username ${local.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }

  provisioner "local-exec" {
    command = "fn build"
    working_dir = "${path.module}/functions/fkFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep ${var.fk_fn_name} | awk -F ' ' '{print $3}') ; docker tag $image ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    working_dir = "${path.module}/functions/fkFn"
  }

  provisioner "local-exec" {
    command = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    working_dir = "${path.module}/functions/fkFn"
  }

}

resource "local_file" "dockerfile_content" {
  count    = var.use_my_fn ? 1 : 0  
  content  = var.dockerfile_content
  filename = "${path.module}/functions/fkFn/Dockerfile"
}

resource "local_file" "func_py_content" {
  count    = var.use_my_fn ? 1 : 0  
  content  = var.func_py_content
  filename = "${path.module}/functions/fkFn/func.py"
}

resource "local_file" "func_yaml_content" {
  count    = var.use_my_fn ? 1 : 0  
  content  = var.func_yaml_content
  filename = "${path.module}/functions/fkFn/func.yaml"
}

resource "local_file" "requirements_txt_content" {
  count    = var.use_my_fn ? 1 : 0  
  content  = var.requirements_txt_content
  filename = "${path.module}/functions/fkFn/requirements.txt"
}

resource "null_resource" "FoggyKitchenMyFnSetup" {
  count = var.use_my_fn ? 1 : 0
  depends_on = [oci_functions_application.FoggyKitchenFnApp, oci_artifacts_container_repository.FoggyKitchenOCIR,local_file.dockerfile_content,local_file.func_py_content,local_file.func_yaml_content,local_file.requirements_txt_content]

  provisioner "local-exec" {
    command = "echo '${var.ocir_user_password}' |  docker login ${local.ocir_docker_repository} --username ${local.ocir_namespace}/${var.ocir_user_name} --password-stdin"
  }

  provisioner "local-exec" {
    command = "fn build"
    working_dir = "${path.module}/functions/fkFn"
  }

  provisioner "local-exec" {
    command = "image=$(docker images | grep ${var.fk_fn_name} | awk -F ' ' '{print $3}') ; docker tag $image ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    working_dir = "${path.module}/functions/fkFn"
  }

  provisioner "local-exec" {
    command = "docker push ${local.ocir_docker_repository}/${local.ocir_namespace}/${var.ocir_repo_name}/${var.fk_fn_name}:${var.fk_fn_version}"
    working_dir = "${path.module}/functions/fkFn"
  }

}