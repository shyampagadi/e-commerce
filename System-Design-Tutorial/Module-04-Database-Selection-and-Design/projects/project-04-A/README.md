# Project 04-A: Schema Design

## Overview

Design a comprehensive database schema for a multi-tenant e-commerce platform that supports user management, product catalog, order processing, payment tracking, analytics, and multi-tenancy with proper data isolation.

## Business Requirements

### Core Features
- **Multi-tenant Architecture**: Support multiple tenants with data isolation
- **User Management**: User registration, authentication, and profile management
- **Product Catalog**: Product management with categories, inventory, and pricing
- **Order Processing**: Order creation, tracking, and fulfillment
- **Payment Processing**: Payment tracking and transaction management
- **Analytics**: Sales analytics and reporting
- **Notifications**: Email and SMS notifications

### Non-Functional Requirements
- **Scalability**: Support 1M+ users and 10M+ products
- **Performance**: Sub-second response times for critical operations
- **Availability**: 99.9% uptime
- **Security**: Data encryption, access control, and audit logging
- **Compliance**: GDPR, PCI DSS, and SOX compliance

## Technical Requirements

### Database Requirements
- **Primary Database**: PostgreSQL for transactional data
- **Analytics Database**: ClickHouse for analytics and reporting
- **Cache**: Redis for session management and caching
- **Search**: Elasticsearch for product search
- **File Storage**: S3 for product images and documents

### Data Volume Estimates
- **Users**: 1M+ users across 100+ tenants
- **Products**: 10M+ products across all tenants
- **Orders**: 100M+ orders over 3 years
- **Transactions**: 500M+ payment transactions
- **Analytics**: 1B+ events per month

## Schema Design

### 1. Multi-Tenancy Schema

#### Tenant Management
```sql
-- Tenants table
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    domain VARCHAR(255) UNIQUE NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    plan VARCHAR(50) DEFAULT 'basic',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    settings JSONB DEFAULT '{}',
    billing_info JSONB DEFAULT '{}'
);

-- Tenant users (many-to-many relationship)
CREATE TABLE tenant_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) DEFAULT 'user',
    permissions JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id, user_id)
);
```

#### Data Isolation Strategy
```sql
-- Row-level security for tenant isolation
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Create policies for tenant isolation
CREATE POLICY tenant_isolation_products ON products
    FOR ALL TO authenticated
    USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

CREATE POLICY tenant_isolation_orders ON orders
    FOR ALL TO authenticated
    USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

CREATE POLICY tenant_isolation_payments ON payments
    FOR ALL TO authenticated
    USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

### 2. User Management Schema

#### User Authentication
```sql
-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    status VARCHAR(50) DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- User addresses
CREATE TABLE user_addresses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) DEFAULT 'shipping', -- shipping, billing
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

-- User preferences
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    currency VARCHAR(3) DEFAULT 'USD',
    language VARCHAR(10) DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    notification_settings JSONB DEFAULT '{}',
    privacy_settings JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);
```

#### User Sessions
```sql
-- User sessions (stored in Redis, backed up in PostgreSQL)
CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_token VARCHAR(255) UNIQUE NOT NULL,
    device_info JSONB DEFAULT '{}',
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. Product Catalog Schema

#### Product Management
```sql
-- Categories
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES categories(id),
    image_url VARCHAR(500),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id, slug)
);

-- Products
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    sku VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    short_description TEXT,
    category_id UUID REFERENCES categories(id),
    brand VARCHAR(100),
    model VARCHAR(100),
    weight DECIMAL(10,3),
    dimensions JSONB DEFAULT '{}', -- {length, width, height}
    is_active BOOLEAN DEFAULT TRUE,
    is_digital BOOLEAN DEFAULT FALSE,
    requires_shipping BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id, sku),
    UNIQUE(tenant_id, slug)
);

-- Product variants
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    sku VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    attributes JSONB DEFAULT '{}', -- {color: "red", size: "L"}
    price DECIMAL(10,2) NOT NULL,
    compare_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    weight DECIMAL(10,3),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, sku)
);

-- Product images
CREATE TABLE product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES product_variants(id) ON DELETE CASCADE,
    url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    sort_order INTEGER DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product inventory
CREATE TABLE product_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 0,
    reserved_quantity INTEGER NOT NULL DEFAULT 0,
    available_quantity INTEGER GENERATED ALWAYS AS (quantity - reserved_quantity) STORED,
    low_stock_threshold INTEGER DEFAULT 10,
    reorder_point INTEGER DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(variant_id)
);
```

