locals {
  name = "aws-practical-${var.identifier}"
  tags = {
    provisioner = "terraform"
    Name        = local.name
  }
}
