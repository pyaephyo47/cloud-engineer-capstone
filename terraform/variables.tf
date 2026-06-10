variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The size of the EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "The AMI ID for the operating system disk image"
  type        = string
  default     = "ami-091138d0f0d41ff90" # Your exact Ubuntu 24.04 ID
}

variable "key_name" {
  description = "The name of the AWS Key Pair for SSH access"
  type        = string
  default     = "Newkp"
}
