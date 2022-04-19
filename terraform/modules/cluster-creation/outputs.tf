output "endpoint" {
  description = "The IP address of the cluster master."
  value       = google_container_cluster._.endpoint
}

output "name" {
  description = "The name of the cluster master. This output is used for interpolation with node pools, other modules."
  value       = google_container_cluster._.name
}
