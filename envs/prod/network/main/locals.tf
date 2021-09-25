locals {
  # keys関数: keys(var.azs)で["a", "c"]が返る（keyをlist化する）
  # よってkeys(var.azs)[0]は"a"が返る
  # values関数: values(var.azs)でa,cの各値が入る（private_cidrとか）
  nat_gateway_azs = var.single_nat_gateway ? { keys(var.azs)[0] = values(var.azs)[0] } : var.azs
  # values(var.azs)[0]で以下が返る
  # {
  #  public_cidr  = "171.32.0.0/20"
  #  private_cidr = "171.32.48.0/20"
  #  },
}