import { test, expect } from '@playwright/test';

test.describe('Debug API Errors', () => {
  test('Get detailed error from products endpoint', async ({ request }) => {
    try {
      const response = await request.get('http://localhost:8000/api/v1/products');
      console.log(`Products endpoint status: ${response.status()}`);
      
      const responseText = await response.text();
      console.log(`Products response: ${responseText}`);
      
      if (response.status() === 404) {
        console.log('❌ 404 Error - Route not found or not registered');
      }
      
      // Try to parse as JSON to see error details
      try {
        const errorData = JSON.parse(responseText);
        console.log(`Error details:`, errorData);
      } catch (e) {
        console.log('Response is not JSON');
      }
      
    } catch (error) {
      console.log(`Request failed: ${error.message}`);
    }

    // Test a POST to login to see if that works
    try {
      const loginResponse = await request.post('http://localhost:8000/api/v1/auth/login', {
        data: {
          email: 'user@ecommerce.com',
          password: 'user123'
        }
      });
      console.log(`Login POST status: ${loginResponse.status()}`);
      
      if (loginResponse.status() !== 200) {
        const loginText = await loginResponse.text();
        console.log(`Login error: ${loginText}`);
      }
    } catch (error) {
      console.log(`Login request failed: ${error.message}`);
    }

    expect(true).toBe(true); // Always pass, just for debugging
  });
});
