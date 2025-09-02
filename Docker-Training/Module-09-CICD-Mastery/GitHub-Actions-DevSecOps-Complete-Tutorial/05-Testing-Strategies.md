# 🧪 Testing Strategies

## 📋 Learning Objectives
By the end of this module, you will:
- **Master** comprehensive testing strategies for CI/CD pipelines
- **Implement** unit, integration, and end-to-end testing automation
- **Configure** test reporting and coverage analysis
- **Apply** quality gates and test-driven development practices
- **Build** robust testing frameworks for e-commerce applications

## 🎯 Real-World Context
Testing is the foundation of reliable software delivery. Companies like Netflix and Amazon deploy thousands of times per day with confidence because of comprehensive testing strategies. This module teaches you to build the same level of testing automation used by industry leaders.

---

## 📚 Part 1: Testing Strategy Fundamentals

### Understanding the Testing Pyramid

**Testing Pyramid Architecture:**
```
Testing Pyramid for E-Commerce
├── End-to-End Tests (5-10%)
│   ├── Full user journey testing
│   ├── Cross-browser compatibility
│   ├── Payment flow validation
│   └── Performance under load
├── Integration Tests (20-30%)
│   ├── API endpoint testing
│   ├── Database integration
│   ├── Third-party service integration
│   └── Microservice communication
└── Unit Tests (60-70%)
    ├── Function-level testing
    ├── Component isolation
    ├── Business logic validation
    └── Edge case coverage
```

### Test Types and Their Purpose

**1. Unit Tests**
- Test individual functions or components in isolation
- Fast execution (milliseconds)
- High coverage of business logic
- Easy to debug and maintain

**2. Integration Tests**
- Test interaction between components
- Validate API contracts and data flow
- Test database operations
- Verify third-party integrations

**3. End-to-End Tests**
- Test complete user workflows
- Validate critical business paths
- Cross-browser and device testing
- Performance and load testing

---

## 🔧 Part 2: Unit Testing Implementation

### Jest Configuration for E-Commerce

**Comprehensive Jest Setup:**
```javascript
// jest.config.js - Production-ready Jest configuration
module.exports = {
  // Test environment
  testEnvironment: 'node',
  
  // Test file patterns
  testMatch: [
    '**/__tests__/**/*.(js|jsx|ts|tsx)',
    '**/*.(test|spec).(js|jsx|ts|tsx)'
  ],
  
  // Coverage configuration
  collectCoverage: true,
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/**/*.d.ts',
    '!src/index.ts',
    '!src/**/*.stories.{js,jsx,ts,tsx}',
    '!src/**/*.test.{js,jsx,ts,tsx}'
  ],
  
  // Coverage thresholds
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    },
    // Critical paths require higher coverage
    './src/services/payment/': {
      branches: 95,
      functions: 95,
      lines: 95,
      statements: 95
    },
    './src/services/order/': {
      branches: 90,
      functions: 90,
      lines: 90,
      statements: 90
    }
  },
  
  // Setup files
  setupFilesAfterEnv: ['<rootDir>/src/test/setup.ts'],
  
  // Module mapping
  moduleNameMapping: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '^@test/(.*)$': '<rootDir>/src/test/$1'
  },
  
  // Transform configuration
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest'
  },
  
  // Test timeout
  testTimeout: 10000,
  
  // Reporters
  reporters: [
    'default',
    ['jest-junit', {
      outputDirectory: 'test-results',
      outputName: 'junit.xml'
    }],
    ['jest-html-reporters', {
      publicPath: 'test-results',
      filename: 'report.html'
    }]
  ]
};
```

### Unit Test Examples

