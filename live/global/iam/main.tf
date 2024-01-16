provider "aws" {
    region = "us-east-2"
  
}
# Using count.index
resource "aws_iam_user" "example" {
    count = 2
    name = "neo.${count.index}"
  
}
# Using count with list
resource "aws_iam_user" "example2" {
  count = length(var.user_names)
  name = var.user_names[count.index]
}
#Using Count with modules
module "users" {
  source = "../../../modules/landing_zones"
  count = length(var.user_names_for_modules)
  user_names_for_modules = var.user_names_for_modules[count.index]  
}

resource "aws_iam_user" "for_each_example" {
  for_each = toset(var.user_names_for_foreach)
  name = each.value
}
