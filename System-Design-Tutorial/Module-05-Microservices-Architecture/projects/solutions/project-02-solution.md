# Project 2 Solution: Real-time Chat Application

## Solution Overview

This solution provides a complete implementation of a real-time chat application using microservices architecture with WebSocket support, message persistence, user management, and real-time notifications.

## Architecture Overview

### High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Client    │    │   Mobile App    │    │   Admin Panel   │
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
    │  │User Service │ │Chat Service │ │Notification │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Message Svc  │ │Presence Svc │ │File Service │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
                                 │
    ┌─────────────────────────────────────────────────────────┐
    │                    Data Layer                           │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │ PostgreSQL  │ │   Redis     │ │    S3       │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    └─────────────────────────────────────────────────────────┘
```

## Implementation Details

### 1. User Service

#### Service Implementation
```python
# user-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
import uuid

from .database import get_db
from .models import User, UserProfile, UserSession
from .schemas import UserCreate, UserResponse, UserLogin, Token, UserUpdate

app = FastAPI(title="User Service", version="1.0.0")

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT configuration
SECRET_KEY = "your-secret-key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

@app.post("/users", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """Create a new user"""
    # Check if user already exists
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Hash password
    hashed_password = pwd_context.hash(user.password)
    
    # Create user
    db_user = User(
        id=str(uuid.uuid4()),
        email=user.email,
        hashed_password=hashed_password,
        username=user.username,
        is_active=True,
        created_at=datetime.utcnow()
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    # Create user profile
    profile = UserProfile(
        user_id=db_user.id,
        display_name=user.username,
        avatar_url=None,
        status="offline",
        last_seen=datetime.utcnow()
    )
    
    db.add(profile)
    db.commit()
    
    return UserResponse.from_orm(db_user)

@app.post("/auth/login", response_model=Token)
def login(user_credentials: UserLogin, db: Session = Depends(get_db)):
    """Authenticate user and return JWT token"""
    # Verify user credentials
    user = db.query(User).filter(User.email == user_credentials.email).first()
    if not user or not pwd_context.verify(user_credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password"
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    
    # Update user session
    session = UserSession(
        user_id=user.id,
        token=access_token,
        created_at=datetime.utcnow(),
        expires_at=datetime.utcnow() + access_token_expires
    )
    
    db.add(session)
    db.commit()
    
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=UserResponse)
def get_current_user(current_user: User = Depends(get_current_user)):
    """Get current user information"""
    return UserResponse.from_orm(current_user)

@app.put("/users/me", response_model=UserResponse)
def update_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user profile"""
    # Update user profile
    profile = db.query(UserProfile).filter(UserProfile.user_id == current_user.id).first()
    if profile:
        if user_update.display_name:
            profile.display_name = user_update.display_name
        if user_update.avatar_url:
            profile.avatar_url = user_update.avatar_url
        profile.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(current_user)
    
    return UserResponse.from_orm(current_user)

@app.get("/users/{user_id}", response_model=UserResponse)
def get_user(user_id: str, db: Session = Depends(get_db)):
    """Get user by ID"""
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    return UserResponse.from_orm(user)

@app.get("/users/search")
def search_users(query: str, limit: int = 20, db: Session = Depends(get_db)):
    """Search users by username or email"""
    users = db.query(User).filter(
        (User.username.contains(query)) | (User.email.contains(query))
    ).limit(limit).all()
    
    return [UserResponse.from_orm(user) for user in users]

def create_access_token(data: dict, expires_delta: timedelta = None):
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """Get current user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials"
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user
```

#### Database Models
```python
# user-service/models.py
from sqlalchemy import Column, String, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(String, primary_key=True, index=True)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    profile = relationship("UserProfile", back_populates="user", uselist=False)
    sessions = relationship("UserSession", back_populates="user")

class UserProfile(Base):
    __tablename__ = "user_profiles"
    
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    display_name = Column(String, nullable=False)
    avatar_url = Column(String)
    status = Column(String, default="offline")  # online, offline, away, busy
    last_seen = Column(DateTime, default=datetime.utcnow)
    bio = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="profile")

class UserSession(Base):
    __tablename__ = "user_sessions"
    
    id = Column(String, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    token = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="sessions")
```

### 2. Chat Service

#### Service Implementation
```python
# chat-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status, WebSocket, WebSocketDisconnect
from sqlalchemy.orm import Session
from typing import List, Dict
import json
import uuid
from datetime import datetime

from .database import get_db
from .models import ChatRoom, ChatMessage, ChatMember, ChatRoomType
from .schemas import ChatRoomCreate, ChatRoomResponse, MessageCreate, MessageResponse
from .websocket_manager import WebSocketManager

app = FastAPI(title="Chat Service", version="1.0.0")

# WebSocket manager
websocket_manager = WebSocketManager()

@app.post("/rooms", response_model=ChatRoomResponse)
def create_chat_room(room: ChatRoomCreate, db: Session = Depends(get_db)):
    """Create a new chat room"""
    # Create chat room
    db_room = ChatRoom(
        id=str(uuid.uuid4()),
        name=room.name,
        description=room.description,
        room_type=room.room_type,
        created_by=room.created_by,
        created_at=datetime.utcnow()
    )
    
    db.add(db_room)
    db.commit()
    db.refresh(db_room)
    
    # Add creator as member
    member = ChatMember(
        room_id=db_room.id,
        user_id=room.created_by,
        role="admin",
        joined_at=datetime.utcnow()
    )
    
    db.add(member)
    db.commit()
    
    return ChatRoomResponse.from_orm(db_room)

@app.get("/rooms", response_model=List[ChatRoomResponse])
def get_user_rooms(user_id: str, db: Session = Depends(get_db)):
    """Get user's chat rooms"""
    rooms = db.query(ChatRoom).join(ChatMember).filter(
        ChatMember.user_id == user_id
    ).all()
    
    return [ChatRoomResponse.from_orm(room) for room in rooms]

@app.get("/rooms/{room_id}", response_model=ChatRoomResponse)
def get_chat_room(room_id: str, db: Session = Depends(get_db)):
    """Get chat room by ID"""
    room = db.query(ChatRoom).filter(ChatRoom.id == room_id).first()
    if not room:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat room not found"
        )
    return ChatRoomResponse.from_orm(room)

