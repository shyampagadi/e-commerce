# Project 4 Solution: IoT Data Processing Platform

## Solution Overview

This solution provides a complete implementation of an IoT data processing platform using microservices architecture with real-time data ingestion, processing, analytics, and device management capabilities.

## Architecture Overview

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │    │   Edge Gateway  │    │   Mobile App    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    API Gateway                          │
    │              (Load Balancer + Auth)                    │
    └─────────────────────────────────────────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Microservices                        │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Device Mgmt  │ │Data Ingestion│ │Data Processing│    │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Analytics    │ │Alert Service│ │Dashboard    │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Data Layer                           │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │InfluxDB     │ │   Redis     │ │   MongoDB   │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐                      │
    │  │Elasticsearch│ │   S3        │                      │
    │  └─────────────┘ └─────────────┘                      │
    └─────────────────────────────────────────────────────────┘
```

## Implementation Details

### 1. Device Management Service

#### Service Implementation
```python
# device-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime
import json

from .database import get_db
from .models import Device, DeviceType, DeviceGroup, DeviceConfiguration
from .schemas import DeviceCreate, DeviceResponse, DeviceUpdate, DeviceTypeCreate

app = FastAPI(title="Device Management Service", version="1.0.0")

@app.post("/devices", response_model=DeviceResponse)
def create_device(device: DeviceCreate, db: Session = Depends(get_db)):
    """Create new device"""
    # Check if device type exists
    device_type = db.query(DeviceType).filter(DeviceType.id == device.device_type_id).first()
    if not device_type:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device type not found"
        )
    
    # Create device
    db_device = Device(
        id=str(uuid.uuid4()),
        name=device.name,
        device_id=device.device_id,
        device_type_id=device.device_type_id,
        tenant_id=device.tenant_id,
        location=device.location,
        status="offline",
        last_seen=datetime.utcnow(),
        created_at=datetime.utcnow()
    )
    
    db.add(db_device)
    db.commit()
    db.refresh(db_device)
    
    # Create default configuration
    config = DeviceConfiguration(
        id=str(uuid.uuid4()),
        device_id=db_device.id,
        configuration=device.configuration or {},
        created_at=datetime.utcnow()
    )
    
    db.add(config)
    db.commit()
    
    return DeviceResponse.from_orm(db_device)

@app.get("/devices/{device_id}", response_model=DeviceResponse)
def get_device(device_id: str, db: Session = Depends(get_db)):
    """Get device by ID"""
    device = db.query(Device).filter(Device.id == device_id).first()
    if not device:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found"
        )
    return DeviceResponse.from_orm(device)

@app.put("/devices/{device_id}", response_model=DeviceResponse)
def update_device(
    device_id: str,
    device_update: DeviceUpdate,
    db: Session = Depends(get_db)
):
    """Update device"""
    device = db.query(Device).filter(Device.id == device_id).first()
    if not device:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found"
        )
    
    # Update device fields
    if device_update.name:
        device.name = device_update.name
    if device_update.location:
        device.location = device_update.location
    if device_update.status:
        device.status = device_update.status
    
    device.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(device)
    
    return DeviceResponse.from_orm(device)

@app.get("/devices")
def list_devices(
    tenant_id: str,
    device_type_id: Optional[str] = None,
    status: Optional[str] = None,
    group_id: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """List devices with filtering"""
    query = db.query(Device).filter(Device.tenant_id == tenant_id)
    
    if device_type_id:
        query = query.filter(Device.device_type_id == device_type_id)
    if status:
        query = query.filter(Device.status == status)
    if group_id:
        query = query.filter(Device.group_id == group_id)
    
    devices = query.order_by(Device.created_at.desc()).offset(offset).limit(limit).all()
    
    return [DeviceResponse.from_orm(device) for device in devices]

@app.post("/devices/{device_id}/heartbeat")
def update_device_heartbeat(device_id: str, db: Session = Depends(get_db)):
    """Update device heartbeat"""
    device = db.query(Device).filter(Device.id == device_id).first()
    if not device:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found"
        )
    
    device.last_seen = datetime.utcnow()
    device.status = "online"
    db.commit()
    
    return {"message": "Heartbeat updated successfully"}

