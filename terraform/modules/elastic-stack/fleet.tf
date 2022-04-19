resource "kubernetes_manifest" "agent_fleet_server" {
  manifest = {
    "apiVersion" = "agent.k8s.elastic.co/v1alpha1"
    "kind" = "Agent"
    "metadata" = {
      "name" = "fleet-server"
      "namespace" = "default"
    }
    "spec" = {
      "deployment" = {
        "podTemplate" = {
          "spec" = {
            "automountServiceAccountToken" = true
            "securityContext" = {
              "runAsUser" = 0
            }
            "serviceAccountName" = "fleet-server"
          }
        }
        "replicas" = 1
      }
      "elasticsearchRefs" = [
        {
          "name" = "elasticsearch"
        },
      ]
      "fleetServerEnabled" = true
      "kibanaRef" = {
        "name" = "kibana"
      }
      "mode" = "fleet"
      "version" = "8.0.0"
    }
  }
}

resource "kubernetes_manifest" "agent_elastic_agent" {
  manifest = {
    "apiVersion" = "agent.k8s.elastic.co/v1alpha1"
    "kind" = "Agent"
    "metadata" = {
      "name" = "elastic-agent"
      "namespace" = "default"
    }
    "spec" = {
      "daemonSet" = {
        "podTemplate" = {
          "spec" = {
            "automountServiceAccountToken" = true
            "containers" = [
              {
                "name" = "agent"
                "volumeMounts" = [
                  {
                    "mountPath" = "/var/lib/docker/containers"
                    "name" = "varlibdockercontainers"
                  },
                  {
                    "mountPath" = "/var/log/containers"
                    "name" = "varlogcontainers"
                  },
                  {
                    "mountPath" = "/var/log/pods"
                    "name" = "varlogpods"
                  },
                ]
              },
            ]
            "dnsPolicy" = "ClusterFirstWithHostNet"
            "hostNetwork" = true
            "securityContext" = {
              "runAsUser" = 0
            }
            "serviceAccountName" = "elastic-agent"
            "volumes" = [
              {
                "hostPath" = {
                  "path" = "/var/lib/docker/containers"
                }
                "name" = "varlibdockercontainers"
              },
              {
                "hostPath" = {
                  "path" = "/var/log/containers"
                }
                "name" = "varlogcontainers"
              },
              {
                "hostPath" = {
                  "path" = "/var/log/pods"
                }
                "name" = "varlogpods"
              },
            ]
          }
        }
      }
      "fleetServerRef" = {
        "name" = "fleet-server"
      }
      "kibanaRef" = {
        "name" = "kibana"
      }
      "mode" = "fleet"
      "version" = "8.0.0"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_fleet_server" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "fleet-server"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "namespaces",
          "nodes",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "coordination.k8s.io",
        ]
        "resources" = [
          "leases",
        ]
        "verbs" = [
          "get",
          "create",
          "update",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "serviceaccount_fleet_server" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "fleet-server"
      "namespace" = "default"
    }
  }
}

resource "kubernetes_manifest" "clusterrolebinding_fleet_server" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "fleet-server"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "fleet-server"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "fleet-server"
        "namespace" = "default"
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrole_elastic_agent" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "elastic-agent"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
          "nodes",
          "namespaces",
          "events",
          "services",
          "configmaps",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "coordination.k8s.io",
        ]
        "resources" = [
          "leases",
        ]
        "verbs" = [
          "get",
          "create",
          "update",
        ]
      },
      {
        "nonResourceURLs" = [
          "/metrics",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
        ]
        "resources" = [
          "replicasets",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "apps",
        ]
        "resources" = [
          "statefulsets",
          "deployments",
          "replicasets",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes/stats",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "batch",
        ]
        "resources" = [
          "jobs",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "serviceaccount_elastic_agent" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "elastic-agent"
      "namespace" = "default"
    }
  }
}

resource "kubernetes_manifest" "clusterrolebinding_elastic_agent" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "elastic-agent"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "elastic-agent"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "elastic-agent"
        "namespace" = "default"
      },
    ]
  }
}
