terraform {
  backend "s3" {
    bucket         = "grnhse-tf-state-interview-use1"
    dynamodb_table = "grnhse-tf-state-interview-use1"
    encrypt        = true
    region         = "us-east-1"
  }
}
