variable "resource_group_name" {
  description = "Resource group du projet CloudShop"
  type        = string
  default     = "rg-cloudshop-prod"
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "italynorth"
}

variable "cluster_name" {
  description = "Nom du cluster AKS CloudShop"
  type        = string
  default     = "aks-cloudshop-prod"
}

variable "node_count" {
  description = "Nombre de nodes du pool principal"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "Taille des VMs du nodepool principal"
  type        = string
  default     = "Standard_B2ls_v2"
}

variable "environment" {
  description = "Environnement"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Nom du projet"
  type        = string
  default     = "cloudshop"
}

variable "db_vm_size" {
  description = "Taille du nodepool DB"
  type        = string
  default     = "Standard_B2ls_v2"
}

variable "db_node_count" {
  description = "Nombre de nodes dédiés DB"
  type        = number
  default     = 1
}
