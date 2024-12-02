data "aws_eks_cluster" "this" {
  name = local.name

  depends_on = [ aws_eks_cluster.aws_practical ]
}

data "aws_iam_openid_connect_provider" "this" {
  url = aws_eks_cluster.aws_practical.identity[0].oidc[0].issuer

  depends_on = [ aws_iam_openid_connect_provider.aws_practical_oidc ]
}

module "iam_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${local.name}-ReadCandidateS3Bucket"

  role_policy_arns = {
    policy = aws_iam_policy.read_candidate_s3_bucket.arn
  }

  oidc_providers = {
    oidc = {
      provider_arn               = data.aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["puppy-pics:puppy-pics"]
    }
  }
}

resource "aws_iam_policy" "read_candidate_s3_bucket" {
  name   = "${local.name}-read-candidate-s3-bucket"
  policy = data.aws_iam_policy_document.read_candidate_s3_bucket.json
}

data "aws_iam_policy_document" "read_candidate_s3_bucket" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "s3:ListObjects*",
    ]
    resources = ["arn:aws:s3:::${local.name}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket*",
    ]
    resources = ["arn:aws:s3:::${local.name}"]
  }
}
