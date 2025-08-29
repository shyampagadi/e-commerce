// Test user credentials
export const testUsers = {
  admin: {
    email: 'admin@ecommerce.com',
    password: 'admin123',
    role: 'admin'
  },
  user: {
    email: 'user@ecommerce.com',
    password: 'user123',
    role: 'user'
  },
  newUser: {
    email: 'test@example.com',
    password: 'test123',
    firstName: 'Test',
    lastName: 'User',
    phone: '+1-555-0199',
    address: '123 Test Street',
    city: 'Test City',
    state: 'TS',
    zipCode: '12345',
    country: 'USA'
  }
};

// Test product data
export const testProduct = {
  name: 'Test Product',
  description: 'A test product for automated testing',
  price: 99.99,
  quantity: 10,
  sku: 'TEST001'
};

// Test order data
export const testOrder = {
  shippingAddress: {
    firstName: 'John',
    lastName: 'Doe',
    address: '123 Main St',
    city: 'Anytown',
    state: 'CA',
    zipCode: '12345',
    country: 'USA',
    phone: '+1-555-0123'
  }
};
