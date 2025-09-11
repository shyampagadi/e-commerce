# Amazon SNS and EventBridge Implementation

## Overview
Amazon SNS (Simple Notification Service) and Amazon EventBridge are powerful AWS services for implementing pub/sub messaging and event routing patterns. This guide covers advanced implementation patterns, best practices, and real-world use cases.

## Amazon SNS Deep Dive

### SNS Architecture Patterns

#### Fan-Out Pattern
```python
import boto3
import json
from typing import List, Dict

class SNSFanOutPublisher:
    def __init__(self, topic_arn: str):
        self.sns = boto3.client('sns')
        self.topic_arn = topic_arn
    
    def publish_order_event(self, order_data: Dict):
        """Publish order event to multiple subscribers"""
        message = {
            'eventType': 'OrderPlaced',
            'orderId': order_data['orderId'],
            'customerId': order_data['customerId'],
            'items': order_data['items'],
            'totalAmount': order_data['totalAmount'],
            'timestamp': datetime.now().isoformat()
        }
        
        # Publish to topic - all subscribers receive the message
        response = self.sns.publish(
            TopicArn=self.topic_arn,
            Message=json.dumps(message),
            MessageAttributes={
                'eventType': {
                    'DataType': 'String',
                    'StringValue': 'OrderPlaced'
                },
                'customerId': {
                    'DataType': 'String',
                    'StringValue': str(order_data['customerId'])
                },
                'orderValue': {
                    'DataType': 'Number',
                    'StringValue': str(order_data['totalAmount'])
                }
            },
            Subject='Order Placed Event'
        )
        
        return response['MessageId']

class SNSSubscriptionManager:
    def __init__(self, topic_arn: str):
        self.sns = boto3.client('sns')
        self.topic_arn = topic_arn
    
    def subscribe_sqs_queue(self, queue_arn: str, filter_policy: Dict = None):
        """Subscribe SQS queue with optional message filtering"""
        subscription = self.sns.subscribe(
            TopicArn=self.topic_arn,
            Protocol='sqs',
            Endpoint=queue_arn
        )
        
        if filter_policy:
            self.sns.set_subscription_attributes(
                SubscriptionArn=subscription['SubscriptionArn'],
                AttributeName='FilterPolicy',
                AttributeValue=json.dumps(filter_policy)
            )
        
        return subscription['SubscriptionArn']
    
    def subscribe_lambda_function(self, lambda_arn: str, filter_policy: Dict = None):
        """Subscribe Lambda function with optional filtering"""
        subscription = self.sns.subscribe(
            TopicArn=self.topic_arn,
            Protocol='lambda',
            Endpoint=lambda_arn
        )
        
        if filter_policy:
            self.sns.set_subscription_attributes(
                SubscriptionArn=subscription['SubscriptionArn'],
                AttributeName='FilterPolicy',
                AttributeValue=json.dumps(filter_policy)
            )
        
        return subscription['SubscriptionArn']
```

#### Message Filtering
```python
class SNSMessageFilter:
    def __init__(self, topic_arn: str):
        self.sns = boto3.client('sns')
        self.topic_arn = topic_arn
    
    def setup_filtered_subscriptions(self):
        """Set up subscriptions with different filter policies"""
        
        # Inventory service - only high-value orders
        inventory_filter = {
            "orderValue": [{"numeric": [">=", 1000]}],
            "eventType": ["OrderPlaced"]
        }
        
        # Email service - all orders
        email_filter = {
            "eventType": ["OrderPlaced", "OrderCancelled", "OrderShipped"]
        }
        
        # Analytics service - specific customer segments
        analytics_filter = {
            "customerSegment": ["premium", "enterprise"],
            "eventType": ["OrderPlaced"]
        }
        
        # Fraud detection - high-value or suspicious patterns
        fraud_filter = {
            "orderValue": [{"numeric": [">=", 5000]}],
            "eventType": ["OrderPlaced"]
        }
        
        return {
            'inventory': self.subscribe_with_filter('inventory-queue-arn', inventory_filter),
            'email': self.subscribe_with_filter('email-queue-arn', email_filter),
            'analytics': self.subscribe_with_filter('analytics-queue-arn', analytics_filter),
            'fraud': self.subscribe_with_filter('fraud-queue-arn', fraud_filter)
        }
    
    def subscribe_with_filter(self, endpoint: str, filter_policy: Dict):
        """Helper to subscribe with filter policy"""
        subscription = self.sns.subscribe(
            TopicArn=self.topic_arn,
            Protocol='sqs',
            Endpoint=endpoint
        )
        
        self.sns.set_subscription_attributes(
            SubscriptionArn=subscription['SubscriptionArn'],
            AttributeName='FilterPolicy',
            AttributeValue=json.dumps(filter_policy)
        )
        
        return subscription['SubscriptionArn']
```