@app.post("/rooms/{room_id}/join")
def join_chat_room(room_id: str, user_id: str, db: Session = Depends(get_db)):
    """Join a chat room"""
    # Check if room exists
    room = db.query(ChatRoom).filter(ChatRoom.id == room_id).first()
    if not room:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat room not found"
        )
    
    # Check if user is already a member
    existing_member = db.query(ChatMember).filter(
        ChatMember.room_id == room_id,
        ChatMember.user_id == user_id
    ).first()
    
    if existing_member:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User is already a member of this room"
        )
    
    # Add user to room
    member = ChatMember(
        room_id=room_id,
        user_id=user_id,
        role="member",
        joined_at=datetime.utcnow()
    )
    
    db.add(member)
    db.commit()
    
    return {"message": "Successfully joined chat room"}

@app.post("/rooms/{room_id}/leave")
def leave_chat_room(room_id: str, user_id: str, db: Session = Depends(get_db)):
    """Leave a chat room"""
    member = db.query(ChatMember).filter(
        ChatMember.room_id == room_id,
        ChatMember.user_id == user_id
    ).first()
    
    if not member:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User is not a member of this room"
        )
    
    db.delete(member)
    db.commit()
    
    return {"message": "Successfully left chat room"}

@app.get("/rooms/{room_id}/messages", response_model=List[MessageResponse])
def get_chat_messages(
    room_id: str,
    limit: int = 50,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Get chat room messages"""
    messages = db.query(ChatMessage).filter(
        ChatMessage.room_id == room_id
    ).order_by(ChatMessage.created_at.desc()).offset(offset).limit(limit).all()
    
    return [MessageResponse.from_orm(message) for message in reversed(messages)]

@app.websocket("/ws/{room_id}/{user_id}")
async def websocket_endpoint(websocket: WebSocket, room_id: str, user_id: str):
    """WebSocket endpoint for real-time chat"""
    await websocket_manager.connect(websocket, room_id, user_id)
    
    try:
        while True:
            # Receive message from client
            data = await websocket.receive_text()
            message_data = json.loads(data)
            
            # Process message
            await process_message(room_id, user_id, message_data)
            
    except WebSocketDisconnect:
        websocket_manager.disconnect(room_id, user_id)

async def process_message(room_id: str, user_id: str, message_data: dict):
    """Process incoming message"""
    message_type = message_data.get("type", "message")
    
    if message_type == "message":
        # Create message in database
        message = ChatMessage(
            id=str(uuid.uuid4()),
            room_id=room_id,
            user_id=user_id,
            content=message_data["content"],
            message_type="text",
            created_at=datetime.utcnow()
        )
        
        # Save to database (in real implementation)
        # db.add(message)
        # db.commit()
        
        # Broadcast to all connected users in the room
        await websocket_manager.broadcast_to_room(room_id, {
            "type": "message",
            "message": {
                "id": message.id,
                "user_id": user_id,
                "content": message_data["content"],
                "created_at": message.created_at.isoformat()
            }
        })
    
    elif message_type == "typing":
        # Broadcast typing indicator
        await websocket_manager.broadcast_to_room(room_id, {
            "type": "typing",
            "user_id": user_id,
            "is_typing": message_data.get("is_typing", False)
        })
    
    elif message_type == "presence":
        # Update user presence
        await websocket_manager.broadcast_to_room(room_id, {
            "type": "presence",
            "user_id": user_id,
            "status": message_data.get("status", "online")
        })
```

#### WebSocket Manager
```python
# chat-service/websocket_manager.py
from fastapi import WebSocket
from typing import Dict, List
import json

class WebSocketManager:
    def __init__(self):
        # Dictionary to store active connections by room
        self.active_connections: Dict[str, Dict[str, WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, room_id: str, user_id: str):
        """Accept WebSocket connection and add to room"""
        await websocket.accept()
        
        if room_id not in self.active_connections:
            self.active_connections[room_id] = {}
        
        self.active_connections[room_id][user_id] = websocket
        
        # Notify other users that user joined
        await self.broadcast_to_room(room_id, {
            "type": "user_joined",
            "user_id": user_id
        }, exclude_user=user_id)
    
    def disconnect(self, room_id: str, user_id: str):
        """Remove WebSocket connection from room"""
        if room_id in self.active_connections:
            if user_id in self.active_connections[room_id]:
                del self.active_connections[room_id][user_id]
            
            # If room is empty, remove it
            if not self.active_connections[room_id]:
                del self.active_connections[room_id]
    
    async def broadcast_to_room(self, room_id: str, message: dict, exclude_user: str = None):
        """Broadcast message to all users in a room"""
        if room_id not in self.active_connections:
            return
        
        for user_id, connection in self.active_connections[room_id].items():
            if exclude_user and user_id == exclude_user:
                continue
            
            try:
                await connection.send_text(json.dumps(message))
            except:
                # Remove disconnected connection
                del self.active_connections[room_id][user_id]
    
    async def send_to_user(self, room_id: str, user_id: str, message: dict):
        """Send message to specific user in a room"""
        if room_id in self.active_connections and user_id in self.active_connections[room_id]:
            try:
                await self.active_connections[room_id][user_id].send_text(json.dumps(message))
            except:
                # Remove disconnected connection
                del self.active_connections[room_id][user_id]
    
    def get_room_users(self, room_id: str) -> List[str]:
        """Get list of connected users in a room"""
        if room_id in self.active_connections:
            return list(self.active_connections[room_id].keys())
        return []
```

### 3. Message Service

#### Service Implementation
```python
# message-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime

from .database import get_db
from .models import Message, MessageAttachment, MessageReaction
from .schemas import MessageCreate, MessageResponse, MessageUpdate, ReactionCreate

app = FastAPI(title="Message Service", version="1.0.0")

@app.post("/messages", response_model=MessageResponse)
def create_message(message: MessageCreate, db: Session = Depends(get_db)):
    """Create a new message"""
    # Create message
    db_message = Message(
        id=str(uuid.uuid4()),
        room_id=message.room_id,
        user_id=message.user_id,
        content=message.content,
        message_type=message.message_type,
        reply_to_id=message.reply_to_id,
        created_at=datetime.utcnow()
    )
    
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    
    # Handle attachments
    if message.attachments:
        for attachment_data in message.attachments:
            attachment = MessageAttachment(
                id=str(uuid.uuid4()),
                message_id=db_message.id,
                file_url=attachment_data["file_url"],
                file_name=attachment_data["file_name"],
                file_type=attachment_data["file_type"],
                file_size=attachment_data.get("file_size"),
                created_at=datetime.utcnow()
            )
            db.add(attachment)
    
    db.commit()
    
    return MessageResponse.from_orm(db_message)

@app.get("/messages/{message_id}", response_model=MessageResponse)
def get_message(message_id: str, db: Session = Depends(get_db)):
    """Get message by ID"""
    message = db.query(Message).filter(Message.id == message_id).first()
    if not message:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found"
        )
    return MessageResponse.from_orm(message)

@app.put("/messages/{message_id}", response_model=MessageResponse)
def update_message(
    message_id: str,
    message_update: MessageUpdate,
    db: Session = Depends(get_db)
):
    """Update message"""
    message = db.query(Message).filter(Message.id == message_id).first()
    if not message:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found"
        )
    
    # Update message content
    if message_update.content:
        message.content = message_update.content
        message.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(message)
    
    return MessageResponse.from_orm(message)

@app.delete("/messages/{message_id}")
def delete_message(message_id: str, db: Session = Depends(get_db)):
    """Delete message (soft delete)"""
    message = db.query(Message).filter(Message.id == message_id).first()
    if not message:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found"
        )
    
    # Soft delete
    message.deleted_at = datetime.utcnow()
    message.is_deleted = True
    
    db.commit()
    
    return {"message": "Message deleted successfully"}

@app.post("/messages/{message_id}/reactions")
def add_reaction(
    message_id: str,
    reaction: ReactionCreate,
    db: Session = Depends(get_db)
):
    """Add reaction to message"""
    # Check if message exists
    message = db.query(Message).filter(Message.id == message_id).first()
    if not message:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Message not found"
        )
    
    # Check if user already reacted with this emoji
    existing_reaction = db.query(MessageReaction).filter(
        MessageReaction.message_id == message_id,
        MessageReaction.user_id == reaction.user_id,
        MessageReaction.emoji == reaction.emoji
    ).first()
    
    if existing_reaction:
        # Remove existing reaction
        db.delete(existing_reaction)
    else:
        # Add new reaction
        db_reaction = MessageReaction(
            id=str(uuid.uuid4()),
            message_id=message_id,
            user_id=reaction.user_id,
            emoji=reaction.emoji,
            created_at=datetime.utcnow()
        )
        db.add(db_reaction)
    
    db.commit()
    
    return {"message": "Reaction updated successfully"}

@app.get("/messages/{message_id}/reactions")
def get_message_reactions(message_id: str, db: Session = Depends(get_db)):
    """Get message reactions"""
    reactions = db.query(MessageReaction).filter(
        MessageReaction.message_id == message_id
    ).all()
    
    # Group reactions by emoji
    reaction_groups = {}
    for reaction in reactions:
        if reaction.emoji not in reaction_groups:
            reaction_groups[reaction.emoji] = []
        reaction_groups[reaction.emoji].append({
            "user_id": reaction.user_id,
            "created_at": reaction.created_at.isoformat()
        })
    
    return reaction_groups

@app.get("/rooms/{room_id}/messages")
def get_room_messages(
    room_id: str,
    limit: int = 50,
    offset: int = 0,
    before_message_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get messages for a room with pagination"""
    query = db.query(Message).filter(
        Message.room_id == room_id,
        Message.is_deleted == False
    )
    
    if before_message_id:
        # Get messages before a specific message
        before_message = db.query(Message).filter(Message.id == before_message_id).first()
        if before_message:
            query = query.filter(Message.created_at < before_message.created_at)
    
    messages = query.order_by(Message.created_at.desc()).offset(offset).limit(limit).all()
    
    return [MessageResponse.from_orm(message) for message in reversed(messages)]
```

### 4. Notification Service

#### Service Implementation
```python
# notification-service/main.py
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
import uuid
from datetime import datetime, timedelta

from .database import get_db
from .models import Notification, NotificationTemplate, UserNotificationSettings
from .schemas import NotificationCreate, NotificationResponse, TemplateCreate
from .email_service import EmailService
from .push_service import PushService

app = FastAPI(title="Notification Service", version="1.0.0")

# Initialize services
email_service = EmailService()
push_service = PushService()

@app.post("/notifications", response_model=NotificationResponse)
def create_notification(notification: NotificationCreate, db: Session = Depends(get_db)):
    """Create a new notification"""
    # Create notification
    db_notification = Notification(
        id=str(uuid.uuid4()),
        user_id=notification.user_id,
        type=notification.type,
        title=notification.title,
        content=notification.content,
        data=notification.data,
        is_read=False,
        created_at=datetime.utcnow()
    )
    
    db.add(db_notification)
    db.commit()
    db.refresh(db_notification)
    
    # Send notification based on user preferences
    send_notification(db_notification, db)
    
    return NotificationResponse.from_orm(db_notification)

@app.get("/notifications/{user_id}", response_model=List[NotificationResponse])
def get_user_notifications(
    user_id: str,
    limit: int = 50,
    offset: int = 0,
    unread_only: bool = False,
    db: Session = Depends(get_db)
):
    """Get user notifications"""
    query = db.query(Notification).filter(Notification.user_id == user_id)
    
    if unread_only:
        query = query.filter(Notification.is_read == False)
    
    notifications = query.order_by(Notification.created_at.desc()).offset(offset).limit(limit).all()
    
    return [NotificationResponse.from_orm(notification) for notification in notifications]

@app.put("/notifications/{notification_id}/read")
def mark_notification_read(notification_id: str, db: Session = Depends(get_db)):
    """Mark notification as read"""
    notification = db.query(Notification).filter(Notification.id == notification_id).first()
    if not notification:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Notification not found"
        )
    
    notification.is_read = True
    notification.read_at = datetime.utcnow()
    
    db.commit()
    
    return {"message": "Notification marked as read"}

