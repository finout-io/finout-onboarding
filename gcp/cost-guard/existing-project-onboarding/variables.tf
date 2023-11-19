variable "scoping_project_id" {
  type        = string
  description = "Existing project id"
}

variable "service_account" {
  type        = string
  description = "Finout's (billing) service account"
}

variable "add_monitored_projects" {
  type        = bool
  description = "Should add monitored projects to the scoping project"
  default     = false
}

variable "monitored_projects" {
  type        =  list(string)
  description =  "monitored projects to add to the scoping project"
  default     = []
}
