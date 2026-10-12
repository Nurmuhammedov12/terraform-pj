# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
}
 variable "vpc_cidr" {
  description = "CIDR block for the VPC"
 }

# Create a VPC
resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "development-vpc"
  }
} 

resource "aws_subnet" "development-subnet" {
  vpc_id            = aws_vpc.development-vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "eu-central-1a"
  tags = {
    Name = "development-subnet"
  }
}

# data "aws_vpc" "existing_vpc" {
#   default = true
# }

# resource "aws_subnet" "development-subnet-1" {
#   vpc_id            = data.aws_vpc.existing_vpc.id
#   cidr_block        = "172.31.48.0/20"
#   availability_zone = "eu-central-1a"
#   tags = {
#     Name = "development-subnet-1"
#   }
# } 

output "development_vpc_id" {
  value = aws_vpc.development-vpc.id
}
output "development_subnet_id" {
  value = aws_subnet.development-subnet.id
}
