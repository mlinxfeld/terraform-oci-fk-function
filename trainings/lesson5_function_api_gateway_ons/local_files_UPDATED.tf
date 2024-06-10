## FnInitiator localfiles

data "local_file" "fninitiator_dockerfile" {
  filename = "${path.module}/functions/fninitiator/Dockerfile"
}

data "local_file" "fninitiator_func_py" {
  filename = "${path.module}/functions/fninitiator/func.py"
}

data "local_file" "fninitiator_func_yaml" {
  filename = "${path.module}/functions/fninitiator/func.yaml"
}

data "local_file" "fninitiator_requirements_txt" {
  filename = "${path.module}/functions/fninitiator/requirements.txt"
}

## FnCollector localfiles

data "local_file" "fncollector_dockerfile" {
  filename = "${path.module}/functions/fncollector/Dockerfile"
}

data "local_file" "fncollector_func_py" {
  filename = "${path.module}/functions/fncollector/func.py"
}

data "local_file" "fncollector_func_yaml" {
  filename = "${path.module}/functions/fncollector/func.yaml"
}

data "local_file" "fncollector_requirements_txt" {
  filename = "${path.module}/functions/fncollector/requirements.txt"
}
