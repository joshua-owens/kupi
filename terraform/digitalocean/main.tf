terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
    token = var.do_token
}

data "digitalocean_ssh_key" "default" {
    name = var.ssh_key_name
}

resource "digitalocean_droplet" "web" {
    image  = "ubuntu-22-04-x64"
    name   = "public-node"
    region = "nyc3"
    size   = "s-1vcpu-1gb"
    ssh_keys = [data.digitalocean_ssh_key.default.id]
}

output "ip_address" {
    value = digitalocean_droplet.web.ipv4_address
}