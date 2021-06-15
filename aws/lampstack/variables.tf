variable "region" {
    default = "us-east-1"
    description = "AWS region"
}

variable "AmiLinux" {
  type = map(string)
  default = {
    eu-west-2 = "ami-a36f8dc4"
    eu-west-1 = "ami-ca0135b3"
    us-east-1 = "ami-14c5486b"
  }
  description = "AWS AMI image to use for instances"
}

variable "instance_type" {
    default = "t2.micro"
    description = "AWS EC2 instance type to run instances"
}

variable "keypair_name" {
    default = "LAMP_keypair"
    description = "Keypair name to connect remotely"
}

variable "webapp_count" {
    type = number
    default = 3
    description = "Number of webapp instances to use"
}