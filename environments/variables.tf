variable "vpc_name" {
  description = "The name of the VPC network."
  type        = string
  default     = "ace-vpc"
  
}

variable "environment" {
  description = "The environment name."
  type        = string
  default     = "dev"
}

variable "team" {
  description = "The team name."
  type        = string
  default     = "platform"
}

variable "ip_cidr_range_private" {
  description = "The IP CIDR range for the private subnet."
  type        = string
  default     = "10.1.0.0/16"
}

variable "ip_cidr_range_public" {
  description = "The IP CIDR range for the public subnet."
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
  default     = ""
  
}