import { test, expect } from '@playwright/test';

const API_BASE = 'http://localhost:8000/api/v1';

test.describe('Basic API Tests', () => {
  test('Health check - API is accessible', async ({ request }) => {
    const response = await request.get(`${API_BASE}/products`);
    expect(response.status()).toBe(200);
  });

  test('Products endpoint returns data', async ({ request }) => {
    const response = await request.get(`${API_BASE}/products`);
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    expect(data).toHaveProperty('products');
    expect(Array.isArray(data.products)).toBe(true);
  });

  test('Categories endpoint works', async ({ request }) => {
    const response = await request.get(`${API_BASE}/categories`);
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    expect(Array.isArray(data)).toBe(true);
  });
});
