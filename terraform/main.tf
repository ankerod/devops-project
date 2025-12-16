provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_image" "ubuntu-22-04-x64" {
  slug = "ubuntu-22-04-x64"
}

resource "digitalocean_project" "devops-project" {
  name        = "devops-project"
  description = "Project for DevOps "
  purpose     = "Web Application Hosting"
  environment = "Development"
  resources = flatten([
    digitalocean_droplet.server-1.*.urn,
    digitalocean_reserved_ip.public_ip.*.urn,
  ])
}

resource "digitalocean_ssh_key" "default-key" {
  name       = "default-key"
  public_key = file(var.ssh_public_key_path)
}

resource "digitalocean_vpc" "default" {
  name     = "devops-project-network"
  region   = var.do_region
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_droplet" "server-1" {
  image    = data.digitalocean_image.ubuntu-22-04-x64.id
  name     = "server-1"
  region   = var.do_region
  size     = var.do_droplet_size
  ssh_keys = [digitalocean_ssh_key.default-key.fingerprint]
  vpc_uuid = digitalocean_vpc.default.id
  count = 3
}

resource "digitalocean_reserved_ip" "public_ip" {
  count = length(digitalocean_droplet.server-1)
  droplet_id =  digitalocean_droplet.server-1[count.index].id
  region     = var.do_region
}