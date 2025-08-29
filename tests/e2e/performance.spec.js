import { test, expect } from '@playwright/test';

test.describe('Performance Tests', () => {
  test('Homepage loads within acceptable time', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    expect(loadTime).toBeLessThan(3000); // 3 seconds max
  });

  test('Products page loads quickly with images', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/products');
    
    // Wait for products to load
    await expect(page.locator('[data-testid="product-card"]').first()).toBeVisible();
    
    // Wait for first product image to load
    await expect(page.locator('[data-testid="product-card"] img').first()).toBeVisible();
    
    const loadTime = Date.now() - startTime;
    expect(loadTime).toBeLessThan(5000); // 5 seconds max for products with images
  });

  test('Search is responsive', async ({ page }) => {
    await page.goto('/products');
    
    const startTime = Date.now();
    await page.fill('[data-testid="search-input"]', 'iPhone');
    
    // Wait for search results
    await page.waitForFunction(() => {
      const products = document.querySelectorAll('[data-testid="product-card"]');
      return products.length > 0;
    });
    
    const searchTime = Date.now() - startTime;
    expect(searchTime).toBeLessThan(1000); // 1 second max for search
  });

  test('Cart operations are fast', async ({ page }) => {
    await page.goto('/products');
    
    const startTime = Date.now();
    
    // Click first product and add to cart
    await page.click('[data-testid="product-card"]').first();
    await page.click('[data-testid="add-to-cart"]');
    
    // Wait for cart notification
    await expect(page.locator('text=Added to cart')).toBeVisible();
    
    const operationTime = Date.now() - startTime;
    expect(operationTime).toBeLessThan(2000); // 2 seconds max
  });
});
