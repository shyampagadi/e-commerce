# Amazon MSK and MQ Implementation Guide

## Overview
Amazon MSK (Managed Streaming for Apache Kafka) and Amazon MQ provide enterprise-grade messaging capabilities for high-throughput streaming and traditional message broker patterns.

## Amazon MSK (Managed Streaming for Apache Kafka)

### MSK Cluster Setup
```python
import boto3
import json

class MSKClusterManager:
    def __init__(self, region='us-east-1'):
        self.kafka = boto3.client('kafka', region_name=region)
        self.ec2 = boto3.client('ec2', region_name=region)
    
    def create_msk_cluster(self, cluster_name, vpc_id, subnet_ids):
        """Create MSK cluster with production configuration"""
        
        # Create security group for MSK
        sg_response = self.ec2.create_security_group(
            GroupName=f'{cluster_name}-msk-sg',
            Description='Security group for MSK cluster',
            VpcId=vpc_id
        )
        security_group_id = sg_response['GroupId']
        
        # Configure security group rules
        self.ec2.authorize_security_group_ingress(
            GroupId=security_group_id,
            IpPermissions=[
                {
                    'IpProtocol': 'tcp',
                    'FromPort': 9092,
                    'ToPort': 9092,
                    'IpRanges': [{'CidrIp': '10.0.0.0/8'}]
                },
                {
                    'IpProtocol': 'tcp',
                    'FromPort': 9094,
                    'ToPort': 9094,
                    'IpRanges': [{'CidrIp': '10.0.0.0/8'}]
                }
            ]
        )
        
        # Create MSK cluster
        cluster_config = {
            'ClusterName': cluster_name,
            'KafkaVersion': '2.8.1',
            'NumberOfBrokerNodes': 3,
            'BrokerNodeGroupInfo': {
                'InstanceType': 'kafka.m5.large',
                'ClientSubnets': subnet_ids,
                'SecurityGroups': [security_group_id],
                'StorageInfo': {
                    'EBSStorageInfo': {
                        'VolumeSize': 100
                    }
                }
            },
            'EncryptionInfo': {
                'EncryptionAtRest': {
                    'DataVolumeKMSKeyId': 'alias/aws/msk'
                },
                'EncryptionInTransit': {
                    'ClientBroker': 'TLS',
                    'InCluster': True
                }
            },
            'EnhancedMonitoring': 'PER_TOPIC_PER_BROKER',
            'LoggingInfo': {
                'BrokerLogs': {
                    'CloudWatchLogs': {
                        'Enabled': True,
                        'LogGroup': f'/aws/msk/{cluster_name}'
                    }
                }
            }
        }
        
        response = self.kafka.create_cluster(**cluster_config)
        return response['ClusterArn']
```

### Kafka Producer Implementation
```python
from kafka import KafkaProducer
from kafka.errors import KafkaError
import json
import time

class MSKProducer:
    def __init__(self, bootstrap_servers, security_protocol='SSL'):
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            security_protocol=security_protocol,
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            key_serializer=lambda k: k.encode('utf-8') if k else None,
            
            # Performance optimizations
            batch_size=16384,
            linger_ms=10,
            compression_type='snappy',
            
            # Reliability settings
            acks='all',
            retries=3,
            max_in_flight_requests_per_connection=5,
            enable_idempotence=True
        )
    
    def send_event(self, topic, event_data, partition_key=None):
        """Send event to Kafka topic"""
        try:
            future = self.producer.send(
                topic,
                value=event_data,
                key=partition_key
            )
            
            # Add callback for monitoring
            future.add_callback(self._on_send_success)
            future.add_errback(self._on_send_error)
            
            return future
            
        except Exception as e:
            print(f"Error sending message: {e}")
            raise
    
    def send_batch_events(self, topic, events):
        """Send multiple events efficiently"""
        futures = []
        
        for event in events:
            future = self.send_event(
                topic,
                event['data'],
                event.get('key')
            )
            futures.append(future)
        
        # Flush to ensure all messages are sent
        self.producer.flush()
        
        return futures
    
    def _on_send_success(self, record_metadata):
        """Handle successful send"""
        print(f"Message sent to {record_metadata.topic} partition {record_metadata.partition}")
    
    def _on_send_error(self, exception):
        """Handle send error"""
        print(f"Failed to send message: {exception}")
```

