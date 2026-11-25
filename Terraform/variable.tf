variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "client-portal-eks"
}

variable "kubernetes_version" {
  description = "Check it is in standard support (command below)"
  type        = string
  default     = "1.35"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

# variable "admin_cidrs" {
#   description = "Who can reach the public API endpoint, e.g. [\"203.0.113.10/32\"]"
#   type        = list(string)
# }

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}