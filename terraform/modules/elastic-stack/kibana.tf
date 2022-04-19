resource "kubernetes_manifest" "kibana_kibana" {
  manifest = {
    "apiVersion" = "kibana.k8s.elastic.co/v1"
    "kind" = "Kibana"
    "metadata" = {
      "name" = "kibana"
      "namespace" = "default"
    }
    "spec" = {
      "config" = {
        "xpack.fleet.agentPolicies" = [
          {
            "id" = "eck-fleet-server"
            "is_default_fleet_server" = true
            "monitoring_enabled" = [
              "logs",
              "metrics",
            ]
            "name" = "Fleet Server on ECK policy"
            "namespace" = "default"
            "package_policies" = [
              {
                "id" = "fleet_server-1"
                "name" = "fleet_server-1"
                "package" = {
                  "name" = "fleet_server"
                }
              },
            ]
          },
          {
            "id" = "eck-agent"
            "is_default" = true
            "monitoring_enabled" = [
              "logs",
              "metrics",
            ]
            "name" = "Elastic Agent on ECK policy"
            "namespace" = "default"
            "package_policies" = [
              {
                "name" = "system-1"
                "package" = {
                  "name" = "system"
                }
              },
              {
                "name" = "kubernetes-1"
                "package" = {
                  "name" = "kubernetes"
                }
              },
            ]
            "unenroll_timeout" = 900
          },
        ]
        "xpack.fleet.agents.elasticsearch.hosts" = [
          "https://elasticsearch-es-http.default.svc:9200",
        ]
        "xpack.fleet.agents.fleet_server.hosts" = [
          "https://fleet-server-agent-http.default.svc:8220",
        ]
        "xpack.fleet.packages" = [
          {
            "name" = "system"
            "version" = "latest"
          },
          {
            "name" = "elastic_agent"
            "version" = "latest"
          },
          {
            "name" = "fleet_server"
            "version" = "latest"
          },
          {
            "name" = "kubernetes"
            "version" = "0.14.0"
          },
        ]
        "xpack.security.authc.providers" = {
          "basic.basic1" = {
            "order" = 1
          }
          "saml.saml1" = {
            "order" = 0
            "realm" = "saml1"
          }
        }
      }
      "count" = 1
      "elasticsearchRef" = {
        "name" = "elasticsearch"
      }
      "monitoring" = {
        "logs" = {
          "elasticsearchRefs" = [
            {
              "name" = "monitoring"
              "namespace" = "monitoring"
            },
          ]
        }
        "metrics" = {
          "elasticsearchRefs" = [
            {
              "name" = "monitoring"
              "namespace" = "monitoring"
            },
          ]
        }
      }
      "version" = "8.0.0"
    }
  }
}
