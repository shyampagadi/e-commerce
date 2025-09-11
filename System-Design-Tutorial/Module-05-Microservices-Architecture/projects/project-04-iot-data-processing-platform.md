# Project 4: IoT Data Processing Platform

## Project Overview

Build a comprehensive IoT data processing platform using microservices architecture on AWS. The platform should handle real-time data ingestion, processing, analytics, and visualization for millions of IoT devices with global distribution and edge computing capabilities.

## Requirements

### Functional Requirements

#### Device Management
- Device registration and provisioning
- Device authentication and security
- Device status monitoring
- Firmware update management
- Device grouping and organization

#### Data Ingestion
- Real-time data streaming from devices
- Batch data processing
- Data validation and cleansing
- Data routing and filtering
- Message queuing and buffering

#### Data Processing
- Real-time stream processing
- Complex event processing
- Data transformation and enrichment
- Machine learning model inference
- Anomaly detection and alerting

#### Analytics and Visualization
- Real-time dashboards
- Historical data analysis
- Custom reporting
- Data export capabilities
- Predictive analytics

#### Edge Computing
- Edge data processing
- Local decision making
- Edge-to-cloud synchronization
- Offline capability
- Bandwidth optimization

### Non-Functional Requirements

#### Performance
- Process 1 million messages per second
- Sub-second data processing latency
- 99.99% uptime
- Global edge distribution

#### Scalability
- Auto-scaling based on load
- Multi-region deployment
- Edge computing capabilities
- Horizontal scaling

#### Security
- Device authentication and authorization
- Data encryption in transit and at rest
- Secure device communication
- Compliance with IoT security standards

## Architecture

### Service Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Edge Devices  │    │   Edge Gateway  │    │   Cloud Gateway │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Microservices                        │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Device Svc   │ │Data Ingestion│ │Stream Proc  │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Analytics Svc│ │ML Service   │ │Alert Service│      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Data Layer                           │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │   RDS       │ │  DynamoDB   │ │   Timestream│     │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
```

### Technology Stack

#### Backend Services
- **Language**: Go for high-performance services
- **Framework**: Gin for HTTP services
- **Stream Processing**: Apache Kafka with Kafka Streams
- **Database**: PostgreSQL (RDS) for metadata, Timestream for time-series data
- **Cache**: Redis (ElastiCache) for real-time data

#### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Amazon EKS
- **Message Queue**: Amazon MSK (Managed Kafka)
- **Stream Processing**: Amazon Kinesis
- **Edge Computing**: AWS IoT Greengrass

#### Data Processing
- **Real-time**: Amazon Kinesis Data Analytics
- **Batch**: AWS Glue and EMR
- **ML**: Amazon SageMaker
- **Visualization**: Amazon QuickSight

## Implementation

### Phase 1: Foundation Setup

#### 1.1 Infrastructure Setup
```bash
# Create EKS cluster
eksctl create cluster \
  --name iot-cluster \
  --region us-west-2 \
  --nodegroup-name workers \
  --node-type t3.large \
  --nodes 5

# Create MSK cluster
aws kafka create-cluster \
  --cluster-name iot-kafka \
  --broker-node-group-info BrokerNodeGroupInfo='{InstanceType=kafka.t3.small,ClientSubnets=subnet-xxx,subnet-yyy,SecurityGroups=sg-xxx}'

# Create Timestream database
aws timestream-write create-database \
  --database-name iot-timeseries
```

#### 1.2 Service Structure
```
iot-platform/
├── services/
│   ├── device-service/
│   ├── data-ingestion-service/
│   ├── stream-processing-service/
│   ├── analytics-service/
│   ├── ml-service/
│   └── alert-service/
├── infrastructure/
│   ├── terraform/
│   └── kubernetes/
├── edge/
│   ├── greengrass-components/
│   └── edge-processing/
├── shared/
│   ├── models/
│   ├── utils/
│   └── middleware/
└── docs/
    ├── api/
    └── architecture/
```

### Phase 2: Core Services Implementation

#### 2.1 Device Service
```go
// device-service/main.go
package main

import (
    "github.com/gin-gonic/gin"
    "github.com/aws/aws-sdk-go/service/dynamodb"
    "github.com/aws/aws-sdk-go/aws"
    "github.com/google/uuid"
    "time"
)

