resource "kubernetes_manifest" "beat_heartbeat" {
  manifest = {
    "apiVersion" = "beat.k8s.elastic.co/v1beta1"
    "kind" = "Beat"
    "metadata" = {
      "name" = "heartbeat"
      "namespace" = "default"
    }
    "spec" = {
      "config" = {
        "heartbeat.monitors" = [
          {
            "hosts" = [
              "elasticsearch-es-http.default.svc:9200",
            ]
            "schedule" = "@every 5s"
            "type" = "tcp"
          },
        ]
      }
      "deployment" = {
        "podTemplate" = {
          "spec" = {
            "dnsPolicy" = "ClusterFirstWithHostNet"
            "securityContext" = {
              "runAsUser" = 0
            }
          }
        }
      }
      "elasticsearchRef" = {
        "name" = "elasticsearch"
      }
      "type" = "heartbeat"
      "version" = "8.0.0"
    }
  }
}
