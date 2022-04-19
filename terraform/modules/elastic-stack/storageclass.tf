resource "kubernetes_manifest" "storageclass_sc_hot" {
  manifest = {
    "allowVolumeExpansion" = true
    "apiVersion" = "storage.k8s.io/v1"
    "kind" = "StorageClass"
    "metadata" = {
      "name" = "sc-hot"
    }
    "parameters" = {
      "type" = "pd-ssd"
    }
    "provisioner" = "kubernetes.io/gce-pd"
    "reclaimPolicy" = "Delete"
    "volumeBindingMode" = "WaitForFirstConsumer"
  }
}

resource "kubernetes_manifest" "storageclass_sc_warm_cold" {
  manifest = {
    "allowVolumeExpansion" = true
    "apiVersion" = "storage.k8s.io/v1"
    "kind" = "StorageClass"
    "metadata" = {
      "name" = "sc-warm-cold"
    }
    "parameters" = {
      "type" = "pd-standard"
    }
    "provisioner" = "kubernetes.io/gce-pd"
    "reclaimPolicy" = "Delete"
    "volumeBindingMode" = "WaitForFirstConsumer"
  }
}
