# ---------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Student     = "true"
  }
}

# ---------------------------------------------------------------
# Cluster AKS principal
# ---------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.cluster_name}-dns"

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"

    node_labels = {
      role = "frontend-backend"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
    Student     = "true"
  }
}

# ---------------------------------------------------------------
# Node Pool DB avec taints + labels
# ---------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "dbpool" {
  name                  = "dbpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.db_vm_size
  node_count            = var.db_node_count
  os_disk_size_gb       = 50

  node_labels = {
    role = "database"
  }

  node_taints = [
    "db=true:NoSchedule"
  ]

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}