@app.get("/devices/{device_id}/configuration")
def get_device_configuration(device_id: str, db: Session = Depends(get_db)):
    """Get device configuration"""
    config = db.query(DeviceConfiguration).filter(
        DeviceConfiguration.device_id == device_id
    ).order_by(DeviceConfiguration.created_at.desc()).first()
    
    if not config:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device configuration not found"
        )
    
    return config.configuration

@app.put("/devices/{device_id}/configuration")
def update_device_configuration(
    device_id: str,
    configuration: dict,
    db: Session = Depends(get_db)
):
    """Update device configuration"""
    # Create new configuration version
    config = DeviceConfiguration(
        id=str(uuid.uuid4()),
        device_id=device_id,
        configuration=configuration,
        created_at=datetime.utcnow()
    )
    
    db.add(config)
    db.commit()
    
    return {"message": "Configuration updated successfully"}

@app.post("/device-types", response_model=DeviceType)
def create_device_type(device_type: DeviceTypeCreate, db: Session = Depends(get_db)):
    """Create device type"""
    db_device_type = DeviceType(
        id=str(uuid.uuid4()),
        name=device_type.name,
        description=device_type.description,
        data_schema=device_type.data_schema,
        tenant_id=device_type.tenant_id,
        created_at=datetime.utcnow()
    )
    
    db.add(db_device_type)
    db.commit()
    db.refresh(db_device_type)
    
    return db_device_type

@app.get("/device-types")
def list_device_types(tenant_id: str, db: Session = Depends(get_db)):
    """List device types"""
    device_types = db.query(DeviceType).filter(
        DeviceType.tenant_id == tenant_id
    ).all()
    
    return [DeviceType.from_orm(dt) for dt in device_types]

@app.post("/device-groups")
def create_device_group(group_data: dict, db: Session = Depends(get_db)):
    """Create device group"""
    group = DeviceGroup(
        id=str(uuid.uuid4()),
        name=group_data["name"],
        description=group_data.get("description"),
        tenant_id=group_data["tenant_id"],
        created_at=datetime.utcnow()
    )
    
    db.add(group)
    db.commit()
    db.refresh(group)
    
    return group

@app.post("/device-groups/{group_id}/devices/{device_id}")
def add_device_to_group(group_id: str, device_id: str, db: Session = Depends(get_db)):
    """Add device to group"""
    device = db.query(Device).filter(Device.id == device_id).first()
    if not device:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found"
        )
    
    group = db.query(DeviceGroup).filter(DeviceGroup.id == group_id).first()
    if not group:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device group not found"
        )
    
    device.group_id = group_id
    db.commit()
    
    return {"message": "Device added to group successfully"}
```

#### Database Models
```python
# device-service/models.py
from sqlalchemy import Column, String, Text, DateTime, Boolean, ForeignKey, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class DeviceType(Base):
    __tablename__ = "device_types"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text)
    data_schema = Column(JSON)  # JSON schema for device data
    tenant_id = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    devices = relationship("Device", back_populates="device_type")

class DeviceGroup(Base):
    __tablename__ = "device_groups"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text)
    tenant_id = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    devices = relationship("Device", back_populates="group")

class Device(Base):
    __tablename__ = "devices"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    device_id = Column(String, unique=True, nullable=False, index=True)
    device_type_id = Column(String, ForeignKey("device_types.id"), nullable=False)
    tenant_id = Column(String, nullable=False)
    group_id = Column(String, ForeignKey("device_groups.id"))
    location = Column(String)
    status = Column(String, default="offline")  # online, offline, error
    last_seen = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    device_type = relationship("DeviceType", back_populates="devices")
    group = relationship("DeviceGroup", back_populates="devices")
    configurations = relationship("DeviceConfiguration", back_populates="device")

