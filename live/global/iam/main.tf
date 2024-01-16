provider "aws" {
    region = "us-east-2"
  
}
resource "aws_iam_user" "example" {
    count = 2
    name = "neo.${count.index}"
  
}
# resource "aws_iam_user" "example2" {
#   count = length(var.user_names)
#   name = var.user_names[count.index]
# }
module "users" {
  source = "../../../modules/landing_zones"
  count = length(var.user_names)
  user_names = var.user_names[count.index]  
}