variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "DevOps-Project"
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type    = string
  default = "ami-02003f9f0fde924ea"
}

variable "ssh_key_name" {
  type    = string
  default = "id_ed25519"
}

variable "ssh_private_key_path" {
  description = "Path to private SSH key for accessing the instance"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  type    = string
  default = "10.0.10.0/24"
}
