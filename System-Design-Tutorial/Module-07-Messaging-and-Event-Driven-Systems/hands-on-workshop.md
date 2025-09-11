# Module 07: Hands-On Workshop - Building Event-Driven E-Commerce Platform

## Workshop Overview
This intensive hands-on workshop guides you through building a complete event-driven e-commerce platform using AWS messaging services. You'll implement real-world patterns including event sourcing, CQRS, saga patterns, and high-throughput streaming.

**Duration**: 8 hours (full day workshop)
**Format**: Guided implementation with instructor support
**Prerequisites**: Completion of Module 07 concepts and basic exercises
**Outcome**: Production-ready event-driven system

## Workshop Architecture

### System Overview
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Frontend  │    │   API Gateway   │    │  Load Balancer  │
│                 │───▶│   (Rate Limit)  │───▶│   (Multi-AZ)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    EventBridge Custom Bus                        │
│                   (ecommerce-platform)                          │
└─────────────────────────────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Order Service   │    │Inventory Service│    │Payment Service  │
│ (Event Sourced) │    │ (Event Sourced) │    │ (Event Sourced) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   DynamoDB      │    │   SNS Topics    │    │   MSK Cluster   │
│  Event Store    │    │(Notifications)  │    │  (Analytics)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Workshop Sessions

### Session 1: Infrastructure Setup (90 minutes)

#### 1.1 AWS Environment Preparation
```bash
# Set up workshop environment
export WORKSHOP_REGION=us-east-1
export WORKSHOP_PREFIX=messaging-workshop

# Create VPC for workshop
aws ec2 create-vpc --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=messaging-workshop-vpc}]'

# Create subnets
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24 --availability-zone us-east-1a
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24 --availability-zone us-east-1b
```

#### 1.2 Core Messaging Infrastructure
```python
# Workshop infrastructure setup
class WorkshopInfrastructure:
    def __init__(self, prefix="messaging-workshop"):
        self.prefix = prefix
        self.eventbridge = boto3.client('events')
        self.sqs = boto3.client('sqs')
        self.sns = boto3.client('sns')
        self.dynamodb = boto3.client('dynamodb')
    
    def setup_complete_infrastructure(self):
        """Set up all required AWS resources"""
        resources = {}
        
        # 1. EventBridge Custom Bus
        resources['event_bus'] = self._create_event_bus()
        
        # 2. SQS Queues
        resources['queues'] = self._create_sqs_queues()
        
        # 3. SNS Topics
        resources['topics'] = self._create_sns_topics()
        
        # 4. DynamoDB Tables
        resources['tables'] = self._create_dynamodb_tables()
        
        # 5. EventBridge Rules
        resources['rules'] = self._create_eventbridge_rules()
        
        return resources
    
    def _create_event_bus(self):
        """Create custom EventBridge bus"""
        bus_name = f"{self.prefix}-events"
        response = self.eventbridge.create_event_bus(Name=bus_name)
        return response['EventBusArn']
    
    def _create_sqs_queues(self):
        """Create all required SQS queues"""
        queues = {
            'order-processing': {'FifoQueue': 'true'},
            'inventory-updates': {},
            'payment-processing': {'FifoQueue': 'true'},
            'notifications': {},
            'analytics': {},
            'dead-letter': {}
        }
        
        created_queues = {}
        for queue_name, attributes in queues.items():
            full_name = f"{self.prefix}-{queue_name}"
            if attributes.get('FifoQueue'):
                full_name += '.fifo'
            
            response = self.sqs.create_queue(
                QueueName=full_name,
                Attributes=attributes
            )
            created_queues[queue_name] = response['QueueUrl']
        
        return created_queues
```

### Session 2: Event Sourcing Implementation (120 minutes)

#### 2.1 Event Store and Aggregates
```python
# Complete event sourcing implementation
class WorkshopEventStore:
    def __init__(self, table_name):
        self.dynamodb = boto3.resource('dynamodb')
        self.table = self.dynamodb.Table(table_name)
    
    def save_events(self, aggregate_id, expected_version, events):
        """Save events with optimistic concurrency"""
        # Implementation with error handling and metrics
        pass
    
    def load_events(self, aggregate_id, from_version=0):
        """Load events for aggregate reconstruction"""
        # Implementation with pagination and performance optimization
        pass

class OrderAggregate:
    def __init__(self, order_id):
        # Complete aggregate implementation
        # Business logic for order lifecycle
        # Event generation and application
        pass
```

#### 2.2 Command Handlers and Read Models
```python
# CQRS implementation
class OrderCommandHandler:
    def __init__(self, event_store, event_publisher):
        # Command processing logic
        # Event persistence and publishing
        pass

class OrderProjection:
    def __init__(self, read_model_table):
        # Read model maintenance
        # Event handling for projections
        pass
```

### Session 3: Message Routing and Integration (90 minutes)

#### 3.1 EventBridge Rules and Routing
```python
# Advanced routing implementation
class MessageRouter:
    def __init__(self, event_bus_name):
        # Complex routing logic
        # Content-based routing
        # Message transformation
        pass
```

#### 3.2 SNS Fan-out and Filtering
```python
# SNS implementation with filtering
class NotificationFanout:
    def __init__(self, topic_arn):
        # Fan-out patterns
        # Message filtering
        # Subscription management
        pass
```

