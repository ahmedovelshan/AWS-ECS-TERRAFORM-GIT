variable "vpc" {
  type = string
  description = "VPC CIDR"
  default = "10.0.0.0/16"
}

variable "availability_zone" {
  type    = list(string)
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "web-subnet-cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public-subnet-cidr" {
  type    = list(string)
  default = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "ecs_name" {
  type = string
  description = "ECS Cluster name"
  default = "devops-ecs-cluster"
}

variable "cloudwatch_log_name" {
    type = string
    description = "cloudwatch log location name"
    default = "devops-ecs-cloudwatchlog"
  
}

variable "alb-port" {
  description = "List of ports to allow"
  type = list(string)
  default = ["80", "443"]
}


variable "web-ec2-port" {
  description = "List of ports to allow"
  type = list(string)
  default = ["80", "443"]
}
