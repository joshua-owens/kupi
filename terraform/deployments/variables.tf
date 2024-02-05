variable "address_range" {
  description = "The IP address range for MetalLB to use for load balancing"
  type        = string
  default     = "192.168.1.240-192.168.1.250"
}

variable "docker_username" {
  description = "The username for the Docker registry"
  type        = string
}

variable "docker_access_token" {
  description = "The access token for the Docker registry"
  type        = string
}