variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "athena_workgroup_name" {
  type        = string
  description = "Name of the Athena workgroup"
}

variable "quicksight_user" {
  type        = string
  description = "QuickSight user name"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

