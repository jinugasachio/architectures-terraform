resource "eksctl_cluster" "ugajin_eks_cluster" {
  name            = "ugajin-eks-cluster"
  region          = "ap-northeast-1a"
  version         = "1.21"
  vpc_id          = module.vpc.vpc_id
}