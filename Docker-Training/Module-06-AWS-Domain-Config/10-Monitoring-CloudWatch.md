# Monitoring with CloudWatch

## Overview
Comprehensive monitoring and observability using AWS CloudWatch for production applications.

## CloudWatch Metrics

### Custom Application Metrics
```python
import boto3
import time
from datetime import datetime

class CloudWatchMetrics:
    def __init__(self, namespace='MyApp'):
        self.cloudwatch = boto3.client('cloudwatch')
        self.namespace = namespace
    
    def put_metric(self, metric_name, value, unit='Count', dimensions=None):
        """Send custom metric to CloudWatch"""
        metric_data = {
            'MetricName': metric_name,
            'Value': value,
            'Unit': unit,
            'Timestamp': datetime.utcnow()
        }
        
        if dimensions:
            metric_data['Dimensions'] = [
                {'Name': k, 'Value': v} for k, v in dimensions.items()
            ]
        
        self.cloudwatch.put_metric_data(
            Namespace=self.namespace,
            MetricData=[metric_data]
        )
    
    def put_business_metrics(self, orders_count, revenue, user_signups):
        """Send business metrics"""
        metrics = [
            {
                'MetricName': 'OrdersCount',
                'Value': orders_count,
                'Unit': 'Count',
                'Timestamp': datetime.utcnow()
            },
            {
                'MetricName': 'Revenue',
                'Value': revenue,
                'Unit': 'None',
                'Timestamp': datetime.utcnow()
            },
            {
                'MetricName': 'UserSignups',
                'Value': user_signups,
                'Unit': 'Count',
                'Timestamp': datetime.utcnow()
            }
        ]
        
        self.cloudwatch.put_metric_data(
            Namespace=f'{self.namespace}/Business',
            MetricData=metrics
        )

# Usage in application
metrics = CloudWatchMetrics()

# Track API response times
start_time = time.time()
# ... API call ...
response_time = (time.time() - start_time) * 1000
metrics.put_metric('APIResponseTime', response_time, 'Milliseconds', 
                  {'Endpoint': '/api/products'})

# Track business metrics
metrics.put_business_metrics(orders_count=25, revenue=1250.50, user_signups=5)
```

### Infrastructure Metrics
```yaml
# CloudWatch Dashboard
CloudWatchDashboard:
  Type: AWS::CloudWatch::Dashboard
  Properties:
    DashboardName: MyApp-Infrastructure
    DashboardBody: !Sub |
      {
        "widgets": [
          {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
              "metrics": [
                ["AWS/EC2", "CPUUtilization", "InstanceId", "${WebServer1}"],
                ["AWS/EC2", "CPUUtilization", "InstanceId", "${WebServer2}"]
              ],
              "period": 300,
              "stat": "Average",
              "region": "us-east-1",
              "title": "EC2 CPU Utilization"
            }
          },
          {
            "type": "metric",
            "x": 0,
            "y": 6,
            "width": 12,
            "height": 6,
            "properties": {
              "metrics": [
                ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${LoadBalancer}"],
                ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${LoadBalancer}"]
              ],
              "period": 300,
              "stat": "Sum",
              "region": "us-east-1",
              "title": "Load Balancer Metrics"
            }
          }
        ]
      }
```

## CloudWatch Alarms

### Infrastructure Alarms
```yaml
HighCPUAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: !Sub "${AWS::StackName}-HighCPU"
    AlarmDescription: "CPU utilization is too high"
    MetricName: CPUUtilization
    Namespace: AWS/EC2
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 80
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: InstanceId
        Value: !Ref WebServer
    AlarmActions:
      - !Ref SNSTopicAlerts
      - !Ref ScaleUpPolicy
    OKActions:
      - !Ref SNSTopicAlerts

HighMemoryAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: !Sub "${AWS::StackName}-HighMemory"
    AlarmDescription: "Memory utilization is too high"
    MetricName: MemoryUtilization
    Namespace: CWAgent
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 85
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: InstanceId
        Value: !Ref WebServer
    AlarmActions:
      - !Ref SNSTopicAlerts

DiskSpaceAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: !Sub "${AWS::StackName}-LowDiskSpace"
    AlarmDescription: "Disk space is running low"
    MetricName: DiskSpaceUtilization
    Namespace: CWAgent
    Statistic: Average
    Period: 300
    EvaluationPeriods: 1
    Threshold: 90
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: InstanceId
        Value: !Ref WebServer
      - Name: Filesystem
        Value: /dev/xvda1
    AlarmActions:
      - !Ref SNSTopicCritical
```

