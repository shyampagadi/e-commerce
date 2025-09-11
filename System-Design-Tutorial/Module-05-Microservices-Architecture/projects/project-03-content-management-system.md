# Project 3: Content Management System

## Project Overview

Build a comprehensive content management system using microservices architecture on AWS. The system should support content creation, editing, publishing, versioning, and multi-tenant architecture with advanced search and analytics capabilities.

## Requirements

### Functional Requirements

#### Content Management
- Content creation and editing
- Rich text editor with media support
- Content versioning and history
- Content approval workflows
- Content scheduling and publishing
- Content templates and themes

#### User Management
- Multi-tenant architecture
- Role-based access control
- User authentication and authorization
- Team collaboration features
- User activity tracking

#### Media Management
- Image and video upload
- Media processing and optimization
- CDN integration for global delivery
- Media library and organization
- Thumbnail generation

#### Search and Discovery
- Full-text search across content
- Advanced filtering and faceted search
- Content recommendations
- Search analytics
- Auto-complete and suggestions

#### Analytics and Reporting
- Content performance metrics
- User engagement analytics
- Traffic and usage statistics
- Custom reporting dashboards
- Export capabilities

### Non-Functional Requirements

#### Performance
- Support 1 million content pieces
- Page load time < 2 seconds
- Search response time < 500ms
- 99.9% uptime

#### Scalability
- Multi-tenant architecture
- Horizontal scaling
- Global content delivery
- Auto-scaling based on load

#### Security
- Data isolation between tenants
- Content encryption
- Access control and permissions
- Audit logging

## Architecture

### Service Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │    │   Load Balancer │    │   CDN (CloudFront) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Microservices                        │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │User Service │ │Content Svc  │ │Media Service│      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Search Svc   │ │Analytics Svc│ │Workflow Svc │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Data Layer                           │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │   RDS       │ │  DynamoDB   │ │   ElastiCache│     │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
```

### Technology Stack

#### Backend Services
- **Language**: Python with FastAPI
- **Framework**: FastAPI for high-performance APIs
- **Database**: PostgreSQL (RDS) for relational data, DynamoDB for search
- **Cache**: Redis (ElastiCache) for caching
- **Search**: Amazon OpenSearch for full-text search

#### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Amazon EKS
- **API Gateway**: AWS API Gateway
- **Load Balancer**: Application Load Balancer
- **CDN**: CloudFront for global content delivery

#### Media Processing
- **Storage**: Amazon S3 for media files
- **Processing**: AWS Lambda for image/video processing
- **CDN**: CloudFront for media delivery
- **Transcoding**: AWS MediaConvert for video processing

## Implementation

### Phase 1: Foundation Setup

#### 1.1 Infrastructure Setup
```bash
# Create EKS cluster
eksctl create cluster \
  --name cms-cluster \
  --region us-west-2 \
  --nodegroup-name workers \
  --node-type t3.medium \
  --nodes 3

# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier cms-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password password123

# Create OpenSearch domain
aws opensearch create-domain \
  --domain-name cms-search \
  --cluster-config InstanceType=t3.small.search,InstanceCount=1
```

#### 1.2 Service Structure
```
cms-platform/
├── services/
│   ├── user-service/
│   ├── content-service/
│   ├── media-service/
│   ├── search-service/
│   ├── analytics-service/
│   └── workflow-service/
├── infrastructure/
│   ├── terraform/
│   └── kubernetes/
├── shared/
│   ├── models/
│   ├── utils/
│   └── middleware/
└── docs/
    ├── api/
    └── architecture/
```

### Phase 2: Core Services Implementation

#### 2.1 Content Service
```python
# content-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from .database import get_db
from .models import Content, ContentVersion, Tenant
from .schemas import ContentCreate, ContentUpdate, ContentResponse
from .auth import get_current_user, get_current_tenant

app = FastAPI(title="Content Service", version="1.0.0")