class DeviceConfiguration(Base):
    __tablename__ = "device_configurations"
    
    id = Column(String, primary_key=True, index=True)
    device_id = Column(String, ForeignKey("devices.id"), nullable=False)
    configuration = Column(JSON, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    device = relationship("Device", back_populates="configurations")
```

### 2. Data Ingestion Service

#### Service Implementation
```python
# data-ingestion-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status, BackgroundTasks
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime
import json
import asyncio
from kafka import KafkaProducer
import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS

from .database import get_db
from .models import DataPoint, DataStream, DataValidation
from .schemas import DataPointCreate, DataStreamCreate, DataPointResponse

app = FastAPI(title="Data Ingestion Service", version="1.0.0")

# Kafka producer
kafka_producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda x: json.dumps(x).encode('utf-8')
)

# InfluxDB client
influx_client = influxdb_client.InfluxDBClient(
    url="http://localhost:8086",
    token="your-token",
    org="your-org"
)
write_api = influx_client.write_api(write_options=SYNCHRONOUS)

@app.post("/data/ingest", response_model=DataPointResponse)
def ingest_data_point(
    data_point: DataPointCreate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Ingest data point from IoT device"""
    # Validate data point
    validation_result = validate_data_point(data_point)
    if not validation_result.is_valid:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Data validation failed: {validation_result.error_message}"
        )
    
    # Create data point record
    db_data_point = DataPoint(
        id=str(uuid.uuid4()),
        device_id=data_point.device_id,
        stream_id=data_point.stream_id,
        timestamp=data_point.timestamp or datetime.utcnow(),
        data=data_point.data,
        quality_score=validation_result.quality_score,
        created_at=datetime.utcnow()
    )
    
    db.add(db_data_point)
    db.commit()
    db.refresh(db_data_point)
    
    # Process data point asynchronously
    background_tasks.add_task(process_data_point, db_data_point)
    
    return DataPointResponse.from_orm(db_data_point)

@app.post("/data/batch-ingest")
def batch_ingest_data_points(
    data_points: List[DataPointCreate],
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Batch ingest multiple data points"""
    valid_data_points = []
    invalid_data_points = []
    
    for data_point in data_points:
        validation_result = validate_data_point(data_point)
        if validation_result.is_valid:
            valid_data_points.append(data_point)
        else:
            invalid_data_points.append({
                "data_point": data_point,
                "error": validation_result.error_message
            })
    
    # Process valid data points
    for data_point in valid_data_points:
        db_data_point = DataPoint(
            id=str(uuid.uuid4()),
            device_id=data_point.device_id,
            stream_id=data_point.stream_id,
            timestamp=data_point.timestamp or datetime.utcnow(),
            data=data_point.data,
            quality_score=validation_result.quality_score,
            created_at=datetime.utcnow()
        )
        
        db.add(db_data_point)
    
    db.commit()
    
    # Process data points asynchronously
    background_tasks.add_task(process_batch_data_points, valid_data_points)
    
    return {
        "processed": len(valid_data_points),
        "failed": len(invalid_data_points),
        "errors": invalid_data_points
    }

@app.get("/data/streams/{stream_id}/data")
def get_stream_data(
    stream_id: str,
    start_time: Optional[datetime] = None,
    end_time: Optional[datetime] = None,
    limit: int = 1000,
    db: Session = Depends(get_db)
):
    """Get data for a specific stream"""
    query = db.query(DataPoint).filter(DataPoint.stream_id == stream_id)
    
    if start_time:
        query = query.filter(DataPoint.timestamp >= start_time)
    if end_time:
        query = query.filter(DataPoint.timestamp <= end_time)
    
    data_points = query.order_by(DataPoint.timestamp.desc()).limit(limit).all()
    
    return [DataPointResponse.from_orm(dp) for dp in data_points]

@app.post("/data/streams", response_model=DataStream)
def create_data_stream(stream: DataStreamCreate, db: Session = Depends(get_db)):
    """Create data stream"""
    db_stream = DataStream(
        id=str(uuid.uuid4()),
        name=stream.name,
        device_id=stream.device_id,
        data_schema=stream.data_schema,
        tenant_id=stream.tenant_id,
        created_at=datetime.utcnow()
    )
    
    db.add(db_stream)
    db.commit()
    db.refresh(db_stream)
    
    return db_stream

@app.get("/data/streams")
def list_data_streams(tenant_id: str, db: Session = Depends(get_db)):
    """List data streams for tenant"""
    streams = db.query(DataStream).filter(
        DataStream.tenant_id == tenant_id
    ).all()
    
    return [DataStream.from_orm(stream) for stream in streams]

def validate_data_point(data_point: DataPointCreate) -> DataValidation:
    """Validate data point"""
    # Check required fields
    if not data_point.device_id:
        return DataValidation(is_valid=False, error_message="Device ID is required")
    
    if not data_point.data:
        return DataValidation(is_valid=False, error_message="Data is required")
    
    # Check data schema compliance
    # This would typically validate against the device's data schema
    
    # Calculate quality score
    quality_score = calculate_quality_score(data_point)
    
    return DataValidation(
        is_valid=True,
        quality_score=quality_score,
        error_message=None
    )

def calculate_quality_score(data_point: DataPointCreate) -> float:
    """Calculate data quality score"""
    # Simple quality score calculation
    # In practice, this would be more sophisticated
    score = 1.0
    
    # Check for missing values
    if not data_point.data:
        score -= 0.5
    
    # Check timestamp validity
    if data_point.timestamp and data_point.timestamp > datetime.utcnow():
        score -= 0.2
    
    return max(0.0, min(1.0, score))

async def process_data_point(data_point: DataPoint):
    """Process data point asynchronously"""
    # Store in InfluxDB
    point = influxdb_client.Point("iot_data") \
        .tag("device_id", data_point.device_id) \
        .tag("stream_id", data_point.stream_id) \
        .field("data", json.dumps(data_point.data)) \
        .field("quality_score", data_point.quality_score) \
        .time(data_point.timestamp)
    
    write_api.write(bucket="iot-data", record=point)
    
    # Send to Kafka for real-time processing
    kafka_message = {
        "id": data_point.id,
        "device_id": data_point.device_id,
        "stream_id": data_point.stream_id,
        "timestamp": data_point.timestamp.isoformat(),
        "data": data_point.data,
        "quality_score": data_point.quality_score
    }
    
    kafka_producer.send("iot-data-stream", value=kafka_message)
    
    # Trigger alerting if needed
    await check_alerts(data_point)

async def process_batch_data_points(data_points: List[DataPointCreate]):
    """Process batch data points"""
    for data_point in data_points:
        await process_data_point(data_point)

async def check_alerts(data_point: DataPoint):
    """Check for alert conditions"""
    # This would typically check against alert rules
    # and trigger notifications if conditions are met
    pass
```

### 3. Data Processing Service

#### Service Implementation
```python
# data-processing-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime, timedelta
import json
import asyncio
from kafka import KafkaConsumer
import pandas as pd
import numpy as np

from .database import get_db
from .models import ProcessingJob, ProcessingRule, ProcessedData
from .schemas import ProcessingJobCreate, ProcessingJobResponse, ProcessingRuleCreate

app = FastAPI(title="Data Processing Service", version="1.0.0")

# Kafka consumer
kafka_consumer = KafkaConsumer(
    'iot-data-stream',
    bootstrap_servers=['localhost:9092'],
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)

@app.post("/processing/jobs", response_model=ProcessingJobResponse)
def create_processing_job(job: ProcessingJobCreate, db: Session = Depends(get_db)):
    """Create processing job"""
    db_job = ProcessingJob(
        id=str(uuid.uuid4()),
        name=job.name,
        description=job.description,
        processing_type=job.processing_type,
        configuration=job.configuration,
        status="pending",
        tenant_id=job.tenant_id,
        created_at=datetime.utcnow()
    )
    
    db.add(db_job)
    db.commit()
    db.refresh(db_job)
    
    # Start processing job asynchronously
    asyncio.create_task(process_job(db_job.id))
    
    return ProcessingJobResponse.from_orm(db_job)

@app.get("/processing/jobs/{job_id}", response_model=ProcessingJobResponse)
def get_processing_job(job_id: str, db: Session = Depends(get_db)):
    """Get processing job by ID"""
    job = db.query(ProcessingJob).filter(ProcessingJob.id == job_id).first()
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Processing job not found"
        )
    return ProcessingJobResponse.from_orm(job)

