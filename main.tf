provider "aws" {
  region = "us-east-1"  # Set AWS region to US East 1 (N. Virginia)
}

locals {
  aws_key = "KF_AWS_KEY"   # SSH key pair name for EC2 instance access
}

# Get the default VPC (needed for security group)
data "aws_vpc" "default" {
  default = true
}

# Security Group to allow browser + SSH
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow web and SSH access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 🔒 Ideally restrict to your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance resource definition
resource "aws_instance" "my_server" {
  ami             = data.aws_ami.amazonlinux.id
  instance_type   = var.instance_type
  key_name        = local.aws_key
  security_groups = [aws_security_group.web_sg.name]

  # Run the WordPress install script on boot
  user_data = file("${path.module}/wp_install.sh")

  tags = {
    Name = "my-ec2"
  }
}

# Output the EC2 public IP
output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my_server.public_ip
}