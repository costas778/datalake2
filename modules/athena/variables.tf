variable "athena_database_name" {
  description = "Name of the Athena database"
  type        = string
}

variable "athena_workgroup_name" {
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
  default     = {}
}

variable "table_name" {
  description = "Name of the Athena/Glue table"
  type        = string
  default     = "my_ingested_data"
}