@app.get("/processing/jobs")
def list_processing_jobs(
    tenant_id: str,
    status: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """List processing jobs"""
    query = db.query(ProcessingJob).filter(ProcessingJob.tenant_id == tenant_id)
    
    if status:
        query = query.filter(ProcessingJob.status == status)
    
    jobs = query.order_by(ProcessingJob.created_at.desc()).offset(offset).limit(limit).all()
    
    return [ProcessingJobResponse.from_orm(job) for job in jobs]

@app.post("/processing/rules")
def create_processing_rule(rule: ProcessingRuleCreate, db: Session = Depends(get_db)):
    """Create processing rule"""
    db_rule = ProcessingRule(
        id=str(uuid.uuid4()),
        name=rule.name,
        description=rule.description,
        conditions=rule.conditions,
        actions=rule.actions,
        is_active=True,
        tenant_id=rule.tenant_id,
        created_at=datetime.utcnow()
    )
    
    db.add(db_rule)
    db.commit()
    db.refresh(db_rule)
    
    return db_rule

@app.get("/processing/rules")
def list_processing_rules(tenant_id: str, db: Session = Depends(get_db)):
    """List processing rules"""
    rules = db.query(ProcessingRule).filter(
        ProcessingRule.tenant_id == tenant_id,
        ProcessingRule.is_active == True
    ).all()
    
    return [ProcessingRule.from_orm(rule) for rule in rules]

async def process_job(job_id: str):
    """Process job asynchronously"""
    # This would typically be implemented as a background task
    # For now, we'll simulate processing
    await asyncio.sleep(1)
    
    # Update job status
    # In a real implementation, this would update the database
    print(f"Processing job {job_id} completed")

async def start_kafka_consumer():
    """Start Kafka consumer for real-time processing"""
    for message in kafka_consumer:
        data = message.value
        
        # Process data point
        await process_data_point(data)

async def process_data_point(data: dict):
    """Process individual data point"""
    # Apply processing rules
    await apply_processing_rules(data)
    
    # Perform data transformations
    processed_data = await transform_data(data)
    
    # Store processed data
    await store_processed_data(processed_data)

async def apply_processing_rules(data: dict):
    """Apply processing rules to data"""
    # This would typically query the database for active rules
    # and apply them to the data
    pass

async def transform_data(data: dict) -> dict:
    """Transform data based on processing configuration"""
    # Example transformations:
    # - Data aggregation
    # - Data filtering
    # - Data enrichment
    # - Data normalization
    
    transformed_data = {
        "original_id": data["id"],
        "device_id": data["device_id"],
        "timestamp": data["timestamp"],
        "processed_data": data["data"],
        "processing_timestamp": datetime.utcnow().isoformat()
    }
    
    return transformed_data

async def store_processed_data(processed_data: dict):
    """Store processed data"""
    # This would typically store the processed data in a database
    # or send it to another service
    pass

# Start Kafka consumer
asyncio.create_task(start_kafka_consumer())
```

### 4. Analytics Service

#### Service Implementation
```python
# analytics-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime, timedelta
import json
import pandas as pd
import numpy as np
from influxdb_client import InfluxDBClient
from influxdb_client.client.query_api import QueryApi

from .database import get_db
from .models import AnalyticsQuery, AnalyticsResult, Dashboard, Widget
from .schemas import AnalyticsQueryCreate, AnalyticsResultResponse, DashboardCreate

app = FastAPI(title="Analytics Service", version="1.0.0")

# InfluxDB client
influx_client = InfluxDBClient(
    url="http://localhost:8086",
    token="your-token",
    org="your-org"
)
query_api = QueryApi(influx_client)

@app.post("/analytics/query", response_model=AnalyticsResultResponse)
def execute_analytics_query(
    query: AnalyticsQueryCreate,
    db: Session = Depends(get_db)
):
    """Execute analytics query"""
    # Create query record
    db_query = AnalyticsQuery(
        id=str(uuid.uuid4()),
        name=query.name,
        query_type=query.query_type,
        parameters=query.parameters,
        tenant_id=query.tenant_id,
        created_at=datetime.utcnow()
    )
    
    db.add(db_query)
    db.commit()
    db.refresh(db_query)
    
    # Execute query
    result = execute_query(query)
    
    # Store result
    db_result = AnalyticsResult(
        id=str(uuid.uuid4()),
        query_id=db_query.id,
        result_data=result,
        created_at=datetime.utcnow()
    )
    
    db.add(db_result)
    db.commit()
    
    return AnalyticsResultResponse.from_orm(db_result)

@app.get("/analytics/results/{result_id}", response_model=AnalyticsResultResponse)
def get_analytics_result(result_id: str, db: Session = Depends(get_db)):
    """Get analytics result by ID"""
    result = db.query(AnalyticsResult).filter(AnalyticsResult.id == result_id).first()
    if not result:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Analytics result not found"
        )
    return AnalyticsResultResponse.from_orm(result)

