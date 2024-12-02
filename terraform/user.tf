
resource "aws_iam_user" "this" {
  name          = local.name
  force_destroy = true

  tags = local.tags
}

resource "aws_iam_user_policy_attachment" "this" {
  user       = aws_iam_user.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_policy_attachment" "console_admin" {
  user       = aws_iam_user.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user_policy_attachment" "dynamo_access" {
  user       = aws_iam_user.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_user_policy_attachment" "iam_access" {
  user       = aws_iam_user.this.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_policy" "iam_user_eks_allow_all" {
  name = "${local.name}-allow-all-eks"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowUserEKSAccess",
        "Effect" : "Allow",
        "Action": "eks:*",
        "Resource" : "*"
      }
    ]
  })
}
resource "aws_iam_user_policy_attachment" "iam_user_eks_allow_all_attachment" {
  user       = aws_iam_user.this.name
  policy_arn = aws_iam_policy.iam_user_eks_allow_all.arn
}

resource "pgp_key" "this" {
  name    = "AWS Practical"
  email   = "email@example.com"
  comment = "Used to encrypt user creds from AWS API"
}

resource "aws_iam_user_login_profile" "this" {
  pgp_key                 = pgp_key.this.private_key_base64
  password_reset_required = false
  user                    = aws_iam_user.this.name
}

resource "aws_iam_access_key" "this" {
  user    = aws_iam_user.this.name
  pgp_key = pgp_key.this.private_key_base64
}

data "pgp_decrypt" "security_token" {
  private_key         = pgp_key.this.private_key
  ciphertext          = aws_iam_access_key.this.encrypted_secret
  ciphertext_encoding = "base64"
}

data "pgp_decrypt" "console_password" {
  private_key         = pgp_key.this.private_key
  ciphertext          = aws_iam_user_login_profile.this.encrypted_password
  ciphertext_encoding = "base64"
}
