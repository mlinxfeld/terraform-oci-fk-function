resource "null_resource" "FoggyKitchenFnInvoke" {
  count = var.invoke_fn ? 1 : 0

  depends_on = [oci_functions_function.FoggyKitchenFn]

  provisioner "local-exec" {
    command = "sleep 30"
  }

  provisioner "local-exec" {
    command = <<-EOT
      RESPONSE=$(oci raw-request --http-method POST --target-uri ${oci_functions_function.FoggyKitchenFn.invoke_endpoint}/20181201/functions/${oci_functions_function.FoggyKitchenFn.id}/actions/invoke --request-body '')
      echo "$RESPONSE"
      echo "$RESPONSE" | grep -Eq '"status": 0|"data": ""'
    EOT
  }

}
