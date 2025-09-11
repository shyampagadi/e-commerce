# Project 2: Real-time Chat Application

## Project Overview

Build a comprehensive real-time chat application using microservices architecture on AWS. The application should support multiple chat rooms, direct messaging, file sharing, and real-time notifications with global scalability.

## Requirements

### Functional Requirements

#### User Management
- User registration and authentication
- User profiles and avatars
- Online/offline status
- User search and discovery
- Friend requests and connections

#### Chat Features
- Multiple chat rooms and channels
- Direct messaging between users
- Group chat creation and management
- Message history and search
- Message reactions and emojis
- File and media sharing
- Voice and video calling integration

#### Real-time Features
- Real-time message delivery
- Typing indicators
- Message read receipts
- Online presence indicators
- Push notifications
- Live chat support

#### Administration
- Room moderation and management
- User management and banning
- Content moderation and filtering
- Analytics and reporting
- System monitoring

### Non-Functional Requirements

#### Performance
- Support 100,000 concurrent users
- Message delivery < 100ms
- 99.9% uptime
- Global distribution

#### Scalability
- Horizontal scaling of all services
- Auto-scaling based on load
- Message queue scaling
- Database sharding

#### Security
- End-to-end encryption
- Message authentication
- Rate limiting and DDoS protection
- Data privacy compliance

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
    │  │User Service │ │Chat Service │ │Message Svc  │      │
    │  └─────────────┘ └─────────────┘ └─────────────┘      │
    │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
    │  │Room Service │ │File Service │ │Notification │      │
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
- **Language**: Node.js with TypeScript
- **Framework**: Express.js with Socket.io
- **Database**: PostgreSQL (RDS) for user data, DynamoDB for messages
- **Cache**: Redis (ElastiCache) for sessions and real-time data
- **Message Queue**: SQS for async processing

#### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Amazon ECS with Fargate
- **API Gateway**: AWS API Gateway
- **Load Balancer**: Application Load Balancer
- **CDN**: CloudFront for static content

#### Real-time Communication
- **WebSocket**: Socket.io for real-time communication
- **Message Broker**: Redis for pub/sub
- **Push Notifications**: Amazon SNS
- **File Storage**: Amazon S3

## Implementation

### Phase 1: Foundation Setup

#### 1.1 Infrastructure Setup
```bash
# Create VPC and networking
aws ec2 create-vpc --cidr-block 10.0.0.0/16
aws ec2 create-subnet --vpc-id vpc-xxx --cidr-block 10.0.1.0/24

# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier chat-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password password123

# Create ElastiCache cluster
aws elasticache create-cache-cluster \
  --cache-cluster-id chat-cache \
  --cache-node-type cache.t3.micro \
  --engine redis \
  --num-cache-nodes 1
```

#### 1.2 Service Structure
```
chat-application/
├── services/
│   ├── user-service/
│   ├── chat-service/
│   ├── message-service/
│   ├── room-service/
│   ├── file-service/
│   └── notification-service/
├── infrastructure/
│   ├── terraform/
│   └── docker-compose.yml
├── shared/
│   ├── models/
│   ├── utils/
│   └── middleware/
└── docs/
    ├── api/
    └── architecture/
```

### Phase 2: Core Services Implementation

#### 2.1 User Service
```typescript
// user-service/src/app.ts
import express from 'express';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

const app = express();
const prisma = new PrismaClient();

app.use(express.json());

// User registration
app.post('/users', async (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Create user
    const user = await prisma.user.create({
      data: {
        username,
        email,
        password: hashedPassword,
        status: 'offline'
      }
    });
    
    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, username: user.username },
      process.env.JWT_SECRET!,
      { expiresIn: '24h' }
    );
    
    res.status(201).json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        status: user.status
      },
      token
    });
  } catch (error) {
    res.status(400).json({ error: 'User creation failed' });
  }
});

// User authentication
app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Find user
    const user = await prisma.user.findUnique({
      where: { email }
    });
    
    if (!user || !await bcrypt.compare(password, user.password)) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    // Update status to online
    await prisma.user.update({
      where: { id: user.id },
      data: { status: 'online' }
    });
    
    // Generate JWT token
    const token = jwt.sign(
      { userId: user.id, username: user.username },
      process.env.JWT_SECRET!,
      { expiresIn: '24h' }
    );
    
    res.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        status: 'online'
      },
      token
    });
  } catch (error) {
    res.status(500).json({ error: 'Authentication failed' });
  }
});

export default app;
```

