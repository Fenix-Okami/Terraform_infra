# Terraform AWS EC2 Instance

This Terraform script creates an AWS EC2 instance with a public IP address and a security group that allows SSH, HTTP, and custom port access.

## Prerequisites

- Terraform installed
- AWS account
- AWS CLI installed and configured

## Usage

1. Clone this repository.
2. Navigate to the directory containing the Terraform script.
3. Initialize Terraform:

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

After running `terraform apply``, you will see the public IP address of the created EC2 instance printed in the terminal.

Resources Created
- VPC with a single public subnet and a single private subnet
- Security group that allows inbound traffic on ports 22 (SSH), 80 (HTTP), 8080 (custom web interface), 8888 (Jupyter Lab), and 8501 (Streamlit)
- EC2 instance of type t3.medium with a public IP address
Note

Please replace the key_name in the ec2_instance module with the name of your key pair in AWS. You need to import your local SSH key pair into AWS first.

License
This project is licensed under the MIT License.