
##################
# Lambda Function
##################
module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.7.0"

  lambda_at_edge = false

  function_name = "ec2-count"
  description   = "count the number of running ec2 instances in a region"
  handler       = "index.lambda_handler"
  runtime       = "python3.13"

  source_path = "${path.module}/src"

  attach_cloudwatch_logs_policy     = true
  cloudwatch_logs_retention_in_days = 30

  timeout = 60

  environment_variables = {
    REGION = var.region
  }

  publish = true

  attach_policies    = true
  number_of_policies = 2
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.ec2_count.arn
  ]

  allowed_triggers = {
    StartDBRule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.ec2_count.arn
    }
  }

  tags = var.tags
}

##############
# IAM Policy
##############
resource "aws_iam_policy" "ec2_count" {
  name        = "ec2_count"
  description = "lambda that count the number of ec2 instances"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "EC2Count",
          "Effect": "Allow",
          "Action": [
              "ec2:DescribeInstances",
              "ec2:DescribeRegions"
          ],
          "Resource": "*"
      },
      {
          "Sid": "MetriPut",
          "Effect": "Allow",
          "Action": [
              "cloudwatch:PutMetricData"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

##################################
# Cloudwatch Events (EventBridge)
##################################
resource "aws_cloudwatch_event_rule" "ec2_count" {
  name                = "ec2_count"
  description         = "count the number of running ec2 instances in a region"
  schedule_expression = var.cron_expression
}

resource "aws_cloudwatch_event_target" "ec2_count" {
  rule = aws_cloudwatch_event_rule.ec2_count.name
  arn  = module.lambda_function.lambda_function_arn
}

##################################
# CloudWatch Alarm (optional)
##################################
resource "aws_cloudwatch_metric_alarm" "ec2_alarm" {
  count = var.create_alarm ? 1 : 0

  alarm_name          = "ec2-count-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "InstanceCount"
  namespace           = "Custom/EC2"
  period              = var.period
  statistic           = "Average"
  threshold           = var.ec2_threshold
  alarm_description   = var.alarm_description

  insufficient_data_actions = []

  alarm_actions = [var.sns_topic_arn]
  ok_actions    = [var.sns_topic_arn]
}
