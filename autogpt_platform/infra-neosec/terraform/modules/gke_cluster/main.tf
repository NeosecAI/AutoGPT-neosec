resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  private_cluster_config {
    enable_private_nodes    = false
    enable_private_endpoint = false
  }

  network_policy {
    enabled = true
  } 

  dynamic "node_pool" {
    for_each = var.enable_autopilot ? [] : [1]
    content {
      name       = var.node_pool_name
      node_count = var.node_count

      node_config {
        machine_type = var.machine_type
        disk_size_gb = var.disk_size_gb

        workload_metadata_config {
          mode = "GKE_METADATA"
        }
      }
    }
  }

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  resource_labels = {
    cluster_name = var.cluster_name
  }
}

