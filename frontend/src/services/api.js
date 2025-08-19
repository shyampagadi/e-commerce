import axios from 'axios';
import Cookies from 'js-cookie';
import toast from 'react-hot-toast';

// Create axios instance
const api = axios.create({
  baseURL: process.env.REACT_APP_API_BASE_URL || 'http://localhost:8000/api/v1',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

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
    
    if (response?.status === 401) {
      // Unauthorized - clear token and redirect to login
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
      toast.error(response.data.detail);
    } else if (error.message === 'Network Error') {
      toast.error('Network error. Please check your connection.');
    } else {
      toast.error('An unexpected error occurred.');
    }
    
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  register: (userData) => api.post('/auth/register', userData),
  getProfile: () => api.get('/auth/me'),
  refreshToken: () => api.post('/auth/refresh'),
};

// Users API
export const usersAPI = {
  getUsers: (params) => api.get('/users/', { params }),
  getUser: (id) => api.get(`/users/${id}`),
  updateProfile: (data) => api.put('/users/profile', data),
  updateUser: (id, data) => api.put(`/users/${id}`, data),
  uploadAvatar: (id, file) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post(`/users/${id}/avatar`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
  deleteAvatar: (id) => api.delete(`/users/${id}/avatar`),
  deleteUser: (id) => api.delete(`/users/${id}`),
};

// Categories API
export const categoriesAPI = {
  getCategories: (params) => api.get('/categories/', { params }),
  getCategory: (id) => api.get(`/categories/${id}`),
  getCategoryBySlug: (slug) => api.get(`/categories/slug/${slug}`),
  createCategory: (data) => api.post('/categories/', data),
  updateCategory: (id, data) => api.put(`/categories/${id}`, data),
  uploadCategoryImage: (id, file) => {
    const formData = new FormData();
    formData.append('file', file);
    return api.post(`/categories/${id}/image`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
  deleteCategoryImage: (id) => api.delete(`/categories/${id}/image`),
  deleteCategory: (id) => api.delete(`/categories/${id}`),
};

// Products API
export const productsAPI = {
  getProducts: (params) => api.get('/products/', { params }),
  getFeaturedProducts: (params) => api.get('/products/featured', { params }),
  getProduct: (id) => api.get(`/products/${id}`),
  getProductBySlug: (slug) => api.get(`/products/slug/${slug}`),
  createProduct: (data) => api.post('/products/', data),
  updateProduct: (id, data) => api.put(`/products/${id}`, data),
  uploadProductImages: (id, files) => {
    const formData = new FormData();
    files.forEach((file) => {
      formData.append('files', file);
    });
    return api.post(`/products/${id}/images`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
  deleteProductImage: (id, imageIndex) => api.delete(`/products/${id}/images/${imageIndex}`),
  deleteProduct: (id) => api.delete(`/products/${id}`),
};

// Cart API
export const cartAPI = {
  getCart: () => api.get('/cart'),
  getCartSummary: () => api.get('/cart/summary'),
  addToCart: (data) => api.post('/cart/items', data),
  updateCartItem: (id, data) => api.put(`/cart/items/${id}`, data),
  removeFromCart: (id) => api.delete(`/cart/items/${id}`),
  clearCart: () => api.delete('/cart'),
};

// Orders API
export const ordersAPI = {
  getOrders: (params) => api.get('/orders/', { params }),
  getAllOrders: (params) => api.get('/orders/admin', { params }),
  getOrder: (id) => api.get(`/orders/${id}`),
  createOrder: (data) => api.post('/orders/', data),
  updateOrder: (id, data) => api.put(`/orders/${id}`, data),
  cancelOrder: (id) => api.delete(`/orders/${id}`),
};

// File upload helper
export const uploadFile = async (file, endpoint) => {
  const formData = new FormData();
  formData.append('file', file);
  
  return api.post(endpoint, formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  });
};

// Helper function to get image URL
export const getImageUrl = (imagePath) => {
  if (!imagePath) return null;
  if (imagePath.startsWith('http')) return imagePath;
  return `${process.env.REACT_APP_API_URL || 'http://localhost:8000'}/uploads/${imagePath}`;
};

export default api;
