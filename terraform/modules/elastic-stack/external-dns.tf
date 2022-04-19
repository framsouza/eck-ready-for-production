resource "kubernetes_manifest" "serviceaccount_external_dns" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "name" = "external-dns"
      "namespace" = "default"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_external_dns" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "name" = "external-dns"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "services",
          "endpoints",
          "pods",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "extensions",
          "networking.k8s.io",
        ]
        "resources" = [
          "ingresses",
        ]
        "verbs" = [
          "get",
          "watch",
          "list",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_external_dns_viewer" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "name" = "external-dns-viewer"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "external-dns"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "external-dns"
        "namespace" = "default"
      },
    ]
  }
}

resource "kubernetes_manifest" "deployment_external_dns" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "external-dns"
      "namespace" = "default"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "external-dns"
        }
      }
      "strategy" = {
        "type" = "Recreate"
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "external-dns"
          }
        }
        "spec" = {
          "containers" = [
            {
              "args" = [
                "--source=service",
                "--source=ingress",
                "--provider=cloudflare",
              ]
              "env" = [
                {
                  "name" = "CF_API_TOKEN"
                  "value" = "XCgG0QGaBP9WcisxY7I70GF4U0UQTG7hobQ6cr4d"
                },
              ]
              "image" = "k8s.gcr.io/external-dns/external-dns:v0.7.6"
              "name" = "external-dns"
            },
          ]
          "serviceAccountName" = "external-dns"
        }
      }
    }
  }
}