### SNS FIFO Topics
```python
class SNSFIFOPublisher:
    def __init__(self, fifo_topic_arn: str):
        self.sns = boto3.client('sns')
        self.topic_arn = fifo_topic_arn  # Must end with .fifo
    
    def publish_ordered_event(self, message: Dict, group_id: str, dedup_id: str = None):
        """Publish message to FIFO topic with ordering"""
        if not dedup_id:
            dedup_id = hashlib.sha256(
                json.dumps(message, sort_keys=True).encode()
            ).hexdigest()
        
        response = self.sns.publish(
            TopicArn=self.topic_arn,
            Message=json.dumps(message),
            MessageGroupId=group_id,
            MessageDeduplicationId=dedup_id,
            MessageAttributes={
                'eventType': {
                    'DataType': 'String',
                    'StringValue': message.get('eventType', 'Unknown')
                }
            }
        )
        
        return response['MessageId']
    
    def publish_user_journey_events(self, user_id: str, events: List[Dict]):
        """Publish sequence of user events in order"""
        group_id = f"user_{user_id}"
        
        for sequence, event in enumerate(events):
            event_with_sequence = {
                **event,
                'userId': user_id,
                'sequence': sequence,
                'timestamp': datetime.now().isoformat()
            }
            
            dedup_id = f"{user_id}_{sequence}_{event['eventType']}"
            self.publish_ordered_event(event_with_sequence, group_id, dedup_id)
```

### SNS Error Handling and DLQ
```python
class SNSErrorHandling:
    def __init__(self, topic_arn: str):
        self.sns = boto3.client('sns')
        self.sqs = boto3.client('sqs')
        self.topic_arn = topic_arn
    
    def setup_subscription_with_dlq(self, queue_arn: str, dlq_arn: str):
        """Set up subscription with dead letter queue"""
        
        # Create subscription
        subscription = self.sns.subscribe(
            TopicArn=self.topic_arn,
            Protocol='sqs',
            Endpoint=queue_arn
        )
        
        # Configure delivery policy with retries
        delivery_policy = {
            "healthyRetryPolicy": {
                "minDelayTarget": 20,
                "maxDelayTarget": 20,
                "numRetries": 3,
                "numMaxDelayRetries": 0,
                "numMinDelayRetries": 0,
                "numNoDelayRetries": 0,
                "backoffFunction": "linear"
            },
            "sicklyRetryPolicy": {
                "minDelayTarget": 20,
                "maxDelayTarget": 20,
                "numRetries": 3,
                "numMaxDelayRetries": 0,
                "numMinDelayRetries": 0,
                "numNoDelayRetries": 0,
                "backoffFunction": "linear"
            },
            "throttlePolicy": {
                "maxReceivesPerSecond": 1000
            }
        }
        
        self.sns.set_subscription_attributes(
            SubscriptionArn=subscription['SubscriptionArn'],
            AttributeName='DeliveryPolicy',
            AttributeValue=json.dumps(delivery_policy)
        )
        
        # Configure redrive policy for DLQ
        redrive_policy = {
            "deadLetterTargetArn": dlq_arn
        }
        
        self.sns.set_subscription_attributes(
            SubscriptionArn=subscription['SubscriptionArn'],
            AttributeName='RedrivePolicy',
            AttributeValue=json.dumps(redrive_policy)
        )
        
        return subscription['SubscriptionArn']
```

