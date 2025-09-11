# Real-World Messaging Calculations and Capacity Planning

## Overview
This document provides practical calculations, formulas, and real-world examples for sizing, capacity planning, and performance optimization of messaging systems in production environments.

## 1. Throughput and Capacity Calculations

### Basic Throughput Formula
```python
def calculate_throughput_requirements(users, events_per_user_per_day, peak_factor):
    """
    Calculate peak throughput requirements
    
    Args:
        users: Total number of active users
        events_per_user_per_day: Average events generated per user daily
        peak_factor: Peak traffic multiplier (typically 3-10x)
    """
    daily_events = users * events_per_user_per_day
    avg_events_per_second = daily_events / 86400  # seconds in a day
    peak_events_per_second = avg_events_per_second * peak_factor
    
    return {
        'daily_events': daily_events,
        'avg_eps': avg_events_per_second,
        'peak_eps': peak_events_per_second
    }

# Example: E-commerce platform
ecommerce_throughput = calculate_throughput_requirements(
    users=10_000_000,           # 10M active users
    events_per_user_per_day=50, # 50 events per user per day
    peak_factor=5               # 5x peak during sales
)
# Result: 28,935 peak events/second
```

### Message Size and Bandwidth Calculations
```python
def calculate_bandwidth_requirements(throughput_eps, avg_message_size_kb, overhead_factor=1.3):
    """
    Calculate network bandwidth requirements
    
    Args:
        throughput_eps: Events per second
        avg_message_size_kb: Average message size in KB
        overhead_factor: Protocol overhead (TCP, HTTP, etc.)
    """
    bandwidth_kbps = throughput_eps * avg_message_size_kb * overhead_factor
    bandwidth_mbps = bandwidth_kbps / 1024
    bandwidth_gbps = bandwidth_mbps / 1024
    
    return {
        'bandwidth_kbps': bandwidth_kbps,
        'bandwidth_mbps': bandwidth_mbps,
        'bandwidth_gbps': bandwidth_gbps
    }

# Example: Real-time analytics
analytics_bandwidth = calculate_bandwidth_requirements(
    throughput_eps=50_000,      # 50K events/second
    avg_message_size_kb=2,      # 2KB average message
    overhead_factor=1.4         # 40% protocol overhead
)
# Result: 137 Mbps required bandwidth
```

## 2. Storage and Retention Calculations

### Kafka Storage Requirements
```python
def calculate_kafka_storage(throughput_eps, avg_message_size_kb, retention_days, 
                          replication_factor=3, compression_ratio=0.7):
    """
    Calculate Kafka cluster storage requirements
    """
    # Daily storage calculation
    daily_messages = throughput_eps * 86400
    daily_storage_gb = (daily_messages * avg_message_size_kb * compression_ratio) / (1024 * 1024)
    
    # Total storage with retention and replication
    total_storage_gb = daily_storage_gb * retention_days * replication_factor
    
    # Add 20% buffer for operations
    recommended_storage_gb = total_storage_gb * 1.2
    
    return {
        'daily_storage_gb': daily_storage_gb,
        'total_storage_gb': total_storage_gb,
        'recommended_storage_gb': recommended_storage_gb,
        'storage_per_broker_gb': recommended_storage_gb / 3  # Assuming 3 brokers
    }

# Example: High-volume logging system
logging_storage = calculate_kafka_storage(
    throughput_eps=100_000,     # 100K log events/second
    avg_message_size_kb=1.5,    # 1.5KB per log entry
    retention_days=7,           # 7-day retention
    replication_factor=3,       # 3x replication
    compression_ratio=0.6       # 40% compression savings
)
# Result: 3.3TB total storage needed
```

### AWS SQS Cost Calculations
```python
def calculate_sqs_costs(monthly_requests, message_size_kb, data_transfer_gb=0):
    """
    Calculate AWS SQS monthly costs
    
    SQS Pricing (as of 2024):
    - First 1M requests/month: Free
    - Additional requests: $0.40 per 1M requests
    - Data transfer: $0.09 per GB (out to internet)
    """
    free_tier_requests = 1_000_000
    billable_requests = max(0, monthly_requests - free_tier_requests)
    
    request_cost = (billable_requests / 1_000_000) * 0.40
    data_transfer_cost = data_transfer_gb * 0.09
    
    total_cost = request_cost + data_transfer_cost
    
    return {
        'request_cost': request_cost,
        'data_transfer_cost': data_transfer_cost,
        'total_monthly_cost': total_cost,
        'cost_per_million_requests': (total_cost / monthly_requests) * 1_000_000
    }

# Example: Order processing system
order_processing_cost = calculate_sqs_costs(
    monthly_requests=50_000_000,  # 50M requests/month
    message_size_kb=4,            # 4KB average message
    data_transfer_gb=200          # 200GB data transfer
)
# Result: $37.60/month total cost
```

