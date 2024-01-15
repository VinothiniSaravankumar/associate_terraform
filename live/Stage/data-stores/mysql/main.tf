terraform {
  backend "s3" {
    bucket = "statefilestore"
    key = "stage/datastores/mysql/terraform.tfstate"
    region = "us-east-2"
    # Replace this with dynamo DB table name
    dynamodb_table = "s3_bkt_locks"
    encrypt = true    
  }
}

provider "aws" {
    region = "us-east-2"
  
}

resource "aws_db_instance" "example" {
  identifier_prefix = "chstates"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t2.micro"
  skip_final_snapshot = true
  db_name = "ch_states_db"

  username = var.db_username
  password = var.db_password
}