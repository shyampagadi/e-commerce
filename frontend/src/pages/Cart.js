import React from 'react';
import { Link } from 'react-router-dom';
import { TrashIcon } from '@heroicons/react/24/outline';
import { useCart } from '../context/CartContext';
import { useAuth } from '../context/AuthContext';
import { getImageUrl } from '../services/api';

const Cart = () => {
  const { items, totalItems, subtotal, isLoading, updateCartItem, removeFromCart } = useCart();
  const { isAuthenticated } = useAuth();

  const updateQuantity = async (itemId, newQuantity) => {
    if (newQuantity === 0) {
      await removeFromCart(itemId);
      return;
    }
    await updateCartItem(itemId, newQuantity);
  };

  const removeItem = async (itemId) => {
    await removeFromCart(itemId);
  };

  // Show login message if not authenticated
  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center py-12">
            <h1 className="text-3xl font-bold text-gray-900 mb-4">Please Login</h1>
            <p className="text-gray-600 mb-8">You need to login to view your cart.</p>
            <Link
              to="/login"
              className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors duration-200"
            >
              Login
            </Link>
          </div>
        </div>
      </div>
    );
  }

  // Show loading state
  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center py-12">
            <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading your cart...</p>
          </div>
        </div>
      </div>
    );
  }

  // Show empty cart
  if (!items || items.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center py-12">
            <h1 className="text-3xl font-bold text-gray-900 mb-4">Your Cart is Empty</h1>
            <p className="text-gray-600 mb-8">Add some products to get started!</p>
            <Link
              to="/products"
              className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors duration-200"
            >
              Continue Shopping
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Shopping Cart</h1>
        
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="p-6">
            {items.map(item => {
              const product = item.product;
              const imageUrl = product?.images && product.images.length > 0 
                ? getImageUrl(product.images[0]) 
                : 'https://via.placeholder.com/100x100?text=No+Image';

              return (
                <div key={item.id} className="flex items-center py-4 border-b border-gray-200 last:border-b-0">
                  <img
                    src={imageUrl}
                    alt={product?.name || 'Product'}
                    className="w-16 h-16 object-cover rounded-lg mr-4"
                    onError={(e) => {
                      console.error(`Failed to load image: ${e.target.src}`);
                      e.target.src = 'https://via.placeholder.com/100x100?text=No+Image';
                    }}
                  />
                  
                  <div className="flex-1">
                    <h3 className="text-lg font-semibold text-gray-900">
                      {product?.name || 'Unknown Product'}
                    </h3>
                    <p className="text-gray-600">
                      ${product?.price ? product.price.toFixed(2) : '0.00'}
                    </p>
                    {product?.is_in_stock === false && (
                      <p className="text-red-600 text-sm">Out of stock</p>
                    )}
                  </div>
                  
                  <div className="flex items-center gap-4">
                    <div className="flex items-center">
                      <button
                        onClick={() => updateQuantity(item.id, item.quantity - 1)}
                        className="px-2 py-1 border border-gray-300 rounded-l-md hover:bg-gray-50 disabled:opacity-50"
                        disabled={isLoading}
                      >
                        -
                      </button>
                      <span className="px-4 py-1 border-t border-b border-gray-300 bg-gray-50">
                        {item.quantity}
                      </span>
                      <button
                        onClick={() => updateQuantity(item.id, item.quantity + 1)}
                        className="px-2 py-1 border border-gray-300 rounded-r-md hover:bg-gray-50 disabled:opacity-50"
                        disabled={isLoading}
                      >
                        +
                      </button>
                    </div>
                    
                    <p className="text-lg font-semibold text-gray-900 w-20 text-right">
                      ${product?.price ? (product.price * item.quantity).toFixed(2) : '0.00'}
                    </p>
                    
                    <button
                      onClick={() => removeItem(item.id)}
                      className="text-red-600 hover:text-red-800 p-2 disabled:opacity-50"
                      disabled={isLoading}
                    >
                      <TrashIcon className="h-5 w-5" />
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
          
          <div className="bg-gray-50 px-6 py-4">
            <div className="flex justify-between items-center mb-4">
              <div>
                <p className="text-sm text-gray-600">
                  {totalItems} {totalItems === 1 ? 'item' : 'items'} in cart
                </p>
                <span className="text-xl font-semibold text-gray-900">
                  Total: ${subtotal ? subtotal.toFixed(2) : '0.00'}
                </span>
              </div>
            </div>
            
            <div className="flex gap-4">
              <Link
                to="/products"
                className="flex-1 bg-gray-200 text-gray-800 px-6 py-3 rounded-lg hover:bg-gray-300 transition-colors duration-200 text-center"
              >
                Continue Shopping
              </Link>
              <Link
                to="/checkout"
                className="flex-1 bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors duration-200 text-center"
              >
                Proceed to Checkout
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Cart;
