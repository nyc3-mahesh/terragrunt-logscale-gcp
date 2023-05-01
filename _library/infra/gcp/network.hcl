# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder. If any environment
# needs to deploy a different module version, it should redefine this block with a different ref to override the
# deployed version.

terraform {
  source = "${local.source_module.base_url}${local.source_module.version}"
}


# ---------------------------------------------------------------------------------------------------------------------
# Locals are named constants that are reusable within the configuration.
# ---------------------------------------------------------------------------------------------------------------------
locals {
  source_module = {
    base_url = "tfr:///terraform-google-modules/network/google"
    version  = "?version=6.0.1"
  }

  gcp_vars   = read_terragrunt_config(find_in_parent_folders("gcp.hcl"))
  project_id = local.gcp_vars.locals.project_id
  region     = local.gcp_vars.locals.region

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env      = local.environment_vars.locals.environment
  name     = local.environment_vars.locals.name
  codename = local.environment_vars.locals.codename

}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  network_name = "${local.name}-${local.env}-${local.codename}"
  routing_mode = "GLOBAL"
  project_id   = local.project_id
  subnets = [
    {
      subnet_name   = "k8s"
      subnet_ip     = "10.0.0.0/17"
      subnet_region = "us-central1"
    },
    # {
    #   subnet_name   = "k8s-svc"
    #   subnet_ip     = "10.0.2.0/23"
    #   subnet_region = "us-central1"
    # },
    # {
    #   subnet_name           = "k8s-pods"
    #   subnet_ip             = "10.0.4.0/23"
    #   subnet_region         = "us-central1"
    #   subnet_private_access = "true"
    #   # subnet_flow_logs      = "true"
    # }

  ]
  secondary_ranges = {
    "k8s" = [
      {
        range_name    = "pods"
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = "svc"
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }

}
#   name_suffix = "${local.name}-${local.env}-${local.codename}"
#   ip_ranges = {
#     private_primary    = "10.0.2.0/23"
#     private_g_services = "10.0.0.0/23"
#     proxy_only         = ""
#     private_k8s = [
#       {
#         pods_rname = "pods",
#         pods_cidr  = "10.0.4.0/23",
#         svcs_rname = "svc",
#         svcs_cidr  = "10.0.6.0/23"
#       }
#     ]
#     private_redis     = []
#     serverless_access = []
#   }

#   # enable_ipv6                     = true
#   # assign_ipv6_address_on_creation = true

#   # private_subnet_assign_ipv6_address_on_creation = true

#   # public_subnet_ipv6_prefixes  = [0, 1, 2]
#   # private_subnet_ipv6_prefixes = [3, 4, 5]


# }