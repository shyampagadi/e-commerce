import { test, expect } from '@playwright/test';
import { testUsers } from '../fixtures/users.js';

const API_BASE = 'http://localhost:8000/api/v1';

test.describe('Cart and Checkout API', () => {
  let userToken;
  let productId;

  test.beforeAll(async ({ request }) => {
    // Get user token
    const loginResponse = await request.post(`${API_BASE}/auth/login`, {
      data: {
        email: testUsers.user.email,
        password: testUsers.user.password
      }
    });
    const loginData = await loginResponse.json();
    userToken = loginData.access_token;

    // Get a product ID for testing
    const productsResponse = await request.get(`${API_BASE}/products`);
    const productsData = await productsResponse.json();
    productId = productsData.products[0].id;
  });

  test('Add item to cart', async ({ request }) => {
    const response = await request.post(`${API_BASE}/cart/items`, {
      headers: {
        'Authorization': `Bearer ${userToken}`
      },
      data: {
        product_id: productId,
        quantity: 2
      }
    });

    expect(response.status()).toBe(201);
    const data = await response.json();
    expect(data).toHaveProperty('product_id', productId);
    expect(data).toHaveProperty('quantity', 2);
  });

  test('Get cart items', async ({ request }) => {
    const response = await request.get(`${API_BASE}/cart`, {
      headers: {
        'Authorization': `Bearer ${userToken}`
      }
    });

    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(Array.isArray(data)).toBe(true);
  });

  test('Update cart item quantity', async ({ request }) => {
    // First add item to cart
    const addResponse = await request.post(`${API_BASE}/cart/items`, {
      headers: {
        'Authorization': `Bearer ${userToken}`
      },
      data: {
        product_id: productId,
        quantity: 1
      }
    });
    const addData = await addResponse.json();

    // Update quantity
    const response = await request.put(`${API_BASE}/cart/items/${addData.id}`, {
      headers: {
        'Authorization': `Bearer ${userToken}`
      },
      data: {
        quantity: 3
      }
    });

    expect(response.status()).toBe(200);
    const data = await response.json();
    expect(data).toHaveProperty('quantity', 3);
  });

  test('Remove item from cart', async ({ request }) => {
    // First add item to cart
    const addResponse = await request.post(`${API_BASE}/cart/items`, {
      headers: {
        'Authorization': `Bearer ${userToken}`
      },
      data: {
        product_id: productId,
        quantity: 1
      }
    });
    const addData = await addResponse.json();

    // Remove item
    const response = await request.delete(`${API_BASE}/cart/items/${addData.id}`, {
      headers: {
        'Authorization': `Bearer ${userToken}`
      }
    });

    expect(response.status()).toBe(204);
  });

  test('Create order from cart', async ({ request }) => {
    // Add item to cart first
    await request.post(`${API_BASE}/cart/items`, {
      headers: {
        'Authorization': `Bearer ${userToken}`
      },
      data: {
        product_id: productId,
        quantity: 1
      }
    });

    // Create order
    const response = await request.post(`${API_BASE}/orders`, {
      headers: {
        'Authorization': `Bearer ${userToken}`
      },
      data: {
        shipping_address: {
          first_name: 'John',
          last_name: 'Doe',
          address: '123 Main St',
          city: 'Anytown',
          state: 'CA',
          zip_code: '12345',
          country: 'USA',
          phone: '+1-555-0123'
        }
      }
    });

    expect(response.status()).toBe(201);
    const data = await response.json();
    expect(data).toHaveProperty('id');
    expect(data).toHaveProperty('status', 'pending');
  });
});
