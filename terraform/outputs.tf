output "droplet_public_ip" {
    description = "Public IP of droplets"
    value       = digitalocean_reserved_ip.public_ip.*.ip_address
}

output "ssh_connect_command" {
    description = "SSH connect command for the droplets"
    value = [
        for ip in digitalocean_reserved_ip.public_ip.*.ip_address :
        "ssh -i ${var.ssh_private_key_path} root@${ip}"
    ]
  }