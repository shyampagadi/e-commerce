import { test as base } from '@playwright/test';
import { AuthHelper } from './auth.js';

// Extend base test with custom fixtures
export const test = base.extend({
  // Auto-login as regular user
  authenticatedPage: async ({ page }, use) => {
    const authHelper = new AuthHelper(page);
    await authHelper.loginAsUser();
    await use(page);
  },

  // Auto-login as admin
  adminPage: async ({ page }, use) => {
    const authHelper = new AuthHelper(page);
    await authHelper.loginAsAdmin();
    await use(page);
  },

  // API context with authentication
  authenticatedAPI: async ({ request }, use) => {
    // Login to get token
    const response = await request.post('http://localhost:8000/api/v1/auth/login', {
      data: {
        email: 'user@ecommerce.com',
        password: 'user123'
      }
    });
    const { access_token } = await response.json();

    // Create new request context with auth header
    const apiContext = await request.newContext({
      extraHTTPHeaders: {
        'Authorization': `Bearer ${access_token}`
      }
    });

    await use(apiContext);
  },

  // Clean cart before each test
  cleanCart: async ({ authenticatedAPI }, use) => {
    // Clear cart before test
    await authenticatedAPI.delete('http://localhost:8000/api/v1/cart');
    await use(authenticatedAPI);
    // Clean up after test
    await authenticatedAPI.delete('http://localhost:8000/api/v1/cart');
  }
});

export { expect } from '@playwright/test';