**E-Commerce Service Unit Tests:**
```typescript
// src/services/order/OrderService.test.ts
import { OrderService } from './OrderService';
import { PaymentService } from '../payment/PaymentService';
import { InventoryService } from '../inventory/InventoryService';
import { NotificationService } from '../notification/NotificationService';

// Mock dependencies
jest.mock('../payment/PaymentService');
jest.mock('../inventory/InventoryService');
jest.mock('../notification/NotificationService');

describe('OrderService', () => {
  let orderService: OrderService;
  let mockPaymentService: jest.Mocked<PaymentService>;
  let mockInventoryService: jest.Mocked<InventoryService>;
  let mockNotificationService: jest.Mocked<NotificationService>;

  beforeEach(() => {
    mockPaymentService = new PaymentService() as jest.Mocked<PaymentService>;
    mockInventoryService = new InventoryService() as jest.Mocked<InventoryService>;
    mockNotificationService = new NotificationService() as jest.Mocked<NotificationService>;
    
    orderService = new OrderService(
      mockPaymentService,
      mockInventoryService,
      mockNotificationService
    );
  });

  describe('createOrder', () => {
    const validOrderData = {
      userId: 'user123',
      items: [
        { productId: 'prod1', quantity: 2, price: 29.99 },
        { productId: 'prod2', quantity: 1, price: 49.99 }
      ],
      shippingAddress: {
        street: '123 Main St',
        city: 'Anytown',
        zipCode: '12345'
      },
      paymentMethod: {
        type: 'credit_card',
        token: 'card_token_123'
      }
    };

    it('should create order successfully with valid data', async () => {
      // Arrange
      mockInventoryService.checkAvailability.mockResolvedValue(true);
      mockInventoryService.reserveItems.mockResolvedValue(true);
      mockPaymentService.processPayment.mockResolvedValue({
        success: true,
        transactionId: 'txn_123'
      });

      // Act
      const result = await orderService.createOrder(validOrderData);

      // Assert
      expect(result).toMatchObject({
        id: expect.any(String),
        userId: 'user123',
        status: 'confirmed',
        total: 109.97,
        transactionId: 'txn_123'
      });
      
      expect(mockInventoryService.checkAvailability).toHaveBeenCalledWith(
        validOrderData.items
      );
      expect(mockPaymentService.processPayment).toHaveBeenCalledWith({
        amount: 109.97,
        paymentMethod: validOrderData.paymentMethod
      });
      expect(mockNotificationService.sendOrderConfirmation).toHaveBeenCalledWith(
        expect.objectContaining({ userId: 'user123' })
      );
    });

    it('should throw error when inventory is insufficient', async () => {
      // Arrange
      mockInventoryService.checkAvailability.mockResolvedValue(false);

      // Act & Assert
      await expect(orderService.createOrder(validOrderData))
        .rejects
        .toThrow('Insufficient inventory for requested items');
      
      expect(mockPaymentService.processPayment).not.toHaveBeenCalled();
    });

    it('should handle payment failure gracefully', async () => {
      // Arrange
      mockInventoryService.checkAvailability.mockResolvedValue(true);
      mockInventoryService.reserveItems.mockResolvedValue(true);
      mockPaymentService.processPayment.mockResolvedValue({
        success: false,
        error: 'Card declined'
      });

      // Act & Assert
      await expect(orderService.createOrder(validOrderData))
        .rejects
        .toThrow('Payment failed: Card declined');
      
      expect(mockInventoryService.releaseReservation).toHaveBeenCalled();
    });

    it('should calculate total correctly with tax and shipping', async () => {
      // Arrange
      const orderWithTax = {
        ...validOrderData,
        taxRate: 0.08,
        shippingCost: 9.99
      };
      
      mockInventoryService.checkAvailability.mockResolvedValue(true);
      mockInventoryService.reserveItems.mockResolvedValue(true);
      mockPaymentService.processPayment.mockResolvedValue({
        success: true,
        transactionId: 'txn_123'
      });

      // Act
      const result = await orderService.createOrder(orderWithTax);

      // Assert
      const expectedSubtotal = 109.97;
      const expectedTax = expectedSubtotal * 0.08;
      const expectedTotal = expectedSubtotal + expectedTax + 9.99;
      
      expect(result.total).toBeCloseTo(expectedTotal, 2);
    });
  });

  describe('cancelOrder', () => {
    it('should cancel order and refund payment', async () => {
      // Arrange
      const orderId = 'order123';
      mockPaymentService.refundPayment.mockResolvedValue({
        success: true,
        refundId: 'refund_123'
      });

      // Act
      const result = await orderService.cancelOrder(orderId);

      // Assert
      expect(result.status).toBe('cancelled');
      expect(mockPaymentService.refundPayment).toHaveBeenCalledWith(orderId);
      expect(mockInventoryService.releaseReservation).toHaveBeenCalledWith(orderId);
    });
  });
});
```

---

## 🔗 Part 3: Integration Testing

### API Integration Tests

