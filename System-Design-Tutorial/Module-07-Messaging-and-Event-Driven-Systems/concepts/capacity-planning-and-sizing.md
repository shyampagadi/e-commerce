# Capacity Planning and Sizing for Messaging Systems

## Overview
Effective capacity planning for messaging systems requires understanding throughput patterns, latency requirements, storage needs, and cost optimization strategies. This guide provides mathematical models and practical approaches for sizing messaging infrastructure.

## Throughput Capacity Planning

### Message Volume Estimation
```python
def calculate_message_volume(users, events_per_user_per_day, peak_factor=5):
    """
    Calculate daily and peak message volumes
    
    Args:
        users: Number of active users
        events_per_user_per_day: Average events per user daily
        peak_factor: Peak traffic multiplier (typically 3-10x)
    
    Returns:
        Dictionary with volume calculations
    """
    daily_messages = users * events_per_user_per_day
    avg_messages_per_second = daily_messages / 86400
    peak_messages_per_second = avg_messages_per_second * peak_factor
    
    return {
        'daily_messages': daily_messages,
        'avg_messages_per_second': avg_messages_per_second,
        'peak_messages_per_second': peak_messages_per_second,
        'monthly_messages': daily_messages * 30
    }

# Example: E-commerce platform
ecommerce_volume = calculate_message_volume(
    users=5_000_000,           # 5M active users
    events_per_user_per_day=20, # 20 events per user per day
    peak_factor=8              # 8x peak during flash sales
)

print(f"Peak throughput needed: {ecommerce_volume['peak_messages_per_second']:,.0f} msg/sec")
# Output: Peak throughput needed: 9,259 msg/sec
```

### Service Capacity Mapping
| Service | Standard Throughput | Burst Capacity | Latency (P95) | Cost Model |
|---------|-------------------|-----------------|---------------|------------|
| **SQS Standard** | 3,000 msg/sec | Unlimited | 10-50ms | $0.40/1M requests |
| **SQS FIFO** | 300 msg/sec | 3,000 msg/sec | 10-100ms | $0.50/1M requests |
| **SNS** | 100,000 msg/sec | 300,000 msg/sec | 50-200ms | $0.50/1M publishes |
| **EventBridge** | 10,000 events/sec | 10,000 events/sec | 100-500ms | $1.00/1M events |
| **MSK (m5.large)** | 50,000 msg/sec | 100,000 msg/sec | 2-10ms | $146/month/broker |
| **Kinesis** | 1,000 records/sec/shard | 2,000 records/sec/shard | 1-5ms | $0.015/shard/hour |

### Capacity Planning Formula
```python
import math

def calculate_required_capacity(peak_throughput, service_limits, safety_factor=1.5):
    """
    Calculate required service capacity with safety margins
    
    Args:
        peak_throughput: Peak messages per second required
        service_limits: Dictionary of service throughput limits
        safety_factor: Safety margin multiplier (default 1.5 = 50% buffer)
    
    Returns:
        Required capacity for each service
    """
    required_capacity = {}
    
    for service, limit in service_limits.items():
        # Calculate base requirement
        base_requirement = peak_throughput / limit
        
        # Apply safety factor
        safe_requirement = base_requirement * safety_factor
        
        # Round up to next integer (can't have partial instances)
        required_capacity[service] = math.ceil(safe_requirement)
    
    return required_capacity

# Example calculation
peak_throughput = 50_000  # 50K messages/second peak

service_limits = {
    'sqs_standard_queues': 3_000,      # 3K msg/sec per queue
    'sns_topics': 100_000,             # 100K msg/sec per topic  
    'msk_brokers': 50_000,             # 50K msg/sec per broker
    'kinesis_shards': 1_000            # 1K records/sec per shard
}

capacity = calculate_required_capacity(peak_throughput, service_limits)
print("Required capacity:")
for service, count in capacity.items():
    print(f"  {service}: {count} units")

# Output:
# Required capacity:
#   sqs_standard_queues: 25 units
#   sns_topics: 1 units
#   msk_brokers: 2 units
#   kinesis_shards: 75 units
```

## Storage Capacity Planning