@app.post("/content", response_model=ContentResponse)
def create_content(
    content: ContentCreate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    current_tenant = Depends(get_current_tenant)
):
    """Create new content"""
    try:
        # Create content
        db_content = Content(
            id=str(uuid.uuid4()),
            title=content.title,
            body=content.body,
            status=content.status,
            tenant_id=current_tenant.id,
            author_id=current_user.id,
            created_at=datetime.utcnow()
        )
        
        db.add(db_content)
        db.commit()
        db.refresh(db_content)
        
        # Create initial version
        version = ContentVersion(
            id=str(uuid.uuid4()),
            content_id=db_content.id,
            version_number=1,
            title=content.title,
            body=content.body,
            author_id=current_user.id,
            created_at=datetime.utcnow()
        )
        
        db.add(version)
        db.commit()
        
        return ContentResponse.from_orm(db_content)
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to create content"
        )

@app.get("/content", response_model=List[ContentResponse])
def get_content_list(
    skip: int = 0,
    limit: int = 100,
    status: Optional[str] = None,
    db: Session = Depends(get_db),
    current_tenant = Depends(get_current_tenant)
):
    """Get list of content"""
    query = db.query(Content).filter(Content.tenant_id == current_tenant.id)
    
    if status:
        query = query.filter(Content.status == status)
    
    content_list = query.offset(skip).limit(limit).all()
    return [ContentResponse.from_orm(content) for content in content_list]

@app.get("/content/{content_id}", response_model=ContentResponse)
def get_content(
    content_id: str,
    db: Session = Depends(get_db),
    current_tenant = Depends(get_current_tenant)
):
    """Get specific content"""
    content = db.query(Content).filter(
        Content.id == content_id,
        Content.tenant_id == current_tenant.id
    ).first()
    
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    return ContentResponse.from_orm(content)

@app.put("/content/{content_id}", response_model=ContentResponse)
def update_content(
    content_id: str,
    content_update: ContentUpdate,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
    current_tenant = Depends(get_current_tenant)
):
    """Update content"""
    content = db.query(Content).filter(
        Content.id == content_id,
        Content.tenant_id == current_tenant.id
    ).first()
    
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    # Update content
    for field, value in content_update.dict(exclude_unset=True).items():
        setattr(content, field, value)
    
    content.updated_at = datetime.utcnow()
    
    # Create new version
    latest_version = db.query(ContentVersion).filter(
        ContentVersion.content_id == content_id
    ).order_by(ContentVersion.version_number.desc()).first()
    
    new_version = ContentVersion(
        id=str(uuid.uuid4()),
        content_id=content_id,
        version_number=latest_version.version_number + 1,
        title=content.title,
        body=content.body,
        author_id=current_user.id,
        created_at=datetime.utcnow()
    )
    
    db.add(new_version)
    db.commit()
    db.refresh(content)
    
    return ContentResponse.from_orm(content)

@app.get("/content/{content_id}/versions")
def get_content_versions(
    content_id: str,
    db: Session = Depends(get_db),
    current_tenant = Depends(get_current_tenant)
):
    """Get content version history"""
    # Verify content belongs to tenant
    content = db.query(Content).filter(
        Content.id == content_id,
        Content.tenant_id == current_tenant.id
    ).first()
    
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    versions = db.query(ContentVersion).filter(
        ContentVersion.content_id == content_id
    ).order_by(ContentVersion.version_number.desc()).all()
    
    return [{
        "version_number": v.version_number,
        "title": v.title,
        "author_id": v.author_id,
        "created_at": v.created_at
    } for v in versions]

