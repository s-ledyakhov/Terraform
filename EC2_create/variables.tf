variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "ubuntu_volume" {
  description = "Ubuntu volume size"
  type        = string
  default     = "10"
}

variable "windows_volume" {
  description = "Windows volume size"
  type        = string
  default     = "30"
}

variable "allow_ports" {
  description = "List of Ports to ACL"
  type        = list(any)
  default     = ["22", "3389"]
}

variable "pem_key" {
  description = "Pem key id"
  type        = string
  default     = "stage_key"
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(any)
  default = {
    Owner       = "main_ops"
    Environment = "stage "
  }
}