### Kafka Consumer Implementation
```python
from kafka import KafkaConsumer
from kafka.errors import CommitFailedError
import json

class MSKConsumer:
    def __init__(self, topics, bootstrap_servers, group_id, security_protocol='SSL'):
        self.consumer = KafkaConsumer(
            *topics,
            bootstrap_servers=bootstrap_servers,
            group_id=group_id,
            security_protocol=security_protocol,
            
            # Deserialization
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            key_deserializer=lambda k: k.decode('utf-8') if k else None,
            
            # Consumer configuration
            auto_offset_reset='earliest',
            enable_auto_commit=False,  # Manual commit for reliability
            max_poll_records=500,
            session_timeout_ms=30000,
            heartbeat_interval_ms=3000
        )
    
    def consume_messages(self, message_handler):
        """Consume messages with error handling"""
        try:
            for message in self.consumer:
                try:
                    # Process message
                    message_handler(message)
                    
                    # Commit offset after successful processing
                    self.consumer.commit()
                    
                except Exception as e:
                    print(f"Error processing message: {e}")
                    # Decide whether to skip or retry based on error type
                    
        except KeyboardInterrupt:
            print("Consumer interrupted")
        finally:
            self.consumer.close()
    
    def consume_batch(self, batch_handler, batch_size=100):
        """Consume messages in batches for better throughput"""
        batch = []
        
        try:
            for message in self.consumer:
                batch.append(message)
                
                if len(batch) >= batch_size:
                    try:
                        batch_handler(batch)
                        self.consumer.commit()
                        batch = []
                    except Exception as e:
                        print(f"Error processing batch: {e}")
                        batch = []  # Skip failed batch
                        
        except KeyboardInterrupt:
            print("Consumer interrupted")
        finally:
            if batch:  # Process remaining messages
                try:
                    batch_handler(batch)
                    self.consumer.commit()
                except Exception as e:
                    print(f"Error processing final batch: {e}")
            
            self.consumer.close()
```

## Amazon MQ Implementation

### MQ Broker Setup
```python
class AmazonMQManager:
    def __init__(self, region='us-east-1'):
        self.mq = boto3.client('mq', region_name=region)
    
    def create_activemq_broker(self, broker_name, vpc_id, subnet_ids):
        """Create ActiveMQ broker"""
        
        broker_config = {
            'BrokerName': broker_name,
            'EngineType': 'ACTIVEMQ',
            'EngineVersion': '5.16.4',
            'HostInstanceType': 'mq.t3.micro',
            'DeploymentMode': 'ACTIVE_STANDBY_MULTI_AZ',
            
            'Users': [
                {
                    'Username': 'admin',
                    'Password': 'SecurePassword123!',
                    'Groups': ['admin']
                }
            ],
            
            'SubnetIds': subnet_ids,
            'SecurityGroups': [self._create_mq_security_group(vpc_id)],
            
            'PubliclyAccessible': False,
            'AutoMinorVersionUpgrade': True,
            
            'Logs': {
                'General': True,
                'Audit': True
            },
            
            'MaintenanceWindowStartTime': {
                'DayOfWeek': 'SUNDAY',
                'TimeOfDay': '03:00',
                'TimeZone': 'UTC'
            }
        }
        
        response = self.mq.create_broker(**broker_config)
        return response['BrokerId']
    
    def create_rabbitmq_broker(self, broker_name, vpc_id, subnet_ids):
        """Create RabbitMQ broker"""
        
        broker_config = {
            'BrokerName': broker_name,
            'EngineType': 'RABBITMQ',
            'EngineVersion': '3.9.16',
            'HostInstanceType': 'mq.t3.micro',
            'DeploymentMode': 'CLUSTER_MULTI_AZ',
            
            'Users': [
                {
                    'Username': 'admin',
                    'Password': 'SecurePassword123!'
                }
            ],
            
            'SubnetIds': subnet_ids,
            'SecurityGroups': [self._create_mq_security_group(vpc_id)],
            
            'PubliclyAccessible': False,
            'AutoMinorVersionUpgrade': True,
            
            'Logs': {
                'General': True
            }
        }
        
        response = self.mq.create_broker(**broker_config)
        return response['BrokerId']
```

