resource "aws_vpc_dhcp_options" "shaandhcp" {
  domain_name         = var.DnsZoneName
  domain_name_servers = ["AmazonProvidedDNS"]
  tags = {
    Name = "My internal name"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.terraformmain.id
  dhcp_options_id = aws_vpc_dhcp_options.shaandhcp.id
}

/* DNS PART ZONE AND RECORDS */
resource "aws_route53_zone" "main" {
  name    = var.DnsZoneName
  vpc {
      vpc_id = aws_vpc.terraformmain.id
  }
  comment = "Managed by terraform"
}

resource "aws_route53_record" "database" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "mydatabase.${var.DnsZoneName}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.database.private_ip}"]
}

resource "aws_route53_record" "app0" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app0.${var.DnsZoneName}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.phpapp[0].private_ip}"]
}

resource "aws_route53_record" "app1" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app1.${var.DnsZoneName}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.phpapp[1].private_ip}"]
}

resource "aws_route53_record" "app2" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app2.${var.DnsZoneName}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.phpapp[2].private_ip}"]
}