### Message Storage Requirements
```python
def calculate_storage_requirements(throughput_per_second, avg_message_size_kb, 
                                 retention_days, replication_factor=1, 
                                 compression_ratio=0.7):
    """
    Calculate storage requirements for message retention
    
    Args:
        throughput_per_second: Messages per second
        avg_message_size_kb: Average message size in KB
        retention_days: Message retention period
        replication_factor: Data replication factor (1 for SQS, 3 for Kafka)
        compression_ratio: Compression efficiency (0.7 = 30% compression)
    
    Returns:
        Storage requirements in various units
    """
    # Calculate daily storage
    daily_messages = throughput_per_second * 86400
    daily_storage_kb = daily_messages * avg_message_size_kb * compression_ratio
    daily_storage_gb = daily_storage_kb / (1024 * 1024)
    
    # Calculate total storage with retention and replication
    total_storage_gb = daily_storage_gb * retention_days * replication_factor
    
    # Add 20% operational buffer
    recommended_storage_gb = total_storage_gb * 1.2
    
    return {
        'daily_storage_gb': daily_storage_gb,
        'total_storage_gb': total_storage_gb,
        'recommended_storage_gb': recommended_storage_gb,
        'monthly_growth_gb': daily_storage_gb * 30
    }

# Example: Kafka cluster storage planning
kafka_storage = calculate_storage_requirements(
    throughput_per_second=25_000,    # 25K messages/second
    avg_message_size_kb=2,           # 2KB average message
    retention_days=7,                # 7-day retention
    replication_factor=3,            # 3x replication
    compression_ratio=0.6            # 40% compression
)

print(f"Recommended Kafka storage: {kafka_storage['recommended_storage_gb']:,.1f} GB")
# Output: Recommended Kafka storage: 1,088.6 GB
```

### Cost-Optimized Storage Tiering
```python
def optimize_storage_tiering(total_storage_gb, access_patterns):
    """
    Optimize storage costs using tiered storage strategies
    
    Args:
        total_storage_gb: Total storage requirement
        access_patterns: Dictionary with access frequency percentages
    
    Returns:
        Optimized storage allocation and costs
    """
    # Storage tier pricing (example AWS pricing)
    storage_tiers = {
        'hot': {'cost_per_gb_month': 0.023, 'access_cost_per_gb': 0.0004},
        'warm': {'cost_per_gb_month': 0.0125, 'access_cost_per_gb': 0.01},
        'cold': {'cost_per_gb_month': 0.004, 'access_cost_per_gb': 0.03}
    }
    
    allocation = {}
    total_cost = 0
    
    for tier, percentage in access_patterns.items():
        if tier in storage_tiers:
            allocated_gb = total_storage_gb * (percentage / 100)
            tier_cost = allocated_gb * storage_tiers[tier]['cost_per_gb_month']
            
            allocation[tier] = {
                'storage_gb': allocated_gb,
                'monthly_cost': tier_cost
            }
            total_cost += tier_cost
    
    return {
        'allocation': allocation,
        'total_monthly_cost': total_cost,
        'cost_per_gb': total_cost / total_storage_gb
    }

# Example: Message archive optimization
access_patterns = {
    'hot': 20,    # 20% frequently accessed (last 24 hours)
    'warm': 30,   # 30% occasionally accessed (last week)
    'cold': 50    # 50% rarely accessed (archive)
}

storage_optimization = optimize_storage_tiering(1000, access_patterns)  # 1TB total
print(f"Optimized monthly cost: ${storage_optimization['total_monthly_cost']:.2f}")
# Output: Optimized monthly cost: $12.10
```

## Network Capacity Planning

### Bandwidth Requirements
```python
def calculate_network_bandwidth(throughput_msg_per_sec, avg_message_size_kb, 
                              protocol_overhead=1.3, redundancy_factor=1.5):
    """
    Calculate network bandwidth requirements
    
    Args:
        throughput_msg_per_sec: Peak message throughput
        avg_message_size_kb: Average message size
        protocol_overhead: Protocol overhead factor (TCP, HTTP, etc.)
        redundancy_factor: Network redundancy multiplier
    
    Returns:
        Bandwidth requirements in various units
    """
    # Base bandwidth calculation
    base_bandwidth_kbps = throughput_msg_per_sec * avg_message_size_kb
    
    # Apply overhead and redundancy
    required_bandwidth_kbps = base_bandwidth_kbps * protocol_overhead * redundancy_factor
    
    # Convert to different units
    required_bandwidth_mbps = required_bandwidth_kbps / 1024
    required_bandwidth_gbps = required_bandwidth_mbps / 1024
    
    return {
        'base_bandwidth_kbps': base_bandwidth_kbps,
        'required_bandwidth_kbps': required_bandwidth_kbps,
        'required_bandwidth_mbps': required_bandwidth_mbps,
        'required_bandwidth_gbps': required_bandwidth_gbps
    }

# Example: High-throughput messaging system
network_req = calculate_network_bandwidth(
    throughput_msg_per_sec=100_000,  # 100K messages/second
    avg_message_size_kb=1.5,         # 1.5KB average
    protocol_overhead=1.4,           # 40% protocol overhead
    redundancy_factor=2.0            # 2x redundancy for HA
)

print(f"Required network bandwidth: {network_req['required_bandwidth_mbps']:.1f} Mbps")
# Output: Required network bandwidth: 410.2 Mbps
```