type Device struct {
    ID          string    `json:"id"`
    Name        string    `json:"name"`
    Type        string    `json:"type"`
    Status      string    `json:"status"`
    TenantID    string    `json:"tenant_id"`
    CreatedAt   time.Time `json:"created_at"`
    UpdatedAt   time.Time `json:"updated_at"`
    LastSeen    time.Time `json:"last_seen"`
    Metadata    map[string]interface{} `json:"metadata"`
}

type DeviceService struct {
    dynamoDB *dynamodb.DynamoDB
}

func NewDeviceService(dynamoDB *dynamodb.DynamoDB) *DeviceService {
    return &DeviceService{dynamoDB: dynamoDB}
}

func (ds *DeviceService) RegisterDevice(c *gin.Context) {
    var device Device
    if err := c.ShouldBindJSON(&device); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }
    
    // Generate device ID
    device.ID = uuid.New().String()
    device.Status = "active"
    device.CreatedAt = time.Now()
    device.UpdatedAt = time.Now()
    device.LastSeen = time.Now()
    
    // Save to DynamoDB
    _, err := ds.dynamoDB.PutItem(&dynamodb.PutItemInput{
        TableName: aws.String("devices"),
        Item: map[string]*dynamodb.AttributeValue{
            "id": {S: aws.String(device.ID)},
            "name": {S: aws.String(device.Name)},
            "type": {S: aws.String(device.Type)},
            "status": {S: aws.String(device.Status)},
            "tenant_id": {S: aws.String(device.TenantID)},
            "created_at": {S: aws.String(device.CreatedAt.Format(time.RFC3339))},
            "updated_at": {S: aws.String(device.UpdatedAt.Format(time.RFC3339))},
            "last_seen": {S: aws.String(device.LastSeen.Format(time.RFC3339))},
        },
    })
    
    if err != nil {
        c.JSON(500, gin.H{"error": "Failed to register device"})
        return
    }
    
    c.JSON(201, device)
}

func (ds *DeviceService) GetDevice(c *gin.Context) {
    deviceID := c.Param("id")
    
    result, err := ds.dynamoDB.GetItem(&dynamodb.GetItemInput{
        TableName: aws.String("devices"),
        Key: map[string]*dynamodb.AttributeValue{
            "id": {S: aws.String(deviceID)},
        },
    })
    
    if err != nil {
        c.JSON(500, gin.H{"error": "Failed to get device"})
        return
    }
    
    if result.Item == nil {
        c.JSON(404, gin.H{"error": "Device not found"})
        return
    }
    
    device := Device{
        ID:       *result.Item["id"].S,
        Name:     *result.Item["name"].S,
        Type:     *result.Item["type"].S,
        Status:   *result.Item["status"].S,
        TenantID: *result.Item["tenant_id"].S,
    }
    
    c.JSON(200, device)
}

func (ds *DeviceService) UpdateDeviceStatus(c *gin.Context) {
    deviceID := c.Param("id")
    var statusUpdate struct {
        Status string `json:"status"`
    }
    
    if err := c.ShouldBindJSON(&statusUpdate); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }
    
    _, err := ds.dynamoDB.UpdateItem(&dynamodb.UpdateItemInput{
        TableName: aws.String("devices"),
        Key: map[string]*dynamodb.AttributeValue{
            "id": {S: aws.String(deviceID)},
        },
        UpdateExpression: aws.String("SET #status = :status, updated_at = :updated_at, last_seen = :last_seen"),
        ExpressionAttributeNames: map[string]*string{
            "#status": aws.String("status"),
        },
        ExpressionAttributeValues: map[string]*dynamodb.AttributeValue{
            ":status": {S: aws.String(statusUpdate.Status)},
            ":updated_at": {S: aws.String(time.Now().Format(time.RFC3339))},
            ":last_seen": {S: aws.String(time.Now().Format(time.RFC3339))},
        },
    })
    
    if err != nil {
        c.JSON(500, gin.H{"error": "Failed to update device status"})
        return
    }
    
    c.JSON(200, gin.H{"message": "Device status updated"})
}

