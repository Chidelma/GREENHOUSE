output "oidc_provider_url" {
  value = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "iam_role_arn" {
  value = module.iam_eks_role.iam_role_arn
}

output "message" {
  value = <<EOT

Hi candidate!

The AWS console is accessible at:

URL: https://283535628747.signin.aws.amazon.com/console
user: ${aws_iam_user.this.name}
password: ${data.pgp_decrypt.console_password.plaintext}

You can set up your aws cli profile running:

aws configure --profile ${var.identifier}-interview

This will prompt you for the keys below:

AWS_ACCESS_KEY_ID=${aws_iam_access_key.this.id}
AWS_SECRET_ACCESS_KEY=${data.pgp_decrypt.security_token.plaintext}
AWS_REGION="us-east-1"

Please make sure you set your AWS_PROFILE, and INITIALS environment variable as well:

export AWS_PROFILE=${var.identifier}-interview
export INITIALS=${var.identifier}

Your K8s cluster is called "aws-practical-${var.identifier}". After configuring the AWS CLI, you can enable kubectl access by running the below command: 

aws eks --region us-east-1 update-kubeconfig --name aws-practical-${var.identifier} --profile ${var.identifier}-interview

EOT
}
