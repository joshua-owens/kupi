
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

variable "postgres_user" {
  description = "The username for the PostgreSQL database"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "The password for the PostgreSQL database"
  type        = string
}

variable "postgres_host" {
  description = "The hostname for the PostgreSQL database"
  type        = string
  default     = "postgres"
}

variable "postgres_port" {
  description = "The port for the PostgreSQL database"
  type        = number
  default     = 5432
}

variable "gim_backend_secret" {
  description = "The secret for the GIM backend"
  type        = string
}

