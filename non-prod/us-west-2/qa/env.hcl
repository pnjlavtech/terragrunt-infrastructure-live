# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  cidr        = "10.230.0.0/16"
  vpc_cidr    = local.cidr  

  environment = "qa"
  eks_name    = "eks-${local.environment}"

  
  # Set cidr_subnet newbits and netnums values to be common across all environments
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


# vpc_cidr = "10.231.0.0/16"   # stg
# vpc_cidr = "10.232.0.0/16"   # prod
