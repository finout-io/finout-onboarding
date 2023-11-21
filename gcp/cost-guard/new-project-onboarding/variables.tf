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
