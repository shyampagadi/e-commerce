# Exercise 1: Database Schema Design

## Objective

Design a normalized database schema for a social media platform that supports users, posts, comments, likes, follows, and messaging. The platform should handle millions of users and billions of interactions.

## Prerequisites

- Basic knowledge of SQL and database design
- Understanding of normalization principles (1NF, 2NF, 3NF)
- Familiarity with PostgreSQL
- Access to PostgreSQL 13+

## Requirements

### Functional Requirements
- **User Management**: User registration, profiles, authentication
- **Content Creation**: Users can create posts, comments, and media
- **Social Features**: Users can follow each other, like posts, and comment
- **Messaging**: Direct messaging between users
- **Content Discovery**: Feed generation and content search
- **Notifications**: Real-time notifications for user activities

### Non-Functional Requirements
- **Scalability**: Support 10M+ users and 1B+ posts
- **Performance**: Sub-second response times for critical operations
- **Availability**: 99.9% uptime
- **Data Integrity**: Maintain referential integrity and data consistency
- **Security**: Protect user data and privacy

## Database Design

### 1. User Management Schema

#### Users Table
```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(500),
    cover_url VARCHAR(500),
    date_of_birth DATE,
    location VARCHAR(100),
    website VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    is_private BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User settings
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    privacy_level VARCHAR(20) DEFAULT 'public',
    language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);
```

#### User Relationships
```sql
-- Follow relationships
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CHECK(follower_id != following_id)
);

-- Block relationships
CREATE TABLE blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(blocker_id, blocked_id),
    CHECK(blocker_id != blocked_id)
);
```

### 2. Content Schema

#### Posts Table
```sql
-- Posts table
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    post_type VARCHAR(20) DEFAULT 'text', -- text, image, video, link
    media_urls JSONB DEFAULT '[]',
    hashtags TEXT[] DEFAULT '{}',
    mentions TEXT[] DEFAULT '{}',
    location JSONB, -- {lat, lng, name, address}
    is_public BOOLEAN DEFAULT TRUE,
    is_pinned BOOLEAN DEFAULT FALSE,
    reply_to_post_id UUID REFERENCES posts(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Post media
CREATE TABLE post_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    media_type VARCHAR(20) NOT NULL, -- image, video, audio
    media_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    alt_text VARCHAR(255),
    file_size INTEGER,
    duration INTEGER, -- for video/audio in seconds
    width INTEGER,
    height INTEGER,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Comments and Interactions
```sql
-- Comments table
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES comments(id),
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Likes table
CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id),
    UNIQUE(user_id, comment_id),
    CHECK((post_id IS NOT NULL AND comment_id IS NULL) OR (post_id IS NULL AND comment_id IS NOT NULL))
);

-- Shares table
CREATE TABLE shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    content TEXT, -- Optional comment when sharing
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id)
);
```

### 3. Messaging Schema

#### Direct Messages
```sql
-- Conversations table
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_group BOOLEAN DEFAULT FALSE,
    name VARCHAR(255), -- For group conversations
    description TEXT, -- For group conversations
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conversation participants
CREATE TABLE conversation_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- member, admin
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    UNIQUE(conversation_id, user_id)
);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text', -- text, image, video, file
    media_url VARCHAR(500),
    reply_to_message_id UUID REFERENCES messages(id),
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Message read status
CREATE TABLE message_reads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id)
);
```

### 4. Notifications Schema

#### Notifications
```sql
-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- like, comment, follow, mention, message
    title VARCHAR(255) NOT NULL,
    content TEXT,
    data JSONB DEFAULT '{}', -- Additional data for the notification
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notification preferences
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, notification_type)
);
```

## Indexing Strategy

### Primary Indexes
```sql
-- Primary key indexes (automatically created)
-- users.id, posts.id, comments.id, etc.

