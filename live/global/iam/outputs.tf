output "neo_first_arn" {
    value = aws_iam_user.example[0].arn
    description = "arn of neo first user"
}
output "neo_2nd_arn" {
    value = aws_iam_user.example[1].arn
    description = "arn of neo 2nd user"
}
# output "all_other_arns" {
#   value = aws_iam_user.example2[*].arn
#   description = "arn of all users in the list"
# }
output "user_arns" {
  value = module.users[*].user_arn
  description = "ARNS of uers created using modules"  
}