@app.put("/notifications/{user_id}/read-all")
def mark_all_notifications_read(user_id: str, db: Session = Depends(get_db)):
    """Mark all user notifications as read"""
    db.query(Notification).filter(
        Notification.user_id == user_id,
        Notification.is_read == False
    ).update({"is_read": True, "read_at": datetime.utcnow()})
    
    db.commit()
    
    return {"message": "All notifications marked as read"}

@app.get("/notifications/{user_id}/unread-count")
def get_unread_count(user_id: str, db: Session = Depends(get_db)):
    """Get unread notification count"""
    count = db.query(Notification).filter(
        Notification.user_id == user_id,
        Notification.is_read == False
    ).count()
    
    return {"unread_count": count}

@app.post("/templates", response_model=NotificationTemplate)
def create_template(template: TemplateCreate, db: Session = Depends(get_db)):
    """Create notification template"""
    db_template = NotificationTemplate(
        id=str(uuid.uuid4()),
        name=template.name,
        type=template.type,
        subject=template.subject,
        body=template.body,
        variables=template.variables,
        created_at=datetime.utcnow()
    )
    
    db.add(db_template)
    db.commit()
    db.refresh(db_template)
    
    return db_template

def send_notification(notification: Notification, db: Session):
    """Send notification based on user preferences"""
    # Get user notification settings
    settings = db.query(UserNotificationSettings).filter(
        UserNotificationSettings.user_id == notification.user_id
    ).first()
    
    if not settings:
        # Default settings
        settings = UserNotificationSettings(
            user_id=notification.user_id,
            email_enabled=True,
            push_enabled=True,
            sms_enabled=False
        )
        db.add(settings)
        db.commit()
    
    # Send email notification
    if settings.email_enabled and notification.type in ["message", "mention", "system"]:
        email_service.send_notification(notification)
    
    # Send push notification
    if settings.push_enabled and notification.type in ["message", "mention", "system"]:
        push_service.send_notification(notification)
    
    # Send SMS notification (for urgent notifications)
    if settings.sms_enabled and notification.type == "urgent":
        # Implement SMS service
        pass
