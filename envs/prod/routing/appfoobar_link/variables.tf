# albは料金がかかるため検証用としてenable_albをfalseで渡す（terraform apply時）と、albが作成されないようにする
variable "enable_alb" {
  type    = bool
  default = true
}