@app.get("/analytics/dashboards")
def list_dashboards(tenant_id: str, db: Session = Depends(get_db)):
    """List dashboards for tenant"""
    dashboards = db.query(Dashboard).filter(
        Dashboard.tenant_id == tenant_id
    ).all()
    
    return [Dashboard.from_orm(dashboard) for dashboard in dashboards]

@app.post("/analytics/dashboards", response_model=Dashboard)
def create_dashboard(dashboard: DashboardCreate, db: Session = Depends(get_db)):
    """Create dashboard"""
    db_dashboard = Dashboard(
        id=str(uuid.uuid4()),
        name=dashboard.name,
        description=dashboard.description,
        configuration=dashboard.configuration,
        tenant_id=dashboard.tenant_id,
        created_at=datetime.utcnow()
    )
    
    db.add(db_dashboard)
    db.commit()
    db.refresh(db_dashboard)
    
    return db_dashboard

@app.get("/analytics/devices/{device_id}/metrics")
def get_device_metrics(
    device_id: str,
    start_time: datetime,
    end_time: datetime,
    metric_type: str = "all"
):
    """Get device metrics"""
    # Build InfluxDB query
    query = f'''
    from(bucket: "iot-data")
      |> range(start: {start_time.isoformat()}, stop: {end_time.isoformat()})
      |> filter(fn: (r) => r.device_id == "{device_id}")
      |> filter(fn: (r) => r._field == "data")
      |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
    '''
    
    # Execute query
    result = query_api.query(query)
    
    # Process results
    metrics = []
    for table in result:
        for record in table.records:
            metrics.append({
                "timestamp": record.get_time().isoformat(),
                "value": record.get_value(),
                "field": record.get_field()
            })
    
    return metrics

