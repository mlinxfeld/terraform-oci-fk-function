data "local_file" "fncustom_dockerfile" {
  filename = "${path.module}/functions/fncustom/Dockerfile"
}

data "local_file" "fncustom_func_py" {
  filename = "${path.module}/functions/fncustom/func.py"
}

data "local_file" "fncustom_func_yaml" {
  filename = "${path.module}/functions/fncustom/func.yaml"
}

data "local_file" "fncustom_requirements_txt" {
  filename = "${path.module}/functions/fncustom/requirements.txt"
}