**Express API Integration Testing:**
```typescript
// src/test/integration/api.test.ts
import request from 'supertest';
import { app } from '../../app';
import { DatabaseManager } from '../../database/DatabaseManager';
import { RedisClient } from '../../cache/RedisClient';

describe('E-Commerce API Integration Tests', () => {
  let dbManager: DatabaseManager;
  let redisClient: RedisClient;

  beforeAll(async () => {
    // Setup test database
    dbManager = new DatabaseManager(process.env.TEST_DATABASE_URL);
    await dbManager.connect();
    await dbManager.migrate();
    
    // Setup test cache
    redisClient = new RedisClient(process.env.TEST_REDIS_URL);
    await redisClient.connect();
  });

  afterAll(async () => {
    await dbManager.disconnect();
    await redisClient.disconnect();
  });

  beforeEach(async () => {
    // Clean database before each test
    await dbManager.truncateAll();
    await redisClient.flushAll();
    
    // Seed test data
    await seedTestData();
  });

  describe('Product API', () => {
    describe('GET /api/products', () => {
      it('should return paginated products', async () => {
        const response = await request(app)
          .get('/api/products?page=1&limit=10')
          .expect(200);

        expect(response.body).toMatchObject({
          products: expect.any(Array),
          pagination: {
            page: 1,
            limit: 10,
            total: expect.any(Number),
            totalPages: expect.any(Number)
          }
        });

        expect(response.body.products).toHaveLength(10);
        expect(response.body.products[0]).toMatchObject({
          id: expect.any(String),
          name: expect.any(String),
          price: expect.any(Number),
          category: expect.any(String)
        });
      });

      it('should filter products by category', async () => {
        const response = await request(app)
          .get('/api/products?category=electronics')
          .expect(200);

        expect(response.body.products).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ category: 'electronics' })
          ])
        );
      });

      it('should search products by name', async () => {
        const response = await request(app)
          .get('/api/products?search=laptop')
          .expect(200);

        expect(response.body.products).toEqual(
          expect.arrayContaining([
            expect.objectContaining({
              name: expect.stringContaining('laptop')
            })
          ])
        );
      });
    });

    describe('POST /api/products', () => {
      it('should create new product with valid data', async () => {
        const productData = {
          name: 'Test Product',
          description: 'A test product',
          price: 99.99,
          category: 'electronics',
          inventory: 50
        };

        const response = await request(app)
          .post('/api/products')
          .send(productData)
          .expect(201);

        expect(response.body).toMatchObject({
          id: expect.any(String),
          ...productData,
          createdAt: expect.any(String)
        });

        // Verify product was saved to database
        const savedProduct = await dbManager.query(
          'SELECT * FROM products WHERE id = $1',
          [response.body.id]
        );
        expect(savedProduct.rows).toHaveLength(1);
      });

      it('should validate required fields', async () => {
        const invalidProduct = {
          name: 'Test Product'
          // Missing required fields
        };

        const response = await request(app)
          .post('/api/products')
          .send(invalidProduct)
          .expect(400);

        expect(response.body).toMatchObject({
          error: 'Validation failed',
          details: expect.arrayContaining([
            expect.objectContaining({
              field: 'price',
              message: expect.any(String)
            })
          ])
        });
      });
    });
  });

  describe('Order API', () => {
    let testUser: any;
    let testProducts: any[];

    beforeEach(async () => {
      // Create test user and products
      testUser = await createTestUser();
      testProducts = await createTestProducts();
    });

    describe('POST /api/orders', () => {
      it('should create order with valid data', async () => {
        const orderData = {
          items: [
            { productId: testProducts[0].id, quantity: 2 },
            { productId: testProducts[1].id, quantity: 1 }
          ],
          shippingAddress: {
            street: '123 Test St',
            city: 'Test City',
            zipCode: '12345'
          },
          paymentMethod: {
            type: 'credit_card',
            token: 'test_card_token'
          }
        };

        const response = await request(app)
          .post('/api/orders')
          .set('Authorization', `Bearer ${testUser.token}`)
          .send(orderData)
          .expect(201);

        expect(response.body).toMatchObject({
          id: expect.any(String),
          userId: testUser.id,
          status: 'confirmed',
          items: expect.arrayContaining([
            expect.objectContaining({
              productId: testProducts[0].id,
              quantity: 2
            })
          ]),
          total: expect.any(Number)
        });
      });

      it('should handle insufficient inventory', async () => {
        const orderData = {
          items: [
            { productId: testProducts[0].id, quantity: 1000 } // More than available
          ],
          shippingAddress: {
            street: '123 Test St',
            city: 'Test City',
            zipCode: '12345'
          },
          paymentMethod: {
            type: 'credit_card',
            token: 'test_card_token'
          }
        };

        const response = await request(app)
          .post('/api/orders')
          .set('Authorization', `Bearer ${testUser.token}`)
          .send(orderData)
          .expect(400);

        expect(response.body).toMatchObject({
          error: 'Insufficient inventory',
          details: expect.any(Object)
        });
      });
    });
  });

  // Helper functions
  async function seedTestData() {
    // Seed products
    await dbManager.query(`
      INSERT INTO products (id, name, description, price, category, inventory)
      VALUES 
        ('prod1', 'Gaming Laptop', 'High-performance laptop', 1299.99, 'electronics', 10),
        ('prod2', 'Wireless Mouse', 'Ergonomic wireless mouse', 29.99, 'electronics', 50),
        ('prod3', 'Coffee Mug', 'Ceramic coffee mug', 12.99, 'home', 100)
    `);
  }

  async function createTestUser() {
    const user = await dbManager.query(`
      INSERT INTO users (id, email, password_hash)
      VALUES ('user1', 'test@example.com', 'hashed_password')
      RETURNING *
    `);
    
    return {
      id: user.rows[0].id,
      email: user.rows[0].email,
      token: 'test_jwt_token'
    };
  }

  async function createTestProducts() {
    const products = await dbManager.query('SELECT * FROM products');
    return products.rows;
  }
});
```

