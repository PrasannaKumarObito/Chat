# Provide
provider "aws" {
    region = "us-east-1"
}

#VPC
resource "aws_vpc" "obito_vpc" {
   cidr_block = "10.0.0.0/16"
   tags = {
     Name= "obito_vpc"
   }
}

# subnets ( 2 public subnets)
 resource "aws_subnet" "obito_subnet" {
    count = 2
    vpc_id = aws_vpc.obito_vpc.id
    cidr_block = cidrsubnet(aws_vpc.obito_vpc.cidr_block, 8, count.index)

    availability_zone = element(["us-east-1a","us-east-1b"],count.index)
    map_public_ip_on_launch = true

    tags ={
        Name =" obito_subnet_${count.index}"
    }   
 }

 #Internet Gateway
 resource "aws_internet_gateway" "obito_IT" {
    vpc_id = aws_vpc.obito_vpc.id
    tags = {
      Name= "obito_IT"
    }
 }
 #Route Table
 resource "aws_route_table" "obito_RT"{
    vpc_id = aws_vpc.obito_vpc.id

    route {
        cidr_block= "0.0.0.0/0"
        gateway_id= aws_internet_gateway.obito_IT.id
    }
    tags = {
      Name= "obito_RT"
    }
 }
 #Rout tabel association
 resource "aws_route_table_association" "obito_RTA" {
    count = 2
    subnet_id = aws_subnet.obito_subnet[count.index].id
   route_table_id = aws_route_table.obito_RT.id
 }
# EKS Cluster Security Group
resource "aws_security_group" "obito_cluster_sg" {
  vpc_id = aws_vpc.obito_vpc.id

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "obito-cluster-sg"
  }
}

# Security Groups
resource "aws_security_group" "obito_node_sg" {
  vpc_id = aws_vpc.obito_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "obito-node-sg"
  }
}
# IAM Role - EKS Cluster
resource "aws_iam_role" "obito_eks_cluster_role" {
  name = "obito_eks_cluster_role"

  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.obito_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role - Worker Nodes
resource "aws_iam_role" "obito_eks_node_role" {
  name = "obito_eks_node_role"

  assume_role_policy = <<EOF
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
EOF
}
# Worker node required policies
resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.obito_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.obito_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_registry_policy" {
  role       = aws_iam_role.obito_eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS Cluster
resource "aws_eks_cluster" "obito" {
  name     = "obito-cluster"
  role_arn = aws_iam_role.obito_eks_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.obito_subnet[*].id
    security_group_ids = [aws_security_group.obito_cluster_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

# EKS Node Group

resource "aws_eks_node_group" "obito" {
  cluster_name    = aws_eks_cluster.obito.name
  node_group_name = "obito-node-group"
  node_role_arn   = aws_iam_role.obito_eks_node_role.arn

  subnet_ids = aws_subnet.obito_subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 100
    min_size     = 2
  }

  instance_types = ["m7i-flex.large"]

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.obito_node_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_registry_policy
  ]
}