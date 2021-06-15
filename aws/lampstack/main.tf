provider "aws" { 
  region     = var.region
}

module "network" {
    source = "./network"
}

module "ec2" {
   source = "./ec2"

   vpc_id = module.network.vpc_id
   route53_zone_id = module.network.route53_zone_id
   public_subnet_id = module.network.public_subnet_id
   private_subnet_id = module.network.private_subnet_id
   domain = module.network.domain

   nginx = {
        instance_type = var.instance_type
        ami = lookup(var.AmiLinux, var.region)
        keypair_name = var.keypair_name
    }

    webapp = {
        instance_type = var.instance_type
        ami = lookup(var.AmiLinux, var.region)
        count = var.webapp_count 
        keypair_name = var.keypair_name
    }

    db = {
        instance_type = var.instance_type
        ami = lookup(var.AmiLinux, var.region)
        keypair_name = var.keypair_name
    }
}