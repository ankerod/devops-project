variable "do_region" {
    description = "Digital ocean region"
    type        = string
    default     = "fra1"
}

variable "do_droplet_size" {
    description = "Digital droplet size"
    type        = string
    default     = "s-2vcpu-4gb"
}

variable "do_token" {
    description = "Digital Ocean API Token"
    type        = string
    sensitive = true
}

variable "ssh_public_key_path" {
  description = "Digital ocean public ssh key path"
  type = string
  default = "~/.ssh/digitalocean.pub"
}

variable "ssh_private_key_path" {
  description = "Digital ocean private ssh key path"
  type = string
  default = "~/.ssh/digitalocean"
}