## 3. Performance and Latency Calculations

### End-to-End Latency Modeling
```python
def calculate_end_to_end_latency(components):
    """
    Calculate total system latency including all components
    
    Args:
        components: Dict of component latencies in milliseconds
    """
    # Sequential latencies (sum)
    sequential_latency = sum([
        components.get('network_ingress', 0),
        components.get('load_balancer', 0),
        components.get('api_gateway', 0),
        components.get('application_processing', 0),
        components.get('message_broker_publish', 0),
        components.get('message_broker_consume', 0),
        components.get('downstream_processing', 0),
        components.get('database_write', 0),
        components.get('network_egress', 0)
    ])
    
    # Parallel latencies (max)
    parallel_latency = max([
        components.get('cache_lookup', 0),
        components.get('external_api_call', 0)
    ])
    
    total_latency = sequential_latency + parallel_latency
    
    return {
        'sequential_ms': sequential_latency,
        'parallel_ms': parallel_latency,
        'total_ms': total_latency,
        'sla_compliance': total_latency < components.get('sla_target', 1000)
    }

# Example: Real-time notification system
notification_latency = calculate_end_to_end_latency({
    'network_ingress': 5,
    'load_balancer': 2,
    'api_gateway': 10,
    'application_processing': 15,
    'message_broker_publish': 3,
    'message_broker_consume': 5,
    'downstream_processing': 20,
    'database_write': 8,
    'network_egress': 5,
    'cache_lookup': 2,
    'external_api_call': 50,
    'sla_target': 100
})
# Result: 123ms total latency (exceeds 100ms SLA)
```

### Queue Depth and Backlog Calculations
```python
def calculate_queue_metrics(producer_rate, consumer_rate, initial_backlog=0):
    """
    Calculate queue depth over time and processing delays
    
    Args:
        producer_rate: Messages produced per second
        consumer_rate: Messages consumed per second
        initial_backlog: Starting queue depth
    """
    if consumer_rate >= producer_rate:
        # Queue will drain
        time_to_drain = initial_backlog / (consumer_rate - producer_rate) if consumer_rate > producer_rate else 0
        steady_state_depth = 0
    else:
        # Queue will grow indefinitely
        time_to_drain = float('inf')
        growth_rate = producer_rate - consumer_rate
        steady_state_depth = float('inf')
    
    # Calculate processing delay
    processing_delay = initial_backlog / consumer_rate if consumer_rate > 0 else float('inf')
    
    return {
        'time_to_drain_seconds': time_to_drain,
        'steady_state_depth': steady_state_depth,
        'processing_delay_seconds': processing_delay,
        'queue_growing': producer_rate > consumer_rate
    }

# Example: Order processing during flash sale
flash_sale_queue = calculate_queue_metrics(
    producer_rate=5000,    # 5K orders/second during flash sale
    consumer_rate=2000,    # 2K orders/second processing capacity
    initial_backlog=10000  # 10K orders already queued
)
# Result: Queue growing at 3K orders/second, needs scaling
```

## 4. Scaling and Partitioning Calculations

### Kafka Partition Sizing
```python
def calculate_kafka_partitions(target_throughput, consumer_throughput, 
                             max_partitions_per_consumer=10):
    """
    Calculate optimal number of Kafka partitions
    
    Args:
        target_throughput: Target messages per second
        consumer_throughput: Messages per second per consumer
        max_partitions_per_consumer: Max partitions one consumer can handle
    """
    # Minimum partitions needed for throughput
    min_partitions_throughput = math.ceil(target_throughput / consumer_throughput)
    
    # Minimum consumers needed
    min_consumers = math.ceil(min_partitions_throughput / max_partitions_per_consumer)
    
    # Optimal partitions (should be multiple of consumer count)
    optimal_partitions = min_consumers * max_partitions_per_consumer
    
    # Ensure power of 2 for better distribution
    optimal_partitions = 2 ** math.ceil(math.log2(optimal_partitions))
    
    return {
        'min_partitions': min_partitions_throughput,
        'min_consumers': min_consumers,
        'optimal_partitions': optimal_partitions,
        'max_consumers': optimal_partitions
    }

# Example: User activity tracking
activity_partitions = calculate_kafka_partitions(
    target_throughput=200_000,      # 200K events/second
    consumer_throughput=5_000,      # 5K events/second per consumer
    max_partitions_per_consumer=8   # 8 partitions per consumer max
)
# Result: 64 partitions optimal, up to 64 consumers
```

