import { expect } from '@playwright/test';
import { testUsers } from './users.js';

export class AuthHelper {
  constructor(page) {
    this.page = page;
  }

  async loginAsAdmin() {
    await this.login(testUsers.admin);
  }

  async loginAsUser() {
    await this.login(testUsers.user);
  }

  async login(user) {
    await this.page.goto('/login');
    await this.page.fill('[data-testid="email"]', user.email);
    await this.page.fill('[data-testid="password"]', user.password);
    await this.page.click('[data-testid="login-button"]');
    
    // Wait for successful login
    await expect(this.page).toHaveURL(/\/(?!login)/);
  }

  async logout() {
    await this.page.click('[data-testid="user-menu"]');
    await this.page.click('[data-testid="logout-button"]');
    await expect(this.page).toHaveURL('/');
  }

  async register(userData) {
    await this.page.goto('/register');
    await this.page.fill('[data-testid="email"]', userData.email);
    await this.page.fill('[data-testid="password"]', userData.password);
    await this.page.fill('[data-testid="firstName"]', userData.firstName);
    await this.page.fill('[data-testid="lastName"]', userData.lastName);
    await this.page.click('[data-testid="register-button"]');
    
    // Wait for successful registration
    await expect(this.page).toHaveURL(/\/(?!register)/);
  }
}
