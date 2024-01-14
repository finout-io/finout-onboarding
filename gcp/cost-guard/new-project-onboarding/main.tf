resource "random_string" "random_suffix_id" {
  length  = 6
  upper   = false
  lower   = true
  numeric  = true
  special = false
}

data "google_projects" "org_projects" {
  filter="lifecycleState:ACTIVE"
}

locals {
    scoping_project_id = var.scoping_project_id != null ? var.scoping_project_id : "finout-scoping-project-${random_string.random_suffix_id.result}"
    user_metric_scopes = toset(var.monitored_projects)
    projects_ids = toset([for project in data.google_projects.org_projects.projects: project.project_id])
    metric_scopes = length(local.user_metric_scopes) == 0 ? local.projects_ids : local.user_metric_scopes

    depends_on = [
        random_string.random_suffix_id
    ]
}

output "projects" {
  value = [
    for project in local.metric_scopes: project
  ]
}

output "scoping_project_id" {
  value = local.scoping_project_id
}


# create scoping project
resource "google_project" "create_scoping_project" {
  name       = var.scoping_project_name != null ? var.scoping_project_name : "finout-scoping-project"
  project_id = var.scoping_project_id != null ? var.scoping_project_id : "finout-scoping-project-${random_string.random_suffix_id.result}"
  org_id     = var.org_id
}

# enable monitoring api
resource "google_project_service" "project_monitor_api" {
  project = local.scoping_project_id
  service  = "monitoring.googleapis.com"

  depends_on = [
    google_project.create_scoping_project
  ]
}

# bind service account to the scoping project with Monitoring View role
resource "google_project_iam_binding" "project" {
  project = local.scoping_project_id
  role    = "roles/monitoring.viewer"
  members = [
   "serviceAccount:${var.service_account}",
  ]

  depends_on = [
    google_project.create_scoping_project
  ]
}

# bind projects as monitored to the scoping project
resource "google_monitoring_monitored_project" "projects_monitored" {
  for_each      = local.metric_scopes
  metrics_scope = join("", ["locations/global/metricsScopes/", local.scoping_project_id])
  name          = each.value
  depends_on = [
    google_project_service.project_monitor_api
  ]
}

# bind service account to the each monitored project with Compute View role
resource "google_project_iam_binding" "monitored_project" {
  for_each = local.metric_scopes
  project  = each.value
  role     = "roles/compute.viewer"
  members  = [
   "serviceAccount:${var.service_account}",
  ]

  depends_on = [
    google_monitoring_monitored_project.projects_monitored
  ]
}

# enable compute engine api
resource "google_project_service" "project_compute_engine_api" {
  for_each = local.metric_scopes
  project = each.value
  service  = "compute.googleapis.com"
  depends_on = [
    google_monitoring_monitored_project.projects_monitored
  ]
}