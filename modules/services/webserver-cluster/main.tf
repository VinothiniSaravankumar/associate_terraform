# terraform {
#    backend "s3" {
#     key = "stage/services/webserver-cluster/terraform.tfstate"
#     bucket = "statefilestore"
#     region = "us-east-2"
#     dynamodb_table = "s3_bkt_locks"
#     encrypt = true  
#    } 

# }

locals {
  http_port = 80
  any_port = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]

}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    # bucket = "statefilestore"
    # key = "stage/datastores/mysql/terraform.tfstate"
    bucket = var.db_remote_state_bucket
    key = var.db_remote_state_key
    region = "us-east-2"
  }
  
}

# commenting the providers. since changing the format to modules
# provider "aws" {
#   region = "us-east-2"
# }

resource "aws_launch_configuration" "example" {
  image_id           =  "ami-0fb653ca2d3203ac1" 
  instance_type = var.instance_type
  security_groups = [aws_security_group.instance.id]

  # user_data = <<-EOF
  #             #!/bin/bash
  #             echo "Hello, World" > index.html
  #             echo "${data.terraform_remote_state.db.outputs.address}" >> index.html
  #             echo "${data.terraform_remote_state.db.outputs.port}" >> index.html
  #             nohup busybox httpd -f -p ${var.server_port} &
  #             EOF

  user_data = templatefile("${path.module}/user-data.sh", {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  })
  # Required when using a launch configuration with an ASG.
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = var.min_size
  max_size = var.max_size

  tag {
    key                 = "Name"
    # value               = "terraform-asg-example"
    value               = "${var.cluster_name}-example"
    propagate_at_launch = true
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "instance" {
  # name = "terraform-example-instance"
  name = "${var.cluster_name}-instance"
  # Changing the below inline config to separate config
  # ingress {
  #   from_port   = local.http_port
  #   to_port     = local.http_port
  #   protocol    = local.tcp_protocol
  #   cidr_blocks = local.all_ips
  # }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id
  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_lb" "example" {
  # name               = "terraform-asg-example"
  name               = "${var.cluster_name}-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  # name     = "terraform-asg-example"
  name     = "${var.cluster_name}-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "alb" {
  # name = "terraform-example-alb"
  name = "${var.cluster_name}-alb"
  # Allow inbound HTTP requests
  ## Changing the inline config  to separate resources
  # ingress {
  #   from_port   = local.http_port
  #   to_port     = local.http_port
  #   protocol    = local.any_protocol
  #   cidr_blocks = local.all_ips
  # }

  # # Allow all outbound requests
  # egress {
  #   from_port   = local.any_port
  #   to_port     = local.any_port
  #   protocol    = local.any_protocol
  #   cidr_blocks = local.all_ips
  # }
}

resource "aws_security_group_rule" "allow_http_inbound_alb" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound_alb" {
  type = "egress"
  security_group_id = aws_security_group.alb.id
  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}



