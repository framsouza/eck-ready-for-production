resource "kubernetes_manifest" "secret_elastic_system_eck_trial_license" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Secret"
    "metadata" = {
      "annotations" = {
        "elastic.co/eula" = "accepted"
      }
      "labels" = {
        "license.k8s.elastic.co/type" = "enterprise_trial"
      }
      "name" = "eck-trial-license"
      "namespace" = "elastic-system"
    }
  }
}
