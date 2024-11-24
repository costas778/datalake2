variable "database_name" {
  type        = string
  description = "Name of the Athena database"
}

variable "workgroup_name" {
  type        = string
  description = "Name of the Athena workgroup"
}

variable "analytics_bucket_name" {
  type        = string
  description = "Name of the analytics S3 bucket"
}

variable "create_table_sql_path" {
  type        = string
  description = "Path to the SQL file containing table creation statements"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

