# Exercise 03: High-Throughput Event Streaming with MSK

## Overview
Build a high-throughput event streaming platform using Amazon MSK (Managed Streaming for Apache Kafka) to handle real-time data processing at scale.

## Learning Objectives
- Set up and configure Amazon MSK clusters
- Implement high-performance Kafka producers and consumers
- Design partitioning strategies for optimal throughput
- Build real-time stream processing applications
- Monitor and optimize streaming performance

## Prerequisites
- Completion of Exercises 01 and 02
- AWS CLI configured with MSK permissions
- Python 3.8+ with kafka-python library
- Understanding of stream processing concepts

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Data Sources  │    │   Kafka Topics  │    │   Consumers     │
│                 │    │                 │    │                 │
│ • User Events   │───▶│ • user-events   │───▶│ • Analytics     │
│ • Transactions │    │ • transactions  │    │ • Fraud Detect  │
│ • IoT Sensors   │    │ • sensor-data   │    │ • Notifications │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   MSK Cluster   │
                    │                 │
                    │ • 3 Brokers     │
                    │ • Multi-AZ      │
                    │ • Encrypted     │
                    └─────────────────┘
```

## Exercise Tasks

### Task 1: MSK Cluster Setup

#### 1.1 Create MSK Cluster
```python
import boto3
import json
import time