### Session 4: High-Throughput Streaming (90 minutes)

#### 4.1 MSK Cluster Setup
```python
# MSK implementation for analytics
class AnalyticsStreaming:
    def __init__(self, cluster_name):
        # High-throughput streaming
        # Real-time analytics
        # Performance optimization
        pass
```

#### 4.2 Stream Processing
```python
# Real-time stream processing
class StreamProcessor:
    def __init__(self, bootstrap_servers):
        # Kafka consumer implementation
        # Real-time analytics
        # Anomaly detection
        pass
```

### Session 5: Monitoring and Operations (60 minutes)

#### 5.1 Comprehensive Monitoring
```python
# Monitoring and observability
class WorkshopMonitoring:
    def __init__(self):
        # CloudWatch integration
        # Custom metrics
        # Alerting setup
        pass
```

#### 5.2 Error Handling and Recovery
```python
# Production-ready error handling
class ErrorRecoverySystem:
    def __init__(self):
        # Circuit breakers
        # Retry mechanisms
        # Dead letter queue processing
        pass
```

### Session 6: Testing and Validation (60 minutes)

#### 6.1 Load Testing
```python
# Load testing framework
class WorkshopLoadTester:
    def __init__(self):
        # Performance testing
        # Scalability validation
        # Bottleneck identification
        pass
```

#### 6.2 End-to-End Testing
```python
# Integration testing
def test_complete_ecommerce_flow():
    """Test complete e-commerce workflow"""
    # Order creation to delivery
    # Payment processing
    # Inventory management
    # Customer notifications
    pass
```

## Workshop Deliverables

### 1. Working System
- Complete event-driven e-commerce platform
- All AWS services configured and integrated
- End-to-end order processing workflow
- Real-time analytics and monitoring

### 2. Source Code
- Production-ready Python implementation
- Infrastructure as Code (CloudFormation)
- Comprehensive test suite
- Documentation and README files

### 3. Architecture Documentation
- System architecture diagrams
- Event flow documentation
- API specifications
- Operational runbooks

### 4. Performance Results
- Load testing results and analysis
- Performance optimization recommendations
- Scalability assessment
- Cost analysis and optimization

## Workshop Schedule

### Morning Session (4 hours)
- **9:00-9:30**: Workshop introduction and environment setup
- **9:30-11:00**: Session 1 - Infrastructure Setup
- **11:00-11:15**: Break
- **11:15-1:15**: Session 2 - Event Sourcing Implementation
- **1:15-2:15**: Lunch Break

### Afternoon Session (4 hours)
- **2:15-3:45**: Session 3 - Message Routing and Integration
- **3:45-4:00**: Break
- **4:00-5:30**: Session 4 - High-Throughput Streaming
- **5:30-6:30**: Session 5 - Monitoring and Operations
- **6:30-7:30**: Session 6 - Testing and Validation
- **7:30-8:00**: Wrap-up and Q&A

## Success Metrics

### Technical Achievements
- ✅ Complete event-driven system deployed and functional
- ✅ All AWS services properly configured and integrated
- ✅ Performance targets met (1000+ orders/minute processing)
- ✅ Comprehensive monitoring and alerting implemented
- ✅ Error handling and recovery mechanisms working

### Learning Outcomes
- ✅ Hands-on experience with all major AWS messaging services
- ✅ Understanding of event sourcing and CQRS patterns
- ✅ Ability to design and implement scalable messaging architectures
- ✅ Knowledge of performance optimization techniques
- ✅ Experience with monitoring and operational best practices

### Business Value
- ✅ Scalable architecture supporting business growth
- ✅ Complete audit trail for compliance requirements
- ✅ Real-time analytics enabling business insights
- ✅ Resilient system with graceful failure handling
- ✅ Cost-optimized implementation with usage-based pricing

## Post-Workshop Activities

### Immediate Next Steps (Week 1)
1. **Code Review**: Review and refine workshop implementation
2. **Documentation**: Complete technical documentation
3. **Testing**: Expand test coverage and scenarios
4. **Optimization**: Implement performance improvements identified

### Short-term Goals (Weeks 2-4)
1. **Production Readiness**: Harden system for production deployment
2. **Security Review**: Implement comprehensive security controls
3. **Monitoring Enhancement**: Add business-specific metrics and dashboards
4. **Team Training**: Share knowledge with broader development team

### Long-term Objectives (Months 2-6)
1. **Feature Extensions**: Add advanced features and capabilities
2. **Scale Testing**: Validate system under production-level loads
3. **Cost Optimization**: Implement cost reduction strategies
4. **Knowledge Sharing**: Present learnings to organization

## Workshop Resources

### Code Repository
- Complete workshop code available in GitHub repository
- Branch for each workshop session
- Final implementation with all features
- Additional examples and extensions

### Documentation
- Step-by-step implementation guides
- Troubleshooting and FAQ sections
- Best practices and anti-patterns
- Additional reading and resources

### Support
- Instructor support during workshop
- Slack channel for questions and collaboration
- Office hours for follow-up questions
- Peer learning and knowledge sharing

This hands-on workshop provides intensive, practical experience building event-driven systems with AWS messaging services, bridging the gap between theoretical knowledge and real-world implementation skills.
