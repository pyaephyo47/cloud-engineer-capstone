# 1. Define the AWS provider plugin
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket  = "pyaephyo-terraform-state-bucket"
    key     = "dev/terraform.tfstate" # The folder path inside the bucket
    region  = "us-east-1"
    encrypt = true # Encrypts the state file for security
  }
}

# 2. Configure the AWS Provider using a variable
provider "aws" {
  region = var.aws_region
}

# 3. Create a Security Group inside your DEFAULT VPC
resource "aws_security_group" "web_ssh_sg" {
  name        = "allow-ssh-http"
  description = "Allow inbound SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-SSH-SecurityGroup"
  }
}

# 4. Launch the EC2 Instance using variables
resource "aws_instance" "my_first_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_ssh_sg.id]
  key_name               = var.key_name
  user_data              = <<-EOF
              #!/bin/bash
              # Update packages
              sudo apt-get update -y
              
              # Install Git and Docker cleanly (No native Nginx)
              sudo apt-get install -y git docker.io
              
              # Start and enable the Docker daemon engine
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # Add default system user to docker group permissions
              sudo usermod -aG docker ubuntu
              EOF


  tags = {
    Name = "Terraform-Nginx-Server"
  }
}

# 6. Allocate a permanent Static Elastic IP address
resource "aws_eip" "my_static_ip" {
  instance = aws_instance.my_first_server.id
  domain   = "vpc" # Tells AWS to allocate it inside your default network stack

  tags = {
    Name = "Capstone-Static-IP"
  }
}

# 7. Update your output block to print your permanent IP instead
output "server_public_ip" {
  description = "The permanent static IP address of the EC2 instance"
  value       = aws_eip.my_static_ip.public_ip
}