@app.post("/content/{content_id}/publish")
def publish_content(
    content_id: str,
    db: Session = Depends(get_db),
    current_tenant = Depends(get_current_tenant)
):
    """Publish content"""
    content = db.query(Content).filter(
        Content.id == content_id,
        Content.tenant_id == current_tenant.id
    ).first()
    
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    content.status = "published"
    content.published_at = datetime.utcnow()
    
    db.commit()
    
    return {"message": "Content published successfully"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

#### 2.2 Search Service
```python
# search-service/main.py
from fastapi import FastAPI, Depends, HTTPException
from typing import List, Optional
import boto3
from opensearchpy import OpenSearch, RequestsHttpConnection
from aws_requests_auth import boto_utils
from aws_requests_auth.aws_auth import AWSRequestsAuth

app = FastAPI(title="Search Service", version="1.0.0")

# Initialize OpenSearch client
def get_opensearch_client():
    host = 'search-cms-search-xxx.us-west-2.es.amazonaws.com'
    region = 'us-west-2'
    
    awsauth = AWSRequestsAuth(
        aws_access_key=boto3.Session().get_credentials().access_key,
        aws_secret_access_key=boto3.Session().get_credentials().secret_key,
        aws_token=boto3.Session().get_credentials().token,
        aws_host=host,
        aws_region=region,
        aws_service='es'
    )
    
    client = OpenSearch(
        hosts=[{'host': host, 'port': 443}],
        http_auth=awsauth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection
    )
    
    return client

@app.post("/search")
def search_content(
    query: str,
    tenant_id: str,
    filters: Optional[dict] = None,
    page: int = 1,
    size: int = 20,
    opensearch: OpenSearch = Depends(get_opensearch_client)
):
    """Search content across the platform"""
    try:
        # Build search query
        search_body = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "multi_match": {
                                "query": query,
                                "fields": ["title^2", "body", "tags"],
                                "type": "best_fields"
                            }
                        },
                        {
                            "term": {
                                "tenant_id": tenant_id
                            }
                        }
                    ]
                }
            },
            "from": (page - 1) * size,
            "size": size,
            "highlight": {
                "fields": {
                    "title": {},
                    "body": {}
                }
            }
        }
        
        # Add filters if provided
        if filters:
            filter_queries = []
            for field, value in filters.items():
                if isinstance(value, list):
                    filter_queries.append({
                        "terms": {field: value}
                    })
                else:
                    filter_queries.append({
                        "term": {field: value}
                    })
            
            search_body["query"]["bool"]["filter"] = filter_queries
        
        # Execute search
        response = opensearch.search(
            index="content",
            body=search_body
        )
        
        # Process results
        results = []
        for hit in response['hits']['hits']:
            result = hit['_source']
            result['score'] = hit['_score']
            
            if 'highlight' in hit:
                result['highlight'] = hit['highlight']
            
            results.append(result)
        
        return {
            "results": results,
            "total": response['hits']['total']['value'],
            "page": page,
            "size": size
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Search failed: {str(e)}"
        )

@app.post("/content/{content_id}/index")
def index_content(
    content_id: str,
    content_data: dict,
    opensearch: OpenSearch = Depends(get_opensearch_client)
):
    """Index content for search"""
    try:
        # Index content in OpenSearch
        opensearch.index(
            index="content",
            id=content_id,
            body=content_data
        )
        
        return {"message": "Content indexed successfully"}
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Indexing failed: {str(e)}"
        )

@app.delete("/content/{content_id}/index")
def remove_content_index(
    content_id: str,
    opensearch: OpenSearch = Depends(get_opensearch_client)
):
    """Remove content from search index"""
    try:
        opensearch.delete(
            index="content",
            id=content_id
        )
        
        return {"message": "Content removed from index"}
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Removal failed: {str(e)}"
        )

@app.get("/suggestions")
def get_search_suggestions(
    query: str,
    tenant_id: str,
    opensearch: OpenSearch = Depends(get_opensearch_client)
):
    """Get search suggestions"""
    try:
        suggestion_body = {
            "suggest": {
                "content_suggest": {
                    "prefix": query,
                    "completion": {
                        "field": "suggest",
                        "size": 10
                    }
                }
            }
        }
        
        response = opensearch.search(
            index="content",
            body=suggestion_body
        )
        
        suggestions = []
        if 'suggest' in response and 'content_suggest' in response['suggest']:
            for option in response['suggest']['content_suggest'][0]['options']:
                suggestions.append(option['text'])
        
        return {"suggestions": suggestions}
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Suggestion failed: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Phase 3: Media Management

#### 3.1 Media Service
```python
# media-service/main.py
from fastapi import FastAPI, Depends, HTTPException, UploadFile, File
from fastapi.responses import StreamingResponse
import boto3
from botocore.exceptions import ClientError
import uuid
from typing import List
import io

app = FastAPI(title="Media Service", version="1.0.0")

# Initialize S3 client
s3_client = boto3.client('s3')
BUCKET_NAME = 'cms-media-storage'

@app.post("/upload")
async def upload_media(
    file: UploadFile = File(...),
    tenant_id: str = None,
    folder: str = "uploads"
):
    """Upload media file to S3"""
    try:
        # Generate unique filename
        file_extension = file.filename.split('.')[-1]
        file_key = f"{tenant_id}/{folder}/{uuid.uuid4()}.{file_extension}"
        
        # Upload to S3
        s3_client.upload_fileobj(
            file.file,
            BUCKET_NAME,
            file_key,
            ExtraArgs={
                'ContentType': file.content_type,
                'Metadata': {
                    'original_filename': file.filename,
                    'tenant_id': tenant_id
                }
            }
        )
        
        # Generate presigned URL for access
        presigned_url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': BUCKET_NAME, 'Key': file_key},
            ExpiresIn=3600
        )
        
        return {
            "file_id": str(uuid.uuid4()),
            "file_key": file_key,
            "filename": file.filename,
            "content_type": file.content_type,
            "size": file.size,
            "url": presigned_url
        }
        
    except ClientError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Upload failed: {str(e)}"
        )

