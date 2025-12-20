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
  tags = [
    "web-server-1",
    "production",
    "web",
  ]
}

resource "digitalocean_droplet" "server-sonarcube" {
  image    = data.digitalocean_image.ubuntu-22-04-x64.id
  name     = "server-sonarcube"
  region   = var.do_region
  size     = var.do_droplet_size
  ssh_keys = [digitalocean_ssh_key.default-key.fingerprint]
  vpc_uuid = digitalocean_vpc.default.id
  tags = [
    "sonar-server-1",
    "production",
  ]
}

resource "digitalocean_droplet" "server-harbor" {
  image    = data.digitalocean_image.ubuntu-22-04-x64.id
  name     = "server-harbor"
  region   = var.do_region
  size     = var.do_droplet_size
  ssh_keys = [digitalocean_ssh_key.default-key.fingerprint]
  vpc_uuid = digitalocean_vpc.default.id
  tags = [
    "harbor-server-1",
    "production",
  ]
}

resource "digitalocean_reserved_ip" "public_ip" {
  count      = 1
  droplet_id = digitalocean_droplet.server-1.id
  region     = var.do_region
}

resource "digitalocean_reserved_ip" "public_ip_for_sonercube" {
  count      = 1
  droplet_id = digitalocean_droplet.server-sonarcube.id
  region     = var.do_region
}

resource "digitalocean_reserved_ip" "public_ip_for_harbor" {
  count      = 1
  droplet_id = digitalocean_droplet.server-harbor.id
  region     = var.do_region
}
