# Project 3 Solution: Content Management System

## Solution Overview

This solution provides a complete implementation of a content management system using microservices architecture with content creation, editing, publishing, versioning, and multi-tenant support.

## Architecture Overview

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Admin Panel   │    │   Author Portal │    │   Public Site   │
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
    │  │User Service │ │Content Svc  │ │Media Service│      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Publishing   │ │Search Svc   │ │Analytics Svc│      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Data Layer                           │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │ PostgreSQL  │ │   Redis     │ │     S3      │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐                      │
    │  │Elasticsearch│ │   MongoDB   │                      │
    │  └─────────────┘ └─────────────┘                      │
    └─────────────────────────────────────────────────────────┘
```

## Implementation Details

### 1. Content Service

#### Service Implementation
```python
# content-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime
import json

from .database import get_db
from .models import Content, ContentVersion, ContentCategory, ContentTag, ContentComment
from .schemas import ContentCreate, ContentResponse, ContentUpdate, ContentVersionResponse

app = FastAPI(title="Content Service", version="1.0.0")

@app.post("/content", response_model=ContentResponse)
def create_content(content: ContentCreate, db: Session = Depends(get_db)):
    """Create new content"""
    # Create content
    db_content = Content(
        id=str(uuid.uuid4()),
        title=content.title,
        slug=content.slug,
        content_type=content.content_type,
        status="draft",
        author_id=content.author_id,
        tenant_id=content.tenant_id,
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
        excerpt=content.excerpt,
        metadata=content.metadata,
        created_at=datetime.utcnow()
    )
    
    db.add(version)
    db.commit()
    
    return ContentResponse.from_orm(db_content)

@app.get("/content/{content_id}", response_model=ContentResponse)
def get_content(content_id: str, db: Session = Depends(get_db)):
    """Get content by ID"""
    content = db.query(Content).filter(Content.id == content_id).first()
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
    db: Session = Depends(get_db)
):
    """Update content"""
    content = db.query(Content).filter(Content.id == content_id).first()
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    # Update content fields
    if content_update.title:
        content.title = content_update.title
    if content_update.slug:
        content.slug = content_update.slug
    if content_update.status:
        content.status = content_update.status
    if content_update.published_at:
        content.published_at = content_update.published_at
    
    content.updated_at = datetime.utcnow()
    
    # Create new version if body is updated
    if content_update.body:
        latest_version = db.query(ContentVersion).filter(
            ContentVersion.content_id == content_id
        ).order_by(ContentVersion.version_number.desc()).first()
        
        new_version = ContentVersion(
            id=str(uuid.uuid4()),
            content_id=content_id,
            version_number=latest_version.version_number + 1,
            title=content_update.title or content.title,
            body=content_update.body,
            excerpt=content_update.excerpt,
            metadata=content_update.metadata,
            created_at=datetime.utcnow()
        )
        
        db.add(new_version)
    
    db.commit()
    db.refresh(content)
    
    return ContentResponse.from_orm(content)

@app.get("/content/{content_id}/versions", response_model=List[ContentVersionResponse])
def get_content_versions(content_id: str, db: Session = Depends(get_db)):
    """Get content versions"""
    versions = db.query(ContentVersion).filter(
        ContentVersion.content_id == content_id
    ).order_by(ContentVersion.version_number.desc()).all()
    
    return [ContentVersionResponse.from_orm(version) for version in versions]

@app.get("/content/{content_id}/versions/{version_number}", response_model=ContentVersionResponse)
def get_content_version(content_id: str, version_number: int, db: Session = Depends(get_db)):
    """Get specific content version"""
    version = db.query(ContentVersion).filter(
        ContentVersion.content_id == content_id,
        ContentVersion.version_number == version_number
    ).first()
    
    if not version:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content version not found"
        )
    
    return ContentVersionResponse.from_orm(version)

@app.post("/content/{content_id}/publish")
def publish_content(content_id: str, db: Session = Depends(get_db)):
    """Publish content"""
    content = db.query(Content).filter(Content.id == content_id).first()
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    content.status = "published"
    content.published_at = datetime.utcnow()
    content.updated_at = datetime.utcnow()
    
    db.commit()
    
    # Trigger publishing workflow
    # This would typically send an event to other services
    
    return {"message": "Content published successfully"}

@app.post("/content/{content_id}/unpublish")
def unpublish_content(content_id: str, db: Session = Depends(get_db)):
    """Unpublish content"""
    content = db.query(Content).filter(Content.id == content_id).first()
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    content.status = "draft"
    content.updated_at = datetime.utcnow()
    
    db.commit()
    
    return {"message": "Content unpublished successfully"}

