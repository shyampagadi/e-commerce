# Exercise 01 Solution: Message Queue Implementation

## Solution Overview
This solution implements a comprehensive message queue system using AWS SQS with proper error handling, monitoring, and performance optimization for the e-commerce notification system.

## Architecture Solution

### System Design
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Order API     │───▶│   SQS Standard   │───▶│ Notification    │
│   (Producer)    │    │     Queue        │    │   Service       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   CloudWatch    │    │   Dead Letter    │    │   Customer      │
│   Metrics       │    │     Queue        │    │ Notifications   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Implementation Solution

### 1. SQS Queue Configuration
```python
import boto3
import json
from datetime import datetime, timedelta

class NotificationQueueManager:
    def __init__(self):
        self.sqs = boto3.client('sqs')
        self.queue_url = None
        self.dlq_url = None
        
    def create_queues(self):
        """Create main queue and dead letter queue"""
        
        # Create Dead Letter Queue first
        dlq_response = self.sqs.create_queue(
            QueueName='notification-dlq',
            Attributes={
                'MessageRetentionPeriod': '1209600',  # 14 days
                'VisibilityTimeoutSeconds': '60'
            }
        )
        self.dlq_url = dlq_response['QueueUrl']
        
        # Get DLQ ARN for main queue configuration
        dlq_attributes = self.sqs.get_queue_attributes(
            QueueUrl=self.dlq_url,
            AttributeNames=['QueueArn']
        )
        dlq_arn = dlq_attributes['Attributes']['QueueArn']
        
        # Create main notification queue
        redrive_policy = {
            'deadLetterTargetArn': dlq_arn,
            'maxReceiveCount': 3
        }
        
        queue_response = self.sqs.create_queue(
            QueueName='notification-queue',
            Attributes={
                'VisibilityTimeoutSeconds': '300',  # 5 minutes
                'MessageRetentionPeriod': '1209600',  # 14 days
                'ReceiveMessageWaitTimeSeconds': '20',  # Long polling
                'RedrivePolicy': json.dumps(redrive_policy)
            }
        )
        self.queue_url = queue_response['QueueUrl']
        
        return self.queue_url, self.dlq_url
```

### 2. Message Producer Implementation
```python
class NotificationProducer:
    def __init__(self, queue_url):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
        
    def send_notification(self, notification_data):
        """Send notification message to queue"""
        try:
            message_body = {
                'notification_id': notification_data['id'],
                'customer_id': notification_data['customer_id'],
                'type': notification_data['type'],  # email, sms, push
                'template': notification_data['template'],
                'data': notification_data['data'],
                'priority': notification_data.get('priority', 'normal'),
                'created_at': datetime.utcnow().isoformat(),
                'retry_count': 0
            }
            
            # Add message attributes for filtering
            message_attributes = {
                'NotificationType': {
                    'StringValue': notification_data['type'],
                    'DataType': 'String'
                },
                'Priority': {
                    'StringValue': notification_data.get('priority', 'normal'),
                    'DataType': 'String'
                },
                'CustomerId': {
                    'StringValue': str(notification_data['customer_id']),
                    'DataType': 'String'
                }
            }
            
            response = self.sqs.send_message(
                QueueUrl=self.queue_url,
                MessageBody=json.dumps(message_body),
                MessageAttributes=message_attributes,
                DelaySeconds=notification_data.get('delay_seconds', 0)
            )
            
            return response['MessageId']
            
        except Exception as e:
            print(f"Error sending notification: {str(e)}")
            raise
            
    def send_batch_notifications(self, notifications):
        """Send multiple notifications in batch (up to 10)"""
        entries = []
        
        for i, notification in enumerate(notifications[:10]):  # SQS batch limit
            message_body = {
                'notification_id': notification['id'],
                'customer_id': notification['customer_id'],
                'type': notification['type'],
                'template': notification['template'],
                'data': notification['data'],
                'priority': notification.get('priority', 'normal'),
                'created_at': datetime.utcnow().isoformat(),
                'retry_count': 0
            }
            
            entries.append({
                'Id': str(i),
                'MessageBody': json.dumps(message_body),
                'MessageAttributes': {
                    'NotificationType': {
                        'StringValue': notification['type'],
                        'DataType': 'String'
                    },
                    'Priority': {
                        'StringValue': notification.get('priority', 'normal'),
                        'DataType': 'String'
                    }
                }
            })
        
        try:
            response = self.sqs.send_message_batch(
                QueueUrl=self.queue_url,
                Entries=entries
            )
            return response
            
        except Exception as e:
            print(f"Error sending batch notifications: {str(e)}")
            raise
```

