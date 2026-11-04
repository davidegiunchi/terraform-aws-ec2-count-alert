
output "lambda_function_arn" {
  description = "The ARN of the Lambda Function"
  value       = module.lambda_function.lambda_function_arn
}

output "lambda_function_name" {
  description = "The name of the Lambda Function"
  value       = module.lambda_function.lambda_function_name
}

output "lambda_role_arn" {
  description = "The ARN of the IAM role created for the Lambda Function"
  value       = module.lambda_function.lambda_role_arn
}

output "eventbridge_rule_arn" {
  description = "The ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.ec2_count.arn
}

output "cloudwatch_alarm_arn" {
  description = "The ARN of the CloudWatch alarm (empty if create_alarm is false)"
  value       = var.create_alarm ? aws_cloudwatch_metric_alarm.ec2_alarm[0].arn : null
}