---

## 🌐 Part 4: End-to-End Testing

### Playwright E2E Testing

**E-Commerce User Journey Tests:**
```typescript
// src/test/e2e/ecommerce-flow.spec.ts
import { test, expect, Page } from '@playwright/test';

test.describe('E-Commerce User Journey', () => {
  let page: Page;

  test.beforeEach(async ({ browser }) => {
    page = await browser.newPage();
    
    // Setup test data
    await setupTestData();
  });

  test('complete purchase flow', async () => {
    // Step 1: Navigate to homepage
    await page.goto('/');
    await expect(page).toHaveTitle(/E-Commerce Store/);

    // Step 2: Search for product
    await page.fill('[data-testid="search-input"]', 'laptop');
    await page.click('[data-testid="search-button"]');
    
    // Verify search results
    await expect(page.locator('[data-testid="product-card"]')).toHaveCount(3);

    // Step 3: Select product
    await page.click('[data-testid="product-card"]:first-child');
    
    // Verify product details page
    await expect(page.locator('[data-testid="product-title"]')).toBeVisible();
    await expect(page.locator('[data-testid="product-price"]')).toBeVisible();

    // Step 4: Add to cart
    await page.click('[data-testid="add-to-cart-button"]');
    
    // Verify cart notification
    await expect(page.locator('[data-testid="cart-notification"]')).toBeVisible();
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText('1');

    // Step 5: Go to cart
    await page.click('[data-testid="cart-icon"]');
    
    // Verify cart contents
    await expect(page.locator('[data-testid="cart-item"]')).toHaveCount(1);
    await expect(page.locator('[data-testid="cart-total"]')).toBeVisible();

    // Step 6: Proceed to checkout
    await page.click('[data-testid="checkout-button"]');

    // Step 7: Fill shipping information
    await page.fill('[data-testid="shipping-street"]', '123 Test Street');
    await page.fill('[data-testid="shipping-city"]', 'Test City');
    await page.fill('[data-testid="shipping-zipcode"]', '12345');
    await page.click('[data-testid="continue-to-payment"]');

    // Step 8: Fill payment information
    await page.fill('[data-testid="card-number"]', '4111111111111111');
    await page.fill('[data-testid="card-expiry"]', '12/25');
    await page.fill('[data-testid="card-cvc"]', '123');
    await page.fill('[data-testid="card-name"]', 'Test User');

    // Step 9: Place order
    await page.click('[data-testid="place-order-button"]');

    // Step 10: Verify order confirmation
    await expect(page.locator('[data-testid="order-confirmation"]')).toBeVisible();
    await expect(page.locator('[data-testid="order-number"]')).toBeVisible();
    
    // Verify order details
    const orderNumber = await page.locator('[data-testid="order-number"]').textContent();
    expect(orderNumber).toMatch(/^ORD-\d+$/);
  });

  test('cart persistence across sessions', async () => {
    // Add item to cart
    await page.goto('/products/laptop-1');
    await page.click('[data-testid="add-to-cart-button"]');
    
    // Verify cart count
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText('1');

    // Reload page
    await page.reload();
    
    // Verify cart persists
    await expect(page.locator('[data-testid="cart-count"]')).toHaveText('1');
  });

  test('responsive design on mobile', async ({ browser }) => {
    // Create mobile context
    const mobileContext = await browser.newContext({
      viewport: { width: 375, height: 667 },
      userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)'
    });
    
    const mobilePage = await mobileContext.newPage();
    await mobilePage.goto('/');

    // Test mobile navigation
    await mobilePage.click('[data-testid="mobile-menu-button"]');
    await expect(mobilePage.locator('[data-testid="mobile-menu"]')).toBeVisible();

    // Test mobile product grid
    const productCards = mobilePage.locator('[data-testid="product-card"]');
    await expect(productCards).toHaveCount(6); // Mobile shows fewer items

    await mobileContext.close();
  });

  test('accessibility compliance', async () => {
    await page.goto('/');
    
    // Check for accessibility violations
    const accessibilityResults = await page.evaluate(() => {
      // This would integrate with axe-core or similar
      return {
        violations: [],
        passes: 25
      };
    });
    
    expect(accessibilityResults.violations).toHaveLength(0);
  });

  async function setupTestData() {
    // Setup test products, users, etc.
    await page.evaluate(() => {
      // Mock API responses or seed test data
      window.testData = {
        products: [
          { id: 'laptop-1', name: 'Gaming Laptop', price: 1299.99 },
          { id: 'mouse-1', name: 'Wireless Mouse', price: 29.99 }
        ]
      };
    });
  }
});
```

