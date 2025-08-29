import { test, expect } from '@playwright/test';
import { AuthHelper } from '../fixtures/auth.js';
import { testUsers, testOrder } from '../fixtures/users.js';

test.describe('Complete User Journey', () => {
  let authHelper;

  test.beforeEach(async ({ page }) => {
    authHelper = new AuthHelper(page);
  });

  test('Guest user can browse products and register', async ({ page }) => {
    // Visit homepage
    await page.goto('/');
    await expect(page).toHaveTitle(/E-Commerce/);

    // Browse products
    await page.click('text=Products');
    await expect(page).toHaveURL('/products');
    
    // Verify products are loaded
    await expect(page.locator('[data-testid="product-card"]').first()).toBeVisible();
    
    // Search for a product
    await page.fill('[data-testid="search-input"]', 'iPhone');
    await expect(page.locator('text=iPhone 15 Pro')).toBeVisible();

    // View product details
    await page.click('text=iPhone 15 Pro');
    await expect(page).toHaveURL(/\/products\/iphone-15-pro/);
    await expect(page.locator('[data-testid="product-name"]')).toContainText('iPhone 15 Pro');
    
    // Try to add to cart (should redirect to login)
    await page.click('[data-testid="add-to-cart"]');
    await expect(page).toHaveURL('/login');

    // Register new user
    await page.click('text=Register');
    await authHelper.register(testUsers.newUser);
  });

  test('Registered user can complete purchase', async ({ page }) => {
    // Login as regular user
    await authHelper.loginAsUser();

    // Browse and add product to cart
    await page.goto('/products');
    await page.click('[data-testid="product-card"]').first();
    await page.click('[data-testid="add-to-cart"]');
    
    // Verify cart notification
    await expect(page.locator('text=Added to cart')).toBeVisible();

    // Go to cart
    await page.click('[data-testid="cart-icon"]');
    await expect(page).toHaveURL('/cart');
    await expect(page.locator('[data-testid="cart-item"]')).toBeVisible();

    // Update quantity
    await page.click('[data-testid="quantity-increase"]');
    await expect(page.locator('[data-testid="quantity-input"]')).toHaveValue('2');

    // Proceed to checkout
    await page.click('[data-testid="checkout-button"]');
    await expect(page).toHaveURL('/checkout');

    // Fill shipping information
    await page.fill('[data-testid="firstName"]', testOrder.shippingAddress.firstName);
    await page.fill('[data-testid="lastName"]', testOrder.shippingAddress.lastName);
    await page.fill('[data-testid="address"]', testOrder.shippingAddress.address);
    await page.fill('[data-testid="city"]', testOrder.shippingAddress.city);
    await page.fill('[data-testid="state"]', testOrder.shippingAddress.state);
    await page.fill('[data-testid="zipCode"]', testOrder.shippingAddress.zipCode);
    await page.fill('[data-testid="phone"]', testOrder.shippingAddress.phone);

    // Place order
    await page.click('[data-testid="place-order"]');
    
    // Verify order success
    await expect(page.locator('text=Order placed successfully')).toBeVisible();
    await expect(page).toHaveURL(/\/orders\/\d+/);
  });

  test('User can view order history', async ({ page }) => {
    await authHelper.loginAsUser();

    // Go to orders page
    await page.click('[data-testid="user-menu"]');
    await page.click('text=Orders');
    await expect(page).toHaveURL('/orders');

    // Verify orders are displayed
    await expect(page.locator('[data-testid="order-item"]').first()).toBeVisible();

    // View order details
    await page.click('[data-testid="order-item"]').first();
    await expect(page).toHaveURL(/\/orders\/\d+/);
    await expect(page.locator('[data-testid="order-details"]')).toBeVisible();
  });
});
