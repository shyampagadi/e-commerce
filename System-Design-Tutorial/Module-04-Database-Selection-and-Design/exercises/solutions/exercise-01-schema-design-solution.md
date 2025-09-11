# Exercise 1: Database Schema Design - Solution

## Overview

This solution demonstrates a comprehensive database schema design for a social media platform that can handle millions of users and billions of interactions. The design follows normalization principles while optimizing for performance and scalability.

## Complete Schema Implementation

### 1. Database Setup

```sql
-- Create database
CREATE DATABASE social_media_platform;
\c social_media_platform;

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
```

### 2. User Management Tables

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

-- User addresses
CREATE TABLE user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) DEFAULT 'shipping',
    is_default BOOLEAN DEFAULT FALSE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    company VARCHAR(255),
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. Social Relationship Tables

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

-- User preferences
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    preference_key VARCHAR(100) NOT NULL,
    preference_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, preference_key)
);
```

### 4. Content Management Tables

```sql
-- Posts table
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

-- Post media
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

-- Post tags
CREATE TABLE post_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(post_id, tag_name)
);
```

### 5. Interaction Tables

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
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id)
);

-- Bookmarks table
CREATE TABLE bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id)
);
```

### 6. Messaging Tables

```sql
-- Conversations table
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_group BOOLEAN DEFAULT FALSE,
    name VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Conversation participants
CREATE TABLE conversation_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member',
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
    message_type VARCHAR(20) DEFAULT 'text',
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

### 7. Notification Tables

```sql
-- Notifications table
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
CREATE UNIQUE INDEX idx_bookmarks_user_post ON bookmarks(user_id, post_id);
```

### Performance Indexes
```sql
-- Foreign key indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at);
CREATE INDEX idx_posts_reply_to_post_id ON posts(reply_to_post_id);
CREATE INDEX idx_posts_is_public ON posts(is_public);
CREATE INDEX idx_posts_is_pinned ON posts(is_pinned);
CREATE INDEX idx_comments_post_id ON comments(post_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_comments_created_at ON comments(created_at);
CREATE INDEX idx_likes_post_id ON likes(post_id) WHERE post_id IS NOT NULL;
CREATE INDEX idx_likes_comment_id ON likes(comment_id) WHERE comment_id IS NOT NULL;
CREATE INDEX idx_shares_post_id ON shares(post_id);
CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
```

### Composite Indexes
```sql
-- Multi-column indexes for complex queries
CREATE INDEX idx_posts_user_created ON posts(user_id, created_at DESC);
CREATE INDEX idx_posts_public_created ON posts(is_public, created_at DESC) WHERE is_public = TRUE;
CREATE INDEX idx_posts_pinned_created ON posts(is_pinned, created_at DESC) WHERE is_pinned = TRUE;
CREATE INDEX idx_comments_post_created ON comments(post_id, created_at DESC);
CREATE INDEX idx_messages_conversation_created ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read, created_at DESC);
CREATE INDEX idx_follows_follower_created ON follows(follower_id, created_at DESC);
CREATE INDEX idx_follows_following_created ON follows(following_id, created_at DESC);
```

### Full-Text Search Indexes
```sql
-- Full-text search for posts
CREATE INDEX idx_posts_content_fts ON posts USING gin(to_tsvector('english', content));

-- Full-text search for comments
CREATE INDEX idx_comments_content_fts ON comments USING gin(to_tsvector('english', content));

-- Full-text search for users
CREATE INDEX idx_users_bio_fts ON users USING gin(to_tsvector('english', bio));
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

-- Partition notifications table by month
CREATE TABLE notifications_2024_01 PARTITION OF notifications
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE notifications_2024_02 PARTITION OF notifications
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
```

## Sample Data Insertion

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

## Sample Queries

### 1. User Feed Query
```sql
-- Get user feed (posts from followed users)
SELECT 
    p.id,
    p.content,
    p.created_at,
    u.username,
    u.first_name,
    u.last_name,
    u.avatar_url,
    COUNT(DISTINCT c.id) as comment_count,
    COUNT(DISTINCT l.id) as like_count,
    COUNT(DISTINCT s.id) as share_count
