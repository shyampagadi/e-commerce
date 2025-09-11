# Exercise 03: Data Warehouse Design and Implementation

## Objective
Design and implement a comprehensive data warehouse solution for a global retail company that supports business intelligence, analytics, and machine learning workloads across multiple business units.

## Business Context

### Global Retail Company Profile
```yaml
Business Scale:
  - 50M+ customers across 25 countries
  - 10,000+ retail stores worldwide
  - 1M+ products in catalog
  - $50B+ annual revenue

Data Sources:
  - Point-of-sale systems (1000+ stores)
  - E-commerce platform (web and mobile)
  - Supply chain management systems
  - Customer relationship management (CRM)
  - Marketing automation platforms
  - Financial systems (ERP)

Analytics Requirements:
  - Real-time dashboards for operations
  - Historical trend analysis (5+ years)
  - Customer segmentation and lifetime value
  - Inventory optimization and forecasting
  - Financial reporting and compliance
  - Marketing campaign effectiveness
```

## Exercise Tasks

### Task 1: Dimensional Model Design (60 minutes)
Design a comprehensive dimensional model for the retail data warehouse:

**Business Processes to Model:**
1. **Sales Transactions**
   - In-store and online sales
   - Returns and exchanges
   - Promotions and discounts
   - Payment methods and loyalty programs

2. **Inventory Management**
   - Stock levels and movements
   - Purchase orders and receipts
   - Supplier performance
   - Warehouse operations

3. **Customer Analytics**
   - Customer demographics and preferences
   - Purchase history and behavior
   - Marketing campaign responses
   - Customer service interactions

4. **Financial Performance**
   - Revenue and profitability analysis
   - Cost center performance
   - Budget vs. actual reporting
   - Currency conversion and consolidation

**Deliverables:**
1. **Fact Table Designs** (4 major fact tables)
   - Grain definition and measures
   - Additive, semi-additive, and non-additive measures
   - Slowly changing dimension handling
   - Factless fact tables where appropriate

2. **Dimension Table Designs** (10+ dimensions)
   - Hierarchical structures and drill-down paths
   - Type 1, Type 2, and Type 3 SCD implementation
   - Bridge tables for many-to-many relationships
   - Junk dimensions for miscellaneous attributes

3. **Star Schema Diagrams**
   - Logical data model with relationships
   - Physical implementation considerations
   - Indexing and partitioning strategies

### Task 2: Redshift Implementation (75 minutes)
Implement the data warehouse using Amazon Redshift:

**Cluster Configuration:**
```yaml
Redshift Cluster Setup:
  Node Type: ra3.4xlarge
  Number of Nodes: 6 (scalable to 20)
  Total Storage: Managed storage (auto-scaling)
  Compute Capacity: 192 vCPUs, 1.5TB RAM
  
Performance Features:
  - Automatic WLM (Workload Management)
  - Concurrency scaling (up to 10 clusters)
  - Result caching (24-hour TTL)
  - Materialized views for aggregations
```

**Implementation Steps:**

**Step 1: Create Fact Tables**
```sql
-- Sales fact table with optimized design
CREATE TABLE fact_sales (
    sale_id BIGINT IDENTITY(1,1),
    date_key INTEGER NOT NULL,
    time_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    customer_key INTEGER NOT NULL,
    promotion_key INTEGER NOT NULL,
    payment_method_key INTEGER NOT NULL,
    
    -- Measures
    quantity_sold DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    cost_amount DECIMAL(10,2) NOT NULL,
    profit_amount DECIMAL(10,2) NOT NULL,
    
    -- Metadata
    transaction_number VARCHAR(50) NOT NULL,
    channel VARCHAR(20) NOT NULL, -- 'STORE', 'ONLINE', 'MOBILE'
    currency_code CHAR(3) NOT NULL,
    exchange_rate DECIMAL(10,6) DEFAULT 1.0,
    
    created_timestamp TIMESTAMP DEFAULT GETDATE()
)
DISTKEY(customer_key)
SORTKEY(date_key, store_key);

-- Inventory fact table for stock movements
CREATE TABLE fact_inventory (
    inventory_id BIGINT IDENTITY(1,1),
    date_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL,
    store_key INTEGER NOT NULL,
    supplier_key INTEGER NOT NULL,
    
    -- Measures
    beginning_quantity INTEGER NOT NULL,
    received_quantity INTEGER DEFAULT 0,
    sold_quantity INTEGER DEFAULT 0,
    adjusted_quantity INTEGER DEFAULT 0,
    ending_quantity INTEGER NOT NULL,
    
    unit_cost DECIMAL(10,2) NOT NULL,
    total_value DECIMAL(12,2) NOT NULL,
    
    created_timestamp TIMESTAMP DEFAULT GETDATE()
)
DISTKEY(product_key)
SORTKEY(date_key, store_key);
```

