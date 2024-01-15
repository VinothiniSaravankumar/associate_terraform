output "address" {
    value = aws_db_instance.example.address
    description = "connect to the db at this endpoint"
  
}

output "port" {
    value = aws_db_instance.example.port
    description = "The port the db is listening on"
  
}