# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the source URL in the child terragrunt configurations.
  base_source_url = "git::git@github.com:pnjlavtech/terragrunt-infrastructure-modules.git//modules/vpc"

  # Set cidr
  cidr      = ${local.env} 
  vpc_cidr  = cidr

  # Set cidr_subnet newbits and netnums values to be common across all environments
  public_subnets = [
    cidrsubnet(vpc_cidr, 6, 0),
    cidrsubnet(vpc_cidr, 6, 1),
    cidrsubnet(vpc_cidr, 6, 2),
  ]

  private_subnets = [
    cidrsubnet(vpc_cidr, 6, 4),
    cidrsubnet(vpc_cidr, 6, 5),
    cidrsubnet(vpc_cidr, 6, 6),
  ]

  database_subnets = [
    cidrsubnet(vpc_cidr, 6, 7),
    cidrsubnet(vpc_cidr, 6, 8),
    cidrsubnet(vpc_cidr, 6, 9),
  ]

  eks_name = replace(var.environment, "_", "-")
}


# var.vpc_cidr = "10.230.0.0/16"
# cidrsubnet(prefix, newbits, netnum)
# newbits is the number of additional bits with which to extend the prefix
# netnum is a whole number that can be represented as a binary integer with no more than newbits binary digits, 
#     which will be used to populate the additional bits added to the prefix.


# newbits decides how much longer the resulting prefix will be in bits - for the subnet
# newbits = 6, use 6 more bits for the subnets
#       10 .      230  .      ?       .        0
# 00001010   11100110  | XXXXXX  | 00 | 00000000
#    parent network    | netnum  |   host

# The netnum argument then decides what number value to encode into those four new subnet bits. 
#       10 .      230  .      0       .        0
# 00001010   11100110  | 000000  | 00 | 00000000
#    parent network    | netnum  |   host
# so the third octet would be 0000 0000 in binary which is 0 in decimal
# so the subnet would be 10.230.0.0/22


#       10 .      230  .      1       .        0
# 00001010   11100110  | 000001  | 00 | 00000000
#    parent network    | netnum  |   host
# so the third octet would be 0000 0100 in binary which is 4 in decimal
# so the subnet would be 10.230.4.0/22

#       10 .      230  .      2       .        0
# 00001010   11100110  | 000010  | 00 | 00000000
#    parent network    | netnum  |   host
# so the third octet would be 0000 1000 in binary which is 8 in decimal
# so the subnet would be 10.230.8.0/22

#       10 .      230  .      4       .        0
# 00001010   11100110  | 000100  | 00 | 00000000
#    parent network    | netnum  |   host
# so the third octet would be 0000 1000 in binary which is 8 in decimal
# so the subnet would be 10.230.16.0/22









# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  database_subnet_ipv6_prefixes                 = [6, 7, 8]
  enable_ipv6                                   = true
  private_subnet_ipv6_prefixes                  = [3, 4, 5]
  public_subnet_assign_ipv6_address_on_creation = true
  public_subnet_ipv6_prefixes                   = [0, 1, 2]

  cidr                                            = ${local.env}
  create_database_subnet_group                    = false
  create_flow_log_cloudwatch_iam_role             = true
  create_flow_log_cloudwatch_log_group            = true
  database_subnets                                = local.database_subnets
  enable_dhcp_options                             = true
  enable_dns_hostnames                            = true
  enable_dns_support                              = true
  enable_flow_log                                 = true
  enable_nat_gateway                              = true
  flow_log_cloudwatch_log_group_retention_in_days = 7
  flow_log_max_aggregation_interval               = 60
  name                                            = ${local.env}
  one_nat_gateway_per_az                          = false
  private_subnet_suffix                           = "private"
  private_subnets                                 = local.private_subnets
  public_subnets                                  = local.public_subnets
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.eks_name}" = "shared"
    "kubernetes.io/role/elb"                  = 1
  }
  single_nat_gateway = true
  tags               = var.tags







  name              = "mysql_${local.env}"
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  storage_type      = "standard"
  master_username   = "admin"

  # TODO: To avoid storing your DB password in the code, set it as the environment variable TF_VAR_master_password
}
