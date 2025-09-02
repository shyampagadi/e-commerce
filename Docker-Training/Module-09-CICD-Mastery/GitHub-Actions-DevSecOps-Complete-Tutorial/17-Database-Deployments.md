# 🗄️ Database Deployments: Migration Automation and Schema Management

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** automated database migration strategies
- **Implement** zero-downtime deployment patterns
- **Configure** multi-database platform support
- **Build** rollback and recovery mechanisms
- **Secure** database deployment pipelines

## 🎯 Real-World Context
Database deployments are critical for e-commerce platforms. Companies like Shopify and Amazon handle millions of transactions daily, requiring sophisticated migration strategies that ensure zero downtime and data integrity during deployments.

---

## 🏗️ Database Migration Fundamentals

### **Migration Strategy Types**

| Strategy | Downtime | Complexity | Use Case |
|----------|----------|------------|----------|
| **Blue-Green** | Minimal | High | Production systems |
| **Rolling** | None | Medium | Microservices |
| **Canary** | None | High | High-risk changes |
| **Maintenance Window** | Scheduled | Low | Legacy systems |

### **Basic Migration Workflow**

```yaml
# .github/workflows/database-migration-pipeline.yml
# ↑ Workflow for safe database migration deployment
# Critical for e-commerce: database changes must be zero-downtime

name: Database Migration Pipeline
# ↑ Descriptive name for database deployment workflow

on:
  # ↑ Defines when database migrations should run
  push:
    # ↑ Runs when code is pushed to repository
    branches: [main]
    # ↑ Only runs for main branch (production-ready migrations)
    paths:
      # ↑ Only runs when database-related files change
      - 'migrations/**'
      # ↑ Database migration files (SQL scripts, migration definitions)
      - 'database/**'
      # ↑ Database schema, seeds, or configuration files
  workflow_dispatch:
    # ↑ Allows manual triggering of migrations
    # Critical for emergency database fixes or rollbacks
    inputs:
      # ↑ Parameters that can be provided when manually triggering
      environment:
        # ↑ Input parameter for target environment selection
        description: 'Target environment'
        # ↑ Human-readable description shown in GitHub UI
        required: true
        # ↑ This parameter must be provided
        default: 'staging'
        # ↑ Default value if not specified
        type: choice
        # ↑ Dropdown selection (not free text)
        options:
          # ↑ Available environment options
          - staging
          - production
          # ↑ Prevents typos and ensures valid environments

jobs:
  # ↑ Section defining all jobs in this workflow
  validate-migrations:
    # ↑ Job that validates migrations before applying to production
    runs-on: ubuntu-latest
    # ↑ Uses Ubuntu virtual machine
    
    services:
      # ↑ Additional services needed for this job
      postgres:
        # ↑ Service name (can be referenced as 'postgres' in connection strings)
        image: postgres:15
        # ↑ PostgreSQL version 15 Docker image
        # Use specific versions for consistency
        env:
          # ↑ Environment variables for the PostgreSQL service
          POSTGRES_PASSWORD: postgres
          # ↑ Sets password for postgres user
          # This is a test database, so simple password is acceptable
          POSTGRES_DB: testdb
          # ↑ Creates a database named 'testdb' on startup
        options: >-
          # ↑ Additional Docker options for the PostgreSQL container
          --health-cmd pg_isready
          # ↑ Command to check if PostgreSQL is ready to accept connections
          # pg_isready is PostgreSQL's built-in health check utility
          --health-interval 10s
          # ↑ Check health every 10 seconds
          --health-timeout 5s
          # ↑ Each health check times out after 5 seconds
          --health-retries 5
          # ↑ Retry health check 5 times before marking as unhealthy
          # Total startup time: up to 50 seconds (10s × 5 retries)
    
    steps:
      # ↑ Sequential tasks within the validation job
      - uses: actions/checkout@v4
        # ↑ Downloads repository code including migration files
      
      - name: Setup Node.js
        # ↑ Prepares JavaScript/TypeScript runtime for migration tools
        uses: actions/setup-node@v4
        # ↑ Official GitHub action for Node.js setup
        with:
          node-version: '18'
          # ↑ Node.js LTS version for stability
          cache: 'npm'
          # ↑ Caches npm dependencies for faster subsequent runs
          
      - name: Install Dependencies
        # ↑ Installs migration tools and database libraries
        run: npm ci
        # ↑ npm ci ensures exact dependency versions from package-lock.json
        # Critical for database tools - version consistency prevents issues
        
      - name: Run Migration Tests
        # ↑ Validates migrations work correctly before production deployment
        env:
          # ↑ Environment variables for database connection
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
          # ↑ Connection string to test PostgreSQL service
          # Format: postgresql://username:password@host:port/database
          # localhost:5432 connects to the service defined above
        run: |
          # ↑ Shell commands for migration testing
          
          # Test migrations on clean database
          npm run migrate:up
          # ↑ Applies all pending migrations to test database
          # This simulates what will happen in production
          
          npm run migrate:test
          # ↑ Runs tests to verify migrations worked correctly
          # Should test data integrity, schema correctness, etc.
          
          # Test rollback capability
          npm run migrate:down
          # ↑ Rolls back the last migration
          # Critical: ensures we can undo changes if problems occur
          
          npm run migrate:up
          # ↑ Re-applies migrations to test forward migration again
          # Ensures rollback didn't break anything
          
      - name: Validate Schema
        # ↑ Verifies final database schema matches expectations
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
          # ↑ Same connection string as migration tests
        run: |
          # Generate schema dump for validation
          pg_dump -s $DATABASE_URL > schema.sql
          # ↑ pg_dump -s exports only schema (no data)
          # Creates SQL file with table definitions, indexes, constraints
          
          # Validate schema integrity
          npm run schema:validate
          # ↑ Custom script that checks schema against expected structure
          # Could verify required tables exist, indexes are present, etc.
```

