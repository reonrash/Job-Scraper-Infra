
# AWS Region to deploy resources
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" 
}

# RDS Master Username
variable "rds_username" {
  description = "Master username for the RDS PostgreSQL instances."
  type        = string
  default     = "postgres" 
}

# EC2 AMI ID
variable "ec2_ami_id" {
  description = "The AMI ID for the EC2 instance (e.g., ami-0abcdef1234567890 for Amazon Linux 2023)."
  type        = string
  default     = "ami-05ffe3c48a9991133"
}

# RDS Master Password
variable "rds_password" {
  description = "Master password for the RDS PostgreSQL instances."
  type        = string
  sensitive   = true 
}

# EC2 Key Pair Name
# This key pair must already exist in your AWS account in the specified region.
variable "key_pair_name" {
  description = "The name of the EC2 Key Pair to use for the EC2 instance."
  type        = string
}


