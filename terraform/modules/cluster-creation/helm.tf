resource "helm_release" "ingress-nginx" {
  name = "ingress-nginx"

  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = "true"

  depends_on = [google_container_cluster._, google_container_node_pool.hot, google_container_node_pool.warm, google_container_node_pool.cold, google_container_node_pool.frozen, kubernetes_cluster_role_binding.cluster-admin-binding]

}

resource "helm_release" "elastic" {
  name = "elastic-operator"

  repository       = "https://helm.elastic.co"
  chart            = "eck-operator"
  namespace        = "elastic-system"
  create_namespace = "true"

  depends_on = [google_container_cluster._, google_container_node_pool.hot, google_container_node_pool.warm, google_container_node_pool.cold, google_container_node_pool.frozen, kubernetes_cluster_role_binding.cluster-admin-binding]

}

resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = "true"

  set {
    name  = "installCRDs"
    value = "true"
  }


  depends_on = [google_container_cluster._, google_container_node_pool.hot, google_container_node_pool.warm, google_container_node_pool.cold, google_container_node_pool.frozen, kubernetes_cluster_role_binding.cluster-admin-binding]

}
