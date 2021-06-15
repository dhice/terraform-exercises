output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "route53_zone_id" {
    value = aws_route53_zone.main.id
}

output "public_subnet_id" {
    value = aws_subnet.subnet_public.id
}

output "private_subnet_id" {
    value = aws_subnet.subnet_private.id
}

output "domain" {
    value = aws_vpc_dhcp_options.dhcp_options.domain_name
}