variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "cluster_name" {
  description = "Name to use for all cluster resources"
  type = string  
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
  type = string
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
  type = string
}

variable "instance_type" {
  description = "The type of EC2 instances to run"
  type = string
}

variable "min_size" {
  description = "The min number of EC2 instances in the ASG"
  type = number
}

variable "max_size" {
  description = "The max number of EC2 instances in the ASG"
  type = number
}
