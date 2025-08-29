import { test, expect } from '@playwright/test';
import { testUsers } from '../fixtures/users.js';

const API_BASE = 'http://localhost:8000/api/v1';

test.describe('Authentication API', () => {
  test('User can login with valid credentials', async ({ request }) => {
    const response = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: testUsers.user.email,
        password: testUsers.user.password
      }
    });

    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(data).toHaveProperty('access_token');
    expect(data).toHaveProperty('token_type', 'bearer');
  });

  test('Login fails with invalid credentials', async ({ request }) => {
    const response = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: 'invalid@example.com',
        password: 'wrongpassword'
      }
    });

    expect(response.status()).toBe(401);
  });

  test('User can register with valid data', async ({ request }) => {
    const newUser = {
      email: `test${Date.now()}@example.com`,
      password: 'test123',
      username: `testuser${Date.now()}`,
      first_name: 'Test',
      last_name: 'User',
      phone: '+1-555-0123',
      address: '123 Test St',
      city: 'Test City',
      state: 'TS',
      zip_code: '12345',
      country: 'USA'
    };

    const response = await request.post(`${API_BASE}/auth/register`, {
      data: newUser
    });

    expect([200, 201]).toContain(response.status());
    if (response.status() === 201 || response.status() === 200) {
      const data = await response.json();
      expect(data).toHaveProperty('email', newUser.email);
    }
  });

  test('Protected endpoint requires authentication', async ({ request }) => {
    const response = await request.get(`${API_BASE}/auth/me`);
    // Backend returns 403 instead of 401 for missing auth
    expect([401, 403]).toContain(response.status());
  });

  test('Protected endpoint works with valid token', async ({ request }) => {
    // First login to get token
    const loginResponse = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: testUsers.user.email,
        password: testUsers.user.password
      }
    });

    const { access_token } = await loginResponse.json();

    // Use token to access protected endpoint
    const response = await request.get(`${API_BASE}/auth/me`, {
      headers: {
        'Authorization': `Bearer ${access_token}`
      }
    });

    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(data).toHaveProperty('email', testUsers.user.email);
  });
});
