terraform {
  required_version = ">=1.0.0"
}

resource "google_container_cluster" "_" {
  name     = local.name
  location = local.region

  node_pool {
    name = "builtin"
  }
  lifecycle {
    ignore_changes = [node_pool]
  }
}

resource "google_container_node_pool" "hot" {
  name               = "hot"
  cluster            = google_container_cluster._.id
  initial_node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-standard-8"
    labels = {
      type = "hot"
    }
  }
}

resource "google_container_node_pool" "warm" {
  name               = "warm"
  cluster            = google_container_cluster._.id
  initial_node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-standard-4"
    labels = {
      type = "warm"
    }
  }
}

resource "google_container_node_pool" "cold" {
  name               = "cold"
  cluster            = google_container_cluster._.id
  initial_node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-standard-2"
    labels = {
      type = "cold"
    }
  }
}

resource "google_container_node_pool" "frozen" {
  name               = "frozen"
  cluster            = google_container_cluster._.id
  initial_node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    labels = {
      type = "frozen"
    }
  }
}

resource "kubernetes_cluster_role_binding" "cluster-admin-binding" {
  metadata {
    name = "cluster role binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = "${var.elastic_email}"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [google_container_cluster._, google_container_node_pool.hot, google_container_node_pool.warm, google_container_node_pool.cold, google_container_node_pool.frozen]
}
