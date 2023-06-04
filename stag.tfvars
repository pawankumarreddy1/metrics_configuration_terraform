vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
data_subnet_cidr    = ["10.0.6.0/24", "10.0.7.0/24", "10.0.8.0/24"]
ami_id              = "ami-0126086c4e272d3c9"
instance_type       = "c4.2xlarge"
# key_name                 = "lap"
# private_key = file("/c/Users/Narendrareddy/.ssh/id_rsa")
# node_exporter_private_ip = output.node_exporter_private_ip
region = "ap-southeast-1"