#### 2.2 Chat Service with WebSocket
```typescript
// chat-service/src/app.ts
import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { PrismaClient } from '@prisma/client';
import jwt from 'jsonwebtoken';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.CLIENT_URL,
    methods: ['GET', 'POST']
  }
});

const prisma = new PrismaClient();

// Socket.io connection handling
io.use(async (socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId }
    });
    
    if (!user) {
      return next(new Error('Authentication error'));
    }
    
    socket.userId = user.id;
    socket.username = user.username;
    next();
  } catch (error) {
    next(new Error('Authentication error'));
  }
});

io.on('connection', (socket) => {
  console.log(`User ${socket.username} connected`);
  
  // Join user to their personal room
  socket.join(`user_${socket.userId}`);
  
  // Handle joining chat rooms
  socket.on('join_room', async (roomId) => {
    try {
      // Check if user has access to room
      const room = await prisma.room.findFirst({
        where: {
          id: roomId,
          members: {
            some: { userId: socket.userId }
          }
        }
      });
      
      if (room) {
        socket.join(`room_${roomId}`);
        socket.emit('joined_room', { roomId, roomName: room.name });
        
        // Notify others in the room
        socket.to(`room_${roomId}`).emit('user_joined', {
          userId: socket.userId,
          username: socket.username
        });
      }
    } catch (error) {
      socket.emit('error', { message: 'Failed to join room' });
    }
  });
  
  // Handle sending messages
  socket.on('send_message', async (data) => {
    try {
      const { roomId, content, type = 'text' } = data;
      
      // Save message to database
      const message = await prisma.message.create({
        data: {
          content,
          type,
          roomId,
          userId: socket.userId
        },
        include: {
          user: {
            select: { id: true, username: true, avatar: true }
          }
        }
      });
      
      // Broadcast message to room
      io.to(`room_${roomId}`).emit('new_message', message);
      
    } catch (error) {
      socket.emit('error', { message: 'Failed to send message' });
    }
  });
  
  // Handle typing indicators
  socket.on('typing_start', (data) => {
    socket.to(`room_${data.roomId}`).emit('user_typing', {
      userId: socket.userId,
      username: socket.username,
      isTyping: true
    });
  });
  
  socket.on('typing_stop', (data) => {
    socket.to(`room_${data.roomId}`).emit('user_typing', {
      userId: socket.userId,
      username: socket.username,
      isTyping: false
    });
  });
  
  // Handle disconnection
  socket.on('disconnect', () => {
    console.log(`User ${socket.username} disconnected`);
    
    // Update user status to offline
    prisma.user.update({
      where: { id: socket.userId },
      data: { status: 'offline' }
    });
  });
});

export { app, server, io };
```

### Phase 3: Real-time Features

#### 3.1 Message Service
```typescript
// message-service/src/app.ts
import express from 'express';
import { PrismaClient } from '@prisma/client';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';

const app = express();
const prisma = new PrismaClient();
const sqs = new SQSClient({ region: process.env.AWS_REGION });

app.use(express.json());

// Get message history
app.get('/rooms/:roomId/messages', async (req, res) => {
  try {
    const { roomId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    
    const messages = await prisma.message.findMany({
      where: { roomId },
      include: {
        user: {
          select: { id: true, username: true, avatar: true }
        }
      },
      orderBy: { createdAt: 'desc' },
      skip: (Number(page) - 1) * Number(limit),
      take: Number(limit)
    });
    
    res.json({ messages: messages.reverse() });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
});

// Search messages
app.get('/search', async (req, res) => {
  try {
    const { query, roomId, userId } = req.query;
    
    const messages = await prisma.message.findMany({
      where: {
        content: {
          contains: query as string,
          mode: 'insensitive'
        },
        ...(roomId && { roomId: roomId as string }),
        ...(userId && { userId: userId as string })
      },
      include: {
        user: {
          select: { id: true, username: true, avatar: true }
        },
        room: {
          select: { id: true, name: true }
        }
      },
      orderBy: { createdAt: 'desc' },
      take: 100
    });
    
    res.json({ messages });
  } catch (error) {
    res.status(500).json({ error: 'Search failed' });
  }
});

// Process message for analytics
app.post('/process-message', async (req, res) => {
  try {
    const { messageId, content, userId, roomId } = req.body;
    
    // Send to SQS for async processing
    await sqs.send(new SendMessageCommand({
      QueueUrl: process.env.ANALYTICS_QUEUE_URL,
      MessageBody: JSON.stringify({
        messageId,
        content,
        userId,
        roomId,
        timestamp: new Date().toISOString()
      })
    }));
    
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Message processing failed' });
  }
});

export default app;
```

