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

resource "digitalocean_firewall" "web_fw" {
    name = "web-firewall"

    droplet_ids = [digitalocean_droplet.web.id]
    
    inbound_rule {
        protocol           = "tcp"
        port_range         = "443"
        source_addresses   = ["0.0.0.0/0", "::/0"]
    }

    inbound_rule {
        protocol           = "tcp"
        port_range         = "80"
        source_addresses   = ["0.0.0.0/0", "::/0"]
    }
    
    inbound_rule {
        protocol           = "tcp"
        port_range         = "22"
        source_addresses   = ["0.0.0.0/0", "::/0"]
    }

    # Required only for Flannel VXLAN
    inbound_rule {
        protocol           = "udp"
        port_range         = "8472"
        source_addresses   = var.source_addresses
    }
    
    # Kubelete Metrics server
    inbound_rule {
        protocol           = "tcp"
        port_range         = "10250"
        source_addresses   = var.source_addresses
    }

    outbound_rule {
        protocol           = "tcp"
        port_range         = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol           = "udp"
        port_range         = "1-65535"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }

    outbound_rule {
        protocol           = "icmp"
        destination_addresses = ["0.0.0.0/0", "::/0"]
    }
}