**Step 2: Create Dimension Tables**
```sql
-- Customer dimension with SCD Type 2
CREATE TABLE dim_customer (
    customer_key INTEGER IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50) NOT NULL,
    
    -- Current attributes
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    
    -- Address information
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Demographics
    birth_date DATE,
    gender CHAR(1),
    marital_status VARCHAR(20),
    income_range VARCHAR(50),
    
    -- Behavioral attributes
    customer_segment VARCHAR(50),
    loyalty_tier VARCHAR(20),
    preferred_channel VARCHAR(20),
    
    -- SCD Type 2 attributes
    effective_date DATE NOT NULL,
    expiration_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    
    created_timestamp TIMESTAMP DEFAULT GETDATE(),
    updated_timestamp TIMESTAMP DEFAULT GETDATE()
)
DISTKEY(customer_key)
SORTKEY(customer_id, effective_date);

-- Product dimension with hierarchy
CREATE TABLE dim_product (
    product_key INTEGER IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(50) NOT NULL UNIQUE,
    
    -- Product attributes
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    brand VARCHAR(100),
    manufacturer VARCHAR(100),
    
    -- Hierarchy levels
    category_level1 VARCHAR(100), -- Department
    category_level2 VARCHAR(100), -- Category  
    category_level3 VARCHAR(100), -- Subcategory
    category_level4 VARCHAR(100), -- Product Type
    
    -- Physical attributes
    size VARCHAR(50),
    color VARCHAR(50),
    weight DECIMAL(8,2),
    unit_of_measure VARCHAR(20),
    
    -- Business attributes
    list_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    margin_percent DECIMAL(5,2),
    
    -- Status and dates
    product_status VARCHAR(20), -- 'ACTIVE', 'DISCONTINUED', 'SEASONAL'
    launch_date DATE,
    discontinue_date DATE,
    
    created_timestamp TIMESTAMP DEFAULT GETDATE(),
    updated_timestamp TIMESTAMP DEFAULT GETDATE()
)
DISTKEY(product_key)
SORTKEY(product_id);

-- Date dimension with comprehensive attributes
CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    
    -- Date components
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    week INTEGER NOT NULL,
    day_of_year INTEGER NOT NULL,
    day_of_month INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    
    -- Formatted strings
    year_month CHAR(7), -- 'YYYY-MM'
    year_quarter CHAR(7), -- 'YYYY-Q1'
    month_name VARCHAR(20),
    day_name VARCHAR(20),
    
    -- Business calendar
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    holiday_name VARCHAR(100),
    fiscal_year INTEGER,
    fiscal_quarter INTEGER,
    fiscal_month INTEGER,
    
    -- Retail calendar
    retail_week INTEGER,
    retail_month INTEGER,
    retail_quarter INTEGER,
    retail_year INTEGER,
    
    created_timestamp TIMESTAMP DEFAULT GETDATE()
)
DISTKEY(date_key)
SORTKEY(date_key);
```

**Step 3: Implement ETL Processes**
```python
# ETL process using Python and psycopg2
import psycopg2
import pandas as pd
from datetime import datetime, timedelta

class DataWarehouseETL:
    def __init__(self, redshift_config):
        self.conn = psycopg2.connect(**redshift_config)
        self.cursor = self.conn.cursor()
    
    def load_sales_fact(self, source_data_path, load_date):
        """
        Load sales fact data with proper dimension key lookups
        """
        # Read source data
        sales_df = pd.read_csv(source_data_path)
        
        # Lookup dimension keys
        sales_df = self.lookup_dimension_keys(sales_df)
        
        # Data quality checks
        self.validate_sales_data(sales_df)
        
        # Load to staging table first
        self.load_to_staging(sales_df, 'staging_sales')
        
        # Merge to fact table
        merge_sql = """
        INSERT INTO fact_sales (
            date_key, store_key, product_key, customer_key,
            quantity_sold, unit_price, total_amount, cost_amount
        )
        SELECT 
            s.date_key, s.store_key, s.product_key, s.customer_key,
            s.quantity_sold, s.unit_price, s.total_amount, s.cost_amount
        FROM staging_sales s
        WHERE NOT EXISTS (
            SELECT 1 FROM fact_sales f 
            WHERE f.transaction_number = s.transaction_number
        );
        """
        
        self.cursor.execute(merge_sql)
        self.conn.commit()
    
    def update_customer_dimension(self, customer_updates):
        """
        Handle SCD Type 2 updates for customer dimension
        """
        for customer in customer_updates:
            # Check if customer attributes changed
            if self.customer_attributes_changed(customer):
                # Expire current record
                expire_sql = """
                UPDATE dim_customer 
                SET expiration_date = %s, is_current = FALSE
                WHERE customer_id = %s AND is_current = TRUE;
                """
                self.cursor.execute(expire_sql, (datetime.now().date(), customer['customer_id']))
                
                # Insert new record
                insert_sql = """
                INSERT INTO dim_customer (
                    customer_id, first_name, last_name, email,
                    customer_segment, loyalty_tier, effective_date
                ) VALUES (%s, %s, %s, %s, %s, %s, %s);
                """
                self.cursor.execute(insert_sql, (
                    customer['customer_id'], customer['first_name'],
                    customer['last_name'], customer['email'],
                    customer['segment'], customer['tier'], datetime.now().date()
                ))
        
        self.conn.commit()
```