class MSKClusterSetup:
    def __init__(self, region='us-east-1'):
        self.kafka = boto3.client('kafka', region_name=region)
        self.ec2 = boto3.client('ec2', region_name=region)
        self.logs = boto3.client('logs', region_name=region)
    
    def create_cluster(self, cluster_name, vpc_id, subnet_ids):
        """Create production-ready MSK cluster"""
        
        # Create CloudWatch log group
        try:
            self.logs.create_log_group(
                logGroupName=f'/aws/msk/{cluster_name}'
            )
        except self.logs.exceptions.ResourceAlreadyExistsException:
            pass
        
        # Create security group
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
                    'UserIdGroupPairs': [{'GroupId': security_group_id}]
                },
                {
                    'IpProtocol': 'tcp',
                    'FromPort': 9094,
                    'ToPort': 9094,
                    'UserIdGroupPairs': [{'GroupId': security_group_id}]
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
        cluster_arn = response['ClusterArn']
        
        print(f"Creating MSK cluster: {cluster_arn}")
        
        # Wait for cluster to be active
        self.wait_for_cluster_active(cluster_arn)
        
        return cluster_arn
    
    def wait_for_cluster_active(self, cluster_arn):
        """Wait for cluster to become active"""
        while True:
            response = self.kafka.describe_cluster(ClusterArn=cluster_arn)
            state = response['ClusterInfo']['State']
            
            print(f"Cluster state: {state}")
            
            if state == 'ACTIVE':
                break
            elif state in ['FAILED', 'DELETING']:
                raise Exception(f"Cluster creation failed with state: {state}")
            
            time.sleep(30)
    
    def get_bootstrap_servers(self, cluster_arn):
        """Get bootstrap servers for the cluster"""
        response = self.kafka.get_bootstrap_brokers(ClusterArn=cluster_arn)
        return response['BootstrapBrokerStringTls']

# Create the cluster
msk_setup = MSKClusterSetup()
cluster_arn = msk_setup.create_cluster(
    'streaming-exercise-cluster',
    'vpc-12345678',  # Replace with your VPC ID
    ['subnet-12345678', 'subnet-87654321', 'subnet-11111111']  # Replace with your subnet IDs
)
bootstrap_servers = msk_setup.get_bootstrap_servers(cluster_arn)
print(f"Bootstrap servers: {bootstrap_servers}")
```

### Task 2: High-Performance Producer

#### 2.1 Optimized Kafka Producer
```python
from kafka import KafkaProducer
from kafka.errors import KafkaError
import json
import time
import threading
from datetime import datetime
import uuid

class HighThroughputProducer:
    def __init__(self, bootstrap_servers):
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            security_protocol='SSL',
            
            # Serialization
            value_serializer=lambda v: json.dumps(v, default=str).encode('utf-8'),
            key_serializer=lambda k: k.encode('utf-8') if k else None,
            
            # Performance optimizations
            batch_size=32768,  # 32KB batches
            linger_ms=10,      # Wait 10ms for batching
            compression_type='snappy',
            buffer_memory=67108864,  # 64MB buffer
            
            # Reliability settings
            acks='all',
            retries=3,
            max_in_flight_requests_per_connection=5,
            enable_idempotence=True,
            
            # Timeout settings
            request_timeout_ms=30000,
            delivery_timeout_ms=120000
        )
        
        self.metrics = {
            'messages_sent': 0,
            'messages_failed': 0,
            'bytes_sent': 0
        }
        self.lock = threading.Lock()
    
    def send_user_event(self, user_id, event_type, event_data):
        """Send user event with optimal partitioning"""
        event = {
            'eventId': str(uuid.uuid4()),
            'userId': user_id,
            'eventType': event_type,
            'eventData': event_data,
            'timestamp': datetime.now().isoformat(),
            'source': 'web-app'
        }
        
        # Use user_id as partition key for even distribution
        partition_key = str(user_id)
        
        future = self.producer.send(
            'user-events',
            value=event,
            key=partition_key
        )
        
        future.add_callback(self._on_send_success)
        future.add_errback(self._on_send_error)
        
        return future
    
    def send_transaction_event(self, transaction_id, user_id, amount, merchant):
        """Send transaction event for fraud detection"""
        transaction = {
            'transactionId': transaction_id,
            'userId': user_id,
            'amount': amount,
            'merchant': merchant,
            'timestamp': datetime.now().isoformat(),
            'location': self._get_user_location(user_id)
        }
        
        # Partition by user_id for fraud detection patterns
        partition_key = str(user_id)
        
        future = self.producer.send(
            'transactions',
            value=transaction,
            key=partition_key
        )
        
        future.add_callback(self._on_send_success)
        future.add_errback(self._on_send_error)
        
        return future
    
    def send_sensor_data(self, sensor_id, sensor_type, readings):
        """Send IoT sensor data"""
        sensor_event = {
            'sensorId': sensor_id,
            'sensorType': sensor_type,
            'readings': readings,
            'timestamp': datetime.now().isoformat(),
            'location': self._get_sensor_location(sensor_id)
        }
        
        # Partition by sensor_id for temporal ordering
        partition_key = str(sensor_id)
        
        future = self.producer.send(
            'sensor-data',
            value=sensor_event,
            key=partition_key
        )
        
        future.add_callback(self._on_send_success)
        future.add_errback(self._on_send_error)
        
        return future
    
    def send_batch_events(self, events):
        """Send multiple events efficiently"""
        futures = []
        
        for event in events:
            if event['type'] == 'user_event':
                future = self.send_user_event(
                    event['user_id'],
                    event['event_type'],
                    event['data']
                )
            elif event['type'] == 'transaction':
                future = self.send_transaction_event(
                    event['transaction_id'],
                    event['user_id'],
                    event['amount'],
                    event['merchant']
                )
            elif event['type'] == 'sensor_data':
                future = self.send_sensor_data(
                    event['sensor_id'],
                    event['sensor_type'],
                    event['readings']
                )
            
            futures.append(future)
        
        # Flush to ensure all messages are sent
        self.producer.flush()
        
        return futures
    
    def _on_send_success(self, record_metadata):
        """Handle successful send"""
        with self.lock:
            self.metrics['messages_sent'] += 1
            # Estimate bytes sent (approximate)
            self.metrics['bytes_sent'] += 1000  # Average message size
    
    def _on_send_error(self, exception):
        """Handle send error"""
        with self.lock:
            self.metrics['messages_failed'] += 1
        print(f"Failed to send message: {exception}")
    
    def get_metrics(self):
        """Get producer metrics"""
        with self.lock:
            return self.metrics.copy()
    
    def _get_user_location(self, user_id):
        """Mock function to get user location"""
        locations = ['US-East', 'US-West', 'EU-West', 'AP-Southeast']
        return locations[hash(str(user_id)) % len(locations)]
    
    def _get_sensor_location(self, sensor_id):
        """Mock function to get sensor location"""
        return {
            'latitude': 37.7749 + (hash(str(sensor_id)) % 100) / 1000,
            'longitude': -122.4194 + (hash(str(sensor_id)) % 100) / 1000
        }
    
    def close(self):
        """Close producer"""
        self.producer.close()