-- Unique indexes
CREATE UNIQUE INDEX idx_users_username ON users(username);
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_follows_follower_following ON follows(follower_id, following_id);
CREATE UNIQUE INDEX idx_blocks_blocker_blocked ON blocks(blocker_id, blocked_id);
CREATE UNIQUE INDEX idx_likes_user_post ON likes(user_id, post_id) WHERE post_id IS NOT NULL;
CREATE UNIQUE INDEX idx_likes_user_comment ON likes(user_id, comment_id) WHERE comment_id IS NOT NULL;
CREATE UNIQUE INDEX idx_shares_user_post ON shares(user_id, post_id);
```

### Performance Indexes
```sql
-- Foreign key indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at);
CREATE INDEX idx_posts_reply_to_post_id ON posts(reply_to_post_id);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);
CREATE INDEX idx_likes_post_id ON likes(post_id) WHERE post_id IS NOT NULL;
CREATE INDEX idx_likes_comment_id ON likes(comment_id) WHERE comment_id IS NOT NULL;
CREATE INDEX idx_shares_post_id ON shares(post_id);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
```

### Composite Indexes
```sql
-- Multi-column indexes for complex queries
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);
CREATE INDEX idx_posts_public_created ON posts(is_public, created_at DESC) WHERE is_public = TRUE;
CREATE INDEX idx_comments_post_created ON comments(post_id, created_at DESC);
CREATE INDEX idx_messages_conversation_created ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read, created_at DESC);
```

## Data Partitioning

### Time-Based Partitioning
```sql
-- Partition posts table by month
CREATE TABLE posts_2024_01 PARTITION OF posts
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE posts_2024_02 PARTITION OF posts
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Partition messages table by month
CREATE TABLE messages_2024_01 PARTITION OF messages
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE messages_2024_02 PARTITION OF messages
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
```

## Instructions

### Step 1: Database Setup
1. Create a new PostgreSQL database:
   ```sql
   CREATE DATABASE social_media_platform;
   \c social_media_platform;
   ```

2. Enable required extensions:
   ```sql
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS "pg_trgm";
   ```

### Step 2: Create Tables
1. Create all tables in the correct order (respecting foreign key dependencies)
2. Add all constraints and checks
3. Create all indexes
4. Set up partitioning if needed

### Step 3: Insert Sample Data
1. Create sample users (at least 10)
2. Create sample posts (at least 50)
3. Create sample comments (at least 100)
4. Create sample follows and likes
5. Create sample conversations and messages

### Step 4: Test Queries
1. Write queries to test the schema:
   - Get user feed (posts from followed users)
   - Get post details with comments and likes
   - Get user's followers and following
   - Get conversation messages
   - Get user notifications

### Step 5: Performance Testing
1. Test query performance with sample data
2. Identify slow queries
3. Optimize queries and indexes
4. Test with larger datasets

## Expected Outcomes

### 1. Complete Schema
- All tables created with proper relationships
- Appropriate constraints and checks
- Comprehensive indexing strategy
- Data partitioning implementation

### 2. Sample Data
- Realistic sample data for testing
- Proper relationships between entities
- Various data types and scenarios

### 3. Working Queries
- Functional queries for all major operations
- Optimized query performance
- Proper error handling

### 4. Documentation
- Clear documentation of design decisions
- Explanation of trade-offs
- Performance considerations

## Solution

### Complete Schema Creation
```sql
-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(500),
    cover_url VARCHAR(500),
    date_of_birth DATE,
    location VARCHAR(100),
    website VARCHAR(255),
    is_verified BOOLEAN DEFAULT FALSE,
    is_private BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create user_settings table
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email_notifications BOOLEAN DEFAULT TRUE,
    push_notifications BOOLEAN DEFAULT TRUE,
    sms_notifications BOOLEAN DEFAULT FALSE,
    privacy_level VARCHAR(20) DEFAULT 'public',
    language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Create follows table
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CHECK(follower_id != following_id)
);

-- Create blocks table
CREATE TABLE blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(blocker_id, blocked_id),
    CHECK(blocker_id != blocked_id)
);

-- Create posts table
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    post_type VARCHAR(20) DEFAULT 'text',
    media_urls JSONB DEFAULT '[]',
    hashtags TEXT[] DEFAULT '{}',
    mentions TEXT[] DEFAULT '{}',
    location JSONB,
    is_public BOOLEAN DEFAULT TRUE,
    is_pinned BOOLEAN DEFAULT FALSE,
    reply_to_post_id UUID REFERENCES posts(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create post_media table
CREATE TABLE post_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    media_type VARCHAR(20) NOT NULL,
    media_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    alt_text VARCHAR(255),
    file_size INTEGER,
    duration INTEGER,
    width INTEGER,
    height INTEGER,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create comments table
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES comments(id),
    is_edited BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create likes table
CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id),
    UNIQUE(user_id, comment_id),
    CHECK((post_id IS NOT NULL AND comment_id IS NULL) OR (post_id IS NULL AND comment_id IS NOT NULL))
);

-- Create shares table
CREATE TABLE shares (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id)
);

-- Create conversations table
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_group BOOLEAN DEFAULT FALSE,
    name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create conversation_participants table
CREATE TABLE conversation_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    UNIQUE(conversation_id, user_id)
);

-- Create messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text',
    media_url VARCHAR(500),
    reply_to_message_id UUID REFERENCES messages(id),
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create message_reads table
CREATE TABLE message_reads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    read_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(message_id, user_id)
);

-- Create notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create notification_preferences table
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, notification_type)
);
```

### Sample Data Insertion
```sql
-- Insert sample users
INSERT INTO users (username, email, password_hash, first_name, last_name, bio, is_verified) VALUES
('john_doe', 'john@example.com', 'hashed_password_1', 'John', 'Doe', 'Software engineer and tech enthusiast', TRUE),
('jane_smith', 'jane@example.com', 'hashed_password_2', 'Jane', 'Smith', 'Designer and artist', FALSE),
('mike_wilson', 'mike@example.com', 'hashed_password_3', 'Mike', 'Wilson', 'Photographer and traveler', TRUE),
('sarah_jones', 'sarah@example.com', 'hashed_password_4', 'Sarah', 'Jones', 'Writer and blogger', FALSE),
('alex_brown', 'alex@example.com', 'hashed_password_5', 'Alex', 'Brown', 'Musician and producer', FALSE);

