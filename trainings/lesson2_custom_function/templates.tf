data "template_file" "custom_fn_dockerfile_template" {
  template = file("${path.module}/templates/Dockerfile.template")

  vars = {
  }
}


data "template_file" "custom_fn_func_py_template" {
  template = file("${path.module}/templates/func.py.template")

  vars = {
    fn_custom_message = var.fn_custom_message
  }
}

data "template_file" "custom_fn_func_yaml_template" {
  template = file("${path.module}/templates/func.yaml.template")

  vars = {
    fn_name = var.fn_name
  }
}

data "template_file" "requirements_txt_content" {
  template = file("${path.module}/templates/requirements.txt.template")

  vars = {
  }
}