resource "aws_quicksight_data_source" "athena" {
  aws_account_id = data.aws_caller_identity.current.account_id
  data_source_id = "${var.project_name}-athena-source"
  name           = "Athena Data Source"
  type           = "ATHENA"
  
  parameters {
    athena {
      work_group = var.athena_workgroup_name
    }
  }

  permissions {
    actions   = ["quicksight:UpdateDataSourcePermissions", "quicksight:DescribeDataSource", "quicksight:DescribeDataSourcePermissions", "quicksight:PassDataSource", "quicksight:UpdateDataSource", "quicksight:DeleteDataSource"]
    principal = "arn:aws:quicksight:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:user/default/${var.quicksight_user}"
  }

  tags = var.tags
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
