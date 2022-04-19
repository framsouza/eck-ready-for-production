resource "kubernetes_manifest" "elasticsearch_elasticsearch" {
  manifest = {
    "apiVersion" = "elasticsearch.k8s.elastic.co/v1"
    "kind" = "Elasticsearch"
    "metadata" = {
      "annotations" = {
        "elasticsearch.alpha.elastic.co/autoscaling-spec" = <<-EOT
        {
            "policies": [{
                "name": "hot",
                "roles": ["data_hot", "data_content", "ingest"],
                "deciders": {
                  "proactive_storage": {
                      "forecast_window": "5m"
                  }
                },
                "resources": {
                    "nodeCount": { "min": 3, "max": 6 },
                    "cpu": { "min": 1, "max": 8 },
                    "memory": { "min": "2Gi", "max": "16Gi" },
                    "storage": { "min": "64Gi", "max": "512Gi" }
                }
            },
            {
                "name": "ml",
                "roles": ["ml"],
                "deciders": {
                    "ml": {
                        "down_scale_delay": "10m"
                    }
                },
                "resources": {
                    "nodeCount": { "min": 1, "max": 9 },
                    "cpu": { "min": 1, "max": 4 },
                    "memory": { "min": "2Gi", "max": "8Gi" }
                }
            }]
        }
        
        EOT
      }
      "name" = "elasticsearch"
      "namespace" = "default"
    }
    "spec" = {
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
      "nodeSets" = [
        {
          "config" = {
            "node.attr.zone" = "europe-west1-b"
            "node.roles" = [
              "data_hot",
              "data_content",
              "ingest",
            ]
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "hot-zone-b"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-b",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "4Gi"
                    }
                    "requests" = {
                      "memory" = "4Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "hot"
              }
            }
          }
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
                "storageClassName" = "sc-hot"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-c"
            "node.roles" = [
              "data_hot",
              "data_content",
              "ingest",
            ]
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "hot-zone-c"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-c",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "4Gi"
                    }
                    "requests" = {
                      "cpu" = 1
                      "memory" = "4Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "hot"
              }
            }
          }
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
                    "storage" = "50Gi"
                  }
                }
                "storageClassName" = "sc-hot"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-d"
            "node.roles" = [
              "data_hot",
              "data_content",
              "ingest",
            ]
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "hot-zone-d"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-d",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "4Gi"
                    }
                    "requests" = {
                      "cpu" = 1
                      "memory" = "4Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "hot"
              }
            }
          }
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
                    "storage" = "50Gi"
                  }
                }
                "storageClassName" = "sc-hot"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-b"
            "node.roles" = "data_warm"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "warm-zone-b"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-b",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "2Gi"
                    }
                    "requests" = {
                      "cpu" = 1
                      "memory" = "2Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "warm"
              }
            }
          }
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
                    "storage" = "50Gi"
                  }
                }
                "storageClassName" = "sc-warm-cold"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-c"
            "node.roles" = "data_warm"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "warm-zone-c"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-c",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "2Gi"
                    }
                    "requests" = {
                      "cpu" = 1
                      "memory" = "2Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "warm"
              }
            }
          }
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
                    "storage" = "50Gi"
                  }
                }
                "storageClassName" = "sc-warm-cold"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-d"
            "node.roles" = "data_warm"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "warm-zone-d"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-d",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "2Gi"
                    }
                    "requests" = {
                      "cpu" = 1
                      "memory" = "2Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "warm"
              }
            }
          }
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
                    "storage" = "50Gi"
                  }
                }
                "storageClassName" = "sc-warm-cold"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-b"
            "node.roles" = "data_cold"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "cold-zone-b"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-b",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "2Gi"
                    }
                    "requests" = {
                      "memory" = "2Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "cold"
              }
            }
          }
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
                "storageClassName" = "sc-warm-cold"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-b"
            "node.roles" = "data_frozen"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "frozen-zone-b"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-b",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "2Gi"
                    }
                    "requests" = {
                      "memory" = "2Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "frozen"
              }
            }
          }
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
                "storageClassName" = "sc-warm-cold"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-b"
            "node.roles" = "ml"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "ml-zone-b"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-b",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "4Gi"
                    }
                    "requests" = {
                      "memory" = "4Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "hot"
              }
            }
          }
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
                "storageClassName" = "sc-hot"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-b"
            "node.roles" = "master"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "master-zone-b"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-b",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "2Gi"
                    }
                    "requests" = {
                      "cpu" = 1
                      "memory" = "2Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "hot"
              }
            }
          }
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
                    "storage" = "10Gi"
                  }
                }
                "storageClassName" = "sc-hot"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-c"
            "node.roles" = "master"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "master-zone-c"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-c",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "2Gi"
                    }
                    "requests" = {
                      "cpu" = 1
                      "memory" = "2Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "hot"
              }
            }
          }
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
                    "storage" = "10Gi"
                  }
                }
                "storageClassName" = "sc-hot"
              }
            },
          ]
        },
        {
          "config" = {
            "node.attr.zone" = "europe-west1-d"
            "node.roles" = "master"
            "node.store.allow_mmap" = false
            "xpack.security.authc.realms" = {
              "saml" = {
                "saml1" = {
                  "attributes.principal" = "nameid"
                  "idp.entity_id" = "urn:framsouza.eu.auth0.com"
                  "idp.metadata.path" = "https://framsouza.eu.auth0.com/samlp/metadata/nbNudmA4FTPI3kO6im0o5KPV3gugxxQI"
                  "order" = 2
                  "sp.acs" = "https://kibana.framsouza.co/api/security/v1/saml"
                  "sp.entity_id" = "https://framsouza.co"
                  "sp.logout" = "https://kibana.framsouza.co/logout"
                }
              }
            }
          }
          "count" = 1
          "name" = "master-zone-d"
          "podTemplate" = {
            "spec" = {
              "affinity" = {
                "nodeAffinity" = {
                  "requiredDuringSchedulingIgnoredDuringExecution" = {
                    "nodeSelectorTerms" = [
                      {
                        "matchExpressions" = [
                          {
                            "key" = "failure-domain.beta.kubernetes.io/zone"
                            "operator" = "In"
                            "values" = [
                              "europe-west1-d",
                            ]
                          },
                        ]
                      },
                    ]
                  }
                }
              }
              "containers" = [
                {
                  "env" = [
                    {
                      "name" = "READINESS_PROBE_TIMEOUT"
                      "value" = "10"
                    },
                  ]
                  "name" = "elasticsearch"
                  "readinessProbe" = {
                    "exec" = {
                      "command" = [
                        "bash",
                        "-c",
                        "/mnt/elastic-internal/scripts/readiness-probe-script.sh",
                      ]
                    }
                    "failureThreshold" = 3
                    "initialDelaySeconds" = 10
                    "periodSeconds" = 12
                    "successThreshold" = 1
                    "timeoutSeconds" = 12
                  }
                  "resources" = {
                    "limits" = {
                      "memory" = "2Gi"
                    }
                    "requests" = {
                      "cpu" = 1
                      "memory" = "2Gi"
                    }
                  }
                },
              ]
              "nodeSelector" = {
                "type" = "hot"
              }
            }
          }
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
                    "storage" = "10Gi"
                  }
                }
                "storageClassName" = "sc-hot"
              }
            },
          ]
        },
      ]
      "updateStrategy" = {
        "changeBudget" = {
          "maxSurge" = 1
          "maxUnavailable" = 1
        }
      }
      "version" = "8.0.0"
    }
  }
}