### Application Alarms
```yaml
HighErrorRateAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: !Sub "${AWS::StackName}-HighErrorRate"
    AlarmDescription: "Application error rate is too high"
    MetricName: HTTPCode_Target_5XX_Count
    Namespace: AWS/ApplicationELB
    Statistic: Sum
    Period: 300
    EvaluationPeriods: 2
    Threshold: 10
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: LoadBalancer
        Value: !GetAtt ApplicationLoadBalancer.LoadBalancerFullName
    AlarmActions:
      - !Ref SNSTopicCritical

DatabaseConnectionAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: !Sub "${AWS::StackName}-HighDBConnections"
    AlarmDescription: "Database connection count is too high"
    MetricName: DatabaseConnections
    Namespace: AWS/RDS
    Statistic: Average
    Period: 300
    EvaluationPeriods: 2
    Threshold: 80
    ComparisonOperator: GreaterThanThreshold
    Dimensions:
      - Name: DBInstanceIdentifier
        Value: !Ref DatabaseInstance
    AlarmActions:
      - !Ref SNSTopicAlerts
```

## CloudWatch Logs

### Log Groups Configuration
```yaml
ApplicationLogGroup:
  Type: AWS::Logs::LogGroup
  Properties:
    LogGroupName: !Sub "/aws/ec2/${AWS::StackName}/application"
    RetentionInDays: 30

WebServerLogGroup:
  Type: AWS::Logs::LogGroup
  Properties:
    LogGroupName: !Sub "/aws/ec2/${AWS::StackName}/nginx"
    RetentionInDays: 14

DatabaseLogGroup:
  Type: AWS::Logs::LogGroup
  Properties:
    LogGroupName: !Sub "/aws/rds/instance/${DatabaseInstance}/postgresql"
    RetentionInDays: 7
```

### CloudWatch Agent Configuration
```json
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/ec2/myapp/nginx",
                        "log_stream_name": "{instance_id}/access.log",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/ec2/myapp/nginx",
                        "log_stream_name": "{instance_id}/error.log",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/myapp/application.log",
                        "log_group_name": "/aws/ec2/myapp/application",
                        "log_stream_name": "{instance_id}/app.log",
                        "timezone": "UTC",
                        "multi_line_start_pattern": "^\\d{4}-\\d{2}-\\d{2}"
                    }
                ]
            }
        }
    },
    "metrics": {
        "namespace": "CWAgent",
        "metrics_collected": {
            "cpu": {
                "measurement": [
                    "cpu_usage_idle",
                    "cpu_usage_iowait",
                    "cpu_usage_user",
                    "cpu_usage_system"
                ],
                "metrics_collection_interval": 60,
                "totalcpu": false
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "diskio": {
                "measurement": [
                    "io_time",
                    "read_bytes",
                    "write_bytes",
                    "reads",
                    "writes"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
```

### Log Insights Queries
```sql
-- Find error patterns in application logs
fields @timestamp, @message
| filter @message like /ERROR/
| stats count() by bin(5m)
| sort @timestamp desc

-- Analyze API response times
fields @timestamp, @message
| filter @message like /API_RESPONSE_TIME/
| parse @message "response_time=* endpoint=*" as response_time, endpoint
| stats avg(response_time), max(response_time), min(response_time) by endpoint
| sort avg(response_time) desc

-- Monitor database connection patterns
fields @timestamp, @message
| filter @message like /connection/
| parse @message "connections=*" as connections
| stats max(connections) by bin(1h)
| sort @timestamp desc

-- Track user activity
fields @timestamp, @message
| filter @message like /user_action/
| parse @message "user_id=* action=*" as user_id, action
| stats count() by action
| sort count desc
```

## Metric Filters and Alarms

### Application Error Tracking
```yaml
ErrorMetricFilter:
  Type: AWS::Logs::MetricFilter
  Properties:
    LogGroupName: !Ref ApplicationLogGroup
    FilterPattern: '[timestamp, request_id, level="ERROR", ...]'
    MetricTransformations:
      - MetricNamespace: MyApp/Errors
        MetricName: ErrorCount
        MetricValue: "1"
        DefaultValue: 0

ErrorRateAlarm:
  Type: AWS::CloudWatch::Alarm
  Properties:
    AlarmName: !Sub "${AWS::StackName}-HighErrorRate"
    AlarmDescription: "Application error rate is too high"
    MetricName: ErrorCount
    Namespace: MyApp/Errors
    Statistic: Sum
    Period: 300
    EvaluationPeriods: 2
    Threshold: 5
    ComparisonOperator: GreaterThanThreshold
    AlarmActions:
      - !Ref SNSTopicAlerts
```

### Performance Monitoring
```yaml
SlowQueryFilter:
  Type: AWS::Logs::MetricFilter
  Properties:
    LogGroupName: !Ref DatabaseLogGroup
    FilterPattern: '[timestamp, level, message="duration:" duration>1000, ...]'
    MetricTransformations:
      - MetricNamespace: MyApp/Database
        MetricName: SlowQueries
        MetricValue: "$duration"

HighLatencyFilter:
  Type: AWS::Logs::MetricFilter
  Properties:
    LogGroupName: !Ref WebServerLogGroup
    FilterPattern: '[ip, timestamp, request, status_code, response_time>2000, ...]'
    MetricTransformations:
      - MetricNamespace: MyApp/Performance
        MetricName: HighLatencyRequests
        MetricValue: "1"
```

