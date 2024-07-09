## locals
locals {
  pubschema = jsonencode([
    { name = "data", type = "JSON"}
  ])

  last_publish_time_schema = jsonencode([
    { name = "stream_linear_source", type="TIMESTAMP"}
  ])

}


## Security and IAM

# service account used by  composer environment
module "composer_sa" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git?ref=v23.0.0/modules/iam-service-account"
  project_id = var.project_id
  name       = "composer-sa"
  iam_project_roles = {
    (var.project_id) = [
      "roles/editor",
      "roles/composer.user",
      "roles/composer.worker",
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
      "roles/iam.serviceAccountUser",
      "roles/composer.ServiceAgentV2Ext"
    ]
  }
}

##necessary for composer deployment

resource "google_service_account_iam_member" "service_agent_extensions" {
  provider = google-beta
  service_account_id = module.composer_sa.id
  role = "roles/composer.ServiceAgentV2Ext"
  member = "serviceAccount:service-${var.project_number}@cloudcomposer-accounts.iam.gserviceaccount.com"
}


resource "google_compute_network" "vpc_network" {
  project = var.project_id
  name = "etl-tesi-${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode = "GLOBAL"

}

resource "google_compute_subnetwork" "composersub" {
  project = var.project_id
  name = "composer-sub"
  network = google_compute_network.vpc_network.id
  region = "europe-west1"
  ip_cidr_range = "10.1.0.0/24"
  secondary_ip_range = [{
    range_name = "pods"
    ip_cidr_range = "172.16.0.0/20"
  },
  {
    range_name = "services"
    ip_cidr_range = "192.168.0.0/24"
  }
  ]
  private_ip_google_access =  true
}

resource "google_compute_subnetwork" "vmsubnet" {
  project = var.project_id
  region = "europe-west1"
  name = "vm-subnet"
  network = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.16.0/24"
}

module "default-nat" {
  source         = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git?ref=v23.0.0/modules/net-cloudnat"
  project_id     = var.project_id
  region         = var.region
  name           = "default-nat"
  router_network = google_compute_network.vpc_network.self_link
}


module "default_firewall" {
  source       = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git?ref=v23.0.0/modules/net-vpc-firewall"
  project_id   = var.project_id
  network      = google_compute_network.vpc_network.name
  default_rules_config = {
    admin_ranges = [google_compute_subnetwork.composersub.ip_cidr_range, google_compute_subnetwork.vmsubnet.ip_cidr_range]
  }
}

module "import_bucket" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git?ref=v23.0.0/modules/gcs"
  project_id = var.project_id
  name       = "etl-tesi-${var.environment}-data-ingest"
  versioning = true
  location = "europe-west1"
  storage_class = "REGIONAL"
  uniform_bucket_level_access = false
}


module "output_bucket" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric.git?ref=v23.0.0/modules/gcs"
  project_id = var.project_id
  name       = "etl-tesi-${var.environment}-data-output"
  versioning = true
  location = "europe-west1"
  storage_class = "REGIONAL"
  uniform_bucket_level_access = false
}