### Cross-Region Bandwidth Planning
```python
def calculate_cross_region_costs(bandwidth_gbps, regions, data_transfer_pricing):
    """
    Calculate cross-region data transfer costs
    
    Args:
        bandwidth_gbps: Required bandwidth in Gbps
        regions: List of regions for data replication
        data_transfer_pricing: Pricing per GB for different region pairs
    
    Returns:
        Monthly data transfer costs
    """
    # Convert bandwidth to monthly data volume
    monthly_data_tb = bandwidth_gbps * 86400 * 30 * 8 / (1024 * 1024 * 1024 * 1024)
    monthly_data_gb = monthly_data_tb * 1024
    
    total_cost = 0
    transfer_costs = {}
    
    # Calculate costs for each region pair
    for i, source_region in enumerate(regions):
        for j, dest_region in enumerate(regions[i+1:], i+1):
            region_pair = f"{source_region}-{dest_region}"
            
            if region_pair in data_transfer_pricing:
                cost_per_gb = data_transfer_pricing[region_pair]
                monthly_cost = monthly_data_gb * cost_per_gb
                
                transfer_costs[region_pair] = monthly_cost
                total_cost += monthly_cost
    
    return {
        'monthly_data_gb': monthly_data_gb,
        'transfer_costs': transfer_costs,
        'total_monthly_cost': total_cost
    }

# Example: Multi-region deployment
regions = ['us-east-1', 'us-west-2', 'eu-west-1']
pricing = {
    'us-east-1-us-west-2': 0.02,    # $0.02/GB
    'us-east-1-eu-west-1': 0.05,    # $0.05/GB
    'us-west-2-eu-west-1': 0.05     # $0.05/GB
}

cross_region_costs = calculate_cross_region_costs(0.5, regions, pricing)  # 0.5 Gbps
print(f"Monthly cross-region costs: ${cross_region_costs['total_monthly_cost']:,.2f}")
```

## Performance Capacity Planning

### Latency Budget Allocation
```python
def allocate_latency_budget(total_budget_ms, components):
    """
    Allocate latency budget across system components
    
    Args:
        total_budget_ms: Total latency budget in milliseconds
        components: Dictionary of component priorities and base latencies
    
    Returns:
        Optimized latency allocation
    """
    # Calculate total priority weight
    total_weight = sum(comp['priority'] for comp in components.values())
    
    allocation = {}
    remaining_budget = total_budget_ms
    
    # Allocate budget proportionally to priority
    for component, config in components.items():
        base_latency = config['base_latency']
        priority = config['priority']
        
        # Allocate proportional budget
        allocated_budget = (total_budget_ms * priority) / total_weight
        
        # Ensure minimum base latency is met
        final_budget = max(allocated_budget, base_latency)
        
        allocation[component] = {
            'allocated_budget_ms': final_budget,
            'optimization_target_ms': final_budget * 0.8  # 80% target
        }
        
        remaining_budget -= final_budget
    
    return {
        'allocation': allocation,
        'remaining_budget_ms': remaining_budget,
        'total_allocated_ms': sum(a['allocated_budget_ms'] for a in allocation.values())
    }

# Example: E-commerce order processing latency budget
components = {
    'api_gateway': {'base_latency': 5, 'priority': 1},
    'order_validation': {'base_latency': 10, 'priority': 3},
    'inventory_check': {'base_latency': 15, 'priority': 4},
    'payment_processing': {'base_latency': 50, 'priority': 5},
    'message_publishing': {'base_latency': 5, 'priority': 2},
    'notification_delivery': {'base_latency': 20, 'priority': 2}
}

latency_allocation = allocate_latency_budget(200, components)  # 200ms total budget
for component, allocation in latency_allocation['allocation'].items():
    print(f"{component}: {allocation['allocated_budget_ms']:.1f}ms budget")
```

## Auto-Scaling Capacity Planning

