variable "vpc_cidr" {
  type    = string
  default = "171.32.0.0/16"
}

variable "azs" {
  type = map(object({
    public_cidr  = string
    private_cidr = string
  }))
  default = {
    a = {
      public_cidr  = "171.32.0.0/20"
      private_cidr = "171.32.48.0/20"
    },
    c = {
      public_cidr  = "171.32.16.0/20"
      private_cidr = "171.32.64.0/20"
    }
  }
}

# ソース作成するか否かのbool
# nat gatewayは料金が発生するため以下のように指定してリソースの作成有無を選択できるようにする
# terraform apply -var='enable_nat_gateway=false ←のように指定すると作成されない
variable "enable_nat_gateway" {
  type    = bool
  default = true
}

# trueのときはnat gatewayを1つしか作らないようにする（料金関係の考慮）
# enable_nat_gatewayがfalseの場合はこちらの値に関係なくnat gatewayは作成しないようにする
variable "single_nat_gateway" {
  type    = bool
  default = true
}