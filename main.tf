provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"
}

module "subnets" {
  source = "./modules/subnets"
  vpc_id = module.vpc.vpc_id
}

module "internet_gateway" {
  source = "./modules/internet_gateway"
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.subnets.public_subnet_id
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source     = "./modules/ec2"
  subnet_id  = module.subnets.public_subnet_id
  ec2_sg_id  = module.security_groups.ec2_sg_id
  key_name   = var.key_name
}

module "rds" {
  source            = "./modules/rds"
  private_subnet_id = module.subnets.private_subnet_id
  public_subnet_id  = module.subnets.public_subnet_id
  rds_sg_id         = module.security_groups.rds_sg_id
  db_username       = var.db_username
  db_password       = var.db_password
}
