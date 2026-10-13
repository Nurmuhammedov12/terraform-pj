output "ec2_public_ip" {
    value = aws_instance.myapp-ins.public_ip
}

output "aws_ami_id" {
    value = data.aws_ami.latest_amazon_linux.id
}