func main() {
    r := gin.Default()
    
    // Initialize AWS services
    sess := session.Must(session.NewSession())
    dynamoDB := dynamodb.New(sess)
    
    deviceService := NewDeviceService(dynamoDB)
    
    // Routes
    r.POST("/devices", deviceService.RegisterDevice)
    r.GET("/devices/:id", deviceService.GetDevice)
    r.PUT("/devices/:id/status", deviceService.UpdateDeviceStatus)
    
    r.Run(":8080")
}
```

#### 2.2 Data Ingestion Service
```go
// data-ingestion-service/main.go
package main

import (
    "github.com/gin-gonic/gin"
    "github.com/aws/aws-sdk-go/service/kinesis"
    "github.com/aws/aws-sdk-go/aws"
    "encoding/json"
    "time"
)

type DataPoint struct {
    DeviceID    string                 `json:"device_id"`
    Timestamp   time.Time              `json:"timestamp"`
    Metric      string                 `json:"metric"`
    Value       float64                `json:"value"`
    Unit        string                 `json:"unit"`
    Metadata    map[string]interface{} `json:"metadata"`
}

type DataIngestionService struct {
    kinesis *kinesis.Kinesis
}

func NewDataIngestionService(kinesis *kinesis.Kinesis) *DataIngestionService {
    return &DataIngestionService{kinesis: kinesis}
}

func (dis *DataIngestionService) IngestData(c *gin.Context) {
    var dataPoint DataPoint
    if err := c.ShouldBindJSON(&dataPoint); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }
    
    // Set timestamp if not provided
    if dataPoint.Timestamp.IsZero() {
        dataPoint.Timestamp = time.Now()
    }
    
    // Serialize data point
    data, err := json.Marshal(dataPoint)
    if err != nil {
        c.JSON(500, gin.H{"error": "Failed to serialize data"})
        return
    }
    
    // Send to Kinesis
    _, err = dis.kinesis.PutRecord(&kinesis.PutRecordInput{
        StreamName:   aws.String("iot-data-stream"),
        Data:         data,
        PartitionKey: aws.String(dataPoint.DeviceID),
    })
    
    if err != nil {
        c.JSON(500, gin.H{"error": "Failed to ingest data"})
        return
    }
    
    c.JSON(200, gin.H{"message": "Data ingested successfully"})
}

func (dis *DataIngestionService) IngestBatchData(c *gin.Context) {
    var dataPoints []DataPoint
    if err := c.ShouldBindJSON(&dataPoints); err != nil {
        c.JSON(400, gin.H{"error": err.Error()})
        return
    }
    
    // Prepare records for batch ingestion
    var records []*kinesis.PutRecordsRequestEntry
    for _, dataPoint := range dataPoints {
        data, err := json.Marshal(dataPoint)
        if err != nil {
            continue
        }
        
        records = append(records, &kinesis.PutRecordsRequestEntry{
            Data:         data,
            PartitionKey: aws.String(dataPoint.DeviceID),
        })
    }
    
    // Send batch to Kinesis
    _, err := dis.kinesis.PutRecords(&kinesis.PutRecordsInput{
        StreamName: aws.String("iot-data-stream"),
        Records:    records,
    })
    
    if err != nil {
        c.JSON(500, gin.H{"error": "Failed to ingest batch data"})
        return
    }
    
    c.JSON(200, gin.H{"message": "Batch data ingested successfully"})
}

func main() {
    r := gin.Default()
    
    // Initialize AWS services
    sess := session.Must(session.NewSession())
    kinesis := kinesis.New(sess)
    
    dataIngestionService := NewDataIngestionService(kinesis)
    
    // Routes
    r.POST("/ingest", dataIngestionService.IngestData)
    r.POST("/ingest/batch", dataIngestionService.IngestBatchData)
    
    r.Run(":8080")
}
```

#### 2.3 Stream Processing Service
```go
// stream-processing-service/main.go
package main

import (
    "github.com/aws/aws-sdk-go/service/kinesis"
    "github.com/aws/aws-sdk-go/service/timestreamwrite"
    "github.com/aws/aws-sdk-go/aws"
    "encoding/json"
    "time"
)

type StreamProcessor struct {
    kinesis        *kinesis.Kinesis
    timestream     *timestreamwrite.TimestreamWrite
    shardIterator  *string
}

func NewStreamProcessor(kinesis *kinesis.Kinesis, timestream *timestreamwrite.TimestreamWrite) *StreamProcessor {
    return &StreamProcessor{
        kinesis:    kinesis,
        timestream: timestream,
    }
}