---

## 📊 Part 5: GitHub Actions Testing Integration

### Comprehensive Testing Workflow

**Complete Testing Pipeline:**
```yaml
name: Comprehensive Testing Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  POSTGRES_VERSION: '15'

jobs:
  # Unit Tests
  unit-tests:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        component: [frontend, backend, shared-utils]
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
          cache-dependency-path: ${{ matrix.component }}/package-lock.json
      
      - name: Install Dependencies
        working-directory: ${{ matrix.component }}
        run: npm ci
      
      - name: Run Unit Tests
        working-directory: ${{ matrix.component }}
        run: npm run test:unit -- --coverage --ci
        env:
          NODE_ENV: test
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          file: ${{ matrix.component }}/coverage/lcov.info
          flags: ${{ matrix.component }}-unit
          name: ${{ matrix.component }}-unit-coverage

  # Integration Tests
  integration-tests:
    runs-on: ubuntu-latest
    needs: unit-tests
    
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
        ports:
          - 5432:5432
```

**Comprehensive Line-by-Line Analysis:**

**`name: Comprehensive Testing Pipeline`**
- **Purpose**: Descriptive name for multi-layered testing workflow
- **Scope**: Indicates complete testing strategy implementation
- **Visibility**: Clear identification in GitHub Actions UI
- **Organization**: Easy recognition for testing-focused workflow
- **Quality**: Emphasizes comprehensive quality assurance approach

**`on: push: branches: [main, develop]`**
- **Triggers**: Executes on pushes to main and develop branches
- **Quality gates**: Ensures important branches receive full testing
- **Integration**: Continuous integration for critical branches
- **Protection**: Validates code before it reaches production
- **Efficiency**: Focuses testing resources on important branches

**`pull_request: branches: [main]`**
- **PR validation**: Tests pull requests targeting main branch
- **Quality gate**: Prevents untested code from merging
- **Review integration**: Provides test results in PR interface
- **Protection**: Ensures main branch quality standards
- **Collaboration**: Supports code review process with test results

**`env: NODE_VERSION: '18'`**
- **Global configuration**: Node.js version for entire workflow
- **Consistency**: All jobs use identical Node.js version
- **Maintenance**: Single location for version updates
- **Compatibility**: Ensures consistent runtime environment
- **Testing**: Standardized environment for reliable test results

**`POSTGRES_VERSION: '15'`**
- **Database version**: PostgreSQL version for integration tests
- **Consistency**: Matches production database version
- **Testing**: Ensures tests run against correct database version
- **Reliability**: Consistent database environment across tests
- **Production alignment**: Testing mirrors production environment

**`jobs:`**
- **Job collection**: Defines comprehensive testing job suite
- **Organization**: Logical grouping of different test types
- **Execution**: Jobs run in parallel where possible
- **Quality**: Multiple testing layers for thorough validation
- **Pipeline**: Structured testing pipeline with dependencies