# Test the producer
producer = HighThroughputProducer(bootstrap_servers)

# Send test events
for i in range(1000):
    producer.send_user_event(
        user_id=f"user_{i % 100}",
        event_type="page_view",
        event_data={"page": f"/product/{i}", "duration": i % 60}
    )

print(f"Producer metrics: {producer.get_metrics()}")
```

### Task 3: Stream Processing Consumer

#### 3.1 Real-Time Analytics Consumer
```python
from kafka import KafkaConsumer
import json
import threading
from collections import defaultdict, deque
from datetime import datetime, timedelta
import time

class RealTimeAnalyticsConsumer:
    def __init__(self, bootstrap_servers, group_id):
        self.consumer = KafkaConsumer(
            'user-events',
            'transactions',
            'sensor-data',
            bootstrap_servers=bootstrap_servers,
            group_id=group_id,
            security_protocol='SSL',
            
            # Deserialization
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            key_deserializer=lambda k: k.decode('utf-8') if k else None,
            
            # Consumer configuration
            auto_offset_reset='latest',
            enable_auto_commit=False,
            max_poll_records=1000,
            session_timeout_ms=30000,
            heartbeat_interval_ms=3000
        )
        
        # Analytics state
        self.user_sessions = defaultdict(lambda: {'events': deque(), 'last_activity': None})
        self.transaction_stats = defaultdict(lambda: {'count': 0, 'total_amount': 0})
        self.sensor_readings = defaultdict(lambda: deque(maxlen=100))
        
        # Metrics
        self.metrics = {
            'messages_processed': 0,
            'processing_errors': 0,
            'active_users': 0,
            'transactions_per_minute': 0
        }
        
        self.lock = threading.Lock()
        
        # Start metrics reporting thread
        self.metrics_thread = threading.Thread(target=self._report_metrics)
        self.metrics_thread.daemon = True
        self.metrics_thread.start()
    
    def start_processing(self):
        """Start processing messages"""
        try:
            for message in self.consumer:
                try:
                    self._process_message(message)
                    
                    # Commit offset after successful processing
                    self.consumer.commit()
                    
                    with self.lock:
                        self.metrics['messages_processed'] += 1
                        
                except Exception as e:
                    print(f"Error processing message: {e}")
                    with self.lock:
                        self.metrics['processing_errors'] += 1
                    
        except KeyboardInterrupt:
            print("Consumer interrupted")
        finally:
            self.consumer.close()
    
    def _process_message(self, message):
        """Process individual message based on topic"""
        topic = message.topic
        value = message.value
        
        if topic == 'user-events':
            self._process_user_event(value)
        elif topic == 'transactions':
            self._process_transaction(value)
        elif topic == 'sensor-data':
            self._process_sensor_data(value)
    
    def _process_user_event(self, event):
        """Process user event for session analytics"""
        user_id = event['userId']
        event_time = datetime.fromisoformat(event['timestamp'])
        
        with self.lock:
            session = self.user_sessions[user_id]
            session['events'].append(event)
            session['last_activity'] = event_time
            
            # Keep only recent events (last hour)
            cutoff_time = event_time - timedelta(hours=1)
            while session['events'] and datetime.fromisoformat(session['events'][0]['timestamp']) < cutoff_time:
                session['events'].popleft()
        
        # Detect user behavior patterns
        self._analyze_user_behavior(user_id, event)
    
    def _process_transaction(self, transaction):
        """Process transaction for fraud detection"""
        user_id = transaction['userId']
        amount = transaction['amount']
        
        with self.lock:
            stats = self.transaction_stats[user_id]
            stats['count'] += 1
            stats['total_amount'] += amount
        
        # Check for fraud patterns
        self._check_fraud_patterns(transaction)
    
    def _process_sensor_data(self, sensor_data):
        """Process sensor data for anomaly detection"""
        sensor_id = sensor_data['sensorId']
        readings = sensor_data['readings']
        
        with self.lock:
            self.sensor_readings[sensor_id].extend(readings)
        
        # Check for anomalies
        self._detect_sensor_anomalies(sensor_id, readings)
    
    def _analyze_user_behavior(self, user_id, event):
        """Analyze user behavior patterns"""
        session = self.user_sessions[user_id]
        
        # Calculate session duration
        if len(session['events']) > 1:
            first_event = datetime.fromisoformat(session['events'][0]['timestamp'])
            last_event = datetime.fromisoformat(session['events'][-1]['timestamp'])
            session_duration = (last_event - first_event).total_seconds()
            
            # Detect long sessions (potential bot activity)
            if session_duration > 3600:  # 1 hour
                print(f"Long session detected for user {user_id}: {session_duration}s")
        
        # Detect rapid clicking (potential bot)
        if len(session['events']) >= 10:
            recent_events = list(session['events'])[-10:]
            time_span = (
                datetime.fromisoformat(recent_events[-1]['timestamp']) -
                datetime.fromisoformat(recent_events[0]['timestamp'])
            ).total_seconds()
            
            if time_span < 10:  # 10 events in 10 seconds
                print(f"Rapid activity detected for user {user_id}")
    
    def _check_fraud_patterns(self, transaction):
        """Check for fraudulent transaction patterns"""
        user_id = transaction['userId']
        amount = transaction['amount']
        
        # Check for high-value transactions
        if amount > 10000:
            print(f"High-value transaction alert: User {user_id}, Amount ${amount}")
        
        # Check for rapid transactions
        stats = self.transaction_stats[user_id]
        if stats['count'] > 5:  # More than 5 transactions
            avg_amount = stats['total_amount'] / stats['count']
            if amount > avg_amount * 3:  # 3x average
                print(f"Unusual transaction amount: User {user_id}, Amount ${amount}")
    
    def _detect_sensor_anomalies(self, sensor_id, readings):
        """Detect sensor reading anomalies"""
        if len(self.sensor_readings[sensor_id]) < 10:
            return
        
        # Calculate moving average
        recent_readings = list(self.sensor_readings[sensor_id])[-10:]
        avg_reading = sum(recent_readings) / len(recent_readings)
        
        # Check for anomalies in current readings
        for reading in readings:
            if abs(reading - avg_reading) > avg_reading * 0.5:  # 50% deviation
                print(f"Sensor anomaly detected: Sensor {sensor_id}, Reading {reading}")
    
    def _report_metrics(self):
        """Report metrics periodically"""
        while True:
            time.sleep(60)  # Report every minute
            
            with self.lock:
                # Calculate active users (activity in last 5 minutes)
                cutoff_time = datetime.now() - timedelta(minutes=5)
                active_users = sum(
                    1 for session in self.user_sessions.values()
                    if session['last_activity'] and session['last_activity'] > cutoff_time
                )
                
                self.metrics['active_users'] = active_users
                
                print(f"Analytics Metrics: {self.metrics}")
    
    def get_user_analytics(self, user_id):
        """Get analytics for specific user"""
        with self.lock:
            session = self.user_sessions[user_id]
            stats = self.transaction_stats[user_id]
            
            return {
                'session_events': len(session['events']),
                'last_activity': session['last_activity'].isoformat() if session['last_activity'] else None,
                'transaction_count': stats['count'],
                'total_spent': stats['total_amount']
            }