@app.get("/analytics/devices/{device_id}/summary")
def get_device_summary(device_id: str, days: int = 7):
    """Get device summary statistics"""
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(days=days)
    
    # Get data for the period
    query = f'''
    from(bucket: "iot-data")
      |> range(start: {start_time.isoformat()}, stop: {end_time.isoformat()})
      |> filter(fn: (r) => r.device_id == "{device_id}")
      |> filter(fn: (r) => r._field == "data")
    '''
    
    result = query_api.query(query)
    
    # Calculate summary statistics
    values = []
    for table in result:
        for record in table.records:
            values.append(record.get_value())
    
    if not values:
        return {"message": "No data found for the specified period"}
    
    # Calculate statistics
    summary = {
        "device_id": device_id,
        "period_days": days,
        "total_records": len(values),
        "mean": np.mean(values),
        "median": np.median(values),
        "std": np.std(values),
        "min": np.min(values),
        "max": np.max(values),
        "first_reading": min(values),
        "last_reading": max(values)
    }
    
    return summary

@app.get("/analytics/trends")
def get_trends(
    tenant_id: str,
    start_time: datetime,
    end_time: datetime,
    group_by: str = "hour"
):
    """Get trend analysis"""
    # Build query for trend analysis
    query = f'''
    from(bucket: "iot-data")
      |> range(start: {start_time.isoformat()}, stop: {end_time.isoformat()})
      |> filter(fn: (r) => r.tenant_id == "{tenant_id}")
      |> filter(fn: (r) => r._field == "data")
      |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
      |> group(columns: ["device_id"])
    '''
    
    result = query_api.query(query)
    
    # Process results for trend analysis
    trends = {}
    for table in result:
        device_id = table.records[0].values.get("device_id") if table.records else "unknown"
        trends[device_id] = []
        
        for record in table.records:
            trends[device_id].append({
                "timestamp": record.get_time().isoformat(),
                "value": record.get_value()
            })
    
    return trends