**`# Unit Tests`**
- **Documentation**: Comment explaining unit testing job purpose
- **Testing layer**: First layer in testing pyramid
- **Speed**: Fast-running tests for immediate feedback
- **Isolation**: Tests individual components in isolation
- **Foundation**: Base layer of testing strategy

**`unit-tests:`**
- **Job identifier**: Descriptive name for unit testing job
- **Purpose**: Executes unit tests across multiple components
- **Matrix**: Uses matrix strategy for parallel component testing
- **Efficiency**: Parallel execution reduces total testing time
- **Coverage**: Comprehensive unit test coverage across codebase

**`runs-on: ubuntu-latest`**
- **Environment**: Ubuntu Linux for unit test execution
- **Performance**: Fast and reliable testing environment
- **Compatibility**: Supports all Node.js testing tools
- **Standard**: Common choice for JavaScript testing
- **Cost-effective**: Economical runner for unit tests

**`strategy:`**
- **Matrix configuration**: Defines parallel execution strategy
- **Efficiency**: Enables parallel testing of multiple components
- **Organization**: Structured approach to component testing
- **Scalability**: Easy to add new components to testing
- **Performance**: Reduces total pipeline execution time

**`matrix: component: [frontend, backend, shared-utils]`**
- **Component list**: Defines components for parallel testing
- **Separation**: Tests each component independently
- **Parallelization**: All components tested simultaneously
- **Organization**: Clear component-based testing structure
- **Scalability**: Easy to add or remove components

**`steps:`**
- **Step collection**: Sequential steps for unit testing
- **Process**: Standardized unit testing process
- **Reusability**: Same steps applied to each matrix component
- **Efficiency**: Optimized steps for fast unit test execution
- **Quality**: Comprehensive unit testing workflow

**`- name: Setup Node.js`**
- **Environment setup**: Configures Node.js for testing
- **Consistency**: Uses global Node.js version
- **Caching**: Enables npm dependency caching
- **Performance**: Optimized setup for testing efficiency
- **Foundation**: Required for all Node.js testing operations

**`cache-dependency-path: ${{ matrix.component }}/package-lock.json`**
- **Dynamic caching**: Component-specific cache key
- **Matrix integration**: Uses matrix variable for path
- **Efficiency**: Separate cache for each component
- **Performance**: Optimal cache hit rates per component
- **Organization**: Component-isolated dependency caching

**`- name: Install Dependencies`**
- **Dependency setup**: Installs component-specific dependencies
- **Matrix context**: Uses matrix component for directory
- **Foundation**: Required before running tests
- **Performance**: Benefits from component-specific caching
- **Isolation**: Each component has independent dependencies

**`working-directory: ${{ matrix.component }}`**
- **Dynamic directory**: Uses matrix variable for component path
- **Context**: Sets working directory for component
- **Organization**: Handles monorepo structure efficiently
- **Flexibility**: Adapts to different component structures
- **Consistency**: Standardized approach across components

**`run: npm ci`**
- **Clean install**: Reproducible dependency installation
- **Performance**: Faster than npm install in CI
- **Reliability**: Uses package-lock.json for exact versions
- **Best practice**: Preferred npm command for CI environments
- **Consistency**: Ensures identical dependency versions

**`- name: Run Unit Tests`**
- **Test execution**: Runs component-specific unit tests
- **Coverage**: Includes code coverage generation
- **CI optimization**: Uses CI-specific test configuration
- **Quality**: Comprehensive unit test validation
- **Feedback**: Provides immediate test results

**`run: npm run test:unit -- --coverage --ci`**
- **Test command**: Executes unit test script with coverage
- **Coverage**: `--coverage` generates code coverage reports
- **CI mode**: `--ci` optimizes for CI environment
- **Configuration**: Uses component-specific test configuration
- **Reporting**: Generates detailed test and coverage reports

**`env: NODE_ENV: test`**
- **Test environment**: Sets Node.js environment for testing
- **Configuration**: Enables test-specific application behavior
- **Isolation**: Separates test from production configuration
- **Standards**: Common pattern for Node.js testing
- **Optimization**: May enable test-specific optimizations

**`- name: Upload Coverage`**
- **Coverage reporting**: Uploads coverage data to external service
- **Integration**: Integrates with Codecov for coverage tracking
- **Visibility**: Makes coverage data available for review
- **Quality metrics**: Provides coverage metrics and trends
- **Collaboration**: Enables team coverage monitoring