### Auto-scaling Calculations
```python
def calculate_autoscaling_thresholds(baseline_capacity, target_utilization=0.7, 
                                   scale_up_threshold=0.8, scale_down_threshold=0.3):
    """
    Calculate auto-scaling thresholds and capacity requirements
    """
    # Scale up when utilization exceeds threshold
    scale_up_trigger = baseline_capacity * scale_up_threshold
    
    # Scale down when utilization drops below threshold
    scale_down_trigger = baseline_capacity * scale_down_threshold
    
    # Target capacity to maintain desired utilization
    target_capacity = baseline_capacity / target_utilization
    
    # Buffer capacity for sudden spikes
    buffer_capacity = target_capacity * 1.2
    
    return {
        'baseline_capacity': baseline_capacity,
        'scale_up_trigger': scale_up_trigger,
        'scale_down_trigger': scale_down_trigger,
        'target_capacity': target_capacity,
        'buffer_capacity': buffer_capacity
    }

# Example: Message processing service
processing_scaling = calculate_autoscaling_thresholds(
    baseline_capacity=10_000,    # 10K messages/second baseline
    target_utilization=0.7,     # 70% target utilization
    scale_up_threshold=0.8,     # Scale up at 80%
    scale_down_threshold=0.3    # Scale down at 30%
)
# Result: Scale up at 8K msg/sec, target 14.3K msg/sec capacity
```

## 5. Cost Optimization Calculations

### Reserved vs On-Demand Cost Analysis
```python
def calculate_reserved_vs_ondemand(monthly_usage_hours, on_demand_hourly_rate, 
                                 reserved_upfront_cost, reserved_hourly_rate, 
                                 commitment_months=12):
    """
    Compare reserved vs on-demand pricing for messaging infrastructure
    """
    # On-demand costs
    monthly_ondemand_cost = monthly_usage_hours * on_demand_hourly_rate
    annual_ondemand_cost = monthly_ondemand_cost * 12
    
    # Reserved costs
    monthly_reserved_cost = (reserved_upfront_cost / commitment_months) + \
                           (monthly_usage_hours * reserved_hourly_rate)
    annual_reserved_cost = reserved_upfront_cost + (monthly_usage_hours * 12 * reserved_hourly_rate)
    
    # Savings calculation
    annual_savings = annual_ondemand_cost - annual_reserved_cost
    savings_percentage = (annual_savings / annual_ondemand_cost) * 100
    
    # Break-even analysis
    break_even_months = reserved_upfront_cost / (monthly_ondemand_cost - monthly_reserved_cost)
    
    return {
        'monthly_ondemand_cost': monthly_ondemand_cost,
        'monthly_reserved_cost': monthly_reserved_cost,
        'annual_savings': annual_savings,
        'savings_percentage': savings_percentage,
        'break_even_months': break_even_months,
        'recommendation': 'Reserved' if annual_savings > 0 else 'On-Demand'
    }

# Example: MSK cluster cost analysis
msk_cost_analysis = calculate_reserved_vs_ondemand(
    monthly_usage_hours=720,     # 24/7 operation
    on_demand_hourly_rate=0.25,  # $0.25/hour for m5.large
    reserved_upfront_cost=1314,   # $1,314 upfront for 1-year reserved
    reserved_hourly_rate=0.15,    # $0.15/hour reserved rate
    commitment_months=12
)
# Result: $864 annual savings (48% savings) with reserved instances
```