@app.get("/media/{file_key}")
async def get_media(file_key: str):
    """Get media file from S3"""
    try:
        # Generate presigned URL
        presigned_url = s3_client.generate_presigned_url(
            'get_object',
            Params={'Bucket': BUCKET_NAME, 'Key': file_key},
            ExpiresIn=3600
        )
        
        return {"url": presigned_url}
        
    except ClientError as e:
        raise HTTPException(
            status_code=404,
            detail="File not found"
        )

@app.post("/media/{file_key}/process")
async def process_media(
    file_key: str,
    operations: List[str] = None
):
    """Process media file (resize, optimize, etc.)"""
    try:
        # This would typically trigger a Lambda function for processing
        # For now, we'll just return success
        
        return {
            "message": "Media processing started",
            "file_key": file_key,
            "operations": operations or []
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Processing failed: {str(e)}"
        )

@app.delete("/media/{file_key}")
async def delete_media(file_key: str):
    """Delete media file from S3"""
    try:
        s3_client.delete_object(Bucket=BUCKET_NAME, Key=file_key)
        
        return {"message": "File deleted successfully"}
        
    except ClientError as e:
        raise HTTPException(
            status_code=500,
            detail=f"Deletion failed: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

## Testing

### Unit Tests
```python
# tests/test_content_service.py
import pytest
from fastapi.testclient import TestClient
from content_service.main import app

client = TestClient(app)

def test_create_content():
    content_data = {
        "title": "Test Content",
        "body": "This is test content",
        "status": "draft"
    }
    
    response = client.post("/content", json=content_data)
    assert response.status_code == 201
    assert response.json()["title"] == content_data["title"]

def test_get_content():
    response = client.get("/content/test-id")
    assert response.status_code == 200
    assert "id" in response.json()

def test_search_content():
    search_data = {
        "query": "test",
        "tenant_id": "test-tenant"
    }
    
    response = client.post("/search", json=search_data)
    assert response.status_code == 200
    assert "results" in response.json()
```

## Deployment

### Kubernetes Configuration
```yaml
# k8s/content-service-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: content-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: content-service
  template:
    metadata:
      labels:
        app: content-service
    spec:
      containers:
      - name: content-service
        image: cms/content-service:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        - name: OPENSEARCH_URL
          valueFrom:
            secretKeyRef:
              name: opensearch-secret
              key: url
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
4. **Move to Project 4**: Continue with the next project
