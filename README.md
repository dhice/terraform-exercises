# terraform-exercises
Personal repo to learn terraform

## aws/lampstack
This exercise creates an AWS VPC, private & public subnets, 1 nginx load balancer, 3 php web apps, with 1 MySQL db

To run: 
    terraform apply -target=module.ec2.aws_instance.webapp             
    terraform apply