## Amazon EventBridge Deep Dive

### EventBridge Custom Bus
```python
class EventBridgeCustomBus:
    def __init__(self, bus_name: str):
        self.eventbridge = boto3.client('events')
        self.bus_name = bus_name
    
    def create_custom_bus(self):
        """Create custom event bus"""
        try:
            response = self.eventbridge.create_event_bus(
                Name=self.bus_name,
                Tags=[
                    {'Key': 'Environment', 'Value': 'production'},
                    {'Key': 'Application', 'Value': 'ecommerce'}
                ]
            )
            return response['EventBusArn']
        except self.eventbridge.exceptions.ResourceAlreadyExistsException:
            # Bus already exists
            return f"arn:aws:events:us-east-1:123456789012:event-bus/{self.bus_name}"
    
    def put_custom_event(self, source: str, detail_type: str, detail: Dict):
        """Put event to custom bus"""
        response = self.eventbridge.put_events(
            Entries=[
                {
                    'Source': source,
                    'DetailType': detail_type,
                    'Detail': json.dumps(detail),
                    'EventBusName': self.bus_name,
                    'Time': datetime.now()
                }
            ]
        )
        
        if response['FailedEntryCount'] > 0:
            raise Exception(f"Failed to put events: {response['Entries']}")
        
        return response['Entries'][0]['EventId']

class EventBridgeRuleManager:
    def __init__(self, bus_name: str = 'default'):
        self.eventbridge = boto3.client('events')
        self.bus_name = bus_name
    
    def create_pattern_rule(self, rule_name: str, event_pattern: Dict, targets: List[Dict]):
        """Create rule with event pattern matching"""
        
        # Create the rule
        self.eventbridge.put_rule(
            Name=rule_name,
            EventPattern=json.dumps(event_pattern),
            State='ENABLED',
            EventBusName=self.bus_name,
            Description=f'Rule for {rule_name} event processing'
        )
        
        # Add targets to the rule
        formatted_targets = []
        for i, target in enumerate(targets):
            formatted_target = {
                'Id': str(i + 1),
                'Arn': target['arn']
            }
            
            # Add input transformation if specified
            if 'input_transformer' in target:
                formatted_target['InputTransformer'] = target['input_transformer']
            
            # Add SQS message group ID for FIFO queues
            if 'sqs_parameters' in target:
                formatted_target['SqsParameters'] = target['sqs_parameters']
            
            formatted_targets.append(formatted_target)
        
        self.eventbridge.put_targets(
            Rule=rule_name,
            EventBusName=self.bus_name,
            Targets=formatted_targets
        )
        
        return rule_name
```

