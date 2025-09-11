# Exercise 03 Solution: High-Throughput Streaming System

## Solution Overview
This solution implements a high-throughput streaming system using Amazon MSK (Managed Kafka) for real-time IoT data processing with proper partitioning, consumer groups, and stream processing.

## Architecture Solution

### System Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   IoT Devices   │───▶│   API Gateway    │───▶│   Data Ingestion│
│  (100K sensors) │    │ (Rate Limiting)  │    │    Service      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                                                         ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Real-time     │◀───│   Amazon MSK     │◀───│   Kafka         │
│   Dashboard     │    │  (Kafka Cluster) │    │  Producers      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Kinesis       │    │   Stream         │    │   Batch         │
│  Analytics      │    │  Processors      │    │  Processing     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Implementation Solution

### 1. Kafka Producer Implementation
```python
from kafka import KafkaProducer
import json
import time
import uuid
from datetime import datetime
from typing import Dict, Any
import threading
from concurrent.futures import ThreadPoolExecutor

class IoTDataProducer:
    def __init__(self, bootstrap_servers: str, topic_name: str):
        self.topic_name = topic_name
        self.producer = KafkaProducer(
            bootstrap_servers=bootstrap_servers,
            value_serializer=lambda v: json.dumps(v).encode('utf-8'),
            key_serializer=lambda k: k.encode('utf-8') if k else None,
            # Performance optimizations
            batch_size=16384,  # 16KB batch size
            linger_ms=10,      # Wait 10ms for batching
            compression_type='snappy',  # Compression
            acks='1',          # Wait for leader acknowledgment
            retries=3,         # Retry failed sends
            max_in_flight_requests_per_connection=5,
            buffer_memory=33554432,  # 32MB buffer
        )
        
    def send_sensor_data(self, sensor_id: str, data: Dict[str, Any]) -> bool:
        """Send sensor data to Kafka topic"""
        try:
            # Create message with proper partitioning key
            message = {
                'sensor_id': sensor_id,
                'timestamp': datetime.utcnow().isoformat(),
                'data': data,
                'message_id': str(uuid.uuid4())
            }
            
            # Use sensor_id as partition key for even distribution
            partition_key = sensor_id
            
            # Send message asynchronously
            future = self.producer.send(
                topic=self.topic_name,
                key=partition_key,
                value=message
            )
            
            # Optional: Add callback for success/failure handling
            future.add_callback(self._on_send_success)
            future.add_errback(self._on_send_error)
            
            return True
            
        except Exception as e:
            print(f"Error sending sensor data: {str(e)}")
            return False
    
    def send_batch_data(self, sensor_data_batch: list) -> Dict[str, int]:
        """Send multiple sensor readings in batch"""
        successful = 0
        failed = 0
        
        for sensor_data in sensor_data_batch:
            if self.send_sensor_data(sensor_data['sensor_id'], sensor_data['data']):
                successful += 1
            else:
                failed += 1
        
        # Flush to ensure all messages are sent
        self.producer.flush()
        
        return {'successful': successful, 'failed': failed}
    
    def _on_send_success(self, record_metadata):
        """Callback for successful message send"""
        print(f"Message sent to topic {record_metadata.topic} "
              f"partition {record_metadata.partition} "
              f"offset {record_metadata.offset}")
    
    def _on_send_error(self, exception):
        """Callback for failed message send"""
        print(f"Error sending message: {str(exception)}")
    
    def close(self):
        """Close producer and flush remaining messages"""
        self.producer.flush()
        self.producer.close()

# High-throughput producer for load testing
class HighThroughputProducer:
    def __init__(self, bootstrap_servers: str, topic_name: str, num_threads: int = 10):
        self.bootstrap_servers = bootstrap_servers
        self.topic_name = topic_name
        self.num_threads = num_threads
        self.running = False
        
    def start_load_test(self, target_messages_per_second: int, duration_seconds: int):
        """Start high-throughput load test"""
        self.running = True
        messages_per_thread = target_messages_per_second // self.num_threads
        
        with ThreadPoolExecutor(max_workers=self.num_threads) as executor:
            futures = []
            
            for thread_id in range(self.num_threads):
                future = executor.submit(
                    self._producer_thread,
                    thread_id,
                    messages_per_thread,
                    duration_seconds
                )
                futures.append(future)
            
            # Wait for all threads to complete
            total_sent = 0
            for future in futures:
                total_sent += future.result()
            
            print(f"Load test completed. Total messages sent: {total_sent}")
            return total_sent
    
    def _producer_thread(self, thread_id: int, messages_per_second: int, duration: int) -> int:
        """Producer thread for load testing"""
        producer = IoTDataProducer(self.bootstrap_servers, self.topic_name)
        messages_sent = 0
        
        start_time = time.time()
        message_interval = 1.0 / messages_per_second
        
        while self.running and (time.time() - start_time) < duration:
            # Generate synthetic sensor data
            sensor_data = self._generate_sensor_data(thread_id, messages_sent)
            
            if producer.send_sensor_data(sensor_data['sensor_id'], sensor_data['data']):
                messages_sent += 1
            
            # Control message rate
            time.sleep(message_interval)
        
        producer.close()
        return messages_sent
    
    def _generate_sensor_data(self, thread_id: int, message_count: int) -> Dict[str, Any]:
        """Generate synthetic IoT sensor data"""
        import random
        
        sensor_id = f"sensor_{thread_id}_{message_count % 1000}"
        
        return {
            'sensor_id': sensor_id,
            'data': {
                'temperature': round(random.uniform(20.0, 35.0), 2),
                'humidity': round(random.uniform(30.0, 80.0), 2),
                'pressure': round(random.uniform(1000.0, 1020.0), 2),
                'battery_level': round(random.uniform(0.0, 100.0), 1),
                'location': {
                    'lat': round(random.uniform(37.0, 38.0), 6),
                    'lon': round(random.uniform(-122.0, -121.0), 6)
                }
            }
        }
```

