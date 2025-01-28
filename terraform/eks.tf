
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "ayush-eks-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true

  enable_irsa = true
  

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      
    }
  }

  vpc_id                   = module.vpc.vpc_id
  
  control_plane_subnet_ids = module.vpc.private_subnets

  subnet_ids               = module.vpc.private_subnets

  
  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.micro"]
    }
    
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}