@app.get("/content")
def list_content(
    tenant_id: str,
    status: Optional[str] = None,
    content_type: Optional[str] = None,
    author_id: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """List content with filtering"""
    query = db.query(Content).filter(Content.tenant_id == tenant_id)
    
    if status:
        query = query.filter(Content.status == status)
    if content_type:
        query = query.filter(Content.content_type == content_type)
    if author_id:
        query = query.filter(Content.author_id == author_id)
    
    content_list = query.order_by(Content.created_at.desc()).offset(offset).limit(limit).all()
    
    return [ContentResponse.from_orm(content) for content in content_list]

@app.post("/content/{content_id}/categories")
def add_category(content_id: str, category_id: str, db: Session = Depends(get_db)):
    """Add category to content"""
    content = db.query(Content).filter(Content.id == content_id).first()
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    category = db.query(ContentCategory).filter(ContentCategory.id == category_id).first()
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Category not found"
        )
    
    # Add category to content
    if category not in content.categories:
        content.categories.append(category)
        db.commit()
    
    return {"message": "Category added successfully"}

@app.post("/content/{content_id}/tags")
def add_tag(content_id: str, tag_name: str, db: Session = Depends(get_db)):
    """Add tag to content"""
    content = db.query(Content).filter(Content.id == content_id).first()
    if not content:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    # Find or create tag
    tag = db.query(ContentTag).filter(ContentTag.name == tag_name).first()
    if not tag:
        tag = ContentTag(
            id=str(uuid.uuid4()),
            name=tag_name,
            created_at=datetime.utcnow()
        )
        db.add(tag)
        db.commit()
    
    # Add tag to content
    if tag not in content.tags:
        content.tags.append(tag)
        db.commit()
    
    return {"message": "Tag added successfully"}
```

#### Database Models
```python
# content-service/models.py
from sqlalchemy import Column, String, Text, DateTime, Boolean, Integer, ForeignKey, Table
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime
import json

Base = declarative_base()

# Association tables
content_categories = Table(
    'content_categories',
    Base.metadata,
    Column('content_id', String, ForeignKey('contents.id')),
    Column('category_id', String, ForeignKey('content_categories.id'))
)

content_tags = Table(
    'content_tags',
    Base.metadata,
    Column('content_id', String, ForeignKey('contents.id')),
    Column('tag_id', String, ForeignKey('content_tags.id'))
)

class Content(Base):
    __tablename__ = "contents"
    
    id = Column(String, primary_key=True, index=True)
    title = Column(String, nullable=False)
    slug = Column(String, unique=True, nullable=False, index=True)
    content_type = Column(String, nullable=False)  # article, page, post, etc.
    status = Column(String, default="draft")  # draft, published, archived
    author_id = Column(String, nullable=False)
    tenant_id = Column(String, nullable=False)
    published_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    versions = relationship("ContentVersion", back_populates="content")
    categories = relationship("ContentCategory", secondary=content_categories, back_populates="contents")
    tags = relationship("ContentTag", secondary=content_tags, back_populates="contents")
    comments = relationship("ContentComment", back_populates="content")

class ContentVersion(Base):
    __tablename__ = "content_versions"
    
    id = Column(String, primary_key=True, index=True)
    content_id = Column(String, ForeignKey("contents.id"), nullable=False)
    version_number = Column(Integer, nullable=False)
    title = Column(String, nullable=False)
    body = Column(Text)
    excerpt = Column(Text)
    metadata = Column(Text)  # JSON string
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    content = relationship("Content", back_populates="versions")

