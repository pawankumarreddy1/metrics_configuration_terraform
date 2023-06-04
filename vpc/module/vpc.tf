module "vpc" {
    source = "../vpc"
    vpc_cidr = var.vpc_cidr
    public_subnet_cidr = var.public_subnet_cidr
    private_subnet_cidr = var.private_subnet_cidr
    data_subnet_cidr = var.data_subnet_cidr
  
}