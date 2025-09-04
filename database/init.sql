-- 🗄️ E-Commerce Database Initialization Script
-- ===============================================
-- This SQL script initializes the PostgreSQL database for the e-commerce application.
-- It creates essential extensions, sets up basic configuration, and prepares the database
-- for the SQLAlchemy models to be created by the Python setup script.

-- Enable required PostgreSQL extensions
-- ====================================

-- UUID extension for generating unique identifiers
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Full-text search extension for product search functionality
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Unaccent extension for accent-insensitive searches
CREATE EXTENSION IF NOT EXISTS "unaccent";

-- Set database configuration
-- =========================

-- Set timezone to UTC for consistent timestamps
SET timezone = 'UTC';

-- Enable row-level security (can be used for multi-tenancy later)
-- ALTER DATABASE ecommerce_db SET row_security = on;

-- Create custom functions for the application
-- ==========================================

-- Function to update the updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to generate slugs from text (backup if Python slug generation fails)
CREATE OR REPLACE FUNCTION generate_slug(input_text TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN lower(
        regexp_replace(
            regexp_replace(
                regexp_replace(input_text, '[^a-zA-Z0-9\s-]', '', 'g'),
                '\s+', '-', 'g'
            ),
            '-+', '-', 'g'
        )
    );
END;
$$ LANGUAGE plpgsql;

-- Function for full-text search on products
CREATE OR REPLACE FUNCTION search_products(search_term TEXT)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR(255),
    description TEXT,
    price DECIMAL(10,2),
    rank REAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.description,
        p.price,
        ts_rank(
            to_tsvector('english', p.name || ' ' || COALESCE(p.description, '')),
            plainto_tsquery('english', search_term)
        ) as rank
    FROM products p
    WHERE to_tsvector('english', p.name || ' ' || COALESCE(p.description, '')) 
          @@ plainto_tsquery('english', search_term)
    ORDER BY rank DESC;
END;
$$ LANGUAGE plpgsql;

-- Create sequences for custom ID generation (if needed)
-- ====================================================

-- Sequence for order numbers (human-readable order IDs)
CREATE SEQUENCE IF NOT EXISTS order_number_seq
    START WITH 1000
    INCREMENT BY 1
    NO MAXVALUE
    CACHE 1;

-- Sequence for SKU generation (if auto-generation is needed)
CREATE SEQUENCE IF NOT EXISTS sku_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    CACHE 1;

-- Create custom types/enums
-- ========================

-- Order status enum
DO $$ BEGIN
    CREATE TYPE order_status AS ENUM (
        'pending',
        'confirmed',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
        'refunded'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Payment status enum
DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM (
        'pending',
        'processing',
        'completed',
        'failed',
        'refunded'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- User role enum
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM (
        'customer',
        'admin',
        'moderator'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Set up database permissions
-- ==========================

-- Grant usage on sequences to the application user
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO postgres;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION update_updated_at_column() TO postgres;
GRANT EXECUTE ON FUNCTION generate_slug(TEXT) TO postgres;
GRANT EXECUTE ON FUNCTION search_products(TEXT) TO postgres;

-- Create indexes that will be useful once tables are created
-- =========================================================
-- Note: These will be created by SQLAlchemy, but we can prepare for them

-- Prepare for common query patterns
-- (These CREATE INDEX statements will be executed after tables are created)

-- Performance optimization settings
-- ================================

-- Increase work_mem for better query performance
-- ALTER SYSTEM SET work_mem = '256MB';

-- Increase shared_buffers for better caching
-- ALTER SYSTEM SET shared_buffers = '256MB';

-- Enable query planning optimizations
-- ALTER SYSTEM SET random_page_cost = 1.1;

-- Log configuration for debugging (development only)
-- ALTER SYSTEM SET log_statement = 'all';
-- ALTER SYSTEM SET log_min_duration_statement = 1000;

-- Reload configuration
-- SELECT pg_reload_conf();

-- Create application-specific schemas (if needed for organization)
-- ==============================================================

-- Schema for audit tables
CREATE SCHEMA IF NOT EXISTS audit;

-- Schema for temporary/staging data
CREATE SCHEMA IF NOT EXISTS staging;

-- Grant permissions on schemas
GRANT USAGE ON SCHEMA audit TO postgres;
GRANT USAGE ON SCHEMA staging TO postgres;
GRANT CREATE ON SCHEMA audit TO postgres;
GRANT CREATE ON SCHEMA staging TO postgres;

-- Success message
-- ==============
DO $$
BEGIN
    RAISE NOTICE '✅ Database initialization completed successfully!';
    RAISE NOTICE '📋 Extensions enabled: uuid-ossp, pg_trgm, unaccent';
    RAISE NOTICE '🔧 Custom functions created for timestamps and search';
    RAISE NOTICE '📊 Sequences and enums prepared for application use';
    RAISE NOTICE '🚀 Database is ready for SQLAlchemy model creation';
END $$;