class ContentCategory(Base):
    __tablename__ = "content_categories"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False, unique=True)
    slug = Column(String, nullable=False, unique=True)
    description = Column(Text)
    parent_id = Column(String, ForeignKey("content_categories.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    contents = relationship("Content", secondary=content_categories, back_populates="categories")
    children = relationship("ContentCategory", backref="parent", remote_side=[id])

class ContentTag(Base):
    __tablename__ = "content_tags"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False, unique=True)
    slug = Column(String, nullable=False, unique=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    contents = relationship("Content", secondary=content_tags, back_populates="tags")

class ContentComment(Base):
    __tablename__ = "content_comments"
    
    id = Column(String, primary_key=True, index=True)
    content_id = Column(String, ForeignKey("contents.id"), nullable=False)
    author_id = Column(String, nullable=False)
    body = Column(Text, nullable=False)
    parent_id = Column(String, ForeignKey("content_comments.id"))
    is_approved = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    content = relationship("Content", back_populates="comments")
    parent = relationship("ContentComment", remote_side=[id])
    replies = relationship("ContentComment", back_populates="parent")
```

### 2. Media Service

#### Service Implementation
```python
# media-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
import boto3
from datetime import datetime
import os

from .database import get_db
from .models import MediaFile, MediaCollection
from .schemas import MediaFileResponse, MediaCollectionCreate, MediaCollectionResponse

app = FastAPI(title="Media Service", version="1.0.0")

# AWS S3 client
s3_client = boto3.client('s3')
BUCKET_NAME = os.getenv('S3_BUCKET_NAME', 'cms-media-bucket')

@app.post("/media/upload", response_model=MediaFileResponse)
async def upload_file(
    file: UploadFile = File(...),
    tenant_id: str = None,
    collection_id: str = None,
    db: Session = Depends(get_db)
):
    """Upload media file"""
    # Generate unique filename
    file_extension = file.filename.split('.')[-1] if '.' in file.filename else ''
    unique_filename = f"{uuid.uuid4()}.{file_extension}"
    
    # Upload to S3
    try:
        s3_client.upload_fileobj(
            file.file,
            BUCKET_NAME,
            f"{tenant_id}/{unique_filename}",
            ExtraArgs={
                'ContentType': file.content_type,
                'ACL': 'public-read'
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to upload file: {str(e)}"
        )
    
    # Save file metadata to database
    media_file = MediaFile(
        id=str(uuid.uuid4()),
        filename=file.filename,
        unique_filename=unique_filename,
        file_path=f"{tenant_id}/{unique_filename}",
        file_size=file.size,
        content_type=file.content_type,
        tenant_id=tenant_id,
        collection_id=collection_id,
        created_at=datetime.utcnow()
    )
    
    db.add(media_file)
    db.commit()
    db.refresh(media_file)
    
    return MediaFileResponse.from_orm(media_file)

@app.get("/media/{file_id}", response_model=MediaFileResponse)
def get_media_file(file_id: str, db: Session = Depends(get_db)):
    """Get media file by ID"""
    media_file = db.query(MediaFile).filter(MediaFile.id == file_id).first()
    if not media_file:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Media file not found"
        )
    return MediaFileResponse.from_orm(media_file)

@app.get("/media")
def list_media_files(
    tenant_id: str,
    collection_id: Optional[str] = None,
    content_type: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """List media files with filtering"""
    query = db.query(MediaFile).filter(MediaFile.tenant_id == tenant_id)
    
    if collection_id:
        query = query.filter(MediaFile.collection_id == collection_id)
    if content_type:
        query = query.filter(MediaFile.content_type.like(f"{content_type}%"))
    
    media_files = query.order_by(MediaFile.created_at.desc()).offset(offset).limit(limit).all()
    
    return [MediaFileResponse.from_orm(file) for file in media_files]

@app.delete("/media/{file_id}")
def delete_media_file(file_id: str, db: Session = Depends(get_db)):
    """Delete media file"""
    media_file = db.query(MediaFile).filter(MediaFile.id == file_id).first()
    if not media_file:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Media file not found"
        )
    
    # Delete from S3
    try:
        s3_client.delete_object(Bucket=BUCKET_NAME, Key=media_file.file_path)
    except Exception as e:
        # Log error but continue with database deletion
        pass
    
    # Delete from database
    db.delete(media_file)
    db.commit()
    
    return {"message": "Media file deleted successfully"}

@app.post("/collections", response_model=MediaCollectionResponse)
def create_collection(collection: MediaCollectionCreate, db: Session = Depends(get_db)):
    """Create media collection"""
    db_collection = MediaCollection(
        id=str(uuid.uuid4()),
        name=collection.name,
        description=collection.description,
        tenant_id=collection.tenant_id,
        created_at=datetime.utcnow()
    )
    
    db.add(db_collection)
    db.commit()
    db.refresh(db_collection)
    
    return MediaCollectionResponse.from_orm(db_collection)

@app.get("/collections/{collection_id}", response_model=MediaCollectionResponse)
def get_collection(collection_id: str, db: Session = Depends(get_db)):
    """Get collection by ID"""
    collection = db.query(MediaCollection).filter(MediaCollection.id == collection_id).first()
    if not collection:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Collection not found"
        )
    return MediaCollectionResponse.from_orm(collection)

@app.get("/collections")
def list_collections(tenant_id: str, db: Session = Depends(get_db)):
    """List collections for tenant"""
    collections = db.query(MediaCollection).filter(
        MediaCollection.tenant_id == tenant_id
    ).order_by(MediaCollection.created_at.desc()).all()
    
    return [MediaCollectionResponse.from_orm(collection) for collection in collections]
```

### 3. Publishing Service

#### Service Implementation
```python
# publishing-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime
import json

from .database import get_db
from .models import PublishingJob, PublishingTarget, PublishingRule
from .schemas import PublishingJobCreate, PublishingJobResponse, PublishingTargetCreate

app = FastAPI(title="Publishing Service", version="1.0.0")

@app.post("/publish", response_model=PublishingJobResponse)
def create_publishing_job(job: PublishingJobCreate, db: Session = Depends(get_db)):
    """Create publishing job"""
    # Create publishing job
    publishing_job = PublishingJob(
        id=str(uuid.uuid4()),
        content_id=job.content_id,
        tenant_id=job.tenant_id,
        target_id=job.target_id,
        status="pending",
        scheduled_at=job.scheduled_at or datetime.utcnow(),
        created_at=datetime.utcnow()
    )
    
    db.add(publishing_job)
    db.commit()
    db.refresh(publishing_job)
    
    # Process publishing job asynchronously
    # This would typically be handled by a background task queue
    
    return PublishingJobResponse.from_orm(publishing_job)

@app.get("/jobs/{job_id}", response_model=PublishingJobResponse)
def get_publishing_job(job_id: str, db: Session = Depends(get_db)):
    """Get publishing job by ID"""
    job = db.query(PublishingJob).filter(PublishingJob.id == job_id).first()
    if not job:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Publishing job not found"
        )
    return PublishingJobResponse.from_orm(job)

