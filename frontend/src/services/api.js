import axios from 'axios';
import Cookies from 'js-cookie';
import toast from 'react-hot-toast';

// Backend availability check
let BACKEND_AVAILABLE = true;

// Create axios instance
const api = axios.create({
  baseURL: process.env.REACT_APP_API_BASE_URL || 'http://localhost:8000/api/v1',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Check backend availability
const checkBackendAvailability = async () => {
  try {
    await axios.get(process.env.REACT_APP_API_URL || 'http://localhost:8000/health', { timeout: 5000 });
    BACKEND_AVAILABLE = true;
    console.log('✅ Backend is available');
  } catch (error) {
    BACKEND_AVAILABLE = false;
    console.log('⚠️ Backend not available, using fallback data');
  }
};

// Check on app start
checkBackendAvailability();

// Fallback data
const FALLBACK_DATA = {
  products: [
    { id: 1, name: "Sample Laptop", price: 999.99, description: "Demo laptop", image: null, category: "Electronics" },
    { id: 2, name: "Sample Phone", price: 599.99, description: "Demo phone", image: null, category: "Electronics" },
    { id: 3, name: "Sample Shirt", price: 29.99, description: "Demo shirt", image: null, category: "Clothing" }
  ],
  categories: [
    { id: 1, name: "Electronics", slug: "electronics" },
    { id: 2, name: "Clothing", slug: "clothing" }
  ],
  user: { id: 1, email: "demo@example.com", name: "Demo User", is_admin: false }
};

// Request interceptor to add auth token
api.interceptors.request.use(
  (config) => {
    const token = Cookies.get('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor to handle errors
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    const { response } = error;
    
    // Check if backend is down
    if (!response && (error.code === 'ECONNREFUSED' || error.message === 'Network Error')) {
      BACKEND_AVAILABLE = false;
      toast.error('Backend not available. Using demo data.');
      return Promise.reject(error);
    }
    
    if (response?.status === 401) {
      Cookies.remove('access_token');
      Cookies.remove('user');
      window.location.href = '/login';
      toast.error('Session expired. Please login again.');
    } else if (response?.status === 403) {
      toast.error('You do not have permission to perform this action.');
    } else if (response?.status === 404) {
      toast.error('Resource not found.');
    } else if (response?.status >= 500) {
      toast.error('Server error. Please try again later.');
    } else if (response?.data?.detail) {
      const detail = response.data.detail;
      let msg = '';
      if (typeof detail === 'string') {
        msg = detail;
      } else if (Array.isArray(detail)) {
        msg = detail.map(d => (d && d.msg) ? d.msg : JSON.stringify(d)).join('; ');
      } else {
        msg = JSON.stringify(detail);
      }
      toast.error(msg);
    } else {
      toast.error('An unexpected error occurred.');
    }
    
    return Promise.reject(error);
  }
);

// Helper function to return fallback data when backend is down
const withFallback = async (apiCall, fallbackData) => {
  if (!BACKEND_AVAILABLE) {
    return { data: fallbackData };
  }
  try {
    return await apiCall();
  } catch (error) {
    if (!error.response) {
      BACKEND_AVAILABLE = false;
      return { data: fallbackData };
    }
    throw error;
  }
};

// Auth API
export const authAPI = {
  login: (credentials) => withFallback(
    () => api.post('/auth/login', credentials),
    { access_token: 'demo-token', user: FALLBACK_DATA.user }
  ),
  register: (userData) => withFallback(
    () => api.post('/auth/register', userData),
    { message: 'Demo registration successful', user: FALLBACK_DATA.user }
  ),
  getProfile: () => withFallback(
    () => api.get('/auth/me'),
    FALLBACK_DATA.user
  ),
  refreshToken: () => withFallback(
    () => api.post('/auth/refresh'),
    { access_token: 'demo-token' }
  ),
};

// Products API
export const productsAPI = {
  getProducts: (params) => withFallback(
    () => api.get('/products/', { params }),
    { products: FALLBACK_DATA.products, total: 3, page: 1, per_page: 20, pages: 1 }
  ),
  getFeaturedProducts: (params) => withFallback(
    () => api.get('/products/featured', { params }),
    { products: FALLBACK_DATA.products.slice(0, 2) }
  ),
  getProduct: (id) => withFallback(
    () => api.get(`/products/${id}`),
    FALLBACK_DATA.products.find(p => p.id == id) || FALLBACK_DATA.products[0]
  ),
  getProductBySlug: (slug) => withFallback(
    () => api.get(`/products/slug/${slug}`),
    FALLBACK_DATA.products[0]
  ),
  createProduct: (data) => withFallback(
    () => api.post('/products/', data),
    { ...data, id: Date.now() }
  ),
  updateProduct: (id, data) => withFallback(
    () => api.put(`/products/${id}`, data),
    { ...data, id }
  ),
  deleteProduct: (id) => withFallback(
    () => api.delete(`/products/${id}`),
    { message: 'Product deleted (demo)' }
  ),
};

// Categories API
export const categoriesAPI = {
  getCategories: (params) => withFallback(
    () => api.get('/categories/', { params }),
    FALLBACK_DATA.categories
  ),
  getCategory: (id) => withFallback(
    () => api.get(`/categories/${id}`),
    FALLBACK_DATA.categories.find(c => c.id == id) || FALLBACK_DATA.categories[0]
  ),
  getCategoryBySlug: (slug) => withFallback(
    () => api.get(`/categories/slug/${slug}`),
    FALLBACK_DATA.categories.find(c => c.slug === slug) || FALLBACK_DATA.categories[0]
  ),
};

// Cart API
export const cartAPI = {
  getCart: () => withFallback(
    () => api.get('/cart'),
    { items: [], total: 0 }
  ),
  getCartSummary: () => withFallback(
    () => api.get('/cart/summary'),
    { items_count: 0, total: 0 }
  ),
  addToCart: (data) => withFallback(
    () => api.post('/cart/items', data),
    { message: 'Added to cart (demo)', item: data }
  ),
  updateCartItem: (id, data) => withFallback(
    () => api.put(`/cart/items/${id}`, data),
    { message: 'Cart updated (demo)' }
  ),
  removeFromCart: (id) => withFallback(
    () => api.delete(`/cart/items/${id}`),
    { message: 'Removed from cart (demo)' }
  ),
  clearCart: () => withFallback(
    () => api.delete('/cart'),
    { message: 'Cart cleared (demo)' }
  ),
};

// Orders API
export const ordersAPI = {
  getOrders: (params) => withFallback(
    () => api.get('/orders/', { params }),
    []
  ),
  getAllOrders: (params) => withFallback(
    () => api.get('/orders/admin', { params }),
    []
  ),
  getOrder: (id) => withFallback(
    () => api.get(`/orders/${id}`),
    { id, status: 'pending', items: [], total: 0 }
  ),
  createOrder: (data) => withFallback(
    () => api.post('/orders/', data),
    { id: Date.now(), status: 'pending', ...data }
  ),
};

// Users API
export const usersAPI = {
  getUsers: (params) => withFallback(
    () => api.get('/users/', { params }),
    [FALLBACK_DATA.user]
  ),
  updateProfile: (data) => withFallback(
    () => api.put('/users/profile', data),
    { ...FALLBACK_DATA.user, ...data }
  ),
};

// Helper function to get image URL
export const getImageUrl = (imagePath) => {
  if (!imagePath) return null;
  if (imagePath.startsWith('http')) return imagePath;
  return `${process.env.REACT_APP_API_URL || 'http://localhost:8000'}/uploads/products/${imagePath}`;
};

export default api;