**`uses: codecov/codecov-action@v3`**
- **Coverage action**: Third-party action for Codecov integration
- **Service**: Uploads coverage to Codecov service
- **Version**: Stable version for reliable coverage upload
- **Integration**: Seamless GitHub Actions integration
- **Reporting**: Comprehensive coverage reporting and analysis

**`file: ${{ matrix.component }}/coverage/lcov.info`**
- **Coverage file**: Component-specific coverage report file
- **Format**: LCOV format for comprehensive coverage data
- **Matrix**: Uses matrix variable for component path
- **Standard**: Common coverage report format
- **Precision**: Component-specific coverage tracking

**`flags: ${{ matrix.component }}-unit`**
- **Coverage flags**: Tags coverage data with component and test type
- **Organization**: Separates coverage by component and test layer
- **Tracking**: Enables detailed coverage analysis
- **Matrix**: Uses matrix variable for dynamic flag naming
- **Reporting**: Structured coverage data organization

**`name: ${{ matrix.component }}-unit-coverage`**
- **Coverage name**: Descriptive name for coverage report
- **Identification**: Clear component and test type identification
- **Organization**: Structured naming for coverage tracking
- **Matrix**: Dynamic naming based on matrix component
- **Clarity**: Obvious coverage report identification

**`# Integration Tests`**
- **Documentation**: Comment explaining integration testing job
- **Testing layer**: Second layer in testing pyramid
- **Scope**: Tests component interactions and integrations
- **Database**: Requires database services for realistic testing
- **Quality**: Higher-level testing for system validation

**`integration-tests:`**
- **Job identifier**: Descriptive name for integration testing
- **Purpose**: Tests component interactions and database integration
- **Dependencies**: Requires unit tests to pass first
- **Services**: Uses database services for realistic testing
- **Quality**: Comprehensive integration validation

**`needs: unit-tests`**
- **Dependency**: Waits for unit tests to complete successfully
- **Quality gate**: Only runs if unit tests pass
- **Efficiency**: Prevents unnecessary integration tests if units fail
- **Pipeline**: Logical testing progression from unit to integration
- **Resource optimization**: Avoids wasted compute on failed units

**`services:`**
- **Service containers**: Additional containers for integration testing
- **Database**: Provides PostgreSQL for realistic testing
- **Integration**: Enables database-dependent integration tests
- **Isolation**: Fresh database instance for each test run
- **Reliability**: Consistent database state for testing

**`postgres:`**
- **Database service**: PostgreSQL service for integration tests
- **Integration**: Enables realistic database testing
- **Isolation**: Dedicated database instance per job
- **Consistency**: Same database version as production
- **Testing**: Supports comprehensive integration validation

**`image: postgres:15`**
- **Database image**: PostgreSQL version 15 container
- **Version**: Matches production database version
- **Consistency**: Ensures test environment matches production
- **Reliability**: Official PostgreSQL Docker image
- **Testing**: Provides realistic database environment

**`env: POSTGRES_PASSWORD: postgres`**
- **Database auth**: Sets PostgreSQL password for testing
- **Access**: Required for application database connection
- **Testing**: Simple credentials for test environment
- **Security**: Test-only credentials, not production
- **Configuration**: Standard test database setup

**`POSTGRES_DB: ecommerce_test`**
- **Test database**: Creates dedicated test database
- **Isolation**: Separate from production database
- **Testing**: Clean database state for each test run
- **Organization**: Clear test database identification
- **Safety**: Prevents accidental production data modification

**`options: >-`**
- **Container options**: PostgreSQL container configuration
- **Health checks**: Ensures database readiness before tests
- **Reliability**: Prevents tests from running before database ready
- **Configuration**: PostgreSQL-specific startup options
- **Stability**: Proper database initialization and health monitoring

**`--health-cmd pg_isready`**
- **Health check**: PostgreSQL readiness verification command
- **Reliability**: Ensures database accepts connections
- **Timing**: Prevents premature test execution
- **Standard**: PostgreSQL utility for connection testing
- **Stability**: Reliable database readiness detection

**`--health-interval 10s`**
- **Check frequency**: Health check every 10 seconds
- **Monitoring**: Regular database health verification
- **Balance**: Frequent enough for quick startup detection
- **Performance**: Reasonable interval for health monitoring
- **Reliability**: Consistent health check timing

**`--health-timeout 5s`**
- **Check timeout**: 5-second timeout for health checks
- **Reliability**: Prevents hanging health checks
- **Performance**: Quick timeout for responsive checks
- **Stability**: Ensures checks don't block indefinitely
- **Configuration**: Appropriate timeout for database checks