### ActiveMQ Integration
```python
import stomp
import json
import time

class ActiveMQClient:
    def __init__(self, broker_url, username, password):
        self.broker_url = broker_url
        self.username = username
        self.password = password
        self.connection = None
    
    def connect(self):
        """Connect to ActiveMQ broker"""
        self.connection = stomp.Connection([self.broker_url])
        self.connection.connect(self.username, self.password, wait=True)
    
    def send_message(self, destination, message, headers=None):
        """Send message to queue or topic"""
        if not self.connection or not self.connection.is_connected():
            self.connect()
        
        message_body = json.dumps(message) if isinstance(message, dict) else message
        
        self.connection.send(
            destination=destination,
            body=message_body,
            headers=headers or {}
        )
    
    def subscribe_to_queue(self, queue_name, message_handler):
        """Subscribe to queue and process messages"""
        if not self.connection or not self.connection.is_connected():
            self.connect()
        
        class MessageListener(stomp.ConnectionListener):
            def __init__(self, handler):
                self.handler = handler
            
            def on_message(self, frame):
                try:
                    message_body = json.loads(frame.body)
                    self.handler(message_body, frame.headers)
                except Exception as e:
                    print(f"Error processing message: {e}")
        
        listener = MessageListener(message_handler)
        self.connection.set_listener('message_listener', listener)
        self.connection.subscribe(destination=f'/queue/{queue_name}', id=1)
    
    def disconnect(self):
        """Disconnect from broker"""
        if self.connection and self.connection.is_connected():
            self.connection.disconnect()
```

### RabbitMQ Integration
```python
import pika
import json

class RabbitMQClient:
    def __init__(self, broker_url, username, password):
        self.broker_url = broker_url
        self.username = username
        self.password = password
        self.connection = None
        self.channel = None
    
    def connect(self):
        """Connect to RabbitMQ broker"""
        credentials = pika.PlainCredentials(self.username, self.password)
        parameters = pika.ConnectionParameters(
            host=self.broker_url,
            credentials=credentials,
            ssl_options=pika.SSLOptions(context=ssl.create_default_context())
        )
        
        self.connection = pika.BlockingConnection(parameters)
        self.channel = self.connection.channel()
    
    def declare_queue(self, queue_name, durable=True):
        """Declare a queue"""
        if not self.channel:
            self.connect()
        
        self.channel.queue_declare(queue=queue_name, durable=durable)
    
    def publish_message(self, exchange, routing_key, message, properties=None):
        """Publish message to exchange"""
        if not self.channel:
            self.connect()
        
        message_body = json.dumps(message) if isinstance(message, dict) else message
        
        self.channel.basic_publish(
            exchange=exchange,
            routing_key=routing_key,
            body=message_body,
            properties=properties or pika.BasicProperties(delivery_mode=2)  # Persistent
        )
    
    def consume_messages(self, queue_name, callback):
        """Consume messages from queue"""
        if not self.channel:
            self.connect()
        
        def wrapper(ch, method, properties, body):
            try:
                message = json.loads(body.decode('utf-8'))
                callback(message, properties)
                ch.basic_ack(delivery_tag=method.delivery_tag)
            except Exception as e:
                print(f"Error processing message: {e}")
                ch.basic_nack(delivery_tag=method.delivery_tag, requeue=False)
        
        self.channel.basic_consume(queue=queue_name, on_message_callback=wrapper)
        self.channel.start_consuming()
```

