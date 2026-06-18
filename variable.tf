variable "aws_region" {
  description = "My Virginia Region VPC"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "pub subnet cidr block"
  default = "0.0.0.0/0"
}