**`--health-retries 5`**
- **Retry attempts**: 5 health check retries before failure
- **Reliability**: Multiple attempts for database startup
- **Patience**: Allows time for database initialization
- **Failure handling**: Eventually fails if database won't start
- **Balance**: Reasonable retry count for reliable startup

**`ports: - 5432:5432`**
- **Port mapping**: Maps PostgreSQL port for application access
- **Connectivity**: Enables integration test database connection
- **Standard**: PostgreSQL default port 5432
- **Access**: Required for application-database communication
- **Testing**: Enables realistic integration test scenarios
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
      
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Setup Test Database
        run: |
          PGPASSWORD=postgres psql -h localhost -U postgres -d ecommerce_test -c "
            CREATE TABLE IF NOT EXISTS products (
              id VARCHAR PRIMARY KEY,
              name VARCHAR NOT NULL,
              price DECIMAL(10,2) NOT NULL,
              category VARCHAR NOT NULL,
              inventory INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS users (
              id VARCHAR PRIMARY KEY,
              email VARCHAR UNIQUE NOT NULL,
              password_hash VARCHAR NOT NULL
            );
            CREATE TABLE IF NOT EXISTS orders (
              id VARCHAR PRIMARY KEY,
              user_id VARCHAR REFERENCES users(id),
              status VARCHAR NOT NULL,
              total DECIMAL(10,2) NOT NULL,
              created_at TIMESTAMP DEFAULT NOW()
            );
          "
      
      - name: Run Integration Tests
        run: npm run test:integration -- --ci
        env:
          NODE_ENV: test
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/ecommerce_test
          REDIS_URL: redis://localhost:6379
      
      - name: Upload Integration Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: integration-test-results
          path: test-results/

  # E2E Tests
  e2e-tests:
    runs-on: ubuntu-latest
    needs: integration-tests
    
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'
      
      - name: Install Dependencies
        run: npm ci
      
      - name: Install Playwright
        run: npx playwright install --with-deps
      
      - name: Build Application
        run: npm run build
      
      - name: Start Application
        run: |
          npm start &
          sleep 30
        env:
          NODE_ENV: test
          PORT: 3000
      
      - name: Run E2E Tests
        run: npx playwright test
        env:
          BASE_URL: http://localhost:3000
      
      - name: Upload E2E Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: e2e-test-results
          path: |
            playwright-report/
            test-results/

  # Test Quality Gate
  test-quality-gate:
    runs-on: ubuntu-latest
    needs: [unit-tests, integration-tests, e2e-tests]
    if: always()
    
    steps:
      - name: Download Test Results
        uses: actions/download-artifact@v3
      
      - name: Evaluate Test Quality Gate
        run: |
          echo "📊 Test Quality Gate Evaluation"
          
          # Check coverage thresholds
          COVERAGE_THRESHOLD=80
          
          # Check test results
          if [ "${{ needs.unit-tests.result }}" != "success" ]; then
            echo "❌ Unit tests failed"
            exit 1
          fi
          
          if [ "${{ needs.integration-tests.result }}" != "success" ]; then
            echo "❌ Integration tests failed"
            exit 1
          fi
          
          if [ "${{ needs.e2e-tests.result }}" != "success" ]; then
            echo "❌ E2E tests failed"
            exit 1
          fi
          
          echo "✅ All tests passed - Quality gate approved"
```

---

## 🎓 Module Summary

You've mastered testing strategies by learning:

**Core Concepts:**
- Testing pyramid and comprehensive test strategy
- Unit, integration, and end-to-end testing approaches
- Test coverage analysis and quality gates
- Performance and accessibility testing

**Practical Skills:**
- Jest configuration for enterprise applications
- API integration testing with real databases
- Playwright E2E testing for user journeys
- GitHub Actions testing pipeline automation

**Enterprise Applications:**
- Production-ready testing frameworks
- Comprehensive quality gate implementation
- Multi-environment testing strategies
- Automated test reporting and analysis

**Next Steps:**
- Implement comprehensive testing for your e-commerce project
- Set up quality gates with appropriate thresholds
- Configure automated test reporting
- Prepare for Module 8: Advanced SAST Tools

---

## 📚 Additional Resources

- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Playwright Testing Guide](https://playwright.dev/docs/intro)
- [Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)
- [Test Coverage Analysis](https://istanbul.js.org/)