-- Insert sample posts
INSERT INTO posts (user_id, content, post_type, hashtags, is_public) VALUES
((SELECT id FROM users WHERE username = 'john_doe'), 'Just finished building an amazing web application! #coding #webdev #tech', 'text', ARRAY['coding', 'webdev', 'tech'], TRUE),
((SELECT id FROM users WHERE username = 'jane_smith'), 'Beautiful sunset from my window today í¼…', 'text', ARRAY['sunset', 'nature', 'photography'], TRUE),
((SELECT id FROM users WHERE username = 'mike_wilson'), 'Amazing architecture in downtown today', 'text', ARRAY['architecture', 'photography', 'downtown'], TRUE),
((SELECT id FROM users WHERE username = 'sarah_jones'), 'Working on my new book chapter about digital marketing', 'text', ARRAY['writing', 'book', 'marketing'], TRUE),
((SELECT id FROM users WHERE username = 'alex_brown'), 'New track coming soon! Stay tuned for updates', 'text', ARRAY['music', 'newtrack', 'comingsoon'], TRUE);

-- Insert sample follows
INSERT INTO follows (follower_id, following_id) VALUES
((SELECT id FROM users WHERE username = 'jane_smith'), (SELECT id FROM users WHERE username = 'john_doe')),
((SELECT id FROM users WHERE username = 'mike_wilson'), (SELECT id FROM users WHERE username = 'jane_smith')),
((SELECT id FROM users WHERE username = 'sarah_jones'), (SELECT id FROM users WHERE username = 'john_doe')),
((SELECT id FROM users WHERE username = 'alex_brown'), (SELECT id FROM users WHERE username = 'mike_wilson'));

-- Insert sample comments
INSERT INTO comments (post_id, user_id, content) VALUES
((SELECT id FROM posts WHERE content LIKE '%web application%'), (SELECT id FROM users WHERE username = 'jane_smith'), 'That sounds amazing! What technologies did you use?'),
((SELECT id FROM posts WHERE content LIKE '%sunset%'), (SELECT id FROM users WHERE username = 'mike_wilson'), 'Beautiful shot! í³¸'),
((SELECT id FROM posts WHERE content LIKE '%architecture%'), (SELECT id FROM users WHERE username = 'sarah_jones'), 'Great composition!');

-- Insert sample likes
INSERT INTO likes (user_id, post_id) VALUES
((SELECT id FROM users WHERE username = 'jane_smith'), (SELECT id FROM posts WHERE content LIKE '%web application%')),
((SELECT id FROM users WHERE username = 'mike_wilson'), (SELECT id FROM posts WHERE content LIKE '%web application%')),
((SELECT id FROM users WHERE username = 'sarah_jones'), (SELECT id FROM posts WHERE content LIKE '%sunset%'));
```

### Sample Queries
```sql
-- Get user feed (posts from followed users)
SELECT p.*, u.username, u.first_name, u.last_name, u.avatar_url
FROM posts p
JOIN users u ON p.user_id = u.id
JOIN follows f ON f.following_id = p.user_id
WHERE f.follower_id = (SELECT id FROM users WHERE username = 'jane_smith')
ORDER BY p.created_at DESC
LIMIT 20;

-- Get post details with comments and likes
SELECT 
    p.*,
    u.username,
    u.first_name,
    u.last_name,
    u.avatar_url,
    COUNT(DISTINCT c.id) as comment_count,
    COUNT(DISTINCT l.id) as like_count
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN comments c ON c.post_id = p.id
LEFT JOIN likes l ON l.post_id = p.id
WHERE p.id = (SELECT id FROM posts WHERE content LIKE '%web application%')
GROUP BY p.id, u.username, u.first_name, u.last_name, u.avatar_url;

-- Get user's followers and following
SELECT 
    u.username,
    u.first_name,
    u.last_name,
    u.avatar_url,
    f.created_at as followed_since
FROM follows f
JOIN users u ON f.follower_id = u.id
WHERE f.following_id = (SELECT id FROM users WHERE username = 'john_doe')
ORDER BY f.created_at DESC;
```

## Key Learning Points

### 1. Database Design Principles
- **Normalization**: Proper 3NF design to eliminate redundancy
- **Relationships**: One-to-many, many-to-many relationships
- **Constraints**: Primary keys, foreign keys, unique constraints, check constraints
- **Data Types**: Appropriate data types for different fields

### 2. Performance Optimization
- **Indexing**: Strategic indexing for query performance
- **Partitioning**: Time-based partitioning for large tables
- **Query Optimization**: Efficient query design
- **Composite Indexes**: Multi-column indexes for complex queries

### 3. Scalability Considerations
- **Data Volume**: Design for millions of users and billions of interactions
- **Query Performance**: Optimize for common access patterns
- **Storage Efficiency**: Minimize storage overhead
- **Future Growth**: Plan for scaling requirements

### 4. Security and Privacy
- **Data Protection**: Secure storage of sensitive data
- **Access Control**: Proper user permissions
- **Privacy Settings**: User-controlled privacy options
- **Audit Trail**: Track important changes

This exercise demonstrates how to design a comprehensive database schema for a social media platform that can handle large-scale operations while maintaining data integrity and performance.