### Advanced Event Patterns
```python
class EventBridgePatterns:
    def __init__(self, bus_name: str):
        self.eventbridge = boto3.client('events')
        self.bus_name = bus_name
    
    def setup_ecommerce_patterns(self):
        """Set up comprehensive event patterns for e-commerce"""
        
        patterns = {
            # Order processing patterns
            'high_value_orders': {
                'source': ['ecommerce.orders'],
                'detail-type': ['Order Placed'],
                'detail': {
                    'totalAmount': [{'numeric': ['>=', 1000]}]
                }
            },
            
            # Customer behavior patterns
            'premium_customer_activity': {
                'source': ['ecommerce.customers'],
                'detail-type': ['Customer Action'],
                'detail': {
                    'customerTier': ['premium', 'enterprise'],
                    'actionType': ['purchase', 'upgrade']
                }
            },
            
            # Inventory patterns
            'low_stock_alerts': {
                'source': ['ecommerce.inventory'],
                'detail-type': ['Stock Level Changed'],
                'detail': {
                    'stockLevel': [{'numeric': ['<=', 10]}],
                    'category': ['electronics', 'books']
                }
            },
            
            # Fraud detection patterns
            'suspicious_activity': {
                'source': ['ecommerce.fraud'],
                'detail-type': ['Fraud Alert'],
                'detail': {
                    'riskScore': [{'numeric': ['>=', 0.8]}],
                    'alertType': ['payment', 'account', 'transaction']
                }
            },
            
            # Geographic patterns
            'international_orders': {
                'source': ['ecommerce.orders'],
                'detail-type': ['Order Placed'],
                'detail': {
                    'shippingAddress': {
                        'country': [{'anything-but': 'US'}]
                    }
                }
            }
        }
        
        return patterns
    
    def create_content_based_routing(self):
        """Create sophisticated content-based routing"""
        
        # Route based on order value and customer type
        order_routing_pattern = {
            'source': ['ecommerce.orders'],
            'detail-type': ['Order Placed'],
            'detail': {
                '$or': [
                    {
                        'totalAmount': [{'numeric': ['>=', 5000]}]
                    },
                    {
                        'customerTier': ['enterprise'],
                        'totalAmount': [{'numeric': ['>=', 1000]}]
                    }
                ]
            }
        }
        
        # Route based on time patterns
        business_hours_pattern = {
            'source': ['ecommerce.support'],
            'detail-type': ['Support Request'],
            'detail': {
                'timestamp': [{'exists': True}]
            },
            'time': [
                {'hour': [9, 10, 11, 12, 13, 14, 15, 16, 17]}  # Business hours
            ]
        }
        
        return {
            'high_priority_orders': order_routing_pattern,
            'business_hours_support': business_hours_pattern
        }
```

### EventBridge Input Transformation
```python
class EventBridgeTransformation:
    def __init__(self, bus_name: str):
        self.eventbridge = boto3.client('events')
        self.bus_name = bus_name
    
    def create_transformation_rules(self):
        """Create rules with input transformation"""
        
        # Transform order events for different services
        order_to_inventory_transformer = {
            'InputPathsMap': {
                'orderId': '$.detail.orderId',
                'items': '$.detail.items',
                'timestamp': '$.time'
            },
            'InputTemplate': json.dumps({
                'action': 'reserve_inventory',
                'orderId': '<orderId>',
                'items': '<items>',
                'processedAt': '<timestamp>'
            })
        }
        
        # Transform customer events for analytics
        customer_to_analytics_transformer = {
            'InputPathsMap': {
                'customerId': '$.detail.customerId',
                'eventType': '$.detail-type',
                'eventData': '$.detail',
                'source': '$.source'
            },
            'InputTemplate': json.dumps({
                'analyticsEvent': {
                    'customerId': '<customerId>',
                    'eventType': '<eventType>',
                    'data': '<eventData>',
                    'source': '<source>',
                    'processedAt': datetime.now().isoformat()
                }
            })
        }
        
        # Create rules with transformations
        self.create_pattern_rule(
            'order-to-inventory',
            {
                'source': ['ecommerce.orders'],
                'detail-type': ['Order Placed']
            },
            [{
                'arn': 'arn:aws:sqs:us-east-1:123456789012:inventory-queue',
                'input_transformer': order_to_inventory_transformer
            }]
        )
        
        self.create_pattern_rule(
            'customer-to-analytics',
            {
                'source': ['ecommerce.customers'],
                'detail-type': ['Customer Action', 'Customer Updated']
            },
            [{
                'arn': 'arn:aws:sqs:us-east-1:123456789012:analytics-queue',
                'input_transformer': customer_to_analytics_transformer
            }]
        )
```

