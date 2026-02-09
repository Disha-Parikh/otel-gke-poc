resource "google_container_cluster" "gke" {
	name = var.cluster_name
	location = var.region
	remove_default_node_pool = true
	initial_node_count = 2
	deletion_protection = false
}

resource "google_container_node_pool" "nodes"{
	cluster = google_container_cluster.gke.name
	location = "us-central1-a"
	name = "primary"
	node_count = var.node_count
	node_config {
		machine_type = var.machine_type
		disk_type = "pd-standard"
		disk_size_gb = 15
		oauth_scopes = [
   			 "https://www.googleapis.com/auth/cloud-platform"
  				]
	}
}