### 3. Message Consumer Implementation
```python
import time
import threading
from concurrent.futures import ThreadPoolExecutor

class NotificationConsumer:
    def __init__(self, queue_url, max_workers=5):
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
        self.max_workers = max_workers
        self.running = False
        self.executor = ThreadPoolExecutor(max_workers=max_workers)
        
    def start_consuming(self):
        """Start consuming messages from the queue"""
        self.running = True
        
        # Start multiple worker threads
        for _ in range(self.max_workers):
            self.executor.submit(self._consume_messages)
            
    def stop_consuming(self):
        """Stop consuming messages"""
        self.running = False
        self.executor.shutdown(wait=True)
        
    def _consume_messages(self):
        """Worker thread to consume messages"""
        while self.running:
            try:
                # Long polling for messages
                response = self.sqs.receive_message(
                    QueueUrl=self.queue_url,
                    MaxNumberOfMessages=10,  # Batch processing
                    WaitTimeSeconds=20,      # Long polling
                    MessageAttributeNames=['All']
                )
                
                messages = response.get('Messages', [])
                
                if messages:
                    # Process messages in parallel
                    futures = []
                    for message in messages:
                        future = self.executor.submit(self._process_message, message)
                        futures.append(future)
                    
                    # Wait for all messages to be processed
                    for future in futures:
                        future.result()
                        
            except Exception as e:
                print(f"Error consuming messages: {str(e)}")
                time.sleep(5)  # Wait before retrying
                
    def _process_message(self, message):
        """Process individual message"""
        try:
            # Parse message body
            message_body = json.loads(message['Body'])
            
            # Process notification based on type
            success = self._send_notification(message_body)
            
            if success:
                # Delete message from queue on successful processing
                self.sqs.delete_message(
                    QueueUrl=self.queue_url,
                    ReceiptHandle=message['ReceiptHandle']
                )
                print(f"Successfully processed notification {message_body['notification_id']}")
            else:
                # Let message return to queue for retry
                print(f"Failed to process notification {message_body['notification_id']}")
                
        except Exception as e:
            print(f"Error processing message: {str(e)}")
            # Message will return to queue for retry
            
    def _send_notification(self, notification_data):
        """Send actual notification (email, SMS, push)"""
        try:
            notification_type = notification_data['type']
            
            if notification_type == 'email':
                return self._send_email(notification_data)
            elif notification_type == 'sms':
                return self._send_sms(notification_data)
            elif notification_type == 'push':
                return self._send_push_notification(notification_data)
            else:
                print(f"Unknown notification type: {notification_type}")
                return False
                
        except Exception as e:
            print(f"Error sending notification: {str(e)}")
            return False
            
    def _send_email(self, notification_data):
        """Send email notification using SES"""
        try:
            ses = boto3.client('ses')
            
            response = ses.send_email(
                Source='noreply@example.com',
                Destination={
                    'ToAddresses': [notification_data['data']['email']]
                },
                Message={
                    'Subject': {
                        'Data': notification_data['data']['subject']
                    },
                    'Body': {
                        'Html': {
                            'Data': notification_data['data']['html_body']
                        },
                        'Text': {
                            'Data': notification_data['data']['text_body']
                        }
                    }
                }
            )
            
            return True
            
        except Exception as e:
            print(f"Error sending email: {str(e)}")
            return False
            
    def _send_sms(self, notification_data):
        """Send SMS notification using SNS"""
        try:
            sns = boto3.client('sns')
            
            response = sns.publish(
                PhoneNumber=notification_data['data']['phone_number'],
                Message=notification_data['data']['message']
            )
            
            return True
            
        except Exception as e:
            print(f"Error sending SMS: {str(e)}")
            return False
            
    def _send_push_notification(self, notification_data):
        """Send push notification"""
        try:
            # Implementation depends on push service (FCM, APNS, etc.)
            # This is a placeholder implementation
            print(f"Sending push notification to device: {notification_data['data']['device_token']}")
            return True
            
        except Exception as e:
            print(f"Error sending push notification: {str(e)}")
            return False
```