# Start the analytics consumer
analytics_consumer = RealTimeAnalyticsConsumer(bootstrap_servers, 'analytics-group')
analytics_consumer.start_processing()
```

### Task 4: Performance Testing and Optimization

#### 4.1 Load Testing Framework
```python
import threading
import time
from concurrent.futures import ThreadPoolExecutor
import random

class KafkaLoadTester:
    def __init__(self, producer, num_threads=10):
        self.producer = producer
        self.num_threads = num_threads
        self.running = False
        self.metrics = {
            'messages_sent': 0,
            'errors': 0,
            'start_time': None,
            'end_time': None
        }
    
    def run_load_test(self, duration_seconds=300, messages_per_second=1000):
        """Run load test for specified duration"""
        print(f"Starting load test: {messages_per_second} msg/sec for {duration_seconds}s")
        
        self.running = True
        self.metrics['start_time'] = time.time()
        
        # Calculate messages per thread
        messages_per_thread_per_second = messages_per_second // self.num_threads
        
        with ThreadPoolExecutor(max_workers=self.num_threads) as executor:
            futures = []
            
            for thread_id in range(self.num_threads):
                future = executor.submit(
                    self._producer_thread,
                    thread_id,
                    messages_per_thread_per_second,
                    duration_seconds
                )
                futures.append(future)
            
            # Wait for all threads to complete
            for future in futures:
                future.result()
        
        self.running = False
        self.metrics['end_time'] = time.time()
        
        return self._calculate_results()
    
    def _producer_thread(self, thread_id, messages_per_second, duration_seconds):
        """Producer thread for load testing"""
        end_time = time.time() + duration_seconds
        message_interval = 1.0 / messages_per_second
        
        while time.time() < end_time and self.running:
            try:
                # Generate test message
                user_id = random.randint(1, 10000)
                event_type = random.choice(['page_view', 'click', 'purchase', 'search'])
                
                self.producer.send_user_event(
                    user_id=f"user_{user_id}",
                    event_type=event_type,
                    event_data={
                        'thread_id': thread_id,
                        'timestamp': time.time(),
                        'random_data': random.randint(1, 1000)
                    }
                )
                
                self.metrics['messages_sent'] += 1
                
                # Control rate
                time.sleep(message_interval)
                
            except Exception as e:
                self.metrics['errors'] += 1
                print(f"Error in producer thread {thread_id}: {e}")
    
    def _calculate_results(self):
        """Calculate load test results"""
        duration = self.metrics['end_time'] - self.metrics['start_time']
        messages_per_second = self.metrics['messages_sent'] / duration
        error_rate = self.metrics['errors'] / (self.metrics['messages_sent'] + self.metrics['errors'])
        
        results = {
            'duration_seconds': duration,
            'total_messages': self.metrics['messages_sent'],
            'total_errors': self.metrics['errors'],
            'messages_per_second': messages_per_second,
            'error_rate': error_rate
        }
        
        print(f"Load Test Results: {results}")
        return results

