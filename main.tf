# IAM Role for the EKS Cluster
resource "aws_iam_role" "cluster-role2" {
  name = "cluster-role2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach necessary policies to the cluster role
resource "aws_iam_role_policy_attachment" "cluster-policy2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster-role2.name
}

# IAM Role for the EKS Node Group
resource "aws_iam_role" "node-role2" {
  name = "node-role2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach necessary policies to the node role
resource "aws_iam_role_policy_attachment" "node-policy2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role2.name
}

resource "aws_iam_role_policy_attachment" "cni-policy2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"  # Updated policy ARN
  role       = aws_iam_role.node-role2.name
}

resource "aws_iam_role_policy_attachment" "registry-policy2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role2.name
}

# EKS Cluster
resource "aws_eks_cluster" "eks-cluster2" {
  name     = "k8-cluster2"
  role_arn = aws_iam_role.cluster-role2.arn
  version  = "1.31"

  vpc_config {
    subnet_ids         = ["subnet-062cac3831aa2af25", "subnet-09bb828737a4db56e"]
    security_group_ids = ["sg-0b7bee4c390b66aad"]
  }

  depends_on = [aws_iam_role_policy_attachment.cluster-policy2]
}

# EKS Node Group
resource "aws_eks_node_group" "k8-cluster-node-group2" {
  cluster_name    = aws_eks_cluster.eks-cluster2.name
  //instance_types = ["t2.micro"]
  node_group_name = "k8-cluster-node-group2"
  node_role_arn   = aws_iam_role.node-role2.arn
  subnet_ids      = ["subnet-062cac3831aa2af25", "subnet-09bb828737a4db56e"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

 depends_on = [
    aws_iam_role_policy_attachment.node-policy2,
    aws_iam_role_policy_attachment.cni-policy2,
    aws_iam_role_policy_attachment.registry-policy2
  ]
}
