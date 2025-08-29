import { test, expect } from '@playwright/test';
import { AuthHelper } from '../fixtures/auth.js';
import { testProduct } from '../fixtures/users.js';

test.describe('Admin Functionality', () => {
  let authHelper;

  test.beforeEach(async ({ page }) => {
    authHelper = new AuthHelper(page);
    await authHelper.loginAsAdmin();
  });

  test('Admin can manage products', async ({ page }) => {
    // Navigate to admin panel
    await page.click('[data-testid="admin-menu"]');
    await page.click('text=Products');
    await expect(page).toHaveURL('/admin/products');

    // Create new product
    await page.click('[data-testid="add-product"]');
    await page.fill('[data-testid="product-name"]', testProduct.name);
    await page.fill('[data-testid="product-description"]', testProduct.description);
    await page.fill('[data-testid="product-price"]', testProduct.price.toString());
    await page.fill('[data-testid="product-quantity"]', testProduct.quantity.toString());
    await page.fill('[data-testid="product-sku"]', testProduct.sku);
    
    // Select category
    await page.selectOption('[data-testid="product-category"]', { index: 1 });
    
    // Save product
    await page.click('[data-testid="save-product"]');
    await expect(page.locator('text=Product created successfully')).toBeVisible();

    // Verify product in list
    await expect(page.locator(`text=${testProduct.name}`)).toBeVisible();

    // Edit product
    await page.click(`[data-testid="edit-${testProduct.sku}"]`);
    await page.fill('[data-testid="product-name"]', `${testProduct.name} - Updated`);
    await page.click('[data-testid="save-product"]');
    await expect(page.locator('text=Product updated successfully')).toBeVisible();

    // Delete product
    await page.click(`[data-testid="delete-${testProduct.sku}"]`);
    await page.click('[data-testid="confirm-delete"]');
    await expect(page.locator('text=Product deleted successfully')).toBeVisible();
  });

  test('Admin can manage orders', async ({ page }) => {
    // Navigate to orders management
    await page.click('[data-testid="admin-menu"]');
    await page.click('text=Orders');
    await expect(page).toHaveURL('/admin/orders');

    // Verify orders are displayed
    await expect(page.locator('[data-testid="order-row"]').first()).toBeVisible();

    // Update order status
    await page.click('[data-testid="order-row"]').first();
    await page.selectOption('[data-testid="order-status"]', 'shipped');
    await page.click('[data-testid="update-status"]');
    await expect(page.locator('text=Order status updated')).toBeVisible();
  });

  test('Admin can view analytics', async ({ page }) => {
    // Navigate to dashboard
    await page.click('[data-testid="admin-menu"]');
    await page.click('text=Dashboard');
    await expect(page).toHaveURL('/admin');

    // Verify analytics widgets
    await expect(page.locator('[data-testid="total-orders"]')).toBeVisible();
    await expect(page.locator('[data-testid="total-revenue"]')).toBeVisible();
    await expect(page.locator('[data-testid="total-products"]')).toBeVisible();
    await expect(page.locator('[data-testid="total-users"]')).toBeVisible();
  });
});
