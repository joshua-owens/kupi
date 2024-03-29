variable "do_token" {
    description = "Digital Ocean API Token"
    type = string
}

variable "ssh_key_name" {
    description = "Name of the SSH key to use in Digital Ocean"
    type = string 
}

variable "source_addresses" {
  description = "Source IP addresses of k3 nodes for fire wall rules"
  type        = list(string)
}