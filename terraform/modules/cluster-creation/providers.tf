terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.6.0"
    }
    kubernetes = {
      source  = "hashicorp/helm"
      version = "2.4.1"
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster._.endpoint
    client_certificate     = base64decode(google_container_cluster._.master_auth.0.client_certificate)
    client_key             = base64decode(google_container_cluster._.master_auth.0.client_key)
    cluster_ca_certificate = base64decode(google_container_cluster._.master_auth.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster._.endpoint}"
  client_certificate     = base64decode(google_container_cluster._.master_auth.0.client_certificate)
  client_key             = base64decode(google_container_cluster._.master_auth.0.client_key)
  cluster_ca_certificate = base64decode(google_container_cluster._.master_auth.0.cluster_ca_certificate)
}

