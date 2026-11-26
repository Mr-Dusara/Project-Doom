resource "aws_security_group" "nodes" {
  name        = "${var.cluster_name}-nodes"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-nodes"
    # lets the AWS Load Balancer Controller find this group later
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Node to node (pod traffic between nodes, DNS)
resource "aws_vpc_security_group_ingress_rule" "nodes_self" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "-1"
  description                  = "Node to node, all traffic"
}

# Control plane to nodes
resource "aws_vpc_security_group_ingress_rule" "nodes_from_cluster_443" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "Control plane to nodes (extension API servers)"
}

resource "aws_vpc_security_group_ingress_rule" "nodes_from_cluster_high" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = 1025
  to_port                      = 65535
  description                  = "Control plane to nodes (kubelet 10250, webhooks)"
}

# Nodes to control plane API
resource "aws_vpc_security_group_ingress_rule" "cluster_from_nodes" {
  security_group_id            = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  description                  = "Nodes to cluster API"
}

# Nodes to the internet (through NAT) for image pulls and AWS APIs
resource "aws_vpc_security_group_egress_rule" "nodes_all_out" {
  security_group_id = aws_security_group.nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Nodes outbound via NAT"
}

resource "aws_launch_template" "nodes" {
  name_prefix            = "${var.cluster_name}-node-"
  vpc_security_group_ids = [aws_security_group.nodes.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types
  ami_type        = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = aws_launch_template.nodes.latest_version
  }

  depends_on = [
    aws_iam_role_policy_attachment.node,
    aws_vpc_security_group_ingress_rule.cluster_from_nodes,
  ]
}