### EventBridge Archive and Replay
```python
class EventBridgeArchiveReplay:
    def __init__(self, bus_name: str):
        self.eventbridge = boto3.client('events')
        self.bus_name = bus_name
    
    def create_archive(self, archive_name: str, event_pattern: Dict, retention_days: int = 30):
        """Create event archive for replay capability"""
        
        response = self.eventbridge.create_archive(
            ArchiveName=archive_name,
            EventSourceArn=f"arn:aws:events:us-east-1:123456789012:event-bus/{self.bus_name}",
            Description=f'Archive for {archive_name} events',
            EventPattern=json.dumps(event_pattern),
            RetentionDays=retention_days
        )
        
        return response['ArchiveArn']
    
    def start_replay(self, replay_name: str, archive_name: str, start_time: datetime, end_time: datetime, destination_arn: str):
        """Start event replay from archive"""
        
        response = self.eventbridge.start_replay(
            ReplayName=replay_name,
            Description=f'Replay events from {archive_name}',
            EventSourceArn=f"arn:aws:events:us-east-1:123456789012:archive/{archive_name}",
            EventStartTime=start_time,
            EventEndTime=end_time,
            Destination={
                'Arn': destination_arn,
                'FilterArns': [
                    f"arn:aws:events:us-east-1:123456789012:rule/{self.bus_name}/replay-rule"
                ]
            }
        )
        
        return response['ReplayArn']
    
    def setup_disaster_recovery_archive(self):
        """Set up comprehensive archive for disaster recovery"""
        
        # Archive all critical business events
        critical_events_pattern = {
            'source': ['ecommerce.orders', 'ecommerce.payments', 'ecommerce.inventory'],
            'detail-type': [
                'Order Placed', 'Order Cancelled', 'Payment Processed',
                'Payment Failed', 'Inventory Updated', 'Stock Alert'
            ]
        }
        
        return self.create_archive(
            'critical-business-events',
            critical_events_pattern,
            retention_days=365  # Keep for 1 year
        )
```

## Integration Patterns

### SNS to EventBridge Integration
```python
class SNSEventBridgeIntegration:
    def __init__(self, sns_topic_arn: str, eventbridge_bus_name: str):
        self.sns = boto3.client('sns')
        self.eventbridge = boto3.client('events')
        self.sns_topic_arn = sns_topic_arn
        self.eventbridge_bus_name = eventbridge_bus_name
    
    def setup_sns_to_eventbridge_bridge(self):
        """Set up SNS to EventBridge integration"""
        
        # Create EventBridge rule to receive SNS events
        rule_name = 'sns-to-eventbridge-bridge'
        
        # Pattern to match SNS events
        event_pattern = {
            'source': ['aws.sns'],
            'detail-type': ['SNS Message'],
            'resources': [self.sns_topic_arn]
        }
        
        self.eventbridge.put_rule(
            Name=rule_name,
            EventPattern=json.dumps(event_pattern),
            State='ENABLED',
            EventBusName=self.eventbridge_bus_name
        )
        
        # Add EventBridge as SNS subscription target
        subscription = self.sns.subscribe(
            TopicArn=self.sns_topic_arn,
            Protocol='eventbridge',
            Endpoint=f"arn:aws:events:us-east-1:123456789012:event-bus/{self.eventbridge_bus_name}"
        )
        
        return {
            'rule_name': rule_name,
            'subscription_arn': subscription['SubscriptionArn']
        }
    
    def publish_to_both_services(self, message: Dict):
        """Publish message that flows through both SNS and EventBridge"""
        
        # Publish to SNS (will flow to EventBridge via subscription)
        sns_response = self.sns.publish(
            TopicArn=self.sns_topic_arn,
            Message=json.dumps(message),
            MessageAttributes={
                'eventType': {
                    'DataType': 'String',
                    'StringValue': message.get('eventType', 'Unknown')
                }
            }
        )
        
        # Also publish directly to EventBridge for immediate processing
        eventbridge_response = self.eventbridge.put_events(
            Entries=[
                {
                    'Source': 'ecommerce.integration',
                    'DetailType': message.get('eventType', 'Integration Event'),
                    'Detail': json.dumps(message),
                    'EventBusName': self.eventbridge_bus_name
                }
            ]
        )
        
        return {
            'sns_message_id': sns_response['MessageId'],
            'eventbridge_event_id': eventbridge_response['Entries'][0]['EventId']
        }
```

