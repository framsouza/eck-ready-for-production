resource "kubernetes_manifest" "clusterissuer_letsencrypt_production" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind" = "ClusterIssuer"
    "metadata" = {
      "name" = "letsencrypt-production"
    }
    "spec" = {
      "acme" = {
        "email" = "fsouza@elastic.co"
        "privateKeySecretRef" = {
          "name" = "issuer-letsencrypt-production"
        }
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "solvers" = [
          {
            "http01" = {
              "ingress" = {
                "class" = "nginx"
              }
            }
          },
        ]
      }
    }
  }
}