## Custom Dashboards

### Executive Dashboard
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["MyApp/Business", "Revenue", {"stat": "Sum"}],
          ["MyApp/Business", "OrdersCount", {"stat": "Sum"}],
          ["MyApp/Business", "UserSignups", {"stat": "Sum"}]
        ],
        "period": 3600,
        "stat": "Sum",
        "region": "us-east-1",
        "title": "Business Metrics (Hourly)",
        "yAxis": {
          "left": {
            "min": 0
          }
        }
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", "app/myapp-alb/1234567890123456"],
          ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "app/myapp-alb/1234567890123456"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Application Performance"
      }
    }
  ]
}
```

### Technical Dashboard
```json
{
  "widgets": [
    {
      "type": "log",
      "properties": {
        "query": "SOURCE '/aws/ec2/myapp/application'\n| fields @timestamp, @message\n| filter @message like /ERROR/\n| sort @timestamp desc\n| limit 20",
        "region": "us-east-1",
        "title": "Recent Errors",
        "view": "table"
      }
    },
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["CWAgent", "mem_used_percent", "InstanceId", "i-1234567890abcdef0"],
          ["CWAgent", "disk_used_percent", "InstanceId", "i-1234567890abcdef0", "device", "/dev/xvda1", "fstype", "ext4", "path", "/"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "System Resources"
      }
    }
  ]
}
```

## Automated Monitoring Setup

### Monitoring Stack Deployment
```bash
#!/bin/bash
# deploy-monitoring.sh

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm

# Configure CloudWatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s

# Create log directories
sudo mkdir -p /var/log/myapp
sudo chown ec2-user:ec2-user /var/log/myapp

# Set up log rotation
cat << 'EOF' | sudo tee /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 ec2-user ec2-user
    postrotate
        systemctl reload myapp
    endscript
}
EOF

echo "Monitoring setup completed"
```

### Health Check Script
```python
#!/usr/bin/env python3
import requests
import boto3
import time
import json
from datetime import datetime

class HealthChecker:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
        self.endpoints = [
            'http://localhost:8000/health',
            'http://localhost:8000/api/v1/products',
            'http://localhost:5432'  # Database check
        ]
    
    def check_endpoint(self, url):
        try:
            start_time = time.time()
            response = requests.get(url, timeout=10)
            response_time = (time.time() - start_time) * 1000
            
            # Send metrics to CloudWatch
            self.cloudwatch.put_metric_data(
                Namespace='MyApp/HealthCheck',
                MetricData=[
                    {
                        'MetricName': 'ResponseTime',
                        'Value': response_time,
                        'Unit': 'Milliseconds',
                        'Dimensions': [
                            {'Name': 'Endpoint', 'Value': url}
                        ]
                    },
                    {
                        'MetricName': 'StatusCode',
                        'Value': response.status_code,
                        'Unit': 'None',
                        'Dimensions': [
                            {'Name': 'Endpoint', 'Value': url}
                        ]
                    }
                ]
            )
            
            return response.status_code == 200
        except Exception as e:
            print(f"Health check failed for {url}: {e}")
            return False
    
    def run_checks(self):
        results = {}
        for endpoint in self.endpoints:
            results[endpoint] = self.check_endpoint(endpoint)
        
        # Overall health metric
        healthy_count = sum(results.values())
        self.cloudwatch.put_metric_data(
            Namespace='MyApp/HealthCheck',
            MetricData=[{
                'MetricName': 'OverallHealth',
                'Value': healthy_count / len(self.endpoints) * 100,
                'Unit': 'Percent'
            }]
        )
        
        return results

if __name__ == "__main__":
    checker = HealthChecker()
    results = checker.run_checks()
    print(f"Health check results: {json.dumps(results, indent=2)}")
```

## Troubleshooting and Optimization

### Common Monitoring Issues
1. **Missing metrics**: Check IAM permissions and CloudWatch agent configuration
2. **High costs**: Optimize log retention and metric frequency
3. **Alert fatigue**: Fine-tune alarm thresholds and use composite alarms

### Performance Optimization
```bash
# Optimize CloudWatch agent performance
sudo systemctl edit amazon-cloudwatch-agent
```

```ini
[Service]
CPUQuota=10%
MemoryLimit=128M
```

### Cost Optimization
```yaml
# Log retention policies
LogRetentionPolicy:
  Type: AWS::Logs::LogGroup
  Properties:
    RetentionInDays: !If
      - IsProduction
      - 30
      - 7

# Metric filters with sampling
SampledMetricFilter:
  Type: AWS::Logs::MetricFilter
  Properties:
    FilterPattern: '[timestamp, request_id="sample-*", level, message]'
    # Only process sampled requests to reduce costs
```
