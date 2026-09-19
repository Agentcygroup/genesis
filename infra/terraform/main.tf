variable "region" { default = "us-east-1" }
variable "replicas" { default = 2 }
output "region" { value = var.region }
output "replicas" { value = var.replicas }
