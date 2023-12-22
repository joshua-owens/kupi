variable "address_range" {
  description = "The IP address range for MetalLB to use for load balancing"
  type        = string
  default     = "192.168.1.240-192.168.1.250"
}