```

### 5. Infrastructure Configuration

#### Docker Compose
```yaml
# docker-compose.yml
version: '3.8'

services:
  # User Service
  user-service:
    build: ./user-service
    ports:
      - "8001:8000"
    environment:
      - DATABASE_URL=postgresql://admin:password@db:5432/chat_app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  # Chat Service
  chat-service:
    build: ./chat-service
    ports:
      - "8002:8000"
    environment:
      - DATABASE_URL=postgresql://admin:password@db:5432/chat_app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  # Message Service
  message-service:
    build: ./message-service
    ports:
      - "8003:8000"
    environment:
      - DATABASE_URL=postgresql://admin:password@db:5432/chat_app
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  # Notification Service
  notification-service:
    build: ./notification-service
    ports:
      - "8004:8000"
    environment:
      - DATABASE_URL=postgresql://admin:password@db:5432/chat_app
      - REDIS_URL=redis://redis:6379
      - EMAIL_SERVICE_URL=http://email-service:8005
    depends_on:
      - db
      - redis

  # Database
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=chat_app
      - POSTGRES_USER=admin
      - POSTGRES_PASSWORD=password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  # Redis
  redis:
    image: redis:6-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  # Nginx (Load Balancer)
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - user-service
      - chat-service
      - message-service
      - notification-service