FROM posts p
JOIN users u ON p.user_id = u.id
JOIN follows f ON f.following_id = p.user_id
LEFT JOIN comments c ON c.post_id = p.id
LEFT JOIN likes l ON l.post_id = p.id
LEFT JOIN shares s ON s.post_id = p.id
WHERE f.follower_id = (SELECT id FROM users WHERE username = 'jane_smith')
  AND p.is_public = TRUE
GROUP BY p.id, p.content, p.created_at, u.username, u.first_name, u.last_name, u.avatar_url
ORDER BY p.created_at DESC
LIMIT 20;
```

### 2. Post Details Query
```sql
-- Get post details with comments and likes
SELECT 
    p.id,
    p.content,
    p.created_at,
    u.username,
    u.first_name,
    u.last_name,
    u.avatar_url,
    COUNT(DISTINCT c.id) as comment_count,
    COUNT(DISTINCT l.id) as like_count,
    COUNT(DISTINCT s.id) as share_count
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN comments c ON c.post_id = p.id
LEFT JOIN likes l ON l.post_id = p.id
LEFT JOIN shares s ON s.post_id = p.id
WHERE p.id = (SELECT id FROM posts WHERE content LIKE '%web application%')
GROUP BY p.id, p.content, p.created_at, u.username, u.first_name, u.last_name, u.avatar_url;
```

### 3. User Followers Query
```sql
-- Get user's followers
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

### 4. Search Posts Query
```sql
-- Search posts by content
SELECT 
    p.id,
    p.content,
    p.created_at,
    u.username,
    u.first_name,
    u.last_name,
    u.avatar_url
FROM posts p
JOIN users u ON p.user_id = u.id
WHERE to_tsvector('english', p.content) @@ plainto_tsquery('english', 'web application')
  AND p.is_public = TRUE
ORDER BY p.created_at DESC
LIMIT 20;
```

### 5. User Statistics Query
```sql
-- Get user statistics
SELECT 
    u.username,
    u.first_name,
    u.last_name,
    COUNT(DISTINCT p.id) as post_count,
    COUNT(DISTINCT f1.follower_id) as follower_count,
    COUNT(DISTINCT f2.following_id) as following_count,
    COUNT(DISTINCT l.id) as total_likes_received
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
LEFT JOIN follows f1 ON f1.following_id = u.id
LEFT JOIN follows f2 ON f2.follower_id = u.id
LEFT JOIN likes l ON l.post_id = p.id
WHERE u.username = 'john_doe'
GROUP BY u.username, u.first_name, u.last_name;
```

## Performance Optimization

### 1. Query Optimization
- Use appropriate indexes for all query patterns
- Optimize JOIN operations with proper indexing
- Use EXPLAIN ANALYZE to identify slow queries
- Consider materialized views for complex aggregations

### 2. Caching Strategy
- Cache frequently accessed user data
- Cache post feeds for active users
- Cache search results
- Use Redis for session management

### 3. Database Tuning
- Configure connection pooling
- Optimize memory settings
- Tune query planner settings
- Monitor and optimize slow queries

### 4. Scaling Strategies
- Use read replicas for read-heavy workloads
- Implement database partitioning
- Consider sharding for very large datasets
- Use CDN for media content

## Security Considerations

### 1. Data Protection
- Encrypt sensitive data at rest
- Use HTTPS for all communications
- Implement proper access controls
- Regular security audits

### 2. Privacy Controls
- Respect user privacy settings
- Implement data retention policies
- Provide data export capabilities
- Comply with GDPR and other regulations

### 3. Access Control
- Implement role-based access control
- Use proper authentication and authorization
- Audit all database access
- Implement rate limiting

## Conclusion

This schema design provides a comprehensive foundation for a social media platform that can handle millions of users and billions of interactions. The key aspects of this design include:

- **Normalization**: Proper 3NF design to eliminate redundancy
- **Performance**: Strategic indexing for query optimization
- **Scalability**: Partitioning and sharding strategies
- **Security**: Data protection and access control
- **Flexibility**: Extensible design for future growth

The design balances data integrity, performance, and scalability while providing a solid foundation for a modern social media platform.

