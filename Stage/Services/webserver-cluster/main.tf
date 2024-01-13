provider "aws" {
    region = "us-east-2"
  
}

module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"
    cluster_name = "webservers-stage"
    db_remote_state_bucket = "statefilestore"
    db_remote_state_key = "stage/datastores/mysql/terraform.tfstate"
  
}