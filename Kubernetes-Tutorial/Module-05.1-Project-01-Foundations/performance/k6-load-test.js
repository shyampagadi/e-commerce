// K6 Load Testing Script for E-commerce Application
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
export let errorRate = new Rate('errors');

// Test configuration
export let options = {
  stages: [
    { duration: '2m', target: 10 },   // Ramp up to 10 users
    { duration: '5m', target: 10 },   // Stay at 10 users
    { duration: '2m', target: 20 },   // Ramp up to 20 users
    { duration: '5m', target: 20 },   // Stay at 20 users
    { duration: '2m', target: 0 },    // Ramp down to 0 users
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
    http_req_failed: ['rate<0.1'],    // Error rate must be below 10%
    errors: ['rate<0.1'],             // Custom error rate below 10%
  },
};

// Base URL - update with your service endpoint
const BASE_URL = 'http://localhost:8080';

export default function() {
  // Test scenarios
  let scenarios = [
    testHomePage,
    testProductList,
    testProductDetail,
    testUserRegistration,
    testUserLogin,
    testAddToCart,
    testCheckout
  ];
  
  // Randomly select a scenario
  let scenario = scenarios[Math.floor(Math.random() * scenarios.length)];
  scenario();
  
  sleep(1);
}

function testHomePage() {
  let response = http.get(`${BASE_URL}/`);
  let success = check(response, {
    'homepage status is 200': (r) => r.status === 200,
    'homepage response time < 200ms': (r) => r.timings.duration < 200,
  });
  errorRate.add(!success);
}

function testProductList() {
  let response = http.get(`${BASE_URL}/api/v1/products`);
  let success = check(response, {
    'products list status is 200': (r) => r.status === 200,
    'products list response time < 300ms': (r) => r.timings.duration < 300,
    'products list has data': (r) => JSON.parse(r.body).length > 0,
  });
  errorRate.add(!success);
}

function testProductDetail() {
  let productId = Math.floor(Math.random() * 10) + 1;
  let response = http.get(`${BASE_URL}/api/v1/products/${productId}`);
  let success = check(response, {
    'product detail status is 200': (r) => r.status === 200,
    'product detail response time < 250ms': (r) => r.timings.duration < 250,
  });
  errorRate.add(!success);
}

function testUserRegistration() {
  let userData = {
    email: `test${Math.random()}@example.com`,
    password: 'testpassword123',
    name: 'Test User'
  };
  
  let response = http.post(`${BASE_URL}/api/v1/auth/register`, JSON.stringify(userData), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  let success = check(response, {
    'registration status is 201': (r) => r.status === 201,
    'registration response time < 400ms': (r) => r.timings.duration < 400,
  });
  errorRate.add(!success);
}

function testUserLogin() {
  let loginData = {
    email: 'user@ecommerce.com',
    password: 'user123'
  };
  
  let response = http.post(`${BASE_URL}/api/v1/auth/login`, JSON.stringify(loginData), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  let success = check(response, {
    'login status is 200': (r) => r.status === 200,
    'login response time < 300ms': (r) => r.timings.duration < 300,
    'login returns token': (r) => JSON.parse(r.body).token !== undefined,
  });
  errorRate.add(!success);
}

function testAddToCart() {
  // First login to get token
  let loginResponse = http.post(`${BASE_URL}/api/v1/auth/login`, JSON.stringify({
    email: 'user@ecommerce.com',
    password: 'user123'
  }), {
    headers: { 'Content-Type': 'application/json' },
  });
  
  if (loginResponse.status === 200) {
    let token = JSON.parse(loginResponse.body).token;
    let cartData = {
      product_id: Math.floor(Math.random() * 10) + 1,
      quantity: Math.floor(Math.random() * 3) + 1
    };
    
    let response = http.post(`${BASE_URL}/api/v1/cart/items`, JSON.stringify(cartData), {
      headers: { 
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
    });
    
    let success = check(response, {
      'add to cart status is 201': (r) => r.status === 201,
      'add to cart response time < 350ms': (r) => r.timings.duration < 350,
    });
    errorRate.add(!success);
  }
}

function testCheckout() {
  // Simplified checkout test
  let response = http.get(`${BASE_URL}/api/v1/cart/summary`);
  let success = check(response, {
    'cart summary accessible': (r) => r.status === 200 || r.status === 401, // 401 if not authenticated
    'cart summary response time < 200ms': (r) => r.timings.duration < 200,
  });
  errorRate.add(!success);
}