### 4. Order Processing Schema

#### Order Management
```sql
-- Orders
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_number VARCHAR(50) NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    shipping_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    shipping_address JSONB NOT NULL,
    billing_address JSONB NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_at TIMESTAMP,
    delivered_at TIMESTAMP,
    UNIQUE(tenant_id, order_number)
);

-- Order items
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    variant_id UUID REFERENCES product_variants(id),
    sku VARCHAR(100) NOT NULL,
    name VARCHAR(255) NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order status history
CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5. Payment Processing Schema

#### Payment Management
```sql
-- Payments
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id),
    payment_method VARCHAR(50) NOT NULL, -- credit_card, paypal, etc.
    payment_provider VARCHAR(50) NOT NULL, -- stripe, paypal, etc.
    external_payment_id VARCHAR(255),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'pending',
    gateway_response JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payment transactions
CREATE TABLE payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES payments(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- charge, refund, void
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    gateway_transaction_id VARCHAR(255),
    gateway_response JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6. Analytics Schema

#### Event Tracking
```sql
-- Events (for analytics)
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    session_id UUID,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Page views
CREATE TABLE page_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    session_id UUID,
    page_url VARCHAR(500) NOT NULL,
    page_title VARCHAR(255),
    referrer VARCHAR(500),
    user_agent TEXT,
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Indexing Strategy

### Primary Indexes
```sql
-- Primary key indexes (automatically created)
-- users.id, products.id, orders.id, etc.

-- Unique indexes
CREATE UNIQUE INDEX idx_users_email ON users(email);
CREATE UNIQUE INDEX idx_tenants_domain ON tenants(domain);
CREATE UNIQUE INDEX idx_products_tenant_sku ON products(tenant_id, sku);
CREATE UNIQUE INDEX idx_orders_tenant_number ON orders(tenant_id, order_number);
```

### Performance Indexes
```sql
-- Foreign key indexes
CREATE INDEX idx_products_tenant_id ON products(tenant_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_tenant_id ON orders(tenant_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);

-- Query optimization indexes
CREATE INDEX idx_products_active ON products(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_products_tenant_active ON products(tenant_id, is_active);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_events_tenant_type ON events(tenant_id, event_type);
CREATE INDEX idx_events_created_at ON events(created_at);
```

### Composite Indexes
```sql
-- Multi-column indexes for complex queries
CREATE INDEX idx_products_tenant_category_active ON products(tenant_id, category_id, is_active);
CREATE INDEX idx_orders_user_status_created ON orders(user_id, status, created_at);
CREATE INDEX idx_events_tenant_user_created ON events(tenant_id, user_id, created_at);
```

## Data Partitioning

### Time-Based Partitioning
```sql
-- Partition events table by month
CREATE TABLE events_2024_01 PARTITION OF events
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE events_2024_02 PARTITION OF events
    FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Partition page_views table by month
CREATE TABLE page_views_2024_01 PARTITION OF page_views
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

### Tenant-Based Partitioning
```sql
-- Partition products by tenant (if needed for very large tenants)
CREATE TABLE products_tenant_1 PARTITION OF products
    FOR VALUES IN ('tenant-1-uuid');

CREATE TABLE products_tenant_2 PARTITION OF products
    FOR VALUES IN ('tenant-2-uuid');
```

## Data Archiving

### Archive Strategy
```sql
-- Archive old orders (older than 7 years)
CREATE TABLE orders_archive (LIKE orders INCLUDING ALL);

-- Archive old events (older than 2 years)
CREATE TABLE events_archive (LIKE events INCLUDING ALL);

-- Archive old page views (older than 1 year)
CREATE TABLE page_views_archive (LIKE page_views INCLUDING ALL);
```

## Security Implementation

### Row-Level Security
```sql
-- Enable RLS on all tenant-specific tables
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE page_views ENABLE ROW LEVEL SECURITY;

-- Create policies for tenant isolation
CREATE POLICY tenant_isolation_products ON products
    FOR ALL TO authenticated
    USING (tenant_id = current_setting('app.current_tenant_id')::UUID);

CREATE POLICY tenant_isolation_orders ON orders
    FOR ALL TO authenticated
    USING (tenant_id = current_setting('app.current_tenant_id')::UUID);
```

### Data Encryption
```sql
-- Encrypt sensitive data
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Encrypt PII data
ALTER TABLE users ADD COLUMN encrypted_phone BYTEA;
ALTER TABLE user_addresses ADD COLUMN encrypted_phone BYTEA;

-- Create functions for encryption/decryption
CREATE OR REPLACE FUNCTION encrypt_phone(phone VARCHAR)
RETURNS BYTEA AS $$
BEGIN
    RETURN pgp_sym_encrypt(phone, current_setting('app.encryption_key'));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrypt_phone(encrypted_phone BYTEA)
RETURNS VARCHAR AS $$
BEGIN
    RETURN pgp_sym_decrypt(encrypted_phone, current_setting('app.encryption_key'));
END;
$$ LANGUAGE plpgsql;
```

## Performance Optimization

### Query Optimization
```sql
-- Create materialized views for complex queries
CREATE MATERIALIZED VIEW product_analytics AS
SELECT 
    p.tenant_id,
    p.category_id,
    c.name as category_name,
    COUNT(*) as product_count,
    AVG(pv.price) as avg_price,
    SUM(pi.quantity) as total_inventory
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN product_variants pv ON p.id = pv.product_id
JOIN product_inventory pi ON pv.id = pi.variant_id
WHERE p.is_active = TRUE
GROUP BY p.tenant_id, p.category_id, c.name;

-- Create index on materialized view
CREATE INDEX idx_product_analytics_tenant ON product_analytics(tenant_id);

-- Refresh materialized view
REFRESH MATERIALIZED VIEW CONCURRENTLY product_analytics;
```

### Connection Pooling
```sql
-- Configure connection pooling
-- Use pgbouncer or similar for connection pooling
-- Configure in application or infrastructure layer
```

## Monitoring and Alerting

### Performance Monitoring
```sql
-- Create monitoring views
CREATE VIEW slow_queries AS
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
WHERE mean_time > 1000 -- queries taking more than 1 second
ORDER BY mean_time DESC;

-- Create table size monitoring
CREATE VIEW table_sizes AS
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

## Implementation Checklist

### Phase 1: Core Schema (Week 1)
- [ ] Create tenant management tables
- [ ] Implement user management schema
- [ ] Set up basic product catalog
- [ ] Configure row-level security
- [ ] Create essential indexes

### Phase 2: Order Processing (Week 2)
- [ ] Implement order management schema
- [ ] Create payment processing tables
- [ ] Set up order status tracking
- [ ] Implement order item management
- [ ] Create order-related indexes

### Phase 3: Analytics and Optimization (Week 3)
- [ ] Set up event tracking schema
- [ ] Create analytics tables
- [ ] Implement data partitioning
- [ ] Set up materialized views
- [ ] Configure performance monitoring

### Phase 4: Security and Compliance (Week 4)
- [ ] Implement data encryption
- [ ] Set up audit logging
- [ ] Configure backup and recovery
- [ ] Implement data archiving
- [ ] Set up compliance reporting

## Testing Strategy

### Unit Tests
- [ ] Test all table constraints
- [ ] Test foreign key relationships
- [ ] Test unique constraints
- [ ] Test check constraints
- [ ] Test trigger functions

### Integration Tests
- [ ] Test multi-tenant data isolation
- [ ] Test order processing workflow
- [ ] Test payment processing workflow
- [ ] Test analytics data collection
- [ ] Test data archiving

### Performance Tests
- [ ] Test query performance
- [ ] Test concurrent access
- [ ] Test data volume handling
- [ ] Test index effectiveness
- [ ] Test connection pooling

## Conclusion

This schema design provides a comprehensive foundation for a multi-tenant e-commerce platform with proper data isolation, scalability, and performance optimization. The design follows best practices for PostgreSQL, implements proper security measures, and provides a solid foundation for future growth and expansion.

The key aspects of this design include:
- **Multi-tenancy**: Proper tenant isolation using row-level security
- **Scalability**: Partitioning and indexing strategies for large datasets
- **Performance**: Optimized queries and materialized views
- **Security**: Data encryption and access control
- **Compliance**: Audit logging and data archiving
- **Flexibility**: JSONB columns for extensible data structures