**Detailed Database Migration Concepts for Newbies:**

1. **Migration Safety Principles:**
   - **Test First**: Always test migrations on identical database before production
   - **Rollback Ready**: Every migration must be reversible
   - **Zero Downtime**: Migrations shouldn't interrupt running application
   - **Data Integrity**: Never lose or corrupt existing data

2. **GitHub Services Feature:**
   - **Service Containers**: Additional Docker containers for testing
   - **Health Checks**: Ensures service is ready before running tests
   - **Networking**: Services accessible via localhost from job steps
   - **Isolation**: Each job gets fresh service instances

3. **Migration Testing Strategy:**
   - **Forward Migration**: Apply new changes (migrate:up)
   - **Rollback Testing**: Undo changes (migrate:down)
   - **Re-application**: Apply again to test idempotency
   - **Schema Validation**: Verify final structure is correct

4. **Database Connection Security:**
   - **Test Environment**: Simple credentials acceptable for testing
   - **Production**: Would use secrets for real database credentials
   - **Connection Strings**: Standard format for database connections
   - **Service Discovery**: localhost connects to GitHub Actions services

5. **Path-Based Triggers:**
   - **Efficiency**: Only runs when database files actually change
   - **Safety**: Prevents accidental migrations on unrelated changes
   - **Specificity**: migrations/** and database/** cover all DB-related files
          # Test migrations on clean database
          npm run migrate:up
          npm run migrate:test
          
          # Test rollback capability
          npm run migrate:down
          npm run migrate:up
          
      - name: Validate Schema
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
        run: |
          # Generate schema dump
          pg_dump -s $DATABASE_URL > schema.sql
          
          # Validate schema integrity
          npm run schema:validate
```

---

## 🚀 Zero-Downtime Migration Patterns

### **Blue-Green Database Deployment**
```yaml
name: Blue-Green Database Deployment

on:
  push:
    branches: [main]

env:
  BLUE_DB: ecommerce_blue
  GREEN_DB: ecommerce_green

jobs:
  prepare-green-database:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Database Tools
        run: |
          sudo apt-get update
          sudo apt-get install -y postgresql-client
          
      - name: Create Green Database
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          psql $DATABASE_URL -c "CREATE DATABASE $GREEN_DB WITH TEMPLATE $BLUE_DB;"
          
      - name: Run Migrations on Green
        env:
          GREEN_DATABASE_URL: ${{ secrets.GREEN_DATABASE_URL }}
        run: |
          npm run migrate:up -- --database-url=$GREEN_DATABASE_URL
          
      - name: Validate Green Database
        env:
          GREEN_DATABASE_URL: ${{ secrets.GREEN_DATABASE_URL }}
        run: |
          npm run test:database -- --database-url=$GREEN_DATABASE_URL
          npm run test:performance -- --database-url=$GREEN_DATABASE_URL

  deploy-application:
    needs: prepare-green-database
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Application to Green
        env:
          GREEN_DATABASE_URL: ${{ secrets.GREEN_DATABASE_URL }}
        run: |
          kubectl set env deployment/ecommerce-app DATABASE_URL=$GREEN_DATABASE_URL
          kubectl rollout status deployment/ecommerce-app
          
      - name: Switch Traffic to Green
        run: |
          kubectl patch service ecommerce-service -p '{"spec":{"selector":{"version":"green"}}}'
          echo "Green deployment successful, blue kept for rollback"
```

**Line-by-Line Analysis:**

**`name: Blue-Green Database Deployment`** - Zero-downtime database deployment strategy for production systems
**`on: push: branches: [main]`** - Triggers only on main branch for production database changes
**`env: BLUE_DB: ecommerce_blue`** - Current production database identifier
**`GREEN_DB: ecommerce_green`** - New database version for deployment testing
**`prepare-green-database:`** - Job creating and validating new database version
**`runs-on: ubuntu-latest`** - Ubuntu environment with PostgreSQL client support
**`uses: actions/checkout@v4`** - Downloads migration scripts and database schema
**`sudo apt-get install -y postgresql-client`** - Installs PostgreSQL command-line tools
**`psql $DATABASE_URL -c "CREATE DATABASE $GREEN_DB WITH TEMPLATE $BLUE_DB;"`** - Creates green database as exact copy of blue
**`DATABASE_URL: ${{ secrets.DATABASE_URL }}`** - Production database connection string from secrets
**`npm run migrate:up -- --database-url=$GREEN_DATABASE_URL`** - Applies new migrations to green database
**`GREEN_DATABASE_URL: ${{ secrets.GREEN_DATABASE_URL }}`** - Green database connection for testing
**`npm run test:database`** - Validates database schema and data integrity
**`npm run test:performance`** - Ensures migration doesn't degrade performance
**`deploy-application:`** - Job deploying application to use green database
**`needs: prepare-green-database`** - Waits for database preparation completion
**`kubectl set env deployment/ecommerce-app DATABASE_URL=$GREEN_DATABASE_URL`** - Updates application to use green database
**`kubectl rollout status deployment/ecommerce-app`** - Waits for application deployment completion
**`kubectl patch service ecommerce-service`** - Switches traffic from blue to green database
**`'{"spec":{"selector":{"version":"green"}}}'`** - Service selector targeting green deployment
**`echo "Green deployment successful, blue kept for rollback"`** - Confirms successful deployment with rollback option
        env:
          GREEN_DATABASE_URL: ${{ secrets.GREEN_DATABASE_URL }}
        run: |
          # Deploy application pointing to green database
          ./scripts/deploy-green.sh
          
      - name: Health Check Green Environment
        run: |
          # Wait for application to be ready
          timeout 300 bash -c 'until curl -f https://green.ecommerce.com/health; do sleep 5; done'
          
      - name: Run Smoke Tests
        run: |
          # Critical path testing
          npm run test:smoke -- --base-url=https://green.ecommerce.com
          
      - name: Switch Traffic to Green
        run: |
          # Update load balancer to point to green
          ./scripts/switch-to-green.sh
          
      - name: Monitor Green Environment
        run: |
          # Monitor for 5 minutes
          for i in {1..60}; do
            if ! curl -f https://ecommerce.com/health; then
              echo "Health check failed, rolling back..."
              ./scripts/rollback-to-blue.sh
              exit 1
            fi
            sleep 5
          done
          
      - name: Cleanup Blue Environment
        if: success()
        run: |
          # Keep blue for rollback window
          echo "Green deployment successful, blue kept for rollback"
```

### **Rolling Migration Strategy**

```yaml
name: Rolling Database Migration

on:
  push:
    branches: [main]

jobs:
  rolling-migration:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        shard: [shard1, shard2, shard3, shard4]
      max-parallel: 2  # Migrate 2 shards at a time
      
    steps:
      - uses: actions/checkout@v4
      
      - name: Migrate Shard ${{ matrix.shard }}
        env:
          SHARD_DATABASE_URL: ${{ secrets[format('DATABASE_URL_{0}', matrix.shard)] }}
        run: |
          echo "🔄 Migrating ${{ matrix.shard }}..."
          
          # Pre-migration validation
          npm run migrate:validate -- --shard=${{ matrix.shard }}
          
          # Apply migrations
          npm run migrate:up -- --shard=${{ matrix.shard }}
          
          # Post-migration validation
          npm run migrate:verify -- --shard=${{ matrix.shard }}
          
      - name: Health Check Shard
        env:
          SHARD_URL: ${{ format('https://{0}.ecommerce.com', matrix.shard) }}
        run: |
          # Verify shard is healthy after migration
          timeout 60 bash -c 'until curl -f $SHARD_URL/health; do sleep 2; done'
          
      - name: Run Shard Tests
        run: |
          npm run test:shard -- --shard=${{ matrix.shard }}
```

---

## 🎯 E-commerce Database Pipeline

### **Complete E-commerce Database Workflow**

```yaml
name: E-commerce Database Pipeline

on:
  push:
    branches: [main, develop]
    paths:
      - 'migrations/**'
      - 'seeds/**'
      - 'database/**'
  pull_request:
    branches: [main]
    paths:
      - 'migrations/**'

env:
  NODE_VERSION: '18'

jobs:
  migration-validation:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: ecommerce_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install Dependencies
        run: npm ci
        
      - name: Analyze Migration Changes
        run: |
          # Check for breaking changes
          git diff HEAD~1 HEAD --name-only migrations/ > changed_migrations.txt
          
          if [ -s changed_migrations.txt ]; then
            echo "🔍 Analyzing migration changes:"
            cat changed_migrations.txt
            
            # Check for destructive operations
            if git diff HEAD~1 HEAD migrations/ | grep -E "(DROP|DELETE|ALTER.*DROP)"; then
              echo "⚠️ Destructive migration detected"
              echo "destructive=true" >> $GITHUB_ENV
            fi
          fi
          
      - name: Setup Test Database
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ecommerce_test
          REDIS_URL: redis://localhost:6379
        run: |
          # Create database schema
          npm run db:create
          
          # Load production-like data
          npm run db:seed:test
          
      - name: Test Migration Forward
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ecommerce_test
        run: |
          # Apply all migrations
          npm run migrate:up
          
          # Verify schema integrity
          npm run db:verify
          
      - name: Test Migration Rollback
        if: env.destructive != 'true'
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ecommerce_test
        run: |
          # Test rollback capability
          npm run migrate:down
          npm run migrate:up
          
      - name: Performance Impact Analysis
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ecommerce_test
        run: |
          # Analyze query performance impact
          npm run db:analyze-performance
          
          # Check index usage
          npm run db:check-indexes
          
      - name: Generate Migration Report
        run: |
          cat > migration-report.md << 'EOF'
          # Migration Analysis Report
          
          ## Changed Files
          $(cat changed_migrations.txt || echo "No migration files changed")
          
          ## Impact Assessment
          - **Destructive Changes**: ${{ env.destructive || 'false' }}
          - **Schema Changes**: $(git diff HEAD~1 HEAD --stat migrations/)
          - **Performance Impact**: See performance analysis logs
          
          ## Recommendations
          EOF
          
          if [ "${{ env.destructive }}" = "true" ]; then
            echo "⚠️ **CAUTION**: This migration contains destructive operations" >> migration-report.md
            echo "- Review data backup procedures" >> migration-report.md
            echo "- Consider maintenance window" >> migration-report.md
          fi
          
      - name: Upload Migration Report
        uses: actions/upload-artifact@v4
        with:
          name: migration-report
          path: migration-report.md

  deploy-staging:
    needs: migration-validation
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Database Tools
        run: |
          curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
          echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
          sudo apt-get update
          sudo apt-get install -y postgresql-client-15
          
      - name: Create Database Backup
        env:
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
        run: |
          # Create backup before migration
          BACKUP_NAME="staging_backup_$(date +%Y%m%d_%H%M%S)"
          pg_dump $DATABASE_URL > "${BACKUP_NAME}.sql"
          
          # Upload backup to S3
          aws s3 cp "${BACKUP_NAME}.sql" s3://ecommerce-db-backups/staging/
          
          echo "BACKUP_NAME=$BACKUP_NAME" >> $GITHUB_ENV
          
      - name: Run Staging Migration
        env:
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
        run: |
          # Apply migrations with monitoring
          timeout 600 npm run migrate:up -- --verbose
          
      - name: Verify Staging Migration
        env:
          DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
        run: |
          # Run post-migration tests
          npm run test:database:staging
          
          # Check data integrity
          npm run db:integrity-check
          
      - name: Update Application
        env:
          STAGING_DATABASE_URL: ${{ secrets.STAGING_DATABASE_URL }}
        run: |
          # Deploy application with new schema
          ./scripts/deploy-staging.sh

  deploy-production:
    needs: migration-validation
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Production Pre-flight Checks
        env:
          DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
        run: |
          # Check database connectivity
          pg_isready -d $DATABASE_URL
          
          # Check disk space
          DISK_USAGE=$(psql $DATABASE_URL -t -c "SELECT pg_size_pretty(pg_database_size('ecommerce_prod'));")
          echo "Database size: $DISK_USAGE"
          
          # Check active connections
          ACTIVE_CONNECTIONS=$(psql $DATABASE_URL -t -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';")
          echo "Active connections: $ACTIVE_CONNECTIONS"
          
          if [ $ACTIVE_CONNECTIONS -gt 100 ]; then
            echo "⚠️ High connection count detected"
            exit 1
          fi
          
      - name: Create Production Backup
        env:
          DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
        run: |
          # Create full backup
          BACKUP_NAME="prod_backup_$(date +%Y%m%d_%H%M%S)"
          pg_dump $DATABASE_URL | gzip > "${BACKUP_NAME}.sql.gz"
          
          # Upload to multiple locations
          aws s3 cp "${BACKUP_NAME}.sql.gz" s3://ecommerce-db-backups/production/
          aws s3 cp "${BACKUP_NAME}.sql.gz" s3://ecommerce-db-backups-dr/production/
          
          echo "BACKUP_NAME=$BACKUP_NAME" >> $GITHUB_ENV
          
      - name: Enable Maintenance Mode
        run: |
          # Enable maintenance mode if destructive migration
          if [ "${{ env.destructive }}" = "true" ]; then
            ./scripts/enable-maintenance-mode.sh
          fi
          
      - name: Run Production Migration
        env:
          DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
        run: |
          # Apply migrations with extensive monitoring
          timeout 1800 npm run migrate:up -- --verbose --production
          
      - name: Verify Production Migration
        env:
          DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
        run: |
          # Critical verification tests
          npm run test:database:production
          
          # Performance regression check
          npm run test:performance:database
          
      - name: Deploy Application
        env:
          PROD_DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
        run: |
          # Blue-green deployment
          ./scripts/deploy-production-blue-green.sh
          
      - name: Disable Maintenance Mode
        if: always()
        run: |
          # Always disable maintenance mode
          ./scripts/disable-maintenance-mode.sh
          
      - name: Post-Deployment Monitoring
        run: |
          # Monitor for 10 minutes
          for i in {1..120}; do
            if ! curl -f https://ecommerce.com/health; then
              echo "❌ Health check failed, initiating rollback"
              ./scripts/rollback-database.sh ${{ env.BACKUP_NAME }}
              exit 1
            fi
            
            # Check error rates
            ERROR_RATE=$(curl -s https://monitoring.ecommerce.com/api/error-rate)
            if (( $(echo "$ERROR_RATE > 0.05" | bc -l) )); then
              echo "❌ High error rate detected: $ERROR_RATE"
              ./scripts/rollback-database.sh ${{ env.BACKUP_NAME }}
              exit 1
            fi
            
            sleep 5
          done
          
          echo "✅ Production deployment successful"
```

---

## 🔧 Database Migration Tools

### **Migration Script Template**

```javascript
// migrations/001_create_products_table.js
exports.up = async function(knex) {
  return knex.schema.createTable('products', function(table) {
    table.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    table.string('name').notNullable();
    table.text('description');
    table.decimal('price', 10, 2).notNullable();
    table.integer('stock_quantity').defaultTo(0);
    table.string('sku').unique().notNullable();
    table.jsonb('metadata').defaultTo('{}');
    table.boolean('active').defaultTo(true);
    table.timestamps(true, true);
    
    // Indexes for performance
    table.index(['active', 'created_at']);
    table.index(['sku']);
    table.index('name');
  });
};

exports.down = async function(knex) {
  return knex.schema.dropTableIfExists('products');
};

// Migration metadata
exports.config = {
  transaction: true,
  destructive: false,
  estimatedDuration: '30s',
  dependencies: []
};
```

### **Database Validation Scripts**

```javascript
// scripts/validate-schema.js
const knex = require('knex')(require('../knexfile'));

async function validateSchema() {
  console.log('🔍 Validating database schema...');
  
  try {
    // Check required tables exist
    const requiredTables = ['users', 'products', 'orders', 'order_items'];
    for (const table of requiredTables) {
      const exists = await knex.schema.hasTable(table);
      if (!exists) {
        throw new Error(`Required table '${table}' does not exist`);
      }
      console.log(`✅ Table '${table}' exists`);
    }
    
    // Check critical indexes
    const indexes = await knex.raw(`
      SELECT schemaname, tablename, indexname 
      FROM pg_indexes 
      WHERE schemaname = 'public'
    `);
    
    const requiredIndexes = [
      'products_sku_unique',
      'users_email_unique',
      'orders_user_id_index'
    ];
    
    for (const indexName of requiredIndexes) {
      const exists = indexes.rows.some(row => row.indexname === indexName);
      if (!exists) {
        console.warn(`⚠️ Missing index: ${indexName}`);
      } else {
        console.log(`✅ Index '${indexName}' exists`);
      }
    }
    
    // Check foreign key constraints
    const constraints = await knex.raw(`
      SELECT conname, contype 
      FROM pg_constraint 
      WHERE contype = 'f'
    `);
    
    console.log(`📊 Found ${constraints.rows.length} foreign key constraints`);
    
    console.log('✅ Schema validation completed');
    
  } catch (error) {
    console.error('❌ Schema validation failed:', error.message);
    process.exit(1);
  } finally {
    await knex.destroy();
  }
}

validateSchema();
```

---

## 🎯 Hands-On Lab: Database Migration Pipeline

### **Lab Objective**
Implement a complete database migration pipeline for an e-commerce application with zero-downtime deployment and rollback capabilities.

### **Lab Steps**

1. **Setup Migration Framework**
```bash
# Initialize migration system
npm install knex pg
npx knex init

# Create migration structure
mkdir -p migrations seeds
```

2. **Create E-commerce Schema Migrations**
```bash
# Create product catalog migrations
npx knex migrate:make create_products_table
npx knex migrate:make create_categories_table
npx knex migrate:make create_orders_table

# Implement migration files
# Copy examples from above
```

3. **Implement Migration Pipeline**
```bash
# Create workflow file
cp examples/database-pipeline.yml .github/workflows/

# Add migration scripts
mkdir -p scripts
cp examples/validate-schema.js scripts/
```

4. **Test Migration Pipeline**
```bash
# Test locally first
npm run migrate:up
npm run migrate:test

# Commit and test in CI
git add .
git commit -m "Add database migration pipeline"
git push
```

### **Expected Results**
- Automated migration validation and testing
- Zero-downtime deployment capability
- Comprehensive backup and rollback procedures
- Production-ready database pipeline

---

## 📚 Best Practices Summary

### **Migration Safety**
- **Always backup** before production migrations
- **Test rollback procedures** in staging
- **Use transactions** for atomic migrations
- **Monitor performance** impact during migrations
- **Implement circuit breakers** for automatic rollback

### **Schema Design**
- **Version all schema changes** through migrations
- **Use descriptive migration names** and comments
- **Avoid destructive operations** in production
- **Plan for backward compatibility** during rolling deployments
- **Index strategy** for performance optimization

---

## 🎯 Module Assessment

### **Knowledge Check**
1. What are the key strategies for zero-downtime database deployments?
2. How do you implement safe rollback procedures for database migrations?
3. What validation steps should be included in database deployment pipelines?
4. How do you handle schema changes in microservices architectures?

### **Practical Exercise**
Implement a complete database deployment pipeline that includes:
- Automated migration validation and testing
- Blue-green deployment strategy
- Comprehensive backup and rollback procedures
- Performance impact monitoring

### **Success Criteria**
- [ ] Zero-downtime migration capability
- [ ] Automated backup and rollback procedures
- [ ] Comprehensive validation and testing
- [ ] Production-ready safety measures
- [ ] Performance monitoring integration

---

**Next Module**: [Microservices Pipelines](./18-Microservices-Pipelines.md) - Learn multi-service orchestration
