# resource "aws_kms_key" "eks" {
#   description             = "Encrypts Kubernetes secrets for ${var.cluster_name}"
#   enable_key_rotation     = true
#   deletion_window_in_days = 7
# }

# resource "aws_cloudwatch_log_group" "eks" {
#   name              = "/aws/eks/${var.cluster_name}/cluster"
#   retention_in_days = 30
# }

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    # public_access_cidrs     = var.admin_cidrs
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

#   encryption_config {
#     resources = ["secrets"]
#     provider {
#       key_arn = aws_kms_key.eks.arn
#     }
#   }

#   enabled_cluster_log_types = ["api", "audit", "authenticator"]

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}