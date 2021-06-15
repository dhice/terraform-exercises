data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr_block
  #### this 2 true values are for use the internal vpc dns resolution
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc.tags_name
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "internet gw terraform generated"
  }
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = var.dhcp_options.dns_zone_name
  domain_name_servers = var.dhcp_options.domain_name_servers
  tags = {
    Name = var.dhcp_options.tags_name
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = aws_vpc.vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options.id
}

resource "aws_route53_zone" "main" {
  name    = var.dhcp_options.dns_zone_name
  vpc {
      vpc_id = aws_vpc.vpc.id
  }
  comment = var.route_53_zone_comment
}

resource "aws_eip" "for_nat" {
  vpc = true
}

resource "aws_nat_gateway" "public_subnet_nat_gateway" {
  allocation_id = aws_eip.for_nat.id
  subnet_id     = aws_subnet.subnet_public.id
  depends_on    = [aws_internet_gateway.internet_gateway]
}

resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_public.cidr_block
  tags = {
    Name = var.subnet_public.tags_name
  }
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.public_route_table.tags_name
  }
  route {
    cidr_block = var.public_route_table.cidr_block
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "subnet_public_route_table" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_subnet" "subnet_private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet_private.cidr_block
  tags = {
    Name = var.subnet_private.tags_name
  }
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.private_route_table.tags_name
  }
  route {
    cidr_block     = var.private_route_table.cidr_block
    nat_gateway_id = aws_nat_gateway.public_subnet_nat_gateway.id
  }
}

resource "aws_route_table_association" "subnet_private_route_table" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.private_route_table.id
}