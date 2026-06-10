# 1. Define the AWS provider plugin
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "pyaephyo-terraform-state-bucket"
    key            = "dev/terraform.tfstate"           # The folder path inside the bucket
    region         = "us-east-1"
    encrypt        = true                              # Encrypts the state file for security
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
  
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "Terraform-Nginx-Server"
  }
}

# 5. Automatically print the EC2 Public IP address
output "server_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.my_first_server.public_ip
}
