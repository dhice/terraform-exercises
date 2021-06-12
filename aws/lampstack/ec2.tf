resource "aws_instance" "nginx" {
    ami                         = lookup(var.AmiLinux, var.region)
    instance_type               = "t2.micro"
    associate_public_ip_address = "true"
    subnet_id                   = aws_subnet.PublicAZA.id
    vpc_security_group_ids      = ["${aws_security_group.Nginx.id}"]
    key_name                    = var.key_name
    tags = {
        Name = "NGINX"
    }
    user_data = <<HEREDOC
    #!/bin/bash
    yum update -y
    yum install -y nginx
    echo "http {" > /etc/nginx/nginx.conf
    echo "  upstream backend {" >> /etc/nginx/nginx.conf
    echo "    server app0.ShaanAWSDNS.internal ;" >> /etc/nginx/nginx.conf
    echo "    server app1.ShaanAWSDNS.internal;" >> /etc/nginx/nginx.conf
    echo "    server app2.ShaanAWSDNS.internal;" >> /etc/nginx/nginx.conf
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
HEREDOC
}

resource "aws_instance" "phpapp" {
  ami                         = lookup(var.AmiLinux, var.region)
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  count = 3
  subnet_id                   = aws_subnet.PrivateAZA.id
  vpc_security_group_ids      = ["${aws_security_group.WebApp.id}"]
  key_name                    = var.key_name
  tags = {
    Name = "My Web App"
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
  echo "\$conn = new mysqli('mydatabase.ShaanAWSDNS.internal', 'root', 'secret', 'test');" >> /var/www/html/myApp.php
  echo "\$sql = 'SELECT * FROM Employees'; " >> /var/www/html/myApp.php
  echo "\$result = \$conn->query(\$sql); " >>  /var/www/html/myApp.php
  echo "while(\$row = \$result->fetch_assoc()) { echo 'the value is: ' . \$row['NAME'],  \$row['ADDRESS'];} " >> /var/www/html/myApp.php
  echo "\$conn->close(); " >> /var/www/html/myApp.php
  echo "?>" >> /var/www/html/myApp.php
HEREDOC
}

resource "aws_instance" "database" {
  ami                         = lookup(var.AmiLinux, var.region)
  instance_type               = "t2.micro"
  associate_public_ip_address = "false"
  subnet_id                   = aws_subnet.PrivateAZA.id
  vpc_security_group_ids      = ["${aws_security_group.MySQLDB.id}"]
  key_name                    = var.key_name
  tags = {
    Name = "sql database"
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