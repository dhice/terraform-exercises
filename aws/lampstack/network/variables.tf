variable "vpc" {
    type = object({
        tags_name = string
        cidr_block = string
    })

    default = {
        tags_name = "LampStack Exercise VPC"
        cidr_block = "172.16.0.0/16"
    }

    description = "AWS VPC variables: name=string cidr_block=string"
}

variable "internet_gateway_tags_name" {
    description = "Tag name for the internet gateway"
    default = "internet gateway terraform generated"
}

variable "dhcp_options" {
    type = object({
        dns_zone_name = string
        domain_name_servers = list(string)
        tags_name = string
    })
    default = {
        tags_name = "internal DHCP options by terraform"
        domain_name_servers = ["AmazonProvidedDNS"]
        dns_zone_name = "lampstack.internal"
    }
    description = "AWS DHCP options variables: dns_zone_name=string domain_name_servers=list(string) tags_name=string"
}

variable "route_53_zone_comment" {
    description = "Comment for route 53 zone"
    default = "maintained by terraform"
}

variable "subnet_public" {
    type = object({
        tags_name = string
        cidr_block = string
    })
    default = {
        tags_name = "public subnet by terraform"
        cidr_block = "172.16.0.0/24"
    }
    description = "Public AWS subnet variables: tags_name=string cidr_block=string"
}

variable "public_route_table" {
    type = object({
        tags_name = string
        cidr_block = string
    })
    default = {
        tags_name = "public route table by terraform"
        cidr_block = "0.0.0.0/0"
    }
    description = "Public route table variables: tags_name=string cidr_block=string"
}

variable "subnet_private" {
    type = object({
        tags_name = string
        cidr_block = string
    })
    default = {
        tags_name = "private subnet by terraform"
        cidr_block = "172.16.3.0/24"
    }
    description = "Private AWS subnet variables: tags_name=string cidr_block=string"
}

variable "private_route_table" {
    type = object({
        tags_name = string
        cidr_block = string
    })
    default = {
        tags_name = "private route table by terraform"
        cidr_block = "0.0.0.0/0"
    }
    description = "Private route table variables: tags_name=string cidr_block=string"
}
