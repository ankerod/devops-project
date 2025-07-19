variable "region" {
  type = "string"
  default = "ea-central-1"
}

variable "project_name" {
  type = "string"
  default = "DevOps Project"
}

variable "instance_type" {
  type = "string"
  default = "t2.micro"
}

variable "ami_id" {
  type = string
  default = "ami-0af9b40b1a16fe700"
}

variable "ssh_key_name" {
  type = string
  default = "devops-project-key"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type = string
  default = "10.0.10.0/24"
}