# Initial design copied from https://github.com/hashicorp/terraform-provider-aws/blob/main/examples/eks-getting-started/eks-cluster.tf

# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController",
  ])
  role   = aws_iam_role.eks_cluster.name
  policy_arn = each.value
}

resource "aws_iam_role" "eks_cluster" {
  name = "${local.name}-cluster"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = local.tags
}

resource "aws_security_group" "eks_cluster" {
  name        = "eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.aws_practical.id

  tags = local.tags
}

resource "aws_eks_cluster" "aws_practical" {
  name     = local.name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster.id]
    subnet_ids         = [aws_subnet.private_use_1a.id, aws_subnet.private_use_1b.id]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  tags = local.tags
}

data "tls_certificate" "aws_practical_eks" {
  url = aws_eks_cluster.aws_practical.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "aws_practical_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.aws_practical_eks.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.aws_practical_eks.url

  depends_on = [ aws_eks_cluster.aws_practical ]
}

# Initial design copied from https://github.com/hashicorp/terraform-provider-aws/blob/main/examples/eks-getting-started/eks-worker-nodes.tf

# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes

resource "aws_iam_role_policy_attachment" "eks_worker_role_attachments" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ])
  role   = aws_iam_role.eks_worker.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "eks_worker_role_ecr_read_attachment" {
  role   = aws_iam_role.eks_worker.name
  policy_arn = aws_iam_policy.eks_worker_read_ecr.arn
}

resource "aws_iam_role" "eks_worker" {
  name = "${local.name}-worker"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = local.tags
}

resource "aws_iam_policy" "eks_worker_read_ecr" {
  name = "${local.name}-eks-worker-read-ecr"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "AllowEKSWorkerReadECR",
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_eks_node_group" "aws_practical" {
  cluster_name    = aws_eks_cluster.aws_practical.name
  node_group_name = local.name
  node_role_arn   = aws_iam_role.eks_worker.arn
  subnet_ids      = [aws_subnet.private_use_1a.id, aws_subnet.private_use_1b.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  tags = local.tags

  depends_on = [
    aws_route_table_association.private_use_1a,
    aws_route_table_association.public_use_1a,
    aws_route_table_association.private_use_1b,
    aws_route_table_association.public_use_1b,
  ]
}

resource "aws_eks_access_entry" "this" {
  cluster_name      = aws_eks_cluster.aws_practical.name
  principal_arn     = aws_iam_user.this.arn
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "this" {
  cluster_name  = aws_eks_cluster.aws_practical.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_iam_user.this.arn

  access_scope {
    type       = "cluster"
  }

  depends_on = [ aws_eks_access_entry.this ]
}

resource "helm_release" "puppy-pics" {
  name       = "puppy-pics"
  chart      = "../helm/puppy-pics"
  namespace = "puppy-pics"
  create_namespace = true

  values = [
    "${file("../helm/puppy-pics/values.yaml")}"
  ]

  set {
    name  = "image.tag"
    value = "v1.0.5"
  }

  set {
    name  = "deployment.bucketName"
    value = local.name
  }

  set {
    name  = "serviceAccount.roleArn"
    value = "arn:aws:iam::283535628747:role/changeme"
  }

  set {
    name  = "service.allowlist"
    value = "1.2.3.4/32"
  }


  depends_on = [ aws_eks_cluster.aws_practical, aws_eks_node_group.aws_practical ]
}
