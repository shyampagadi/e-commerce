import { test, expect, devices } from '@playwright/test';

test.describe('Mobile Responsiveness', () => {
  test('Mobile navigation works correctly', async ({ browser }) => {
    const context = await browser.newContext({
      ...devices['iPhone 12']
    });
    const page = await context.newPage();

    await page.goto('/');
    
    // Check mobile menu
    await page.click('[data-testid="mobile-menu-button"]');
    await expect(page.locator('[data-testid="mobile-menu"]')).toBeVisible();
    
    // Navigate to products
    await page.click('[data-testid="mobile-menu"] text=Products');
    await expect(page).toHaveURL('/products');
    
    await context.close();
  });

  test('Product grid adapts to mobile', async ({ browser }) => {
    const context = await browser.newContext({
      ...devices['iPhone 12']
    });
    const page = await context.newPage();

    await page.goto('/products');
    
    // Check that products are displayed in single column on mobile
    const productCards = page.locator('[data-testid="product-card"]');
    await expect(productCards.first()).toBeVisible();
    
    // Verify mobile-friendly layout
    const firstCard = productCards.first();
    const box = await firstCard.boundingBox();
    expect(box.width).toBeGreaterThan(300); // Should take most of screen width
    
    await context.close();
  });

  test('Cart is accessible on mobile', async ({ browser }) => {
    const context = await browser.newContext({
      ...devices['iPhone 12']
    });
    const page = await context.newPage();

    await page.goto('/products');
    
    // Add item to cart
    await page.click('[data-testid="product-card"]').first();
    await page.click('[data-testid="add-to-cart"]');
    
    // Access cart from mobile menu
    await page.click('[data-testid="mobile-menu-button"]');
    await page.click('[data-testid="cart-link"]');
    
    await expect(page).toHaveURL('/cart');
    await expect(page.locator('[data-testid="cart-item"]')).toBeVisible();
    
    await context.close();
  });

  test('Checkout form is mobile-friendly', async ({ browser }) => {
    const context = await browser.newContext({
      ...devices['iPhone 12']
    });
    const page = await context.newPage();

    // Login and add item to cart
    await page.goto('/login');
    await page.fill('[data-testid="email"]', 'user@ecommerce.com');
    await page.fill('[data-testid="password"]', 'user123');
    await page.click('[data-testid="login-button"]');
    
    await page.goto('/products');
    await page.click('[data-testid="product-card"]').first();
    await page.click('[data-testid="add-to-cart"]');
    
    // Go to checkout
    await page.click('[data-testid="cart-icon"]');
    await page.click('[data-testid="checkout-button"]');
    
    // Verify form fields are accessible on mobile
    await expect(page.locator('[data-testid="firstName"]')).toBeVisible();
    await expect(page.locator('[data-testid="lastName"]')).toBeVisible();
    
    // Test form input on mobile
    await page.fill('[data-testid="firstName"]', 'John');
    await page.fill('[data-testid="lastName"]', 'Doe');
    
    const firstNameValue = await page.inputValue('[data-testid="firstName"]');
    expect(firstNameValue).toBe('John');
    
    await context.close();
  });
});
