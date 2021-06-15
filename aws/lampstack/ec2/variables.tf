variable "vpc_id" {
    description = "AWS VPC ID"
}

variable "public_subnet_id" {
    description = "AWS public subnet ID"
}

variable "private_subnet_id" {
    description = "AWS private subnet ID"
}

variable "route53_zone_id" {
    description = "AWS Route 53 Zone ID for instances"
}

variable "domain" {
    description = "AWS domain name"
}

variable "nginx" {
    type = object({
        instance_type = string
        ami = string
        keypair_name = string
    })
    description = "NGINX variables: instance_type:string tags_name:string ami:string keypair_name:string security_group_name:string"
}

variable "webapp" {
    type = object ({
        instance_type = string
        ami = string
        keypair_name = string
        count = number 
    })
    description = "Webapp variables: instance_type:string tags_name:string ami:string keypair_name:string count:number security_group_name:string"
}

variable "db" {
    type = object ({
        instance_type = string
        ami = string
        keypair_name = string
    })
    description = "DB variables: instance_type:string tags_name:string ami:string keypair_name:string security_group_name:string"
}
