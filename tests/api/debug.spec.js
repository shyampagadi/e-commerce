import { test, expect } from '@playwright/test';

test.describe('Debug Backend Routes', () => {
  test('Check what endpoints are available', async ({ request }) => {
    console.log('🔍 Testing backend endpoints...');
    
    // Test root endpoint
    try {
      const rootResponse = await request.get('http://localhost:8000/');
      console.log(`Root (/) status: ${rootResponse.status()}`);
      if (rootResponse.status() === 200) {
        const rootText = await rootResponse.text();
        console.log(`Root response: ${rootText.substring(0, 100)}...`);
      }
    } catch (error) {
      console.log(`Root endpoint error: ${error.message}`);
    }

    // Test docs endpoint
    try {
      const docsResponse = await request.get('http://localhost:8000/docs');
      console.log(`Docs (/docs) status: ${docsResponse.status()}`);
    } catch (error) {
      console.log(`Docs endpoint error: ${error.message}`);
    }

    // Test API endpoints
    const endpoints = [
      '/api/v1/products',
      '/api/v1/categories', 
      '/api/v1/auth/login',
      '/products',  // Maybe it's without /api/v1?
      '/categories'
    ];

    for (const endpoint of endpoints) {
      try {
        const response = await request.get(`http://localhost:8000${endpoint}`);
        console.log(`${endpoint} status: ${response.status()}`);
        
        if (response.status() === 200) {
          const data = await response.json();
          console.log(`${endpoint} response type: ${typeof data}, keys: ${Object.keys(data).slice(0, 3)}`);
        }
      } catch (error) {
        console.log(`${endpoint} error: ${error.message}`);
      }
    }

    // This test always passes, it's just for debugging
    expect(true).toBe(true);
  });
});