### Task 3: Performance Optimization (45 minutes)
Optimize the data warehouse for query performance:

**Optimization Areas:**

**1. Distribution and Sort Keys**
```sql
-- Analyze table statistics for optimization
ANALYZE fact_sales;
ANALYZE dim_customer;
ANALYZE dim_product;

-- Check distribution key effectiveness
SELECT 
    slice,
    COUNT(*) as row_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentage
FROM stv_tbl_perm 
WHERE name = 'fact_sales'
GROUP BY slice
ORDER BY slice;

-- Optimize sort key based on query patterns
ALTER TABLE fact_sales ALTER SORTKEY (date_key, store_key, customer_key);
```

**2. Materialized Views for Aggregations**
```sql
-- Monthly sales summary materialized view
CREATE MATERIALIZED VIEW mv_monthly_sales AS
SELECT 
    d.year,
    d.month,
    d.year_month,
    s.store_key,
    p.category_level1,
    p.category_level2,
    
    COUNT(*) as transaction_count,
    SUM(f.quantity_sold) as total_quantity,
    SUM(f.total_amount) as total_revenue,
    SUM(f.cost_amount) as total_cost,
    SUM(f.profit_amount) as total_profit,
    AVG(f.total_amount) as avg_transaction_value,
    
    COUNT(DISTINCT f.customer_key) as unique_customers
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_store s ON f.store_key = s.store_key  
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY 1,2,3,4,5,6;

-- Customer lifetime value materialized view
CREATE MATERIALIZED VIEW mv_customer_ltv AS
SELECT 
    c.customer_key,
    c.customer_segment,
    c.loyalty_tier,
    
    MIN(d.full_date) as first_purchase_date,
    MAX(d.full_date) as last_purchase_date,
    COUNT(DISTINCT d.full_date) as purchase_days,
    COUNT(*) as total_transactions,
    
    SUM(f.total_amount) as lifetime_revenue,
    SUM(f.profit_amount) as lifetime_profit,
    AVG(f.total_amount) as avg_order_value,
    
    DATEDIFF(day, MIN(d.full_date), MAX(d.full_date)) as customer_lifespan_days
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE c.is_current = TRUE
GROUP BY 1,2,3;
```

**3. Query Optimization Techniques**
```sql
-- Optimized query with proper joins and filters
SELECT 
    d.year_month,
    p.category_level1,
    s.region,
    
    SUM(f.total_amount) as revenue,
    SUM(f.profit_amount) as profit,
    COUNT(DISTINCT f.customer_key) as unique_customers,
    AVG(f.total_amount) as avg_order_value
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_store s ON f.store_key = s.store_key
WHERE d.full_date >= '2023-01-01'
  AND d.full_date < '2024-01-01'
  AND p.category_level1 IN ('Electronics', 'Clothing', 'Home')
  AND s.country = 'United States'
GROUP BY 1,2,3
ORDER BY 1,2,3;

-- Use EXPLAIN to analyze query execution plan
EXPLAIN SELECT * FROM mv_monthly_sales 
WHERE year = 2023 AND category_level1 = 'Electronics';
```

### Task 4: Advanced Analytics Implementation (45 minutes)
Implement advanced analytics capabilities:

