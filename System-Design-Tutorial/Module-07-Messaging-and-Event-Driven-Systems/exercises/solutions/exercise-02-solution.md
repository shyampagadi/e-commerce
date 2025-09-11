# Exercise 02 Solution: Event-Driven Microservices Architecture

## Solution Overview
This solution implements a comprehensive event-driven microservices architecture for the social media platform using AWS services with proper service isolation, event choreography, and resilience patterns.

## Architecture Solution

### System Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Service  │───▶│   EventBridge    │───▶│  Post Service   │
│   (User Mgmt)   │    │  (Event Router)  │    │ (Content Mgmt)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Notification  │◀───│   SNS Topics     │◀───│ Analytics       │
│    Service      │    │ (Fan-out Msgs)  │    │  Service        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Timeline      │    │   SQS Queues     │    │   Search        │
│   Service       │    │ (Async Processing│    │   Service       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Implementation Solution

### 1. Event Schema Design
```python
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, Any, Optional
import json
import uuid

@dataclass
class BaseEvent:
    event_id: str
    event_type: str
    timestamp: datetime
    source_service: str
    correlation_id: str
    version: str = "1.0"
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'eventId': self.event_id,
            'eventType': self.event_type,
            'timestamp': self.timestamp.isoformat(),
            'sourceService': self.source_service,
            'correlationId': self.correlation_id,
            'version': self.version
        }

@dataclass
class UserRegisteredEvent(BaseEvent):
    user_id: str
    username: str
    email: str
    profile_data: Dict[str, Any]
    
    def __post_init__(self):
        self.event_type = "UserRegistered"
    
    def to_dict(self) -> Dict[str, Any]:
        base_dict = super().to_dict()
        base_dict['data'] = {
            'userId': self.user_id,
            'username': self.username,
            'email': self.email,
            'profileData': self.profile_data
        }
        return base_dict

@dataclass
class PostCreatedEvent(BaseEvent):
    post_id: str
    user_id: str
    content: str
    media_urls: list
    tags: list
    
    def __post_init__(self):
        self.event_type = "PostCreated"
    
    def to_dict(self) -> Dict[str, Any]:
        base_dict = super().to_dict()
        base_dict['data'] = {
            'postId': self.post_id,
            'userId': self.user_id,
            'content': self.content,
            'mediaUrls': self.media_urls,
            'tags': self.tags
        }
        return base_dict

@dataclass
class UserFollowedEvent(BaseEvent):
    follower_id: str
    followed_id: str
    
    def __post_init__(self):
        self.event_type = "UserFollowed"
    
    def to_dict(self) -> Dict[str, Any]:
        base_dict = super().to_dict()
        base_dict['data'] = {
            'followerId': self.follower_id,
            'followedId': self.followed_id
        }
        return base_dict
```

### 2. Event Publisher Service
```python
import boto3
import json
from typing import List
from datetime import datetime

class EventPublisher:
    def __init__(self, event_bus_name: str = 'social-media-events'):
        self.eventbridge = boto3.client('events')
        self.event_bus_name = event_bus_name
        
    def publish_event(self, event: BaseEvent) -> bool:
        """Publish single event to EventBridge"""
        try:
            response = self.eventbridge.put_events(
                Entries=[
                    {
                        'Source': event.source_service,
                        'DetailType': event.event_type,
                        'Detail': json.dumps(event.to_dict()),
                        'EventBusName': self.event_bus_name,
                        'Time': event.timestamp
                    }
                ]
            )
            
            # Check for failures
            if response['FailedEntryCount'] > 0:
                print(f"Failed to publish event: {response['Entries'][0]}")
                return False
                
            print(f"Successfully published event: {event.event_id}")
            return True
            
        except Exception as e:
            print(f"Error publishing event: {str(e)}")
            return False
    
    def publish_events_batch(self, events: List[BaseEvent]) -> Dict[str, int]:
        """Publish multiple events in batch (up to 10)"""
        entries = []
        
        for event in events[:10]:  # EventBridge batch limit
            entries.append({
                'Source': event.source_service,
                'DetailType': event.event_type,
                'Detail': json.dumps(event.to_dict()),
                'EventBusName': self.event_bus_name,
                'Time': event.timestamp
            })
        
        try:
            response = self.eventbridge.put_events(Entries=entries)
            
            return {
                'successful': len(entries) - response['FailedEntryCount'],
                'failed': response['FailedEntryCount']
            }
            
        except Exception as e:
            print(f"Error publishing batch events: {str(e)}")
            return {'successful': 0, 'failed': len(entries)}
```

### 3. User Service Implementation
```python
import boto3
from datetime import datetime
import uuid

class UserService:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.users_table = self.dynamodb.Table('users')
        self.event_publisher = EventPublisher()
        
    def register_user(self, username: str, email: str, profile_data: Dict[str, Any]) -> str:
        """Register new user and publish event"""
        try:
            user_id = str(uuid.uuid4())
            
            # Store user in database
            self.users_table.put_item(
                Item={
                    'user_id': user_id,
                    'username': username,
                    'email': email,
                    'profile_data': profile_data,
                    'created_at': datetime.utcnow().isoformat(),
                    'followers_count': 0,
                    'following_count': 0,
                    'posts_count': 0
                }
            )
            
            # Publish UserRegistered event
            event = UserRegisteredEvent(
                event_id=str(uuid.uuid4()),
                timestamp=datetime.utcnow(),
                source_service='user-service',
                correlation_id=str(uuid.uuid4()),
                user_id=user_id,
                username=username,
                email=email,
                profile_data=profile_data
            )
            
            self.event_publisher.publish_event(event)
            
            return user_id
            
        except Exception as e:
            print(f"Error registering user: {str(e)}")
            raise
    
    def follow_user(self, follower_id: str, followed_id: str) -> bool:
        """Follow user and publish event"""
        try:
            # Update follower relationships
            self.users_table.update_item(
                Key={'user_id': follower_id},
                UpdateExpression='ADD following_count :inc',
                ExpressionAttributeValues={':inc': 1}
            )
            
            self.users_table.update_item(
                Key={'user_id': followed_id},
                UpdateExpression='ADD followers_count :inc',
                ExpressionAttributeValues={':inc': 1}
            )
            
            # Store relationship
            relationships_table = self.dynamodb.Table('user_relationships')
            relationships_table.put_item(
                Item={
                    'follower_id': follower_id,
                    'followed_id': followed_id,
                    'created_at': datetime.utcnow().isoformat()
                }
            )
            
            # Publish UserFollowed event
            event = UserFollowedEvent(
                event_id=str(uuid.uuid4()),
                timestamp=datetime.utcnow(),
                source_service='user-service',
                correlation_id=str(uuid.uuid4()),
                follower_id=follower_id,
                followed_id=followed_id
            )
            
            self.event_publisher.publish_event(event)
            
            return True
            
        except Exception as e:
            print(f"Error following user: {str(e)}")
            return False
```

### 4. Post Service Implementation
```python
class PostService:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.posts_table = self.dynamodb.Table('posts')
        self.event_publisher = EventPublisher()
        
    def create_post(self, user_id: str, content: str, media_urls: List[str] = None, 
                   tags: List[str] = None) -> str:
        """Create new post and publish event"""
        try:
            post_id = str(uuid.uuid4())
            media_urls = media_urls or []
            tags = tags or []
            
            # Store post in database
            self.posts_table.put_item(
                Item={
                    'post_id': post_id,
                    'user_id': user_id,
                    'content': content,
                    'media_urls': media_urls,
                    'tags': tags,
                    'created_at': datetime.utcnow().isoformat(),
                    'likes_count': 0,
                    'comments_count': 0,
                    'shares_count': 0
                }
            )
            
            # Update user's post count
            users_table = self.dynamodb.Table('users')
            users_table.update_item(
                Key={'user_id': user_id},
                UpdateExpression='ADD posts_count :inc',
                ExpressionAttributeValues={':inc': 1}
            )
            
            # Publish PostCreated event
            event = PostCreatedEvent(
                event_id=str(uuid.uuid4()),
                timestamp=datetime.utcnow(),
                source_service='post-service',
                correlation_id=str(uuid.uuid4()),
                post_id=post_id,
                user_id=user_id,
                content=content,
                media_urls=media_urls,
                tags=tags
            )
            
            self.event_publisher.publish_event(event)
            
            return post_id
            
        except Exception as e:
            print(f"Error creating post: {str(e)}")
            raise
    
    def get_user_posts(self, user_id: str, limit: int = 20) -> List[Dict]:
        """Get posts by user"""
        try:
            response = self.posts_table.query(
                IndexName='user-id-created-at-index',
                KeyConditionExpression='user_id = :user_id',
                ExpressionAttributeValues={':user_id': user_id},
                ScanIndexForward=False,  # Latest first
                Limit=limit
            )
            
            return response['Items']
            
        except Exception as e:
            print(f"Error getting user posts: {str(e)}")
            return []
```

### 5. Timeline Service Implementation
```python
class TimelineService:
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.timelines_table = self.dynamodb.Table('user_timelines')
        self.sqs = boto3.client('sqs')
        self.queue_url = 'https://sqs.us-east-1.amazonaws.com/123456789012/timeline-updates'
        
    def handle_post_created_event(self, event_data: Dict[str, Any]):
        """Handle PostCreated event to update follower timelines"""
        try:
            post_id = event_data['data']['postId']
            user_id = event_data['data']['userId']
            
            # Get user's followers
            followers = self._get_user_followers(user_id)
            
            # Add post to each follower's timeline
            for follower_id in followers:
                self._add_to_timeline(follower_id, post_id, event_data['timestamp'])
            
            print(f"Updated timelines for {len(followers)} followers")
            
        except Exception as e:
            print(f"Error handling PostCreated event: {str(e)}")
    
    def handle_user_followed_event(self, event_data: Dict[str, Any]):
        """Handle UserFollowed event to populate timeline with recent posts"""
        try:
            follower_id = event_data['data']['followerId']
            followed_id = event_data['data']['followedId']
            
            # Get recent posts from followed user
            post_service = PostService()
            recent_posts = post_service.get_user_posts(followed_id, limit=50)
            
            # Add recent posts to follower's timeline
            for post in recent_posts:
                self._add_to_timeline(follower_id, post['post_id'], post['created_at'])
            
            print(f"Added {len(recent_posts)} posts to timeline for user {follower_id}")
            
        except Exception as e:
            print(f"Error handling UserFollowed event: {str(e)}")
    
    def _get_user_followers(self, user_id: str) -> List[str]:
        """Get list of user's followers"""
        try:
            relationships_table = self.dynamodb.Table('user_relationships')
            response = relationships_table.query(
                IndexName='followed-id-index',
                KeyConditionExpression='followed_id = :user_id',
                ExpressionAttributeValues={':user_id': user_id}
            )
            
            return [item['follower_id'] for item in response['Items']]
            
        except Exception as e:
            print(f"Error getting followers: {str(e)}")
            return []
    
    def _add_to_timeline(self, user_id: str, post_id: str, timestamp: str):
        """Add post to user's timeline"""
        try:
            self.timelines_table.put_item(
                Item={
                    'user_id': user_id,
                    'post_id': post_id,
                    'timestamp': timestamp,
                    'added_at': datetime.utcnow().isoformat()
                }
            )
            
        except Exception as e:
            print(f"Error adding to timeline: {str(e)}")
    
    def get_user_timeline(self, user_id: str, limit: int = 20) -> List[Dict]:
        """Get user's timeline"""
        try:
            response = self.timelines_table.query(
                KeyConditionExpression='user_id = :user_id',
                ExpressionAttributeValues={':user_id': user_id},
                ScanIndexForward=False,  # Latest first
                Limit=limit
            )
            
            return response['Items']
            
        except Exception as e:
            print(f"Error getting timeline: {str(e)}")
            return []
```

### 6. Notification Service Implementation
```python
class NotificationService:
    def __init__(self):
        self.sns = boto3.client('sns')
        self.ses = boto3.client('ses')
        self.dynamodb = boto3.resource('dynamodb')
        self.notifications_table = self.dynamodb.Table('notifications')
        
    def handle_user_followed_event(self, event_data: Dict[str, Any]):
        """Send notification when user is followed"""
        try:
            follower_id = event_data['data']['followerId']
            followed_id = event_data['data']['followedId']
            
            # Get user details
            follower_info = self._get_user_info(follower_id)
            followed_info = self._get_user_info(followed_id)
            
            # Create notification
            notification = {
                'notification_id': str(uuid.uuid4()),
                'user_id': followed_id,
                'type': 'new_follower',
                'title': 'New Follower',
                'message': f'{follower_info["username"]} started following you',
                'data': {
                    'follower_id': follower_id,
                    'follower_username': follower_info['username']
                },
                'created_at': datetime.utcnow().isoformat(),
                'read': False
            }
            
            # Store notification
            self.notifications_table.put_item(Item=notification)
            
            # Send push notification
            self._send_push_notification(followed_info, notification)
            
            # Send email if user has email notifications enabled
            if followed_info.get('email_notifications', True):
                self._send_email_notification(followed_info, notification)
            
        except Exception as e:
            print(f"Error handling UserFollowed event: {str(e)}")
    
    def handle_post_created_event(self, event_data: Dict[str, Any]):
        """Send notifications to followers when user creates post"""
        try:
            user_id = event_data['data']['userId']
            post_id = event_data['data']['postId']
            
            # Get user info
            user_info = self._get_user_info(user_id)
            
            # Get followers who have post notifications enabled
            followers = self._get_notification_enabled_followers(user_id)
            
            # Send notifications to followers
            for follower_id in followers:
                follower_info = self._get_user_info(follower_id)
                
                notification = {
                    'notification_id': str(uuid.uuid4()),
                    'user_id': follower_id,
                    'type': 'new_post',
                    'title': 'New Post',
                    'message': f'{user_info["username"]} shared a new post',
                    'data': {
                        'post_id': post_id,
                        'author_id': user_id,
                        'author_username': user_info['username']
                    },
                    'created_at': datetime.utcnow().isoformat(),
                    'read': False
                }
                
                # Store notification
                self.notifications_table.put_item(Item=notification)
                
                # Send push notification
                self._send_push_notification(follower_info, notification)
            
        except Exception as e:
            print(f"Error handling PostCreated event: {str(e)}")
    
    def _get_user_info(self, user_id: str) -> Dict[str, Any]:
        """Get user information"""
        try:
            users_table = self.dynamodb.Table('users')
            response = users_table.get_item(Key={'user_id': user_id})
            return response.get('Item', {})
            
        except Exception as e:
            print(f"Error getting user info: {str(e)}")
            return {}
    
    def _get_notification_enabled_followers(self, user_id: str) -> List[str]:
        """Get followers who have notifications enabled"""
        # Implementation would check user preferences
        # For now, return all followers
        timeline_service = TimelineService()
        return timeline_service._get_user_followers(user_id)
    
    def _send_push_notification(self, user_info: Dict, notification: Dict):
        """Send push notification via SNS"""
        try:
            if 'device_token' in user_info:
                message = {
                    'default': notification['message'],
                    'GCM': json.dumps({
                        'data': {
                            'title': notification['title'],
                            'body': notification['message'],
                            'notification_id': notification['notification_id']
                        }
                    })
                }
                
                self.sns.publish(
                    TargetArn=user_info['device_token'],
                    Message=json.dumps(message),
                    MessageStructure='json'
                )
                
        except Exception as e:
            print(f"Error sending push notification: {str(e)}")
    
    def _send_email_notification(self, user_info: Dict, notification: Dict):
        """Send email notification via SES"""
        try:
            if 'email' in user_info:
                self.ses.send_email(
                    Source='notifications@socialmedia.com',
                    Destination={'ToAddresses': [user_info['email']]},
                    Message={
                        'Subject': {'Data': notification['title']},
                        'Body': {
                            'Text': {'Data': notification['message']},
                            'Html': {'Data': f'<p>{notification["message"]}</p>'}
                        }
                    }
                )
                
        except Exception as e:
            print(f"Error sending email notification: {str(e)}")
```

### 7. Event Handler Lambda Functions
```python
import json
import boto3
from typing import Dict, Any

def timeline_event_handler(event, context):
    """Lambda function to handle timeline updates"""
    timeline_service = TimelineService()
    
    for record in event['Records']:
        # Parse EventBridge event
        detail = json.loads(record['body'])
        event_type = detail['detail-type']
        event_data = detail['detail']
        
        if event_type == 'PostCreated':
            timeline_service.handle_post_created_event(event_data)
        elif event_type == 'UserFollowed':
            timeline_service.handle_user_followed_event(event_data)
    
    return {'statusCode': 200}

def notification_event_handler(event, context):
    """Lambda function to handle notifications"""
    notification_service = NotificationService()
    
    for record in event['Records']:
        # Parse EventBridge event
        detail = json.loads(record['body'])
        event_type = detail['detail-type']
        event_data = detail['detail']
        
        if event_type == 'UserFollowed':
            notification_service.handle_user_followed_event(event_data)
        elif event_type == 'PostCreated':
            notification_service.handle_post_created_event(event_data)
    
    return {'statusCode': 200}
```

### 8. Infrastructure as Code (CDK)
```python
from aws_cdk import (
    Stack,
    aws_events as events,
    aws_events_targets as targets,
    aws_lambda as _lambda,
    aws_sqs as sqs,
    aws_dynamodb as dynamodb,
    Duration
)

class SocialMediaEventStack(Stack):
    def __init__(self, scope, construct_id, **kwargs):
        super().__init__(scope, construct_id, **kwargs)
        
        # EventBridge custom bus
        event_bus = events.EventBus(
            self, "SocialMediaEventBus",
            event_bus_name="social-media-events"
        )
        
        # DynamoDB tables
        users_table = dynamodb.Table(
            self, "UsersTable",
            table_name="users",
            partition_key=dynamodb.Attribute(
                name="user_id",
                type=dynamodb.AttributeType.STRING
            ),
            billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST
        )
        
        # SQS queues for event processing
        timeline_queue = sqs.Queue(
            self, "TimelineQueue",
            queue_name="timeline-updates",
            visibility_timeout=Duration.minutes(5)
        )
        
        notification_queue = sqs.Queue(
            self, "NotificationQueue",
            queue_name="notification-updates",
            visibility_timeout=Duration.minutes(5)
        )
        
        # Lambda functions
        timeline_handler = _lambda.Function(
            self, "TimelineHandler",
            runtime=_lambda.Runtime.PYTHON_3_9,
            handler="timeline_handler.timeline_event_handler",
            code=_lambda.Code.from_asset("lambda"),
            timeout=Duration.minutes(5)
        )
        
        # EventBridge rules
        post_created_rule = events.Rule(
            self, "PostCreatedRule",
            event_bus=event_bus,
            event_pattern=events.EventPattern(
                source=["post-service"],
                detail_type=["PostCreated"]
            )
        )
        
        post_created_rule.add_target(
            targets.SqsQueue(timeline_queue)
        )
        
        # Grant permissions
        users_table.grant_read_write_data(timeline_handler)
        timeline_queue.grant_consume_messages(timeline_handler)
```

## Performance Optimization

### 1. Event Processing Optimization
- Use SQS batch processing (up to 10 messages)
- Implement parallel processing with multiple Lambda instances
- Use DynamoDB batch operations for bulk updates

### 2. Timeline Generation Strategy
- **Push Model**: Update timelines when posts are created (current implementation)
- **Pull Model**: Generate timeline on-demand from followed users' posts
- **Hybrid Model**: Push for active users, pull for inactive users

### 3. Caching Strategy
```python
import redis

class CacheManager:
    def __init__(self):
        self.redis_client = redis.Redis(
            host='social-media-cache.abc123.cache.amazonaws.com',
            port=6379,
            decode_responses=True
        )
    
    def cache_timeline(self, user_id: str, timeline_data: List[Dict], ttl: int = 300):
        """Cache user timeline for 5 minutes"""
        cache_key = f"timeline:{user_id}"
        self.redis_client.setex(
            cache_key,
            ttl,
            json.dumps(timeline_data)
        )
    
    def get_cached_timeline(self, user_id: str) -> Optional[List[Dict]]:
        """Get cached timeline"""
        cache_key = f"timeline:{user_id}"
        cached_data = self.redis_client.get(cache_key)
        
        if cached_data:
            return json.loads(cached_data)
        return None
```

This solution provides a scalable, resilient event-driven microservices architecture that can handle millions of users with proper separation of concerns and fault tolerance.