### 2. Kafka Consumer Implementation
```python
from kafka import KafkaConsumer, TopicPartition
import json
from typing import List, Dict, Any
import threading
import time

class IoTDataConsumer:
    def __init__(self, bootstrap_servers: str, topic_name: str, group_id: str):
        self.topic_name = topic_name
        self.group_id = group_id
        self.consumer = KafkaConsumer(
            topic_name,
            bootstrap_servers=bootstrap_servers,
            group_id=group_id,
            value_deserializer=lambda m: json.loads(m.decode('utf-8')),
            key_deserializer=lambda k: k.decode('utf-8') if k else None,
            # Performance optimizations
            fetch_min_bytes=1024,      # Minimum bytes to fetch
            fetch_max_wait_ms=500,     # Max wait time for fetch
            max_poll_records=500,      # Max records per poll
            enable_auto_commit=False,  # Manual commit for reliability
            auto_offset_reset='latest'
        )
        self.running = False
        
    def start_consuming(self, message_handler):
        """Start consuming messages"""
        self.running = True
        
        try:
            while self.running:
                # Poll for messages
                message_batch = self.consumer.poll(timeout_ms=1000)
                
                if message_batch:
                    # Process messages by partition
                    for topic_partition, messages in message_batch.items():
                        self._process_message_batch(messages, message_handler)
                    
                    # Commit offsets after successful processing
                    self.consumer.commit()
                
        except Exception as e:
            print(f"Error consuming messages: {str(e)}")
        finally:
            self.consumer.close()
    
    def _process_message_batch(self, messages: List, message_handler):
        """Process batch of messages"""
        try:
            # Process messages in batch for better performance
            processed_messages = []
            
            for message in messages:
                processed_data = {
                    'partition': message.partition,
                    'offset': message.offset,
                    'key': message.key,
                    'value': message.value,
                    'timestamp': message.timestamp
                }
                processed_messages.append(processed_data)
            
            # Call handler with batch of messages
            message_handler(processed_messages)
            
        except Exception as e:
            print(f"Error processing message batch: {str(e)}")
            raise  # Re-raise to prevent offset commit
    
    def stop_consuming(self):
        """Stop consuming messages"""
        self.running = False

# Specialized consumer for real-time analytics
class RealTimeAnalyticsConsumer:
    def __init__(self, bootstrap_servers: str, topic_name: str):
        self.bootstrap_servers = bootstrap_servers
        self.topic_name = topic_name
        self.metrics = {
            'messages_processed': 0,
            'processing_errors': 0,
            'last_processed_time': None
        }
        
    def start_analytics_processing(self):
        """Start real-time analytics processing"""
        consumer = IoTDataConsumer(
            self.bootstrap_servers,
            self.topic_name,
            'analytics-consumer-group'
        )
        
        consumer.start_consuming(self._analytics_message_handler)
    
    def _analytics_message_handler(self, messages: List[Dict[str, Any]]):
        """Handle messages for real-time analytics"""
        try:
            # Aggregate sensor data
            sensor_aggregates = {}
            
            for message in messages:
                sensor_data = message['value']
                sensor_id = sensor_data['sensor_id']
                data = sensor_data['data']
                
                if sensor_id not in sensor_aggregates:
                    sensor_aggregates[sensor_id] = {
                        'count': 0,
                        'temperature_sum': 0,
                        'humidity_sum': 0,
                        'pressure_sum': 0,
                        'latest_timestamp': sensor_data['timestamp']
                    }
                
                agg = sensor_aggregates[sensor_id]
                agg['count'] += 1
                agg['temperature_sum'] += data['temperature']
                agg['humidity_sum'] += data['humidity']
                agg['pressure_sum'] += data['pressure']
                
                if sensor_data['timestamp'] > agg['latest_timestamp']:
                    agg['latest_timestamp'] = sensor_data['timestamp']
            
            # Calculate averages and store results
            for sensor_id, agg in sensor_aggregates.items():
                analytics_result = {
                    'sensor_id': sensor_id,
                    'avg_temperature': agg['temperature_sum'] / agg['count'],
                    'avg_humidity': agg['humidity_sum'] / agg['count'],
                    'avg_pressure': agg['pressure_sum'] / agg['count'],
                    'sample_count': agg['count'],
                    'latest_timestamp': agg['latest_timestamp'],
                    'processed_at': datetime.utcnow().isoformat()
                }
                
                # Store in time-series database or send to dashboard
                self._store_analytics_result(analytics_result)
            
            self.metrics['messages_processed'] += len(messages)
            self.metrics['last_processed_time'] = datetime.utcnow().isoformat()
            
        except Exception as e:
            print(f"Error in analytics processing: {str(e)}")
            self.metrics['processing_errors'] += 1
    
    def _store_analytics_result(self, result: Dict[str, Any]):
        """Store analytics result (placeholder implementation)"""
        # In real implementation, this would store to:
        # - InfluxDB for time-series data
        # - DynamoDB for real-time queries
        # - CloudWatch for monitoring
        print(f"Analytics result for {result['sensor_id']}: "
              f"Temp={result['avg_temperature']:.2f}°C, "
              f"Humidity={result['avg_humidity']:.1f}%")
```