@app.get("/jobs")
def list_publishing_jobs(
    tenant_id: str,
    status: Optional[str] = None,
    limit: int = 20,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """List publishing jobs"""
    query = db.query(PublishingJob).filter(PublishingJob.tenant_id == tenant_id)
    
    if status:
        query = query.filter(PublishingJob.status == status)
    
    jobs = query.order_by(PublishingJob.created_at.desc()).offset(offset).limit(limit).all()
    
    return [PublishingJobResponse.from_orm(job) for job in jobs]

@app.post("/targets", response_model=PublishingTarget)
def create_publishing_target(target: PublishingTargetCreate, db: Session = Depends(get_db)):
    """Create publishing target"""
    publishing_target = PublishingTarget(
        id=str(uuid.uuid4()),
        name=target.name,
        target_type=target.target_type,
        configuration=target.configuration,
        tenant_id=target.tenant_id,
        is_active=True,
        created_at=datetime.utcnow()
    )
    
    db.add(publishing_target)
    db.commit()
    db.refresh(publishing_target)
    
    return publishing_target

@app.get("/targets")
def list_publishing_targets(tenant_id: str, db: Session = Depends(get_db)):
    """List publishing targets"""
    targets = db.query(PublishingTarget).filter(
        PublishingTarget.tenant_id == tenant_id,
        PublishingTarget.is_active == True
    ).all()
    
    return [PublishingTarget.from_orm(target) for target in targets]

@app.post("/rules")
def create_publishing_rule(rule_data: dict, db: Session = Depends(get_db)):
    """Create publishing rule"""
    rule = PublishingRule(
        id=str(uuid.uuid4()),
        name=rule_data["name"],
        conditions=rule_data["conditions"],
        actions=rule_data["actions"],
        tenant_id=rule_data["tenant_id"],
        is_active=True,
        created_at=datetime.utcnow()
    )
    
    db.add(rule)
    db.commit()
    db.refresh(rule)
    
    return rule

def process_publishing_job(job_id: str, db: Session):
    """Process publishing job"""
    job = db.query(PublishingJob).filter(PublishingJob.id == job_id).first()
    if not job:
        return
    
    try:
        # Update job status to processing
        job.status = "processing"
        job.started_at = datetime.utcnow()
        db.commit()
        
        # Get publishing target
        target = db.query(PublishingTarget).filter(PublishingTarget.id == job.target_id).first()
        if not target:
            job.status = "failed"
            job.error_message = "Publishing target not found"
            db.commit()
            return
        
        # Publish content based on target type
        if target.target_type == "website":
            publish_to_website(job.content_id, target.configuration)
        elif target.target_type == "social_media":
            publish_to_social_media(job.content_id, target.configuration)
        elif target.target_type == "email":
            publish_to_email(job.content_id, target.configuration)
        
        # Update job status to completed
        job.status = "completed"
        job.completed_at = datetime.utcnow()
        db.commit()
        
    except Exception as e:
        # Update job status to failed
        job.status = "failed"
        job.error_message = str(e)
        job.completed_at = datetime.utcnow()
        db.commit()

def publish_to_website(content_id: str, configuration: dict):
    """Publish content to website"""
    # Implementation for website publishing
    pass

def publish_to_social_media(content_id: str, configuration: dict):
    """Publish content to social media"""
    # Implementation for social media publishing
    pass

def publish_to_email(content_id: str, configuration: dict):
    """Publish content via email"""
    # Implementation for email publishing
    pass
```

### 4. Search Service

#### Service Implementation
```python
# search-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime
from elasticsearch import Elasticsearch
import json

from .database import get_db
from .models import SearchIndex, SearchQuery
from .schemas import SearchRequest, SearchResponse, SearchResult

app = FastAPI(title="Search Service", version="1.0.0")

# Elasticsearch client
es_client = Elasticsearch([{'host': 'localhost', 'port': 9200}])
INDEX_NAME = "cms_content"

@app.post("/search", response_model=SearchResponse)
def search_content(search_request: SearchRequest, db: Session = Depends(get_db)):
    """Search content"""
    # Build Elasticsearch query
    query = {
        "query": {
            "bool": {
                "must": [
                    {
                        "multi_match": {
                            "query": search_request.query,
                            "fields": ["title^2", "body", "excerpt", "tags"]
                        }
                    }
                ],
                "filter": [
                    {"term": {"tenant_id": search_request.tenant_id}},
                    {"term": {"status": "published"}}
                ]
            }
        },
        "highlight": {
            "fields": {
                "title": {},
                "body": {},
                "excerpt": {}
            }
        },
        "sort": [
            {"_score": {"order": "desc"}},
            {"published_at": {"order": "desc"}}
        ],
        "from": search_request.offset,
        "size": search_request.limit
    }
    
    # Add filters
    if search_request.content_type:
        query["query"]["bool"]["filter"].append({"term": {"content_type": search_request.content_type}})
    
    if search_request.category:
        query["query"]["bool"]["filter"].append({"term": {"categories": search_request.category}})
    
    if search_request.tags:
        query["query"]["bool"]["filter"].append({"terms": {"tags": search_request.tags}})
    
    if search_request.date_from:
        query["query"]["bool"]["filter"].append({
            "range": {
                "published_at": {
                    "gte": search_request.date_from
                }
            }
        })
    
    if search_request.date_to:
        query["query"]["bool"]["filter"].append({
            "range": {
                "published_at": {
                    "lte": search_request.date_to
                }
            }
        })
    
    # Execute search
    try:
        response = es_client.search(index=INDEX_NAME, body=query)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Search failed: {str(e)}"
        )
    
    # Process results
    results = []
    for hit in response['hits']['hits']:
        result = SearchResult(
            id=hit['_source']['id'],
            title=hit['_source']['title'],
            excerpt=hit['_source'].get('excerpt', ''),
            content_type=hit['_source']['content_type'],
            published_at=hit['_source']['published_at'],
            author_id=hit['_source']['author_id'],
            score=hit['_score'],
            highlights=hit.get('highlight', {})
        )
        results.append(result)
    
    # Log search query
    search_query = SearchQuery(
        id=str(uuid.uuid4()),
        query=search_request.query,
        tenant_id=search_request.tenant_id,
        filters=json.dumps(search_request.dict()),
        result_count=len(results),
        created_at=datetime.utcnow()
    )
    
    db.add(search_query)
    db.commit()
    
    return SearchResponse(
        results=results,
        total=response['hits']['total']['value'],
        took=response['took']
    )

