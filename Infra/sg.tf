resource "aws_security_group" "drupal_sg" {
  name        = "drupal-security-group"
  description = "drupal security group for Terraform"

  vpc_id = module.vpc.vpc_id

  # Inbound rules
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with the desired source IP range
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with the desired source IP range
  }

  # Outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}