# Run load test
load_tester = KafkaLoadTester(producer, num_threads=20)
results = load_tester.run_load_test(duration_seconds=300, messages_per_second=5000)
```

## Testing and Validation

### Performance Validation
```python
def validate_performance():
    """Validate streaming performance meets requirements"""
    
    # Test 1: Throughput test
    print("=== Throughput Test ===")
    load_tester = KafkaLoadTester(producer, num_threads=10)
    results = load_tester.run_load_test(duration_seconds=60, messages_per_second=1000)
    
    assert results['messages_per_second'] >= 900, "Throughput below requirement"
    assert results['error_rate'] < 0.01, "Error rate too high"
    
    # Test 2: Latency test
    print("=== Latency Test ===")
    start_time = time.time()
    future = producer.send_user_event("test_user", "latency_test", {"test": True})
    future.get(timeout=10)  # Wait for send to complete
    latency = (time.time() - start_time) * 1000  # Convert to ms
    
    assert latency < 100, f"Latency too high: {latency}ms"
    
    # Test 3: Consumer lag test
    print("=== Consumer Lag Test ===")
    # This would require additional monitoring setup
    
    print("All performance tests passed!")

# Run validation
validate_performance()
```

## Deliverables

### 1. MSK Cluster Configuration
- Production-ready MSK cluster setup
- Security group and encryption configuration
- Monitoring and logging setup

### 2. High-Performance Applications
- Optimized Kafka producer with batching
- Real-time analytics consumer
- Stream processing logic

### 3. Performance Results
- Load testing results and analysis
- Throughput and latency measurements
- Optimization recommendations

### 4. Monitoring Dashboard
- CloudWatch dashboard for MSK metrics
- Application performance metrics
- Alerting configuration

## Success Criteria

✅ **MSK Cluster**: Successfully deployed and configured
✅ **Throughput**: Achieve 1000+ messages/second
✅ **Latency**: Sub-100ms message delivery
✅ **Reliability**: <1% error rate under load
✅ **Monitoring**: Comprehensive metrics and alerting
✅ **Documentation**: Complete setup and operational guides

## Extension Challenges

### Challenge 1: Multi-Region Replication
Set up cross-region replication using MirrorMaker 2.0

### Challenge 2: Schema Registry
Implement Confluent Schema Registry for message schema management

### Challenge 3: Exactly-Once Processing
Implement exactly-once semantics for critical data processing

This exercise provides hands-on experience with high-throughput event streaming using Amazon MSK, demonstrating real-world patterns for building scalable streaming platforms.
