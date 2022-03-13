resource "aws_dynamodb_table" "cache" {

  name         = "${var.name}-cache"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "key"

  attribute {
    name = "key"
    type = "S"
  }

  attribute {
    name = "expires"
    type = "N"
  }

  ttl {
    attribute_name = "expires"
    enabled        = true
  }

}

module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "1.14.0"

  create_bus = false

  rules = {
    crons = {
      description         = "${var.name}-cron"
      schedule_expression = var.schedule
    }
  }

  targets = {
    crons = [
      {
        name  = "${var.name}-cron"
        arn   = module.lambda.function_arn
        input = jsonencode({ "job" : "cron-by-rate" })
      }
    ]
  }
}

module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.35.0"

  function_name  = var.name
  create_package = false
  image_uri      = "public.ecr.aws/jonohill/lambda-twitter-dedupe:${var.version}"
  package_type   = "Image"
  publish        = true
  architectures  = ["arm64"]

  cloudwatch_logs_retention_in_days = 5
  timeout                           = 120

  environment_variables = var.environment_variables

  attach_policy_statements = true
  policy_statements = {
    cache_table = {
      effect = "Allow",
      actions = [
        "dynamodb:GetItem",
        "dynamodb:BatchGetItem",
        "dynamodb:Query",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:BatchWriteItem"
      ]
      resources = [aws_dynamodb_table.cache.arn]
    }
  }

  allowed_triggers = {
    EventBridge = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["crons"]
    }
  }
}
