output "user_arn" {
    value = aws_iam_user.module_users.arn
    description = "The ARN of the created IAM user"
}