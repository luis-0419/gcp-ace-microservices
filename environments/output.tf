output "vpc_private_name" {
  description = "Private VPC network name"
  value       = module.vpc_private.network_name
}

output "vpc_private_id" {
  description = "Private VPC network ID"
  value       = module.vpc_private.network_id
}

output "vpc_private_self_link" {
  description = "Private VPC self link"
  value       = module.vpc_private.network_self_link
}

output "vpc_private_subnets" {
  description = "Private VPC subnets"
  value       = module.vpc_private.subnets
}

output "vpc_public_name" {
  description = "Public VPC network name"
  value       = module.vpc_public.network_name
}

output "vpc_public_id" {
  description = "Public VPC network ID"
  value       = module.vpc_public.network_id
}

output "vpc_public_self_link" {
  description = "Public VPC self link"
  value       = module.vpc_public.network_self_link
}

output "vpc_public_subnets" {
  description = "Public VPC subnets"
  value       = module.vpc_public.subnets
}