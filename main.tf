provider "aws" {
  region = "us-west-1" # You can change the region as needed
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0" 

  name = "Terraform-VPC"
  cidr = "10.0.0.0/24"

  azs             = ["us-west-1a"] # Using a single AZ
  private_subnets = ["10.0.0.128/25"] # One private subnet
  public_subnets  = ["10.0.0.0/25"] # One public subnet

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0" 

  name        = "my-security-group"
  description = "Security group for allowing SSH, HTTP, and custom port access"
  vpc_id      = module.vpc.vpc_id # Replace with your VPC ID

  # Define rules for inbound traffic
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Custom web interface"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  # Optionally, define rules for outbound traffic
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.5.0" # Use the latest version

  name           = "Terraform-instance"
  ami            = data.aws_ami.latest_ubuntu.id
  instance_type  = "t2.micro"
  subnet_id      = module.vpc.public_subnets[0] # Replace with your subnet ID

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}