variable "user_names" {
    description = "Create IAM users"
    type = list(string)
    default = [ "tiina", "meena", "seema" ]  
}

variable "user_names_for_modules" {
    description = "Create IAM users"
    type = list(string)
    default = [ "nemo", "steffi", "michelle" ]  
}

variable "user_names_for_foreach" {
    description = "Create IAM users"
    type = list(string)
    default = [ "vino", "saravan" ]  
}