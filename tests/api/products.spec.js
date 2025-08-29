import { test, expect } from '@playwright/test';
import { testUsers } from '../fixtures/users.js';

const API_BASE = 'http://localhost:8000/api/v1';

test.describe('Products API', () => {
  let adminToken;

  test.beforeAll(async ({ request }) => {
    // Get admin token for protected operations
    const response = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: testUsers.admin.email,
        password: testUsers.admin.password
      }
    });
    const data = await response.json();
    adminToken = data.access_token;
  });

  test('Get all products', async ({ request }) => {
    const response = await request.get(`${API_BASE}/products`);
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    expect(data).toHaveProperty('products');
    expect(Array.isArray(data.products)).toBe(true);
    expect(data.products.length).toBeGreaterThan(0);
  });

  test('Get product by ID', async ({ request }) => {
    // First get all products to get a valid ID
    const productsResponse = await request.get(`${API_BASE}/products`);
    const productsData = await productsResponse.json();
    const firstProduct = productsData.products[0];

    // Get specific product
    const response = await request.get(`${API_BASE}/products/${firstProduct.id}`);
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    expect(data).toHaveProperty('id', firstProduct.id);
    expect(data).toHaveProperty('name');
    expect(data).toHaveProperty('price');
  });

  test('Search products', async ({ request }) => {
    const response = await request.get(`${API_BASE}/products?search=iPhone`);
    expect(response.status()).toBe(200);
    
    const data = await response.json();
    expect(data).toHaveProperty('products');
    
    // Verify search results contain iPhone
    if (data.products.length > 0) {
      expect(data.products[0].name.toLowerCase()).toContain('iphone');
    }
  });

  test('Filter products by category', async ({ request }) => {
    // First get categories
    const categoriesResponse = await request.get(`${API_BASE}/categories`);
    const categories = await categoriesResponse.json();
    
    if (categories.length > 0) {
      const categoryId = categories[0].id;
      
      const response = await request.get(`${API_BASE}/products?category_id=${categoryId}`);
      expect(response.status()).toBe(200);
      
      const data = await response.json();
      expect(data).toHaveProperty('products');
    }
  });

  test('Admin can create product', async ({ request }) => {
    const newProduct = {
      name: `Test Product ${Date.now()}`,
      description: 'Test product description',
      price: 99.99,
      quantity: 10,
      sku: `TEST${Date.now()}`,
      category_id: 1
    };

    const response = await request.post(`${API_BASE}/products`, {
      headers: {
        'Authorization': `Bearer ${adminToken}`
      },
      data: newProduct
    });

    expect(response.status()).toBe(201);
    const data = await response.json();
    expect(data).toHaveProperty('name', newProduct.name);
    expect(data).toHaveProperty('sku', newProduct.sku);
  });

  test('Non-admin cannot create product', async ({ request }) => {
    // Get regular user token
    const loginResponse = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: testUsers.user.email,
        password: testUsers.user.password
      }
    });
    const { access_token } = await loginResponse.json();

    const newProduct = {
      name: 'Unauthorized Product',
      description: 'This should fail',
      price: 99.99,
      quantity: 10,
      sku: 'FAIL001',
      category_id: 1
    };

    const response = await request.post(`${API_BASE}/products`, {
      headers: {
        'Authorization': `Bearer ${access_token}`
      },
      data: newProduct
    });

    expect(response.status()).toBe(403);
  });
});
