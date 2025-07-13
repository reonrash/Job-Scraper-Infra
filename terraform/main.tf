# main.tf

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# --- Use Default VPC and its Components ---

# Data source to retrieve the default VPC
# This allows us to reference the default VPC's ID without creating a new one.
data "aws_vpc" "default_vpc" {
  default = true
}

# Get available Availability Zones in the specified region
# We'll use these to select a single AZ for deployment.
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source to retrieve all subnets in the default VPC
data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# --- Security Groups ---

# Security Group for EC2 Instance (SSH Access)
# Allows SSH access from anywhere (0.0.0.0/0) for dev purposes.
resource "aws_security_group" "ec2_dev_sg" {
  name        = "ec2-dev-sg"
  description = "Security group for dev EC2 instance"
  vpc_id      = data.aws_vpc.default_vpc.id 

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from anywhere"
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
    Name = "ec2-dev-sg"
  }
}

# Security Group for RDS Instances (PostgreSQL Access from EC2)
# Allows PostgreSQL traffic only from the EC2 security group.
resource "aws_security_group" "rds_dev_sg" {
  name        = "rds-dev-sg"
  description = "Security group for dev RDS instances"
  vpc_id      = data.aws_vpc.default_vpc.id 

  ingress {
    description     = "Allow PostgreSQL from EC2 SG"
    from_port       = 5432 
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_dev_sg.id] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          
    cidr_blocks = ["0.0.0.0/0"] 
  }

  tags = {
    Name = "rds-dev-sg"
  }
}

# --- RDS Database Setup ---
resource "aws_db_subnet_group" "dev_rds_subnet_group" {
  name        = "dev-rds-subnet-group"
  description = "Subnet group for dev RDS instances"
  subnet_ids = [
    data.aws_subnets.default_vpc_subnets.ids[0],
    data.aws_subnets.default_vpc_subnets.ids[1],
  ]

  tags = {
    Name = "dev-rds-subnet-group"
  }
}

# RDS PostgreSQL Instance 1 (Metabase DB)
resource "aws_db_instance" "metabase_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.4" 
  instance_class         = "db.t4g.micro"
  db_name                = "metabasedb"
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = "default.postgres17"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.dev_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_dev_sg.id]
  multi_az               = false
  identifier             = "metabase-db"
  storage_type           = "gp2"
  availability_zone      = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "metabase-db"
  }
}

# RDS PostgreSQL Instance 2 (Jobs DB)
resource "aws_db_instance" "jobs_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.4" 
  instance_class         = "db.t4g.micro"
  db_name                = "jobsdb"
  username               = var.rds_username
  password               = var.rds_password
  parameter_group_name   = "default.postgres17"
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = aws_db_subnet_group.dev_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_dev_sg.id]
  multi_az               = false
  identifier             = "jobs-db"
  storage_type           = "gp2"
  availability_zone      = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "jobs-db"
  }
}

# --- EC2 Instance Setup ---

resource "aws_instance" "metabase_scraper" {
  ami                         = var.ec2_ami_id
  instance_type               = "t2.medium"
  key_name                    = var.key_pair_name
  subnet_id                   = data.aws_subnets.default_vpc_subnets.ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2_dev_sg.id]
  associate_public_ip_address = true

  user_data = file("${path.module}/init.sh")

  tags = {
    Name = "metabase-scraper"
  }
}
