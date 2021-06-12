resource "aws_security_group" "Nginx" {
  name = "Nginx"
  tags = {
    Name = "Nginx"
  }
  description = "ONLY HTTP CONNECTION INBOUND"
  vpc_id      = aws_vpc.terraformmain.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "WebApp" {
  name = "WebApp"
  tags = {
    Name = "WebApp"
  }
  description = "ONLY ACCESSABLE BY NGINX & SSH"
  vpc_id      = aws_vpc.terraformmain.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    security_groups = ["${aws_security_group.Nginx.id}"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "MySQLDB" {
  name = "MySQLDB"
  tags = {
    Name = "MySQLDB"
  }
  description = "ONLY ACCESSABLE BY PHP & SSH"
  vpc_id      = aws_vpc.terraformmain.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = ["${aws_security_group.WebApp.id}"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