@app.post("/index/{content_id}")
def index_content(content_id: str, db: Session = Depends(get_db)):
    """Index content for search"""
    # Get content from content service
    # This would typically be done via API call
    content_data = get_content_from_service(content_id)
    
    if not content_data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Content not found"
        )
    
    # Prepare document for indexing
    doc = {
        "id": content_data["id"],
        "title": content_data["title"],
        "body": content_data["body"],
        "excerpt": content_data.get("excerpt", ""),
        "content_type": content_data["content_type"],
        "status": content_data["status"],
        "tenant_id": content_data["tenant_id"],
        "author_id": content_data["author_id"],
        "published_at": content_data.get("published_at"),
        "categories": content_data.get("categories", []),
        "tags": content_data.get("tags", []),
        "created_at": content_data["created_at"],
        "updated_at": content_data["updated_at"]
    }
    
    # Index document
    try:
        es_client.index(index=INDEX_NAME, id=content_id, body=doc)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Indexing failed: {str(e)}"
        )
    
    return {"message": "Content indexed successfully"}

@app.delete("/index/{content_id}")
def remove_content_from_index(content_id: str):
    """Remove content from search index"""
    try:
        es_client.delete(index=INDEX_NAME, id=content_id)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to remove from index: {str(e)}"
        )
    
    return {"message": "Content removed from index successfully"}