**1. Customer Segmentation Analysis**
```sql
-- RFM (Recency, Frequency, Monetary) Analysis
WITH customer_rfm AS (
    SELECT 
        c.customer_key,
        c.customer_id,
        
        -- Recency (days since last purchase)
        DATEDIFF(day, MAX(d.full_date), CURRENT_DATE) as recency_days,
        
        -- Frequency (number of purchases in last year)
        COUNT(*) as frequency_count,
        
        -- Monetary (total spent in last year)
        SUM(f.total_amount) as monetary_value
    FROM fact_sales f
    JOIN dim_customer c ON f.customer_key = c.customer_key
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE d.full_date >= DATEADD(year, -1, CURRENT_DATE)
      AND c.is_current = TRUE
    GROUP BY 1,2
),
rfm_scores AS (
    SELECT *,
        -- Calculate quintiles for each RFM component
        NTILE(5) OVER (ORDER BY recency_days DESC) as recency_score,
        NTILE(5) OVER (ORDER BY frequency_count) as frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value) as monetary_score
    FROM customer_rfm
)
SELECT 
    customer_key,
    customer_id,
    recency_score,
    frequency_score, 
    monetary_score,
    
    -- Create customer segments based on RFM scores
    CASE 
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 
        THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3
        THEN 'Loyal Customers'
        WHEN recency_score >= 3 AND frequency_score <= 2
        THEN 'Potential Loyalists'
        WHEN recency_score <= 2 AND frequency_score >= 3
        THEN 'At Risk'
        WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score >= 3
        THEN 'Cannot Lose Them'
        ELSE 'Others'
    END as customer_segment
FROM rfm_scores;
```

**2. Product Performance Analysis**
```sql
-- Product performance with trend analysis
WITH monthly_product_sales AS (
    SELECT 
        p.product_key,
        p.product_name,
        p.category_level1,
        d.year_month,
        
        SUM(f.quantity_sold) as units_sold,
        SUM(f.total_amount) as revenue,
        SUM(f.profit_amount) as profit,
        AVG(f.unit_price) as avg_price
    FROM fact_sales f
    JOIN dim_product p ON f.product_key = p.product_key
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE d.full_date >= DATEADD(month, -12, CURRENT_DATE)
    GROUP BY 1,2,3,4
),
product_trends AS (
    SELECT *,
        -- Calculate month-over-month growth
        LAG(revenue, 1) OVER (PARTITION BY product_key ORDER BY year_month) as prev_month_revenue,
        LAG(units_sold, 1) OVER (PARTITION BY product_key ORDER BY year_month) as prev_month_units,
        
        -- Calculate 3-month moving average
        AVG(revenue) OVER (
            PARTITION BY product_key 
            ORDER BY year_month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) as revenue_3mo_avg
    FROM monthly_product_sales
)
SELECT 
    product_key,
    product_name,
    category_level1,
    year_month,
    revenue,
    units_sold,
    
    -- Growth calculations
    CASE 
        WHEN prev_month_revenue > 0 
        THEN ((revenue - prev_month_revenue) / prev_month_revenue) * 100
        ELSE NULL 
    END as revenue_growth_pct,
    
    -- Trend classification
    CASE 
        WHEN revenue > revenue_3mo_avg * 1.1 THEN 'Growing'
        WHEN revenue < revenue_3mo_avg * 0.9 THEN 'Declining'
        ELSE 'Stable'
    END as trend_status
FROM product_trends
WHERE year_month = (SELECT MAX(year_month) FROM product_trends);
```

### Task 5: Data Quality and Governance (30 minutes)
Implement data quality monitoring and governance:

**1. Data Quality Checks**
```sql
-- Comprehensive data quality monitoring
CREATE OR REPLACE VIEW vw_data_quality_metrics AS
SELECT 
    'fact_sales' as table_name,
    COUNT(*) as total_records,
    
    -- Completeness checks
    COUNT(*) - COUNT(customer_key) as missing_customer_keys,
    COUNT(*) - COUNT(product_key) as missing_product_keys,
    COUNT(*) - COUNT(total_amount) as missing_amounts,
    
    -- Validity checks  
    COUNT(CASE WHEN total_amount < 0 THEN 1 END) as negative_amounts,
    COUNT(CASE WHEN quantity_sold <= 0 THEN 1 END) as invalid_quantities,
    COUNT(CASE WHEN unit_price <= 0 THEN 1 END) as invalid_prices,
    
    -- Consistency checks
    COUNT(CASE WHEN total_amount != (quantity_sold * unit_price - discount_amount + tax_amount) 
          THEN 1 END) as amount_calculation_errors,
    
    -- Timeliness checks
    MAX(created_timestamp) as last_load_time,
    DATEDIFF(hour, MAX(created_timestamp), CURRENT_TIMESTAMP) as hours_since_last_load
FROM fact_sales

UNION ALL

SELECT 
    'dim_customer' as table_name,
    COUNT(*) as total_records,
    COUNT(*) - COUNT(email) as missing_emails,
    COUNT(*) - COUNT(customer_segment) as missing_segments,
    0 as missing_amounts,
    COUNT(CASE WHEN email NOT LIKE '%@%' THEN 1 END) as invalid_emails,
    0 as invalid_quantities,
    0 as invalid_prices,
    COUNT(CASE WHEN is_current = TRUE AND expiration_date IS NOT NULL THEN 1 END) as scd_errors,
    MAX(updated_timestamp) as last_load_time,
    DATEDIFF(hour, MAX(updated_timestamp), CURRENT_TIMESTAMP) as hours_since_last_load
FROM dim_customer;
```

