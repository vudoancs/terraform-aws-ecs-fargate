variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "ap-southeast-1"
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  type        = string
  default     = "my-ecs-cluster"
}

variable "key_name" {
  description = "The name of the SSH key pair."
  type        = string
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}