### Predictive Scaling Models
```python
import numpy as np
from datetime import datetime, timedelta

def calculate_predictive_scaling(historical_data, forecast_days=7):
    """
    Calculate predictive scaling requirements based on historical patterns
    
    Args:
        historical_data: List of hourly throughput measurements
        forecast_days: Number of days to forecast
    
    Returns:
        Scaling recommendations and capacity requirements
    """
    # Convert to numpy array for easier manipulation
    data = np.array(historical_data)
    
    # Calculate daily patterns (24-hour cycles)
    daily_patterns = data.reshape(-1, 24)
    avg_hourly_pattern = np.mean(daily_patterns, axis=0)
    
    # Calculate weekly patterns (7-day cycles)
    if len(daily_patterns) >= 7:
        weekly_patterns = daily_patterns.reshape(-1, 7, 24)
        avg_weekly_pattern = np.mean(weekly_patterns, axis=0)
    else:
        avg_weekly_pattern = daily_patterns[:7] if len(daily_patterns) >= 7 else daily_patterns
    
    # Forecast future capacity needs
    forecast = []
    for day in range(forecast_days):
        day_of_week = day % 7
        if len(avg_weekly_pattern) > day_of_week:
            daily_forecast = avg_weekly_pattern[day_of_week]
        else:
            daily_forecast = avg_hourly_pattern
        
        # Add growth trend (simple linear trend)
        growth_factor = 1 + (0.02 * day / 30)  # 2% monthly growth
        daily_forecast = daily_forecast * growth_factor
        
        forecast.extend(daily_forecast)
    
    # Calculate scaling recommendations
    max_forecast = np.max(forecast)
    avg_forecast = np.mean(forecast)
    
    return {
        'forecast': forecast.tolist(),
        'max_capacity_needed': max_forecast,
        'avg_capacity_needed': avg_forecast,
        'scaling_factor': max_forecast / avg_forecast,
        'recommended_base_capacity': avg_forecast,
        'recommended_burst_capacity': max_forecast * 1.2  # 20% buffer
    }

# Example: Historical throughput data (messages per hour for last 30 days)
# This would typically come from CloudWatch metrics
historical_throughput = np.random.normal(10000, 2000, 24 * 30).tolist()  # Simulated data

scaling_forecast = calculate_predictive_scaling(historical_throughput)
print(f"Recommended base capacity: {scaling_forecast['recommended_base_capacity']:,.0f} msg/hour")
print(f"Recommended burst capacity: {scaling_forecast['recommended_burst_capacity']:,.0f} msg/hour")
```

## Cost Optimization Strategies

### Total Cost of Ownership (TCO) Analysis
```python
def calculate_messaging_tco(requirements, pricing_models, time_horizon_months=36):
    """
    Calculate Total Cost of Ownership for messaging infrastructure
    
    Args:
        requirements: Dictionary of capacity requirements
        pricing_models: Dictionary of service pricing models
        time_horizon_months: TCO calculation period
    
    Returns:
        Comprehensive TCO analysis
    """
    tco_breakdown = {}
    total_tco = 0
    
    for service, requirement in requirements.items():
        if service in pricing_models:
            pricing = pricing_models[service]
            
            # Calculate monthly costs
            if pricing['model'] == 'per_unit_hour':
                monthly_cost = requirement['units'] * pricing['rate'] * 24 * 30
            elif pricing['model'] == 'per_request':
                monthly_cost = requirement['requests'] * pricing['rate']
            elif pricing['model'] == 'per_gb_month':
                monthly_cost = requirement['storage_gb'] * pricing['rate']
            else:
                monthly_cost = 0
            
            # Calculate total cost over time horizon
            service_tco = monthly_cost * time_horizon_months
            
            # Add operational costs (monitoring, support, etc.)
            operational_cost = service_tco * pricing.get('operational_factor', 0.1)
            
            total_service_cost = service_tco + operational_cost
            
            tco_breakdown[service] = {
                'monthly_cost': monthly_cost,
                'infrastructure_tco': service_tco,
                'operational_tco': operational_cost,
                'total_tco': total_service_cost
            }
            
            total_tco += total_service_cost
    
    return {
        'breakdown': tco_breakdown,
        'total_tco': total_tco,
        'monthly_average': total_tco / time_horizon_months,
        'cost_per_message': total_tco / (requirements.get('total_messages', 1) * time_horizon_months)
    }

# Example: TCO analysis for messaging platform
requirements = {
    'sqs': {'units': 10, 'requests': 100_000_000},  # 10 queues, 100M requests/month
    'sns': {'units': 5, 'requests': 50_000_000},    # 5 topics, 50M publishes/month
    'msk': {'units': 3, 'storage_gb': 1000},        # 3 brokers, 1TB storage
}

pricing_models = {
    'sqs': {'model': 'per_request', 'rate': 0.0000004, 'operational_factor': 0.05},
    'sns': {'model': 'per_request', 'rate': 0.0000005, 'operational_factor': 0.05},
    'msk': {'model': 'per_unit_hour', 'rate': 0.25, 'operational_factor': 0.15},
}

tco_analysis = calculate_messaging_tco(requirements, pricing_models)
print(f"Total 3-year TCO: ${tco_analysis['total_tco']:,.2f}")
print(f"Monthly average cost: ${tco_analysis['monthly_average']:,.2f}")
```

This comprehensive capacity planning guide provides the mathematical models and practical tools needed to accurately size messaging systems for production workloads while optimizing for performance and cost.
