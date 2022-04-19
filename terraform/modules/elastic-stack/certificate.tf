resource "kubernetes_manifest" "certificate_letsencrypt_cert" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "Certificate"
    "metadata" = {
      "name" = "letsencrypt-cert"
      "namespace" = "default"
    }
    "spec" = {
      "dnsNames" = [
        "kibana.framsouza.co",
        "monitoring.framsouza.co",
      ]
      "issuerRef" = {
        "kind" = "ClusterIssuer"
        "name" = "letsencrypt-production"
      }
      "secretName" = "letsencrypt-cert"
    }
  }
}
