resource "eksctl_cluster" "ugajin_eks_cluster" {
  name            = "ugajin-eks-cluster"
  region          = "ap-northeast-1a"
  version         = "1.21"
  vpc_id          = module.vpc.vpc_id
  spec            = data.template_file.eksctl_cluster.rendered
}

data "template_file" "eksctl_cluster" {
  template = file("eksctl_cluster.yaml")

  vars = {
    az-1            = module.vpc.azs[0]
    az-2            = module.vpc.azs[1]
    az-3            = module.vpc.azs[2]
    private_subnet1 = module.vpc.private_subnets[0]
    private_subnet2 = module.vpc.private_subnets[1]
    private_subnet3 = module.vpc.private_subnets[2]
    public_subnet1  = module.vpc.public_subnets[0]
    public_subnet2  = module.vpc.public_subnets[1]
    public_subnet3  = module.vpc.public_subnets[2]
  }
}