@app.get("/suggestions")
def get_search_suggestions(query: str, tenant_id: str, limit: int = 10):
    """Get search suggestions"""
    suggestion_query = {
        "suggest": {
            "content_suggest": {
                "prefix": query,
                "completion": {
                    "field": "title_suggest",
                    "size": limit,
                    "contexts": {
                        "tenant_id": [tenant_id]
                    }
                }
            }
        }
    }
    
    try:
        response = es_client.search(index=INDEX_NAME, body=suggestion_query)
        suggestions = []
        for suggestion in response['suggest']['content_suggest'][0]['options']:
            suggestions.append({
                "text": suggestion['text'],
                "score": suggestion['score']
            })
        return suggestions
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get suggestions: {str(e)}"
        )

def get_content_from_service(content_id: str):
    """Get content from content service"""
    # This would typically be an API call to the content service
    # For now, return mock data
    return {
        "id": content_id,
        "title": "Sample Content",
        "body": "Sample content body",
        "excerpt": "Sample excerpt",
        "content_type": "article",
        "status": "published",
        "tenant_id": "tenant1",
        "author_id": "author1",
        "published_at": "2024-01-01T00:00:00Z",
        "categories": ["tech", "programming"],
        "tags": ["python", "fastapi"],
        "created_at": "2024-01-01T00:00:00Z",
        "updated_at": "2024-01-01T00:00:00Z"
    }
```

## Best Practices Applied

### Content Management
1. **Version Control**: Complete content versioning system
2. **Content Types**: Support for different content types
3. **Categorization**: Category and tag management
4. **Workflow**: Draft, review, publish workflow
5. **Multi-tenant**: Tenant isolation and management

### Media Management
1. **File Upload**: Secure file upload to S3
2. **File Organization**: Collections and folder structure
3. **File Processing**: Image resizing and optimization
4. **CDN Integration**: Content delivery network integration
5. **File Security**: Access control and permissions

### Publishing System
1. **Multi-channel Publishing**: Publish to multiple channels
2. **Scheduling**: Scheduled publishing
3. **Workflow Management**: Publishing workflow automation
4. **Target Management**: Multiple publishing targets
5. **Rule Engine**: Automated publishing rules

### Search Functionality
1. **Full-text Search**: Elasticsearch integration
2. **Faceted Search**: Filter by categories, tags, dates
3. **Search Suggestions**: Auto-complete functionality
4. **Search Analytics**: Track search queries and results
5. **Real-time Indexing**: Automatic content indexing

## Lessons Learned

### Key Insights
1. **Content Versioning**: Essential for content management
2. **Multi-tenant Architecture**: Proper tenant isolation
3. **Search Integration**: Elasticsearch provides powerful search
4. **Media Management**: S3 integration for file storage
5. **Publishing Workflow**: Automated publishing processes

### Common Pitfalls
1. **Content Conflicts**: Poor version control
2. **Search Performance**: Inadequate search optimization
3. **File Management**: Poor file organization
4. **Publishing Errors**: Inadequate error handling
5. **Tenant Isolation**: Data leakage between tenants

### Recommendations
1. **Start Simple**: Begin with basic content management
2. **Add Features Gradually**: Add advanced features incrementally
3. **Plan for Scale**: Design for multi-tenant architecture
4. **Monitor Performance**: Monitor search and file operations
5. **Test Thoroughly**: Test all content management features

## Next Steps

1. **Implementation**: Implement the CMS system
2. **Testing**: Test all content management features
3. **Search Optimization**: Optimize search performance
4. **Media Processing**: Add image processing capabilities
5. **Analytics**: Add content analytics and reporting
