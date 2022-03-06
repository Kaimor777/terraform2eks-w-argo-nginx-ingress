variable "region" {
  default     = "eu-central-1"
  description = "AWS region"
}

variable "cluster_name" {
  description = "EKS Cluster Name"
  default     = "eks-0001"

}

variable "additional_tags" {
  default     = {}
  description = "Additional resource tags"
  type        = map(string)
}

