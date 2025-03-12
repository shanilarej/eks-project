# IAM Role for the EKS Cluster
resource "aws_iam_role" "cluster-role1" {
  name = "cluster-role1"

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
resource "aws_iam_role_policy_attachment" "cluster-policy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster-role1.name
}

# IAM Role for the EKS Node Group
resource "aws_iam_role" "node-role1" {
  name = "node-role1"

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
resource "aws_iam_role_policy_attachment" "node-policy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-role1.name
}

resource "aws_iam_role_policy_attachment" "cni-policy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"  # Updated policy ARN
  role       = aws_iam_role.node-role1.name
}

resource "aws_iam_role_policy_attachment" "registry-policy1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-role1.name
}

# EKS Cluster
resource "aws_eks_cluster" "eks-cluster1" {
  name     = "k8-cluster1"
  role_arn = aws_iam_role.cluster-role1.arn
  version  = "1.31"

  vpc_config {
    subnet_ids         = ["subnet-062cac3831aa2af25", "subnet-09bb828737a4db56e"]
    security_group_ids = ["sg-0b7bee4c390b66aad"]
  }

  depends_on = [aws_iam_role_policy_attachment.cluster-policy1]
}

# EKS Node Group
resource "aws_eks_node_group" "k8-cluster-node-group1" {
  cluster_name    = aws_eks_cluster.eks-cluster1.name
  //instance_types = ["t2.micro"]
  node_group_name = "k8-cluster-node-group1"
  node_role_arn   = aws_iam_role.node-role1.arn
  subnet_ids      = ["subnet-062cac3831aa2af25", "subnet-09bb828737a4db56e"]

  scaling_config {
    desired_size = 3
    min_size     = 2
    max_size     = 5
  }

 depends_on = [
    aws_iam_role_policy_attachment.node-policy1,
    aws_iam_role_policy_attachment.cni-policy1,
    aws_iam_role_policy_attachment.registry-policy1
  ]
}