resource "kubernetes_manifest" "ingress_kibana" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "Ingress"
    "metadata" = {
      "annotations" = {
        "cert-manager.io/cluster-issuer" = "letsencrypt-production"
        "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      }
      "name" = "kibana"
      "namespace" = "default"

    }
    "spec" = {
      "ingressClassName" = "nginx"
      "rules" = [
        {
          "host" = "kibana.framsouza.co"
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "service" = {
                    "name" = "kibana-kb-http"
                    "port" = {
                      "number" = 5601
                    }
                  }
                }
                "path" = "/"
                "pathType" = "Prefix"
              },
            ]
          }
        },
      ]
      "tls" = [
        {
          "hosts" = [
            "kibana.framsouza.co",
          ]
          "secretName" = "letsencrypt-cert"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "ingress_monitoring_monitoring" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind" = "Ingress"
    "metadata" = {
      "annotations" = {
        "cert-manager.io/cluster-issuer" = "letsencrypt-production"
        "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
      }
      "name" = "monitoring"
      "namespace" = "monitoring"
    }
    "spec" = {
      "ingressClassName" = "nginx"
      "rules" = [
        {
          "host" = "monitoring.framsouza.co"
          "http" = {
            "paths" = [
              {
                "backend" = {
                  "service" = {
                    "name" = "monitoring-kb-http"
                    "port" = {
                      "number" = 5601
                    }
                  }
                }
                "path" = "/"
                "pathType" = "Prefix"
              },
            ]
          }
        },
      ]
      "tls" = [
        {
          "hosts" = [
            "monitoring.framsouza.co",
          ]
          "secretName" = "letsencrypt-cert"
        },
      ]
    }
  }
}
