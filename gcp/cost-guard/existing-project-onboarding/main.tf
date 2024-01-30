data "google_projects" "org_projects" {
  filter="lifecycleState:ACTIVE"
}

locals {
    user_metric_scopes = toset(var.monitored_projects)
    projects_ids = setsubtract(toset([for project in data.google_projects.org_projects.projects: project.project_id]), [var.scoping_project_id])
    metric_scopes = var.add_monitored_projects == true ? (length(local.user_metric_scopes) == 0 ? local.projects_ids : local.user_metric_scopes) : []
}

output "projects" {
  value = [
    for project in local.metric_scopes: project
  ]
}

# enable monitoring api
resource "google_project_service" "project_monitor_api" {
  project = var.scoping_project_id
  service  = "monitoring.googleapis.com"
}

# bind service account to the scoping project with Monitoring View role
resource "google_project_iam_binding" "project" {
  project = var.scoping_project_id
  role    = "roles/monitoring.viewer"

  members = [
   "serviceAccount:${var.service_account}",
  ]
}

# bind projects as monitored to the scoping project
resource "google_monitoring_monitored_project" "projects_monitored" {
  for_each      = local.metric_scopes
  metrics_scope = join("", ["locations/global/metricsScopes/", var.scoping_project_id])
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