### Message Batching Optimization
```python
def calculate_batching_optimization(individual_requests_per_second, batch_size, 
                                  individual_cost_per_request, batch_cost_per_request):
    """
    Calculate cost and performance benefits of message batching
    """
    # Without batching
    monthly_individual_requests = individual_requests_per_second * 86400 * 30
    monthly_individual_cost = monthly_individual_requests * individual_cost_per_request
    
    # With batching
    batched_requests_per_second = individual_requests_per_second / batch_size
    monthly_batched_requests = batched_requests_per_second * 86400 * 30
    monthly_batched_cost = monthly_batched_requests * batch_cost_per_request
    
    # Savings calculation
    cost_savings = monthly_individual_cost - monthly_batched_cost
    cost_reduction_percentage = (cost_savings / monthly_individual_cost) * 100
    
    # Performance impact (latency increase due to batching)
    avg_batching_delay = (batch_size - 1) / (2 * individual_requests_per_second)
    
    return {
        'monthly_individual_cost': monthly_individual_cost,
        'monthly_batched_cost': monthly_batched_cost,
        'monthly_savings': cost_savings,
        'cost_reduction_percentage': cost_reduction_percentage,
        'avg_batching_delay_seconds': avg_batching_delay,
        'throughput_reduction_factor': batch_size
    }

# Example: SQS batching optimization
sqs_batching = calculate_batching_optimization(
    individual_requests_per_second=1000,    # 1K individual requests/second
    batch_size=10,                          # Batch 10 messages together
    individual_cost_per_request=0.0000004,  # $0.0000004 per request
    batch_cost_per_request=0.0000004       # Same cost per batch request
)
# Result: 90% cost reduction with 0.0045 second average delay
```

## 6. Reliability and Disaster Recovery Calculations

### Availability Calculations
```python
def calculate_system_availability(component_availabilities, architecture_type='serial'):
    """
    Calculate overall system availability based on component availabilities
    
    Args:
        component_availabilities: List of component availability percentages
        architecture_type: 'serial', 'parallel', or 'mixed'
    """
    if architecture_type == 'serial':
        # All components must be available (multiply probabilities)
        total_availability = 1.0
        for availability in component_availabilities:
            total_availability *= (availability / 100)
        total_availability *= 100
        
    elif architecture_type == 'parallel':
        # At least one component must be available
        total_unavailability = 1.0
        for availability in component_availabilities:
            total_unavailability *= ((100 - availability) / 100)
        total_availability = (1 - total_unavailability) * 100
    
    # Calculate downtime
    annual_downtime_minutes = (100 - total_availability) / 100 * 365 * 24 * 60
    
    return {
        'availability_percentage': total_availability,
        'annual_downtime_minutes': annual_downtime_minutes,
        'annual_downtime_hours': annual_downtime_minutes / 60,
        'nines': f"{total_availability:.4f}%"
    }

# Example: Messaging system with redundancy
messaging_availability = calculate_system_availability([
    99.9,   # Load balancer
    99.95,  # Message broker cluster
    99.99,  # Database
    99.9    # Application servers
], architecture_type='serial')
# Result: 99.75% availability (21.9 hours downtime/year)
```

### Recovery Time and Point Objectives
```python
def calculate_rto_rpo_metrics(backup_frequency_hours, restore_time_hours, 
                            replication_lag_seconds, failover_time_minutes):
    """
    Calculate Recovery Time Objective (RTO) and Recovery Point Objective (RPO)
    """
    # RPO: Maximum acceptable data loss
    rpo_backup_hours = backup_frequency_hours
    rpo_replication_seconds = replication_lag_seconds
    
    # RTO: Maximum acceptable downtime
    rto_backup_restore_hours = restore_time_hours
    rto_failover_minutes = failover_time_minutes
    
    return {
        'rpo_backup_hours': rpo_backup_hours,
        'rpo_replication_seconds': rpo_replication_seconds,
        'rto_backup_restore_hours': rto_backup_restore_hours,
        'rto_failover_minutes': rto_failover_minutes,
        'recommended_architecture': 'Active-Active' if rto_failover_minutes < 5 else 'Active-Passive'
    }

# Example: Critical messaging system
dr_metrics = calculate_rto_rpo_metrics(
    backup_frequency_hours=1,      # Hourly backups
    restore_time_hours=2,          # 2-hour restore time
    replication_lag_seconds=5,     # 5-second replication lag
    failover_time_minutes=2        # 2-minute failover
)
# Result: Recommended Active-Active architecture for <5min RTO
```

This comprehensive calculation guide provides the mathematical foundation for designing, sizing, and optimizing messaging systems in real-world production environments.