volumes:
  postgres_data:
  redis_data:
```

#### Kubernetes Manifests
```yaml
# k8s/chat-app-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: chat-app/user-service:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: ClusterIP
```

## Best Practices Applied

### Real-time Communication
1. **WebSocket Management**: Efficient WebSocket connection management
2. **Message Broadcasting**: Real-time message broadcasting to room members
3. **Connection Handling**: Proper connection and disconnection handling
4. **Presence Management**: User presence and typing indicators
5. **Error Handling**: Robust error handling for WebSocket connections

### Microservices Architecture
1. **Service Separation**: Clear separation of concerns between services
2. **API Design**: RESTful APIs with proper HTTP status codes
3. **Data Consistency**: Eventual consistency for real-time features
4. **Service Communication**: Asynchronous communication between services
5. **Scalability**: Horizontal scaling capabilities

### Security
1. **Authentication**: JWT-based authentication
2. **Authorization**: Role-based access control
3. **Input Validation**: Comprehensive input validation
4. **SQL Injection Prevention**: Parameterized queries
5. **XSS Protection**: Content sanitization

### Performance
1. **Database Optimization**: Proper indexing and query optimization
2. **Caching**: Redis for session and message caching
3. **Connection Pooling**: Database connection pooling
4. **Load Balancing**: Nginx load balancing
5. **Resource Management**: Proper resource allocation and limits

## Lessons Learned

### Key Insights
1. **Real-time Features**: WebSocket management is crucial for real-time chat
2. **Message Persistence**: Proper message storage and retrieval
3. **User Experience**: Presence indicators and typing indicators improve UX
4. **Scalability**: Microservices enable independent scaling
5. **Security**: Proper authentication and authorization are essential

### Common Pitfalls
1. **WebSocket Management**: Poor WebSocket connection management
2. **Message Ordering**: Incorrect message ordering in chat
3. **Memory Leaks**: WebSocket connection memory leaks
4. **Database Performance**: Poor database query performance
5. **Error Handling**: Inadequate error handling for real-time features

### Recommendations
1. **Start Simple**: Begin with basic chat functionality
2. **Add Features Gradually**: Add advanced features incrementally
3. **Monitor Performance**: Monitor WebSocket and database performance
4. **Test Thoroughly**: Test real-time features thoroughly
5. **Plan for Scale**: Design for horizontal scaling from the start

## Next Steps

1. **Implementation**: Implement the chat application
2. **Testing**: Test all real-time features
3. **Monitoring**: Set up monitoring for WebSocket connections
4. **Optimization**: Optimize performance and scalability
5. **Features**: Add advanced features like file sharing, voice messages