func (sp *StreamProcessor) ProcessStream() {
    for {
        // Get records from Kinesis
        records, err := sp.getRecords()
        if err != nil {
            time.Sleep(1 * time.Second)
            continue
        }
        
        // Process each record
        for _, record := range records {
            sp.processRecord(record)
        }
        
        time.Sleep(100 * time.Millisecond)
    }
}

func (sp *StreamProcessor) getRecords() ([]*kinesis.Record, error) {
    // Get shard iterator if not set
    if sp.shardIterator == nil {
        result, err := sp.kinesis.GetShardIterator(&kinesis.GetShardIteratorInput{
            StreamName:        aws.String("iot-data-stream"),
            ShardId:           aws.String("shardId-000000000000"),
            ShardIteratorType: aws.String("LATEST"),
        })
        if err != nil {
            return nil, err
        }
        sp.shardIterator = result.ShardIterator
    }
    
    // Get records
    result, err := sp.kinesis.GetRecords(&kinesis.GetRecordsInput{
        ShardIterator: sp.shardIterator,
        Limit:         aws.Int64(100),
    })
    if err != nil {
        return nil, err
    }
    
    sp.shardIterator = result.NextShardIterator
    return result.Records, nil
}

func (sp *StreamProcessor) processRecord(record *kinesis.Record) {
    var dataPoint DataPoint
    if err := json.Unmarshal(record.Data, &dataPoint); err != nil {
        return
    }
    
    // Process data point
    sp.enrichData(&dataPoint)
    sp.detectAnomalies(&dataPoint)
    sp.storeData(&dataPoint)
}

func (sp *StreamProcessor) enrichData(dataPoint *DataPoint) {
    // Add enrichment logic here
    // e.g., add location data, device metadata, etc.
}

func (sp *StreamProcessor) detectAnomalies(dataPoint *DataPoint) {
    // Add anomaly detection logic here
    // e.g., check for unusual values, patterns, etc.
}

func (sp *StreamProcessor) storeData(dataPoint *DataPoint) {
    // Store in Timestream
    _, err := sp.timestream.WriteRecords(&timestreamwrite.WriteRecordsInput{
        DatabaseName: aws.String("iot-timeseries"),
        TableName:    aws.String("device-data"),
        Records: []*timestreamwrite.Record{
            {
                Dimensions: []*timestreamwrite.Dimension{
                    {
                        Name:  aws.String("device_id"),
                        Value: aws.String(dataPoint.DeviceID),
                    },
                },
                MeasureName:      aws.String(dataPoint.Metric),
                MeasureValue:     aws.String(fmt.Sprintf("%.2f", dataPoint.Value)),
                MeasureValueType: aws.String("DOUBLE"),
                Time:             aws.String(fmt.Sprintf("%d", dataPoint.Timestamp.UnixNano())),
                TimeUnit:         aws.String("NANOSECONDS"),
            },
        },
    })
    
    if err != nil {
        // Handle error
    }
}

func main() {
    // Initialize AWS services
    sess := session.Must(session.NewSession())
    kinesis := kinesis.New(sess)
    timestream := timestreamwrite.New(sess)
    
    processor := NewStreamProcessor(kinesis, timestream)
    processor.ProcessStream()
}
```

### Phase 3: Analytics and Visualization

#### 3.1 Analytics Service
```go
// analytics-service/main.go
package main

import (
    "github.com/gin-gonic/gin"
    "github.com/aws/aws-sdk-go/service/timestreamquery"
    "github.com/aws/aws-sdk-go/aws"
    "time"
)

type AnalyticsService struct {
    timestream *timestreamquery.TimestreamQuery
}

func NewAnalyticsService(timestream *timestreamquery.TimestreamQuery) *AnalyticsService {
    return &AnalyticsService{timestream: timestream}
}