## Performance Optimization

### MSK Performance Tuning
```python
class MSKPerformanceTuner:
    def __init__(self, cluster_arn):
        self.kafka = boto3.client('kafka')
        self.cluster_arn = cluster_arn
    
    def optimize_cluster_configuration(self):
        """Apply performance optimizations to MSK cluster"""
        
        # Custom configuration for high throughput
        config_properties = {
            'num.network.threads': '8',
            'num.io.threads': '16',
            'socket.send.buffer.bytes': '102400',
            'socket.receive.buffer.bytes': '102400',
            'socket.request.max.bytes': '104857600',
            'num.replica.fetchers': '4',
            'replica.fetch.max.bytes': '1048576',
            'log.segment.bytes': '1073741824',
            'log.retention.hours': '168',
            'log.retention.check.interval.ms': '300000',
            'compression.type': 'snappy'
        }
        
        # Create custom configuration
        config_response = self.kafka.create_configuration(
            Name='high-throughput-config',
            Description='High throughput configuration for MSK',
            KafkaVersions=['2.8.1'],
            ServerProperties='\n'.join([f'{k}={v}' for k, v in config_properties.items()])
        )
        
        return config_response['Arn']
```

## Monitoring and Observability

### MSK Monitoring
```python
class MSKMonitoring:
    def __init__(self, cluster_name):
        self.cloudwatch = boto3.client('cloudwatch')
        self.cluster_name = cluster_name
    
    def create_msk_dashboard(self):
        """Create CloudWatch dashboard for MSK monitoring"""
        
        dashboard_body = {
            "widgets": [
                {
                    "type": "metric",
                    "properties": {
                        "metrics": [
                            ["AWS/Kafka", "BytesInPerSec", "Cluster Name", self.cluster_name],
                            [".", "BytesOutPerSec", ".", "."],
                            [".", "MessagesInPerSec", ".", "."]
                        ],
                        "period": 300,
                        "stat": "Average",
                        "region": "us-east-1",
                        "title": "MSK Throughput Metrics"
                    }
                },
                {
                    "type": "metric",
                    "properties": {
                        "metrics": [
                            ["AWS/Kafka", "ProduceMessageConversionsPerSec", "Cluster Name", self.cluster_name],
                            [".", "FetchMessageConversionsPerSec", ".", "."]
                        ],
                        "period": 300,
                        "stat": "Average",
                        "region": "us-east-1",
                        "title": "MSK Conversion Metrics"
                    }
                }
            ]
        }
        
        self.cloudwatch.put_dashboard(
            DashboardName=f'MSK-{self.cluster_name}-Monitoring',
            DashboardBody=json.dumps(dashboard_body)
        )
```

## Best Practices

### MSK Best Practices
1. **Partition Strategy**: Design partitioning for even load distribution
2. **Replication Factor**: Use replication factor of 3 for production
3. **Security**: Enable encryption in transit and at rest
4. **Monitoring**: Monitor key metrics like throughput and lag
5. **Scaling**: Plan for horizontal scaling with more brokers

### Amazon MQ Best Practices
1. **High Availability**: Use multi-AZ deployment for production
2. **Security**: Use VPC and security groups for network isolation
3. **Monitoring**: Enable CloudWatch logs and metrics
4. **Backup**: Configure automated backups
5. **Maintenance**: Schedule maintenance windows appropriately

## Conclusion

Amazon MSK and MQ provide enterprise-grade messaging capabilities:

- **MSK**: High-throughput streaming for real-time analytics
- **Amazon MQ**: Traditional message broker patterns for enterprise integration
- **Performance**: Optimize for your specific use case requirements
- **Monitoring**: Comprehensive observability for operational excellence
- **Security**: Enterprise-grade security and compliance features

Choose the right service based on your messaging patterns and requirements.
