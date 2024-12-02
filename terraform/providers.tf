locals {
  interview_account_id = "283535628747"
}

provider "aws" {
  allowed_account_ids = [local.interview_account_id]
  region              = "us-east-1"
}

provider "helm" {
  kubernetes {
    host = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.this.name]
      command     = "aws"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.73.0"
    }
    pgp = {
      source  = "ekristen/pgp"
      version = "0.2.4"
    }
  }

  required_version = ">= 0.13"
}