### 4. Monitoring and Metrics
```python
class NotificationMonitoring:
    def __init__(self, queue_url):
        self.cloudwatch = boto3.client('cloudwatch')
        self.sqs = boto3.client('sqs')
        self.queue_url = queue_url
        
    def publish_custom_metrics(self, metric_name, value, unit='Count'):
        """Publish custom metrics to CloudWatch"""
        try:
            self.cloudwatch.put_metric_data(
                Namespace='NotificationSystem',
                MetricData=[
                    {
                        'MetricName': metric_name,
                        'Value': value,
                        'Unit': unit,
                        'Timestamp': datetime.utcnow()
                    }
                ]
            )
        except Exception as e:
            print(f"Error publishing metric: {str(e)}")
            
    def get_queue_metrics(self):
        """Get queue depth and other metrics"""
        try:
            attributes = self.sqs.get_queue_attributes(
                QueueUrl=self.queue_url,
                AttributeNames=[
                    'ApproximateNumberOfMessages',
                    'ApproximateNumberOfMessagesNotVisible',
                    'ApproximateNumberOfMessagesDelayed'
                ]
            )
            
            return {
                'messages_available': int(attributes['Attributes']['ApproximateNumberOfMessages']),
                'messages_in_flight': int(attributes['Attributes']['ApproximateNumberOfMessagesNotVisible']),
                'messages_delayed': int(attributes['Attributes']['ApproximateNumberOfMessagesDelayed'])
            }
            
        except Exception as e:
            print(f"Error getting queue metrics: {str(e)}")
            return None
            
    def setup_cloudwatch_alarms(self):
        """Set up CloudWatch alarms for monitoring"""
        try:
            # Alarm for high queue depth
            self.cloudwatch.put_metric_alarm(
                AlarmName='NotificationQueue-HighDepth',
                ComparisonOperator='GreaterThanThreshold',
                EvaluationPeriods=2,
                MetricName='ApproximateNumberOfVisibleMessages',
                Namespace='AWS/SQS',
                Period=300,
                Statistic='Average',
                Threshold=1000.0,
                ActionsEnabled=True,
                AlarmActions=[
                    'arn:aws:sns:us-east-1:123456789012:notification-alerts'
                ],
                AlarmDescription='Alert when notification queue depth is high',
                Dimensions=[
                    {
                        'Name': 'QueueName',
                        'Value': 'notification-queue'
                    }
                ]
            )
            
            # Alarm for old messages
            self.cloudwatch.put_metric_alarm(
                AlarmName='NotificationQueue-OldMessages',
                ComparisonOperator='GreaterThanThreshold',
                EvaluationPeriods=1,
                MetricName='ApproximateAgeOfOldestMessage',
                Namespace='AWS/SQS',
                Period=300,
                Statistic='Maximum',
                Threshold=1800.0,  # 30 minutes
                ActionsEnabled=True,
                AlarmActions=[
                    'arn:aws:sns:us-east-1:123456789012:notification-alerts'
                ],
                AlarmDescription='Alert when messages are aging in queue'
            )
            
        except Exception as e:
            print(f"Error setting up alarms: {str(e)}")
```

### 5. Usage Example
```python
def main():
    # Initialize components
    queue_manager = NotificationQueueManager()
    queue_url, dlq_url = queue_manager.create_queues()
    
    producer = NotificationProducer(queue_url)
    consumer = NotificationConsumer(queue_url, max_workers=10)
    monitoring = NotificationMonitoring(queue_url)
    
    # Set up monitoring
    monitoring.setup_cloudwatch_alarms()
    
    # Start consumer
    consumer.start_consuming()
    
    # Example: Send notifications
    notifications = [
        {
            'id': 'notif-001',
            'customer_id': 12345,
            'type': 'email',
            'template': 'order_confirmation',
            'data': {
                'email': 'customer@example.com',
                'subject': 'Order Confirmation',
                'html_body': '<h1>Your order has been confirmed!</h1>',
                'text_body': 'Your order has been confirmed!'
            },
            'priority': 'high'
        },
        {
            'id': 'notif-002',
            'customer_id': 12346,
            'type': 'sms',
            'template': 'shipping_update',
            'data': {
                'phone_number': '+1234567890',
                'message': 'Your order has shipped!'
            }
        }
    ]
    
    # Send batch notifications
    producer.send_batch_notifications(notifications)
    
    # Monitor queue metrics
    while True:
        metrics = monitoring.get_queue_metrics()
        if metrics:
            print(f"Queue metrics: {metrics}")
            monitoring.publish_custom_metrics('QueueDepth', metrics['messages_available'])
        
        time.sleep(60)  # Check every minute

if __name__ == "__main__":
    main()
```

## Performance Optimization

### 1. Batch Processing
- Use `send_message_batch()` for up to 10 messages per request
- Process multiple messages concurrently in consumer
- Implement connection pooling for AWS SDK clients

### 2. Long Polling
- Set `ReceiveMessageWaitTimeSeconds` to 20 for long polling
- Reduces empty responses and API costs
- Improves message delivery latency

### 3. Visibility Timeout Tuning
- Set appropriate visibility timeout based on processing time
- Use `ChangeMessageVisibility` to extend timeout if needed
- Implement exponential backoff for retries

### 4. Dead Letter Queue Strategy
- Set `maxReceiveCount` to 3 for automatic DLQ routing
- Monitor DLQ for failed messages requiring investigation
- Implement DLQ message reprocessing workflow

## Cost Optimization

### Monthly Cost Estimation
```python
def calculate_monthly_costs(messages_per_day, avg_message_size_kb):
    """Calculate estimated monthly SQS costs"""
    
    # SQS pricing (as of 2024)
    cost_per_million_requests = 0.40  # USD
    
    monthly_messages = messages_per_day * 30
    monthly_requests = monthly_messages * 2  # Send + Receive
    
    monthly_cost = (monthly_requests / 1_000_000) * cost_per_million_requests
    
    return {
        'monthly_messages': monthly_messages,
        'monthly_requests': monthly_requests,
        'monthly_cost_usd': monthly_cost,
        'cost_per_message': monthly_cost / monthly_messages
    }

# Example calculation
costs = calculate_monthly_costs(100_000, 2)  # 100K messages/day, 2KB each
print(f"Monthly cost: ${costs['monthly_cost_usd']:.2f}")
```

This solution provides a production-ready message queue implementation with proper error handling, monitoring, and optimization strategies for the e-commerce notification system.