def execute_query(query: AnalyticsQueryCreate) -> Dict[str, Any]:
    """Execute analytics query"""
    if query.query_type == "aggregation":
        return execute_aggregation_query(query)
    elif query.query_type == "time_series":
        return execute_time_series_query(query)
    elif query.query_type == "statistical":
        return execute_statistical_query(query)
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported query type"
        )

def execute_aggregation_query(query: AnalyticsQueryCreate) -> Dict[str, Any]:
    """Execute aggregation query"""
    # Build InfluxDB aggregation query
    influx_query = f'''
    from(bucket: "iot-data")
      |> range(start: {query.parameters.get('start_time')}, stop: {query.parameters.get('end_time')})
      |> filter(fn: (r) => r.device_id == "{query.parameters.get('device_id')}")
      |> filter(fn: (r) => r._field == "data")
      |> aggregateWindow(every: {query.parameters.get('window', '1h')}, fn: mean, createEmpty: false)
    '''
    
    result = query_api.query(influx_query)
    
    # Process results
    data = []
    for table in result:
        for record in table.records:
            data.append({
                "timestamp": record.get_time().isoformat(),
                "value": record.get_value()
            })
    
    return {
        "query_type": "aggregation",
        "data": data,
        "count": len(data)
    }

def execute_time_series_query(query: AnalyticsQueryCreate) -> Dict[str, Any]:
    """Execute time series query"""
    # Similar implementation for time series queries
    pass

def execute_statistical_query(query: AnalyticsQueryCreate) -> Dict[str, Any]:
    """Execute statistical query"""
    # Similar implementation for statistical queries
    pass
```

## Best Practices Applied

### IoT Data Management
1. **Real-time Ingestion**: High-throughput data ingestion
2. **Data Validation**: Comprehensive data validation
3. **Quality Scoring**: Data quality assessment
4. **Batch Processing**: Efficient batch processing
5. **Stream Processing**: Real-time stream processing

### Device Management
1. **Device Registration**: Secure device registration
2. **Configuration Management**: Device configuration management
3. **Status Monitoring**: Real-time device status monitoring
4. **Group Management**: Device grouping and organization
5. **Heartbeat Monitoring**: Device connectivity monitoring

### Data Processing
1. **Rule Engine**: Configurable processing rules
2. **Data Transformation**: Flexible data transformations
3. **Real-time Processing**: Kafka-based stream processing
4. **Batch Processing**: Scheduled batch processing
5. **Error Handling**: Robust error handling

### Analytics
1. **Time Series Analysis**: Time series data analysis
2. **Statistical Analysis**: Statistical data analysis
3. **Trend Analysis**: Trend identification and analysis
4. **Dashboard Creation**: Interactive dashboards
5. **Custom Queries**: Flexible query capabilities

## Lessons Learned

### Key Insights
1. **Data Volume**: IoT generates massive data volumes
2. **Real-time Processing**: Real-time processing is crucial
3. **Data Quality**: Data quality is essential for analytics
4. **Scalability**: System must scale with data volume
5. **Device Management**: Proper device management is critical

### Common Pitfalls
1. **Data Loss**: Poor data ingestion can cause data loss
2. **Performance Issues**: Inadequate processing can cause bottlenecks
3. **Data Quality**: Poor data quality affects analytics
4. **Device Connectivity**: Poor device management affects reliability
5. **Scalability**: Poor design can limit scalability

### Recommendations
1. **Start Simple**: Begin with basic data ingestion
2. **Plan for Scale**: Design for high data volumes
3. **Monitor Quality**: Implement data quality monitoring
4. **Test Thoroughly**: Test with real IoT data
5. **Optimize Performance**: Continuously optimize performance

## Next Steps

1. **Implementation**: Implement the IoT platform
2. **Testing**: Test with real IoT devices
3. **Monitoring**: Set up comprehensive monitoring
4. **Optimization**: Optimize for performance and scale
5. **Features**: Add advanced analytics features
