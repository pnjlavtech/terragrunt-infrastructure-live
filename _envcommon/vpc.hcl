# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for mysql. The common variables for each environment to
# deploy mysql are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  aws_region = local.region_vars.locals.aws_region
  cidr       = local.environment_vars.locals.cidr
  eks_name   = local.environment_vars.locals.eks_name
  env        = local.environment_vars.locals.environment
  env-region = "${local.env}-${local.aws_region}"
  vpc_cidr   = local.cidr


  # Expose the base source URL so different versions of the module can be deployed in different environments. 
  # This will be used to construct the source URL in the child terragrunt configurations.
  base_source_url = "git::git@github.com:pnjlavtech/terragrunt-infrastructure-modules.git//modules/vpc"

  //  Set cidr_subnet newbits and netnums values to be common across all environments
  public_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 0),
    cidrsubnet(local.vpc_cidr, 6, 1),
    cidrsubnet(local.vpc_cidr, 6, 2),
  ]

  private_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 4),
    cidrsubnet(local.vpc_cidr, 6, 5),
    cidrsubnet(local.vpc_cidr, 6, 6),
  ]

  database_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 7),
    cidrsubnet(local.vpc_cidr, 6, 8),
    cidrsubnet(local.vpc_cidr, 6, 9),
  ]

}




# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. 
# This defines the parameters that are common across all environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cidr                                            = local.cidr
  database_subnets                                = local.database_subnets
  name                                            = local.env
  private_subnets                                 = local.private_subnets
  public_subnets                                  = local.public_subnets
  database_subnet_tags = {
    env                   = "${local.env}"
    fullname              = "${local.env}-vpc-subnet-database-${local.aws_region}" 
    module-component      = "subnet"
    module-component-type = "subnet-database"
  }
  private_subnet_tags = {
    env                   = "${local.env}"
    fullname              = "${local.env}-vpc-subnet-private-${local.aws_region}" 
    module-component      = "subnet"
    module-component-type = "subnet-private"
  }
  public_subnet_tags = {
    env                                       = "${local.env}"
    fullname                                  = "${local.env}-vpc-subnet-public-${local.aws_region}" 
    "kubernetes.io/cluster/${local.eks_name}" = "shared"
    "kubernetes.io/role/elb"                  = 1
    module-component                          = "subnet"
    module-component-type                     = "subnet-public"
  }

}
