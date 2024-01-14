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
    },
    {
      from_port   = 8888
      to_port     = 8888
      protocol    = "tcp"
      description = "Jupyter Lab"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8501
      to_port     = 8501
      protocol    = "tcp"
      description = "Streamlit"
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
  instance_type  = "t3.medium"
  subnet_id      = module.vpc.public_subnets[0] # Replace with your subnet ID
  key_name       = "Stream" # Replace with your key pair name
  associate_public_ip_address = true
  vpc_security_group_ids = [module.security_group.security_group_id]

  # user_data = <<-EOF
  #         #!/bin/bash
  #         sudo apt-get update
  #         sudo apt-get install -y python3-pip git
  #         pip3 install jupyterlab
  #         nohup jupyter lab --ip=0.0.0.0 --no-browser --allow-root &
  #         git clone https://github.com/Fenix-Okami/algo.git
  #         cd algo
  #         pip3 install -r requirements.txt
  #         nohup streamlit run your_streamlit_app.py &
  #         EOF

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2_instance.public_ip
}