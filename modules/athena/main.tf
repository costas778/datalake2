resource "aws_athena_database" "main" {
  name   = var.database_name
  bucket = var.analytics_bucket_name
}

resource "aws_athena_workgroup" "main" {
  name = var.workgroup_name

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.analytics_bucket_name}/athena-results/"
    }
  }

  tags = var.tags
}

resource "aws_athena_named_query" "create_table" {
  name      = "create-table-query"
  workgroup = aws_athena_workgroup.main.id
  database  = aws_athena_database.main.name
  query     = file(var.create_table_sql_path)
}
