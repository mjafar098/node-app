variable "aws_region" {
  description = "This AWS region to deploy the infrastructure"
  type = string
  default = "us-west-2"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type = string
  default = "hello-world-cluster"
}

variable "app_name" {
  descrition = "The name of the application"
  type = string
  default = "hello-world-app"
}

variable "desired_count" {
  description = "Number of desired instances"
  type = number
  default = 1
}
    
