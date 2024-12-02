locals {
  files = fileset("${path.module}/photos", "*.*")
}

resource "aws_s3_bucket" "aws_practical" {
  bucket = local.name

  # Allows tf destroy to delete the bucket even with objects
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_object" "puppy_pics" {
  for_each = { for f in local.files : f => f }
  bucket   = local.name
  key      = each.value
  source   = "${path.module}/photos/${each.value}"

  depends_on = [ aws_s3_bucket.aws_practical ]
}
