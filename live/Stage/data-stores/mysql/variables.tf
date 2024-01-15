variable "db_username" {
    description = "username of the db"
    type = string
    sensitive = true 
}

variable "db_password" {
    description = "password for db"
    type = string
    sensitive = true
  
}