### 3. Stream Processing with Kafka Streams
```python
# Note: This would typically be implemented in Java/Scala
# Here's a Python equivalent using kafka-python

class StreamProcessor:
    def __init__(self, bootstrap_servers: str, input_topic: str, output_topic: str):
        self.bootstrap_servers = bootstrap_servers
        self.input_topic = input_topic
        self.output_topic = output_topic
        self.producer = IoTDataProducer(bootstrap_servers, output_topic)
        
    def start_stream_processing(self):
        """Start stream processing pipeline"""
        consumer = IoTDataConsumer(
            self.bootstrap_servers,
            self.input_topic,
            'stream-processor-group'
        )
        
        consumer.start_consuming(self._stream_processor_handler)
    
    def _stream_processor_handler(self, messages: List[Dict[str, Any]]):
        """Process stream of messages"""
        try:
            # Window-based aggregation (5-minute windows)
            window_size = 300  # 5 minutes in seconds
            current_time = int(time.time())
            window_start = (current_time // window_size) * window_size
            
            # Group messages by sensor and time window
            windowed_data = {}
            
            for message in messages:
                sensor_data = message['value']
                sensor_id = sensor_data['sensor_id']
                timestamp = int(datetime.fromisoformat(
                    sensor_data['timestamp'].replace('Z', '+00:00')
                ).timestamp())
                
                message_window = (timestamp // window_size) * window_size
                key = f"{sensor_id}_{message_window}"
                
                if key not in windowed_data:
                    windowed_data[key] = {
                        'sensor_id': sensor_id,
                        'window_start': message_window,
                        'window_end': message_window + window_size,
                        'readings': []
                    }
                
                windowed_data[key]['readings'].append(sensor_data['data'])
            
            # Process each window
            for key, window_data in windowed_data.items():
                processed_result = self._process_window(window_data)
                
                # Send processed result to output topic
                self.producer.send_sensor_data(
                    sensor_id=processed_result['sensor_id'],
                    data=processed_result
                )
            
        except Exception as e:
            print(f"Error in stream processing: {str(e)}")
    
    def _process_window(self, window_data: Dict[str, Any]) -> Dict[str, Any]:
        """Process data within a time window"""
        readings = window_data['readings']
        
        if not readings:
            return {}
        
        # Calculate statistics
        temperatures = [r['temperature'] for r in readings]
        humidities = [r['humidity'] for r in readings]
        pressures = [r['pressure'] for r in readings]
        
        result = {
            'sensor_id': window_data['sensor_id'],
            'window_start': window_data['window_start'],
            'window_end': window_data['window_end'],
            'sample_count': len(readings),
            'temperature': {
                'min': min(temperatures),
                'max': max(temperatures),
                'avg': sum(temperatures) / len(temperatures),
                'std': self._calculate_std(temperatures)
            },
            'humidity': {
                'min': min(humidities),
                'max': max(humidities),
                'avg': sum(humidities) / len(humidities)
            },
            'pressure': {
                'min': min(pressures),
                'max': max(pressures),
                'avg': sum(pressures) / len(pressures)
            },
            'anomalies': self._detect_anomalies(readings)
        }
        
        return result
    
    def _calculate_std(self, values: List[float]) -> float:
        """Calculate standard deviation"""
        if len(values) < 2:
            return 0.0
        
        mean = sum(values) / len(values)
        variance = sum((x - mean) ** 2 for x in values) / (len(values) - 1)
        return variance ** 0.5
    
    def _detect_anomalies(self, readings: List[Dict[str, Any]]) -> List[str]:
        """Simple anomaly detection"""
        anomalies = []
        
        for reading in readings:
            # Simple threshold-based anomaly detection
            if reading['temperature'] > 40 or reading['temperature'] < 0:
                anomalies.append('temperature_out_of_range')
            
            if reading['humidity'] > 95 or reading['humidity'] < 5:
                anomalies.append('humidity_out_of_range')
            
            if reading['battery_level'] < 10:
                anomalies.append('low_battery')
        
        return list(set(anomalies))  # Remove duplicates
```

This solution provides a comprehensive high-throughput streaming system capable of processing millions of IoT messages with proper partitioning, consumer groups, and real-time analytics.
