module "vpc_private" {
  source                        = "git::https://github.com/luis-0419/gcp-terraform-modules.git//vpc?ref=master"
  
  project_id                = var.project_id
  vpc_name                  = "${var.vpc_name}-${var.environment}-private-vpc-001"
  auto_create_subnetworks   = false
  routing_mode                  = "REGIONAL"
  subnets           = [
    {
      name                = "${var.vpc_name}-${var.environment}-subnet-us-central1"
      region            = "us-central1"
      ip_cidr_range   = var.ip_cidr_range_private
      private_ip_google_access  = true
      enable_flow_logs = false
    }
  ]
  
  labels = {
    environment                 = var.environment
    team        = var.team
  }
}

module "vpc_public" {
  source                        = "git::https://github.com/luis-0419/gcp-terraform-modules.git//vpc?ref=master"
  
  project_id                = var.project_id
  vpc_name                  = "${var.vpc_name}-${var.environment}-public-vpc-1"
  auto_create_subnetworks   = false
  routing_mode                  = "REGIONAL"
  subnets           = [
    {
      name                = "${var.vpc_name}-${var.environment}-subnet-us-central1"
      region            = "us-central1"
      ip_cidr_range   = var.ip_cidr_range_public
      private_ip_google_access  = true
      enable_flow_logs = false
    }
  ]
  
  labels = {
    environment                 = var.environment
    team        = var.team
  }
}

# module "vpc_peering" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/vpc_peering"
# }




# module "gke" {
#   source = "git::https://github.com/luis-0419/gcp-terraform-modules.git//gke?ref=master"
#   
#   project_id     = "my-project"
#   cluster_name   = "my-cluster"
#   location       = "us-central1-a"
#   network_name   = "my-vpc"
#   subnetwork_name = "my-subnet"
#   
#   initial_node_count      = 3
#   machine_type            = "n1-standard-2"
#   preemptible_nodes       = true
#   enable_autoscaling      = true
#   min_node_count          = 1
#   max_node_count          = 10
#   
#   enable_shielded_nodes   = true
#   enable_ip_alias         = true
#   cluster_secondary_range_name  = "pods"
#   services_secondary_range_name = "services"
#   release_channel         = "REGULAR"
#   
#   labels = {
#     environment = "production"
#   }
# }

# module "apigee" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/apigee"

# }


# module "psc" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/psc"
# }

# module "external_lb" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/external_lb"
# }

# module "private_lb" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/private_lb"
# }

# module "cloud_armor" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/cloud_armor"
# }

# module "cloud_nat" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/cloud_nat"
# }

# module "registry" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/registry"
# }

# module "virtual_machine" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/compute"
# }
