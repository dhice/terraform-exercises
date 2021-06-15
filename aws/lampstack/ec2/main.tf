resource "aws_instance" "nginx" {
    ami                         = var.nginx.ami
    instance_type               = var.nginx.instance_type
    associate_public_ip_address = "true"
    subnet_id                   = var.public_subnet_id
    vpc_security_group_ids      = ["${aws_security_group.nginx_security_group.id}"]
    key_name                    = var.nginx.keypair_name
    depends_on = [aws_route53_record.webapp_addresses]
    tags = {
        Name = "nginx"
    }
    user_data = <<EOT
    #!/bin/bash
    yum update -y
    yum install -y nginx
    echo "http {" > /etc/nginx/nginx.conf
    echo "  upstream backend {" >> /etc/nginx/nginx.conf
    %{for address in aws_route53_record.webapp_addresses}
    echo "    server ${address.name} ;" >> /etc/nginx/nginx.conf
    %{endfor}
    echo "  }" >> /etc/nginx/nginx.conf
    echo "  server {" >> /etc/nginx/nginx.conf
    echo "    listen 80;" >> /etc/nginx/nginx.conf
    echo "    location / {" >> /etc/nginx/nginx.conf
    echo "      proxy_pass http://backend/myApp.php;" >> /etc/nginx/nginx.conf
    echo "    }" >> /etc/nginx/nginx.conf
    echo "  }" >> /etc/nginx/nginx.conf
    echo "}" >> /etc/nginx/nginx.conf
    echo "events {}" >> /etc/nginx/nginx.conf
    sudo service nginx start
}
EOT
}

resource "aws_instance" "webapp" {
  ami                         = var.webapp.ami
  instance_type               = var.webapp.instance_type
  associate_public_ip_address = "false"
  count = var.webapp.count
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = ["${aws_security_group.webapp_security_group.id}"]
  key_name                    = var.webapp.keypair_name
  tags = {
    Name = "webapp-${count.index}"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  yum update -y
  yum install -y httpd24 php56 php56-mysqlnd
  service httpd start
  chkconfig httpd on
  echo "<?php" >> /var/www/html/myApp.php
  echo "ini_set('display_errors', 1);" >> /var/www/html/myApp.php
  echo "ini_set('display_startup_errors', 1);" >> /var/www/html/myApp.php
  echo "error_reporting(E_ALL);" >> /var/www/html/myApp.php
  echo "\$conn = new mysqli('mydatabase.${var.domain}', 'root', 'secret', 'test');" >> /var/www/html/myApp.php
  echo "\$sql = 'SELECT * FROM Employees'; " >> /var/www/html/myApp.php
  echo "\$result = \$conn->query(\$sql); " >>  /var/www/html/myApp.php
  echo "while(\$row = \$result->fetch_assoc()) { echo 'the value is: ' . \$row['NAME'],  \$row['ADDRESS'];} " >> /var/www/html/myApp.php
  echo "\$conn->close(); " >> /var/www/html/myApp.php
  echo "?>" >> /var/www/html/myApp.php
HEREDOC
}

resource "aws_instance" "database" {
  ami                         = var.db.ami
  instance_type               = var.db.instance_type
  associate_public_ip_address = "false"
  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = ["${aws_security_group.db_security_group.id}"]
  key_name                    = var.db.keypair_name
  tags = {
    Name = "db"
  }
  user_data = <<HEREDOC
  #!/bin/bash
  sleep 180
  yum update -y
  yum install -y mysql55-server
  service mysqld start
  /usr/bin/mysqladmin -u root password 'secret'
  mysql -u root -psecret -e "create user 'root'@'%' identified by 'secret';" mysql
  mysql -u root -psecret -e 'CREATE TABLE Employees (ID int(11) NOT NULL AUTO_INCREMENT, NAME varchar(45) DEFAULT NULL, ADDRESS varchar(255) DEFAULT NULL, PRIMARY KEY (ID));' test
  mysql -u root -psecret -e "INSERT INTO Employees (NAME, ADDRESS) values ('JOHN', 'LONDON UK') ;" test
HEREDOC
}

# DNS records for the instances


resource "aws_route53_record" "database" {
  zone_id = var.route53_zone_id
  name    = "mydatabase.${var.domain}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.database.private_ip}"]
}

resource "aws_route53_record" "webapp_addresses" {
    for_each = {for webapp in aws_instance.webapp.*: webapp.id => webapp }

    zone_id = var.route53_zone_id
    name    = "app-${each.value.id}.${var.domain}"
    type    = "A"
    ttl     = "300"
    records = [each.value.private_ip]
}