### Cross-Region Event Replication
```python
class CrossRegionEventReplication:
    def __init__(self, primary_region: str, secondary_regions: List[str]):
        self.primary_region = primary_region
        self.secondary_regions = secondary_regions
        self.eventbridge_clients = {
            region: boto3.client('events', region_name=region)
            for region in [primary_region] + secondary_regions
        }
    
    def setup_cross_region_replication(self, bus_name: str):
        """Set up cross-region event replication"""
        
        replication_rules = {}
        
        for secondary_region in self.secondary_regions:
            rule_name = f'replicate-to-{secondary_region}'
            
            # Create rule in primary region
            primary_client = self.eventbridge_clients[self.primary_region]
            
            primary_client.put_rule(
                Name=rule_name,
                EventPattern=json.dumps({
                    'source': ['ecommerce.orders', 'ecommerce.payments'],
                    'detail-type': ['Order Placed', 'Payment Processed']
                }),
                State='ENABLED',
                EventBusName=bus_name
            )
            
            # Add cross-region target
            target_arn = f"arn:aws:events:{secondary_region}:123456789012:event-bus/{bus_name}"
            
            primary_client.put_targets(
                Rule=rule_name,
                EventBusName=bus_name,
                Targets=[
                    {
                        'Id': '1',
                        'Arn': target_arn,
                        'RoleArn': 'arn:aws:iam::123456789012:role/EventBridgeReplicationRole'
                    }
                ]
            )
            
            replication_rules[secondary_region] = rule_name
        
        return replication_rules
```

## Monitoring and Observability

### SNS/EventBridge Metrics
```python
class MessagingMetrics:
    def __init__(self):
        self.cloudwatch = boto3.client('cloudwatch')
    
    def put_custom_metrics(self, metric_name: str, value: float, unit: str = 'Count', dimensions: Dict = None):
        """Put custom metrics for messaging operations"""
        
        metric_data = {
            'MetricName': metric_name,
            'Value': value,
            'Unit': unit,
            'Timestamp': datetime.now()
        }
        
        if dimensions:
            metric_data['Dimensions'] = [
                {'Name': k, 'Value': v} for k, v in dimensions.items()
            ]
        
        self.cloudwatch.put_metric_data(
            Namespace='ECommerce/Messaging',
            MetricData=[metric_data]
        )
    
    def track_message_processing(self, service_name: str, message_type: str, processing_time: float, success: bool):
        """Track message processing metrics"""
        
        # Processing time metric
        self.put_custom_metrics(
            'MessageProcessingTime',
            processing_time,
            'Milliseconds',
            {
                'ServiceName': service_name,
                'MessageType': message_type
            }
        )
        
        # Success/failure metric
        self.put_custom_metrics(
            'MessageProcessingResult',
            1 if success else 0,
            'Count',
            {
                'ServiceName': service_name,
                'MessageType': message_type,
                'Result': 'Success' if success else 'Failure'
            }
        )
```

## Best Practices

### SNS Best Practices
1. **Message Filtering**: Use filter policies to reduce unnecessary message delivery
2. **Error Handling**: Implement dead letter queues for failed deliveries
3. **Monitoring**: Track delivery success rates and processing times
4. **Security**: Use IAM policies and VPC endpoints for secure access

### EventBridge Best Practices
1. **Event Schema**: Define consistent event schemas across your organization
2. **Rule Optimization**: Use specific event patterns to minimize rule evaluations
3. **Archive Strategy**: Archive important events for replay and compliance
4. **Cross-Account**: Use resource-based policies for cross-account event sharing

### Performance Optimization
1. **Batch Operations**: Use batch APIs when publishing multiple events
2. **Async Processing**: Process events asynchronously to avoid blocking
3. **Circuit Breakers**: Implement circuit breakers for downstream failures
4. **Rate Limiting**: Implement rate limiting to prevent overwhelming downstream systems

## Conclusion

SNS and EventBridge provide powerful capabilities for building scalable, event-driven architectures. Key takeaways:

- **SNS**: Excellent for fan-out patterns and simple pub/sub messaging
- **EventBridge**: Superior for complex event routing and integration patterns
- **Integration**: Combine both services for comprehensive messaging solutions
- **Monitoring**: Implement comprehensive monitoring and alerting
- **Best Practices**: Follow AWS best practices for security, performance, and reliability

These services enable building robust, scalable messaging systems that can handle complex business requirements while maintaining high availability and performance.
