variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}


############
variable "argocd-namespace" {
  description ="Namespace to install ArgoCD"
  default = "argocd"
}