# modules/quicksight/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "athena_workgroup_name" {
  description = "Name of the Athena workgroup"
  type        = string
}

variable "quicksight_user" {
  description = "QuickSight user name"
  type        = string
}

variable "quicksight_user_email" {
  description = "Email address of the QuickSight user"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "quicksight_namespace" {
  description = "The QuickSight namespace."
  type        = string
  default     = "default"
}

variable "quicksight_user_role" {
  description = "The role of the QuickSight user (e.g., ADMIN, AUTHOR, READER)."
  type        = string
  default     = "AUTHOR"
}

variable "quicksight_identity_type" {
  description = "The identity type for the QuickSight user (e.g., 'IAM' or 'QUICKSIGHT')."
  type        = string
  default     = "IAM"
}

# variables.tf

variable "quicksight_policy" {
  description = "IAM policy for QuickSight"
  type        = string
}

variable "iam_user" {
  description = "IAM username for QuickSight"
  type        = string
}


variable "athena_query_results_bucket" {
  description = "The S3 bucket for Athena query results"
  type        = string
}
