data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "strapi_sg" {
  name= "strapi_sg"
  description = "Allow SSH and Strapi access"

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  ingress {
    description = "Strapi"
    from_port = var.strapi_port
    to_port = var.strapi_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "Strapi_ec2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = data.aws_subnets.default.ids[0] 
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.strapi_sg.id]
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  user_data = file("${path.module}/user_data.sh")
  tags = {
    Name = "Strapi_EC2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.Strapi_ec2.public_ip
}

output "Strapi_url" {
  value = "http://${aws_instance.Strapi_ec2.public_ip}:${var.strapi_port}"
}