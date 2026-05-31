module "vpc_private" {
  source                        = "git::https://github.com/luis-0419/gcp-terraform-modules.git//vpc?ref=master"
  
  project_id                = var.project_id
  vpc_name                  = "${var.vpc_name}-${var.environment}-private-001"
  auto_create_subnetworks   = false
  routing_mode                  = "REGIONAL"
  subnets           = [
    {
      name                = "${var.vpc_name}-${var.environment}-subnet-private-us-central1"
      region            = "us-central1"
      ip_cidr_range   = var.ip_cidr_range_private
      private_ip_google_access  = true
      enable_flow_logs = false
      secondary_ranges = [
        {
          range_name    = "pods"
          ip_cidr_range = "10.4.0.0/14"
        },
        {
          range_name    = "services"
          ip_cidr_range = "10.8.0.0/20"
        }
      ]
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
  vpc_name                  = "${var.vpc_name}-${var.environment}-public-001"
  auto_create_subnetworks   = false
  routing_mode                  = "REGIONAL"
  subnets           = [
    {
      name                = "${var.vpc_name}-${var.environment}-subnet-public-us-central1"
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

module "vpc_peering" {
  source             =  "git::https://github.com/luis-0419/gcp-terraform-modules.git//vpc_peering?ref=master"

  project_id = var.project_id
  peer_network_name = module.vpc_public.network_name
  peer_project_id = var.project_id
  local_network_name = module.vpc_private.network_name

  
  labels = {
    environment                 = var.environment
    team        = var.team
  }


  depends_on = [ module.vpc_private, module.vpc_public ]
}




module "gke" {
  source                       = "git::https://github.com/luis-0419/gcp-terraform-modules.git//gke?ref=master"
  
  project_id                   = var.project_id
  cluster_name   = "gke-${var.environment}-cluster-001"
  location       = var.location
  network_name   = module.vpc_private.network_name
  subnetwork_name = module.vpc_private.subnet_names[0]

  initial_node_count           = var.initial_node_count
  machine_type            = var.machine_type
  preemptible_nodes       = var.preemptible_nodes
  enable_autoscaling      = var.enable_autoscaling
  min_node_count          = var.min_node_count
  max_node_count          = var.max_node_count
  
  enable_shielded_nodes   = true
  enable_ip_alias         = true
  cluster_secondary_range_name  = "pods"
  services_secondary_range_name = "services"
  release_channel         = "REGULAR"
  
  labels = {
    environment = var.environment
  }


  depends_on                    = [ module.vpc_peering ]
}

module "private_lb" {
  source              = "git::https://github.com/luis-0419/gcp-terraform-modules.git//private_lb?ref=master"

  project_id         = var.project_id
  load_balancer_name               = "private-lb-${var.environment}-001"
  region             = var.location
  network            = module.vpc_private.network_name
  subnetwork         = module.vpc_private.subnet_names[0]
  labels = {
    environment = var.environment
  }

}


# module "apigee" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/apigee"

# }


# module "psc" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/psc"
# }

# module "external_lb" {
#   source = "https://github.com/luis-0419/gcp-terraform-modules/tree/master/external_lb"
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