func (as *AnalyticsService) GetDeviceMetrics(c *gin.Context) {
    deviceID := c.Param("deviceId")
    metric := c.Query("metric")
    startTime := c.Query("startTime")
    endTime := c.Query("endTime")
    
    // Build query
    query := `SELECT time, measure_value::double as value
              FROM "iot-timeseries"."device-data"
              WHERE device_id = '` + deviceID + `'
              AND measure_name = '` + metric + `'
              AND time BETWEEN '` + startTime + `' AND '` + endTime + `'
              ORDER BY time`
    
    // Execute query
    result, err := as.timestream.Query(&timestreamquery.QueryInput{
        QueryString: aws.String(query),
    })
    
    if err != nil {
        c.JSON(500, gin.H{"error": "Failed to query metrics"})
        return
    }
    
    // Process results
    var metrics []map[string]interface{}
    for _, row := range result.Rows {
        metric := map[string]interface{}{
            "time":  row.Data[0].ScalarValue,
            "value": row.Data[1].ScalarValue,
        }
        metrics = append(metrics, metric)
    }
    
    c.JSON(200, gin.H{"metrics": metrics})
}

func (as *AnalyticsService) GetAggregatedMetrics(c *gin.Context) {
    deviceID := c.Param("deviceId")
    metric := c.Query("metric")
    aggregation := c.Query("aggregation") // avg, sum, min, max
    interval := c.Query("interval") // 1m, 5m, 1h, 1d
    
    // Build query
    query := `SELECT BIN(time, ` + interval + `) as time_bin, 
                     ` + aggregation + `(measure_value::double) as value
              FROM "iot-timeseries"."device-data"
              WHERE device_id = '` + deviceID + `'
              AND measure_name = '` + metric + `'
              GROUP BY BIN(time, ` + interval + `)
              ORDER BY time_bin`
    
    // Execute query
    result, err := as.timestream.Query(&timestreamquery.QueryInput{
        QueryString: aws.String(query),
    })
    
    if err != nil {
        c.JSON(500, gin.H{"error": "Failed to query aggregated metrics"})
        return
    }
    
    // Process results
    var metrics []map[string]interface{}
    for _, row := range result.Rows {
        metric := map[string]interface{}{
            "time":  row.Data[0].ScalarValue,
            "value": row.Data[1].ScalarValue,
        }
        metrics = append(metrics, metric)
    }
    
    c.JSON(200, gin.H{"metrics": metrics})
}

func main() {
    r := gin.Default()
    
    // Initialize AWS services
    sess := session.Must(session.NewSession())
    timestream := timestreamquery.New(sess)
    
    analyticsService := NewAnalyticsService(timestream)
    
    // Routes
    r.GET("/devices/:deviceId/metrics", analyticsService.GetDeviceMetrics)
    r.GET("/devices/:deviceId/aggregated", analyticsService.GetAggregatedMetrics)
    
    r.Run(":8080")
}
```

## Testing

### Unit Tests
```go
// tests/device_service_test.go
package tests

import (
    "testing"
    "net/http"
    "net/http/httptest"
    "bytes"
    "encoding/json"
)

func TestRegisterDevice(t *testing.T) {
    // Setup
    device := Device{
        Name: "Test Device",
        Type: "sensor",
        TenantID: "test-tenant",
    }
    
    jsonData, _ := json.Marshal(device)
    req, _ := http.NewRequest("POST", "/devices", bytes.NewBuffer(jsonData))
    req.Header.Set("Content-Type", "application/json")
    
    w := httptest.NewRecorder()
    
    // Test
    // ... test implementation
    
    if w.Code != 201 {
        t.Errorf("Expected status 201, got %d", w.Code)
    }
}
```

## Deployment

### Kubernetes Configuration
```yaml
# k8s/device-service-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: device-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: device-service
  template:
    metadata:
      labels:
        app: device-service
    spec:
      containers:
      - name: device-service
        image: iot/device-service:latest
        ports:
        - containerPort: 8080
        env:
        - name: AWS_REGION
          value: "us-west-2"
        - name: DYNAMODB_TABLE
          value: "devices"
```

## Solution

Complete solution available in the `solutions/` directory including:
- Full source code for all services
- Infrastructure as code (Terraform)
- Kubernetes manifests
- Docker configurations
- Test suites
- API documentation
- Monitoring dashboards

## Next Steps

After completing this project:
1. **Review the Solution**: Compare your implementation with the provided solution
2. **Identify Improvements**: Look for areas to optimize and improve
3. **Apply Learnings**: Use the knowledge in your own projects
4. **Complete Module 05**: You have completed all projects in Module 05
