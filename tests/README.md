# E-Commerce Application Tests

Comprehensive test suite for the e-commerce application using Playwright for E2E and API testing.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Backend server running on port 8000
- Frontend server running on port 3000
- Database with test data

### Installation
```bash
cd tests
npm install
npx playwright install
```

### Running Tests
```bash
# Run all tests
npm test

# Run specific test suites
npm run test:api      # API tests only
npm run test:e2e      # E2E tests only

# Run with UI mode (interactive)
npm run test:ui

# Run in headed mode (see browser)
npm run test:headed

# Debug mode
npm run test:debug
```

## 📁 Test Structure

```
tests/
├── e2e/                    # End-to-end tests
│   ├── user-journey.spec.js    # Complete user flows
│   ├── admin.spec.js           # Admin functionality
│   ├── performance.spec.js     # Performance tests
│   └── mobile.spec.js          # Mobile responsiveness
├── api/                    # API tests
│   ├── auth.spec.js           # Authentication endpoints
│   ├── products.spec.js       # Product CRUD operations
│   └── cart.spec.js           # Cart and checkout
├── fixtures/               # Test utilities and data
│   ├── users.js              # Test user data
│   ├── auth.js               # Authentication helpers
│   └── setup.js              # Custom test fixtures
├── playwright.config.js    # Playwright configuration
└── package.json           # Dependencies and scripts
```

## 🧪 Test Coverage

### E2E Tests
- ✅ **User Registration & Login**
- ✅ **Product Browsing & Search**
- ✅ **Shopping Cart Operations**
- ✅ **Checkout Process**
- ✅ **Order Management**
- ✅ **Admin Product Management**
- ✅ **Admin Order Management**
- ✅ **Mobile Responsiveness**
- ✅ **Performance Benchmarks**

### API Tests
- ✅ **Authentication Endpoints**
- ✅ **Product CRUD Operations**
- ✅ **Cart Management**
- ✅ **Order Processing**
- ✅ **Authorization & Permissions**

## 🔧 Configuration

### Environment Variables
Tests use the following environment variables:
- `REACT_APP_API_URL`: Frontend API URL (default: http://localhost:8000)
- `DATABASE_URL`: Database connection string

### Browser Configuration
Tests run on:
- ✅ **Desktop Chrome**
- ✅ **Desktop Firefox**
- ✅ **Desktop Safari**
- ✅ **Mobile Chrome (Pixel 5)**

## 📊 CI/CD Integration

### GitHub Actions
The test suite is configured to run automatically on:
- Push to `main` or `develop` branches
- Pull requests to `main`

### Test Reports
- **HTML Report**: Generated after each test run
- **JUnit XML**: For CI/CD integration
- **JSON Results**: For custom reporting
- **Screenshots**: Captured on test failures
- **Videos**: Recorded for failed tests

### Artifacts
Test artifacts are automatically uploaded:
- Test reports (30 days retention)
- Screenshots and videos (30 days retention)

## 🐛 Debugging

### Local Debugging
```bash
# Run specific test with debug
npx playwright test user-journey.spec.js --debug

# Run with trace viewer
npx playwright test --trace on

# Show test report
npm run report
```

### CI Debugging
- Check GitHub Actions logs
- Download test artifacts from failed runs
- Review screenshots and videos

## 📈 Performance Benchmarks

### Expected Performance
- **Homepage load**: < 3 seconds
- **Products page**: < 5 seconds (with images)
- **Search response**: < 1 second
- **Cart operations**: < 2 seconds

### Load Testing
Tests verify the application handles:
- Multiple concurrent users
- Image loading performance
- Database query efficiency
- API response times

## 🔒 Security Testing

### Authentication Tests
- ✅ Valid/invalid login attempts
- ✅ Token validation
- ✅ Protected route access
- ✅ Admin permission checks

### Data Validation
- ✅ Input sanitization
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ CSRF protection

## 📝 Writing New Tests

### E2E Test Example
```javascript
import { test, expect } from './fixtures/setup.js';

test('New feature test', async ({ authenticatedPage }) => {
  await authenticatedPage.goto('/new-feature');
  await expect(authenticatedPage.locator('h1')).toContainText('New Feature');
});
```

### API Test Example
```javascript
import { test, expect } from '@playwright/test';

test('New API endpoint', async ({ request }) => {
  const response = await request.get('/api/v1/new-endpoint');
  expect(response.status()).toBe(200);
});
```

## 🚨 Troubleshooting

### Common Issues
1. **Servers not running**: Ensure backend (8000) and frontend (3000) are running
2. **Database not seeded**: Run `python database/setup.py --all`
3. **Browser installation**: Run `npx playwright install`
4. **Port conflicts**: Check if ports 3000/8000 are available

### Test Failures
- Check test artifacts for screenshots/videos
- Review browser console logs
- Verify test data setup
- Check network requests in trace viewer

## 📞 Support

For test-related issues:
1. Check this README
2. Review test logs and artifacts
3. Check Playwright documentation
4. Create issue with test failure details
