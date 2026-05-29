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
  default     = "your-project-id"
  
}

variable "machine_type" {
  description = "The machine type for GKE nodes."
  type        = string
  default     = "n1-standard-2"
  
}

variable "initial_node_count" {
  description = "The initial number of nodes in the GKE cluster."
  type        = number
  default     = 2
}

variable "preemptible_nodes" {
  description = "Whether to use preemptible nodes in the GKE cluster."
  type        = bool
  default     = true
}

variable "enable_autoscaling" {
  description = "Whether to enable autoscaling for the GKE cluster."
  type        = bool
  default     = true
}

variable "min_node_count" {
  description = "The minimum number of nodes in the GKE cluster when autoscaling is enabled."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "The maximum number of nodes in the GKE cluster when autoscaling is enabled."
  type        = number
  default     = 2
}

variable "location" {
  description = "The location (zone or region) for the GKE cluster."
  type        = string
  default     = "us-central1-a"
}

