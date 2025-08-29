import { test, expect } from '@playwright/test';

const API_BASE = 'http://localhost:8000/api/v1';

test.describe('Working API Tests', () => {
  test('Backend is accessible', async ({ request }) => {
    const response = await request.get('http://localhost:8000/');
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    expect(data).toHaveProperty('message');
    console.log('✅ Backend root endpoint works');
  });

  test('API docs are accessible', async ({ request }) => {
    const response = await request.get('http://localhost:8000/docs');
    expect(response.status()).toBe(200);
    console.log('✅ API docs are accessible');
  });

  test('Login endpoint works', async ({ request }) => {
    const response = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: 'user@ecommerce.com',
        password: 'user123'
      }
    });

    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(data).toHaveProperty('access_token');
    expect(data).toHaveProperty('token_type', 'bearer');
    console.log('✅ Login works correctly');
  });

  test('Login with invalid credentials fails', async ({ request }) => {
    const response = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: 'invalid@example.com',
        password: 'wrongpassword'
      }
    });

    expect([400, 401, 422]).toContain(response.status());
    console.log('✅ Invalid login properly rejected');
  });

  test('Protected endpoint requires authentication', async ({ request }) => {
    const response = await request.get(`${API_BASE}/auth/me`);
    expect([401, 403]).toContain(response.status());
    console.log('✅ Protected endpoints require auth');
  });

  test('Protected endpoint works with valid token', async ({ request }) => {
    // First login to get token
    const loginResponse = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: 'user@ecommerce.com',
        password: 'user123'
      }
    });

    expect(loginResponse.status()).toBe(200);
    const { access_token } = await loginResponse.json();

    // Use token to access protected endpoint
    const response = await request.get(`${API_BASE}/auth/me`, {
      headers: {
        'Authorization': `Bearer ${access_token}`
      }
    });

    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(data).toHaveProperty('email', 'user@ecommerce.com');
    console.log('✅ Token authentication works');
  });
});
