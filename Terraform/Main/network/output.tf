module "network" {
  source               = "../../Modules/network"
  region               = var.region
  vpc                  = var.vpc
  public_cidr          = var.public_cidr
  default_tags = var.default_tags
  prefix       = var.prefix
}