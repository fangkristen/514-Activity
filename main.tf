# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Set AWS region to US East 1 (N. Virginia)
}

# Local variables block for configuration values
locals {
    aws_key = "KF_AWS_KEY"   # SSH key pair name for EC2 instance access
}

# EC2 instance resource definition
resource "aws_instance" "my_server" {
   ami           = data.aws_ami.amazonlinux.id  # Use the AMI ID from the data source
   instance_type = var.instance_type            # Use the instance type from variables
   key_name      = "${local.aws_key}"          # Specify the SSH key pair name
  
   # Add tags to the EC2 instance for identification
   tags = {
     Name = "my ec2"
   }                  
}

terraform {
  backend "s3" {
    bucket  = "kf-github-activity"
    key     = "github-actions/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