### Phase 4: File Sharing

#### 4.1 File Service
```typescript
// file-service/src/app.ts
import express from 'express';
import multer from 'multer';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { PrismaClient } from '@prisma/client';

const app = express();
const prisma = new PrismaClient();
const s3 = new S3Client({ region: process.env.AWS_REGION });

// Configure multer for file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024 // 10MB limit
  }
});

// Upload file
app.post('/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' });
    }
    
    const { roomId, userId } = req.body;
    const fileKey = `uploads/${roomId}/${Date.now()}-${req.file.originalname}`;
    
    // Upload to S3
    await s3.send(new PutObjectCommand({
      Bucket: process.env.S3_BUCKET,
      Key: fileKey,
      Body: req.file.buffer,
      ContentType: req.file.mimetype,
      Metadata: {
        originalName: req.file.originalname,
        userId,
        roomId
      }
    }));
    
    // Save file record to database
    const fileRecord = await prisma.file.create({
      data: {
        filename: req.file.originalname,
        fileKey,
        mimeType: req.file.mimetype,
        size: req.file.size,
        roomId,
        userId
      }
    });
    
    res.json({
      fileId: fileRecord.id,
      filename: fileRecord.filename,
      size: fileRecord.size,
      mimeType: fileRecord.mimeType
    });
  } catch (error) {
    res.status(500).json({ error: 'File upload failed' });
  }
});

// Get file download URL
app.get('/files/:fileId/download', async (req, res) => {
  try {
    const { fileId } = req.params;
    
    const file = await prisma.file.findUnique({
      where: { id: fileId }
    });
    
    if (!file) {
      return res.status(404).json({ error: 'File not found' });
    }
    
    // Generate signed URL for download
    const downloadUrl = await getSignedUrl(
      s3,
      new GetObjectCommand({
        Bucket: process.env.S3_BUCKET,
        Key: file.fileKey
      }),
      { expiresIn: 3600 } // 1 hour
    );
    
    res.json({ downloadUrl });
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate download URL' });
  }
});

export default app;
```

## Testing

### Unit Tests
```typescript
// tests/user-service.test.ts
import request from 'supertest';
import app from '../src/app';

describe('User Service', () => {
  test('should create a new user', async () => {
    const userData = {
      username: 'testuser',
      email: 'test@example.com',
      password: 'password123'
    };
    
    const response = await request(app)
      .post('/users')
      .send(userData)
      .expect(201);
    
    expect(response.body.user).toHaveProperty('id');
    expect(response.body.user.username).toBe(userData.username);
    expect(response.body).toHaveProperty('token');
  });
  
  test('should authenticate user', async () => {
    const loginData = {
      email: 'test@example.com',
      password: 'password123'
    };
    
    const response = await request(app)
      .post('/auth/login')
      .send(loginData)
      .expect(200);
    
    expect(response.body.user).toHaveProperty('id');
    expect(response.body).toHaveProperty('token');
  });
});
```

### Integration Tests
```typescript
// tests/chat-integration.test.ts
import { createClient } from 'socket.io-client';
import { createServer } from 'http';
import { Server } from 'socket.io';

describe('Chat Integration', () => {
  let io: Server;
  let server: any;
  let client: any;
  
  beforeAll((done) => {
    server = createServer();
    io = new Server(server);
    server.listen(() => {
      const port = server.address().port;
      client = createClient(`http://localhost:${port}`);
      client.on('connect', done);
    });
  });
  
  afterAll(() => {
    io.close();
    server.close();
  });
  
  test('should handle message sending', (done) => {
    client.emit('send_message', {
      roomId: 'test-room',
      content: 'Hello, world!'
    });
    
    client.on('new_message', (message) => {
      expect(message.content).toBe('Hello, world!');
      done();
    });
  });
});
```

## Deployment

### Docker Configuration
```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

### Kubernetes Deployment
```yaml
# k8s/chat-service-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chat-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: chat-service
  template:
    metadata:
      labels:
        app: chat-service
    spec:
      containers:
      - name: chat-service
        image: chat-app/chat-service:latest
        ports:
        - containerPort: 3000
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
```

## Monitoring

### CloudWatch Dashboard
```json
{
  "widgets": [
    {
      "type": "metric",
      "properties": {
        "metrics": [
          ["AWS/ECS", "CPUUtilization", "ServiceName", "chat-service"],
          ["AWS/ECS", "MemoryUtilization", "ServiceName", "chat-service"]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-west-2",
        "title": "Chat Service Performance"
      }
    }
  ]
}
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
4. **Move to Project 3**: Continue with the next project
