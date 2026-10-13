# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.myapp-vpc.id
    subnet_cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    env_prefix = var.env_prefix
}

resource "aws_security_group" "myapp-sg" {
    name = "${var.env_prefix}-sg"
    description = "Security group for myapp"
    vpc_id = aws_vpc.myapp-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my-ip]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        }
    tags = {
            Name: "${var.env_prefix}-sg"
    }
}

data "aws_ami" "latest_amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

resource "aws_instance" "myapp-ins" {
    ami = data.aws_ami.latest_amazon_linux.id
    instance_type = var.instance_type

    subnet_id = module.myapp-subnet.subnet.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]   
    availability_zone = var.availability_zone

    associate_public_ip_address = true
    # key_name = "key-pair" # TODO: Replace with your actual key pair name

    # connection {
    #     type        = "ssh"
    #     user        = "ec2-user"
    #     private_key = file("~/.ssh/key-pair") # TODO: Replace 
    #     host        = self.public_ip
    # }
    # provisioner "remote-exec" {
    #     inline = [
    #         "sudo yum update -y",
    #         "sudo yum install -y httpd",
    #         "sudo systemctl start httpd",
    #         "sudo systemctl enable httpd",
    #         "echo '<h1>Hello from Terraform!</h1>' | sudo tee /var/www/html/index.html"
    #     ]
      
    # }

    # provisioner "remote-exec" {
    #     script = "entry-script.sh" #execute the script on the remote instance
    # }

    # provisioner "file" {
    #   source = "entry-script.sh"
    #     destination = "/home/ec2-user/entry-script.sh"
    # } # Copy file from local machine to EC2 instance

    # Zusammenfassung: I don't recommend using the file provisioner for copying files to EC2 instances. Instead, consider using user data scripts or configuration management tools like Ansible, Chef, or Puppet for better scalability and maintainability. And it breaks the idempotency of Terraform, which is one of its core principles. If you need to copy files, consider using S3 or other storage services and then download them in your user data script. Or execute scripts separate from Terraform using CI/CD pipelines or configuration management tools (Ansible).

    tags = {
        Name: "${var.env_prefix}-instance"
    }
}

