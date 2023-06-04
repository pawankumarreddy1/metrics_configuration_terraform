output "azs_names" {
  value = data.aws_availability_zones.available.names
}

# output "ami"{
#     value = data.aws_ami.linux_ami
# }
output "node_exporter_private_ip" {
  value = aws_instance.node_exporter[*].private_ip
}

# output "prometheus-config-rendered" {
#   value = data.template_file.prometheus-config.rendered
# }