**2. Automated Data Quality Alerts**
```python
def monitor_data_quality():
    """
    Automated data quality monitoring with alerts
    """
    quality_checks = [
        {
            'name': 'Sales Fact Completeness',
            'query': '''
                SELECT COUNT(*) as missing_keys
                FROM fact_sales 
                WHERE customer_key IS NULL OR product_key IS NULL
                  AND created_timestamp >= CURRENT_DATE
            ''',
            'threshold': 0,
            'severity': 'CRITICAL'
        },
        {
            'name': 'Daily Load Timeliness', 
            'query': '''
                SELECT DATEDIFF(hour, MAX(created_timestamp), CURRENT_TIMESTAMP) as hours_delay
                FROM fact_sales
            ''',
            'threshold': 6,
            'severity': 'WARNING'
        },
        {
            'name': 'Revenue Anomaly Detection',
            'query': '''
                WITH daily_revenue AS (
                    SELECT 
                        d.full_date,
                        SUM(f.total_amount) as daily_revenue
                    FROM fact_sales f
                    JOIN dim_date d ON f.date_key = d.date_key
                    WHERE d.full_date >= CURRENT_DATE - 30
                    GROUP BY 1
                )
                SELECT COUNT(*) as anomaly_days
                FROM daily_revenue
                WHERE daily_revenue < (
                    SELECT AVG(daily_revenue) * 0.5 
                    FROM daily_revenue
                )
            ''',
            'threshold': 1,
            'severity': 'WARNING'
        }
    ]
    
    for check in quality_checks:
        result = execute_quality_check(check)
        if result > check['threshold']:
            send_alert(check['name'], check['severity'], result)
```

## Solution Guidelines

### Dimensional Model Best Practices
```yaml
Fact Table Design:
  - Choose appropriate grain (transaction level vs. daily summary)
  - Include all relevant measures (additive, semi-additive, non-additive)
  - Use surrogate keys for all dimension references
  - Implement proper indexing and partitioning

Dimension Design:
  - Use surrogate keys as primary keys
  - Implement appropriate SCD types based on business needs
  - Create hierarchies for drill-down analysis
  - Include both business and technical attributes

Performance Optimization:
  - Choose distribution keys based on join patterns
  - Use sort keys for commonly filtered columns
  - Implement materialized views for common aggregations
  - Monitor and optimize query performance regularly
```

### Expected Performance Benchmarks
```yaml
Query Performance Targets:
  - Simple aggregations: < 2 seconds
  - Complex multi-table joins: < 10 seconds
  - Dashboard queries: < 5 seconds
  - Ad-hoc analysis: < 30 seconds

Data Loading Performance:
  - Incremental loads: < 30 minutes
  - Full dimension refresh: < 2 hours
  - Data quality validation: < 15 minutes
  - End-to-end ETL: < 4 hours

System Availability:
  - Uptime SLA: 99.9%
  - Planned maintenance: < 4 hours/month
  - Recovery time: < 1 hour
  - Data freshness: < 6 hours for critical data
```

## Evaluation Criteria

### Dimensional Modeling (35%)
- Proper fact and dimension table design
- Appropriate grain selection and measure definitions
- Correct implementation of SCD types
- Logical and physical model quality

### Technical Implementation (30%)
- Redshift optimization techniques
- ETL process design and efficiency
- Data quality and validation procedures
- Performance tuning and monitoring

### Business Value (25%)
- Alignment with business requirements
- Support for analytical use cases
- Scalability and maintainability
- User experience and accessibility

### Documentation and Best Practices (10%)
- Clear documentation and comments
- Adherence to naming conventions
- Security and governance considerations
- Operational procedures and runbooks
