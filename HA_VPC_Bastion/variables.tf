variable "vpc_cidr" {
  description = "main_vpc_cidr"
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_a" {
  description = "public_subnet_A"
  type        = string
  default     = "10.0.11.0/24"
}

variable "public_subnet_b" {
  description = "public_subnet_B"
  type        = string
  default     = "10.0.21.0/24"
}

variable "private_subnet_a" {
  description = "private_subnet_A"
  type = string
  default = "10.0.12.0/24"
}

variable "private_subnet_b" {
  description = "private_subnet_B"
  type = string
  default = "10.0.22.0/24"
}

variable "db_subnet_a" {
  description = "db_subnet_A"
  type = string
  default = "10.0.13.0/24"
}

variable "db_subnet_b" {
  description = "db_subnet_B"
  type = string
  default = "10.0.23.0/24"
}

variable "availability_zone_a" {
  description = "availability_zone_A"
  type        = string
  default     = "us-east-1a"
}

variable "availability_zone_b" {
  description = "availability_zone_B"
  type        = string
  default     = "us-east-1b"
}

variable "ssh_port" {
  description = "SSH_port_for_sg"
  type        = number
  default     = 22
}

variable "allow_ssh_ip" {
  description = "administrators_ip"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "instance_type"
  type        = string
  default     = "t2.micro"
}

variable "pem_key" {
  description = "Pem key id"
  type        = string
  default     = "stage_key"
}