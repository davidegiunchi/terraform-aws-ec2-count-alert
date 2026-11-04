import boto3
import os

def lambda_handler(event, context):
    region = os.environ.get('REGION', 'us-east-1')
    
    # Initialize EC2 and CloudWatch clients
    ec2_client = boto3.client('ec2', region_name=region)
    cloudwatch = boto3.client('cloudwatch', region_name=region)
    
    # Count running EC2 instances
    instance_count = 0
    paginator = ec2_client.get_paginator('describe_instances')
    
    # Use paginator to handle more than 1000 instances
    for page in paginator.paginate(
        Filters=[
            {
                'Name': 'instance-state-name',
                'Values': ['pending', 'running']
            }
        ]
    ):
        for reservation in page['Reservations']:
            instance_count += len(reservation['Instances'])
    
    # Put the metric data to CloudWatch
    cloudwatch.put_metric_data(
        Namespace='Custom/EC2',
        MetricData=[
            {
                'MetricName': 'InstanceCount',
                'Value': instance_count,
                'Unit': 'Count'
            }
        ]
    )
    
    print(f"EC2 instance count in {region}: {instance_count}")
    return {
        'statusCode': 200,
        'body': f'EC2 instance count in {region}: {instance_count}'
    }