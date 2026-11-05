# EC2 Count Alert

Terraform module that alerts you when the number of running EC2 instances exceedes a certain number.  
It creates a Lambda Function triggered by EventBridge to count running EC2 instances in a region and publish the count as a custom CloudWatch metric, then it creates a CloudWatch Alarm that fires when the number of running instances exceeds a given threshold.
It can be useful to monitoring the ec2 costs and, above all, for being alerted in case of security breaches: One of the first thing an attacker would likely do if they ever got access to your AWS secret keys would be to spin up as many servers as possible for crypto mining purpose or something else, if you get noticed about this behaviour you can block it.  
The lambda will create a new metric named *InstanceCount* on the namespace *Custom/EC2*, you can use that to graph the number of running ec2 in a dashboard.  
The lambda code is taken from various [example like this](https://medium.com/johnveldboom/create-aws-cloudwatch-alarm-on-the-number-of-running-ec2-instances-d57af375356a).  

## Usage

simple:
```hcl
module "ec2_count_alert" {
  source = "davidegiunchi/ec2-count-alert"

  region = "eu-west-1"

  sns_topic_arn = "arn:aws:sns:eu-west-1:123456789012:alerts"
  ec2_threshold = 65

  tags = {
    cost-center = "myproject"
    Environment = "production"
  }
}
```

advanced arguments:

```hcl
module "ec2_count_alert" {
  source = "davidegiunchi/ec2-count-alert"

  region          = "eu-west-1"
  cron_expression = "cron(0/20 * * * ? *)"

  sns_topic_arn     = aws_sns_topic.alerts.arn
  ec2_threshold     = 65
  alarm_description = "Too many EC2 instances running"

  tags = {
    cost-center = "myproject"
    Environment = "production"
  }
}

resource "aws_sns_topic" "alerts" {
  name = "alerts"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | terraform-aws-modules/lambda/aws | 8.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.ec2_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_cloudwatch_event_rule.ec2_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ec2_count](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_metric_alarm.ec2_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region where EC2 instances are counted | `string` | `"eu-west-1"` | no |
| <a name="input_cron_expression"></a> [cron\_expression](#input\_cron\_expression) | Schedule expression for EventBridge to trigger Lambda function. Can be cron() or rate() | `string` | `"cron(0/10 * * * ? *)"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources | `map(string)` | `{}` | no |
| <a name="input_create_alarm"></a> [create\_alarm](#input\_create\_alarm) | Whether to create the CloudWatch alarm | `bool` | `true` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of the SNS topic for alarm notifications. Required if create_alarm is true | `string` | `null` | no |
| <a name="input_ec2_threshold"></a> [ec2\_threshold](#input\_ec2\_threshold) | The number of running EC2 instances that triggers the alarm. Required if create_alarm is true | `number` | `null` | no |
| <a name="input_evaluation_periods"></a> [evaluation\_periods](#input\_evaluation\_periods) | The number of periods over which data is compared to the threshold | `number` | `3` | no |
| <a name="input_period"></a> [period](#input\_period) | The period in seconds over which the statistic is applied | `number` | `600` | no |
| <a name="input_alarm_description"></a> [alarm\_description](#input\_alarm\_description) | Description for the CloudWatch alarm | `string` | `"Too many EC2 instances running"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda Function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The name of the Lambda Function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | The ARN of the IAM role created for the Lambda Function |
| <a name="output_eventbridge_rule_arn"></a> [eventbridge\_rule\_arn](#output\_eventbridge\_rule\_arn) | The ARN of the EventBridge rule |
| <a name="output_cloudwatch_alarm_arn"></a> [cloudwatch\_alarm\_arn](#output\_cloudwatch\_alarm\_arn) | The ARN of the CloudWatch alarm (empty if create_alarm is false) |
