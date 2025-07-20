terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.region
}

resource "aws_key_pair" "ssh-key" {
    key_name = var.ssh_key_name
    public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block

    tags = {
      Name = "#{var.project-name}-vpc"
      Project = var.project_name
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr_block
  
    tags = {
      Name = "#{var.project-name}-subnet-pb"
      Project = var.project_name
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
      Name = "#{var.project-name}-igw"
      Project = var.project_name
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    
    route {
        cidr_block = "0.0.0.0/0" # All trafic
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
      Name = "#{var.project-name}-igw"
      Project = var.project_name
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web_sg" {
    vpc_id = aws_vpc.main.id
    name = "${var.project_name}-web-sg"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
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
      Name = "#{var.project-name}-igw"
      Project = var.project_name
    }
}

resource "aws_instance" "web_server" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
      Name = "#{var.project-name}-igw"
      Project = var.project_name
    }
}