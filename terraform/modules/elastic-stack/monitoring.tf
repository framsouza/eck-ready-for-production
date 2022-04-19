resource "kubernetes_manifest" "namespace_monitoring" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "name" = "monitoring"
    }
  }
}

resource "kubernetes_manifest" "elasticsearch_monitoring_monitoring" {
  manifest = {
    "apiVersion" = "elasticsearch.k8s.elastic.co/v1"
    "kind" = "Elasticsearch"
    "metadata" = {
      "name" = "monitoring"
      "namespace" = "monitoring"
    }
    "spec" = {
      "nodeSets" = [
        {
          "config" = {
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://monitoring.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://monitoring.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "es"
          "volumeClaimTemplates" = [
            {
              "metadata" = {
                "name" = "elasticsearch-data"
              }
              "spec" = {
                "accessModes" = [
                  "ReadWriteOnce",
                ]
                "resources" = {
                  "requests" = {
                    "storage" = "100Gi"
                  }
                }
                "storageClassName" = "standard"
              }
            },
          ]
        },
      ]
      "version" = "8.0.0"
    }
  }
}

resource "kubernetes_manifest" "kibana_monitoring_monitoring" {
  manifest = {
    "apiVersion" = "kibana.k8s.elastic.co/v1"
    "kind" = "Kibana"
    "metadata" = {
      "name" = "monitoring"
      "namespace" = "monitoring"
    }
    "spec" = {
      "config" = {
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
        "name" = "monitoring"
      }
      "version" = "8.0.0"
    }
  }
}
