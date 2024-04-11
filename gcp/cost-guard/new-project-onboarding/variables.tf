variable "org_id" {
  type        = string
  description = "The organization to create the scoping project"
}

variable "scoping_project_name" {
  type        = string
  description = "Scoping project name"
  default = null
}

variable "scoping_project_id" {
  type        = string
  description = "Finout's (billing) service account"
  default = null
}

variable "service_account" {
  type        = string
  description = "Finout's (billing) service account"
}


variable "monitored_projects" {
  type        =  list(string)
  description = "Finout's (billing) service account"
  default     = []
}

variable "projects_filter" {
  type        = string
  description = "A string filter as defined in the GCP REST API"
  default     = "lifecycleState:ACTIVE"
}