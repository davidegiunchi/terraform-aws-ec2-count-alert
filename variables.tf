
variable "region" {
  description = "AWS region where EC2 instances are counted"
  type        = string
  default     = "eu-west-1"
}

variable "cron_expression" {
  description = "Schedule expression for EventBridge to trigger Lambda function. Can be cron() or rate()"
  type        = string
  default     = "cron(0/10 * * * ? *)"
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# Alarm variables

variable "create_alarm" {
  description = "Whether to create the CloudWatch alarm"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications. Required if create_alarm is true"
  type        = string
  default     = null
}

variable "ec2_threshold" {
  description = "The number of running EC2 instances that triggers the alarm. Required if create_alarm is true"
  type        = number
  default     = null
}

variable "evaluation_periods" {
  description = "The number of periods over which data is compared to the threshold"
  type        = number
  default     = 3
}

variable "period" {
  description = "The period in seconds over which the statistic is applied"
  type        = number
  default     = 600
}

variable "alarm_description" {
  description = "Description for the CloudWatch alarm"
  type        = string
  default     = "Too many EC2 instances running"
}
