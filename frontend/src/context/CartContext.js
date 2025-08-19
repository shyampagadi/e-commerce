import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { cartAPI } from '../services/api';
import { useAuth } from './AuthContext';
import toast from 'react-hot-toast';

// Initial state
const initialState = {
  items: [],
  totalItems: 0,
  subtotal: 0,
  isLoading: false,
  error: null,
};

// Action types
const CART_ACTIONS = {
  FETCH_CART_START: 'FETCH_CART_START',
  FETCH_CART_SUCCESS: 'FETCH_CART_SUCCESS',
  FETCH_CART_FAILURE: 'FETCH_CART_FAILURE',
  ADD_TO_CART_START: 'ADD_TO_CART_START',
  ADD_TO_CART_SUCCESS: 'ADD_TO_CART_SUCCESS',
  ADD_TO_CART_FAILURE: 'ADD_TO_CART_FAILURE',
  UPDATE_CART_ITEM_START: 'UPDATE_CART_ITEM_START',
  UPDATE_CART_ITEM_SUCCESS: 'UPDATE_CART_ITEM_SUCCESS',
  UPDATE_CART_ITEM_FAILURE: 'UPDATE_CART_ITEM_FAILURE',
  REMOVE_FROM_CART_START: 'REMOVE_FROM_CART_START',
  REMOVE_FROM_CART_SUCCESS: 'REMOVE_FROM_CART_SUCCESS',
  REMOVE_FROM_CART_FAILURE: 'REMOVE_FROM_CART_FAILURE',
  CLEAR_CART_START: 'CLEAR_CART_START',
  CLEAR_CART_SUCCESS: 'CLEAR_CART_SUCCESS',
  CLEAR_CART_FAILURE: 'CLEAR_CART_FAILURE',
  CLEAR_ERROR: 'CLEAR_ERROR',
};

// Reducer
const cartReducer = (state, action) => {
  switch (action.type) {
    case CART_ACTIONS.FETCH_CART_START:
    case CART_ACTIONS.ADD_TO_CART_START:
    case CART_ACTIONS.UPDATE_CART_ITEM_START:
    case CART_ACTIONS.REMOVE_FROM_CART_START:
    case CART_ACTIONS.CLEAR_CART_START:
      return {
        ...state,
        isLoading: true,
        error: null,
      };

    case CART_ACTIONS.FETCH_CART_SUCCESS:
      return {
        ...state,
        items: action.payload.items,
        totalItems: action.payload.total_items,
        subtotal: action.payload.subtotal,
        isLoading: false,
        error: null,
      };

    case CART_ACTIONS.ADD_TO_CART_SUCCESS:
      // Refresh cart after adding item
      return {
        ...state,
        isLoading: false,
        error: null,
      };

    case CART_ACTIONS.UPDATE_CART_ITEM_SUCCESS:
      return {
        ...state,
        items: state.items.map(item =>
          item.id === action.payload.id ? action.payload : item
        ),
        isLoading: false,
        error: null,
      };

    case CART_ACTIONS.REMOVE_FROM_CART_SUCCESS:
      return {
        ...state,
        items: state.items.filter(item => item.id !== action.payload),
        isLoading: false,
        error: null,
      };

    case CART_ACTIONS.CLEAR_CART_SUCCESS:
      return {
        ...state,
        items: [],
        totalItems: 0,
        subtotal: 0,
        isLoading: false,
        error: null,
      };

    case CART_ACTIONS.FETCH_CART_FAILURE:
    case CART_ACTIONS.ADD_TO_CART_FAILURE:
    case CART_ACTIONS.UPDATE_CART_ITEM_FAILURE:
    case CART_ACTIONS.REMOVE_FROM_CART_FAILURE:
    case CART_ACTIONS.CLEAR_CART_FAILURE:
      return {
        ...state,
        isLoading: false,
        error: action.payload,
      };

    case CART_ACTIONS.CLEAR_ERROR:
      return {
        ...state,
        error: null,
      };

    default:
      return state;
  }
};

// Create context
const CartContext = createContext();

// Cart provider component
export const CartProvider = ({ children }) => {
  const [state, dispatch] = useReducer(cartReducer, initialState);
  const { isAuthenticated } = useAuth();

  // Fetch cart when user is authenticated
  useEffect(() => {
    if (isAuthenticated) {
      fetchCart();
    } else {
      // Clear cart when user logs out
      dispatch({ type: CART_ACTIONS.CLEAR_CART_SUCCESS });
    }
  }, [isAuthenticated]);

  // Fetch cart function
  const fetchCart = async () => {
    try {
      dispatch({ type: CART_ACTIONS.FETCH_CART_START });
      
      const response = await cartAPI.getCart();
      
      dispatch({
        type: CART_ACTIONS.FETCH_CART_SUCCESS,
        payload: response.data,
      });
    } catch (error) {
      dispatch({
        type: CART_ACTIONS.FETCH_CART_FAILURE,
        payload: error.response?.data?.detail || 'Failed to fetch cart',
      });
    }
  };

  // Add to cart function
  const addToCart = async (data) => {
    // Support both object format and separate parameters
    const productId = data.product_id || data;
    const quantity = data.quantity || 1;
    
    if (!isAuthenticated) {
      toast.error('Please login to add items to cart');
      return { success: false };
    }

    try {
      dispatch({ type: CART_ACTIONS.ADD_TO_CART_START });
      
      await cartAPI.addToCart({ product_id: productId, quantity });
      
      dispatch({ type: CART_ACTIONS.ADD_TO_CART_SUCCESS });
      
      // Refresh cart to get updated data
      await fetchCart();
      
      toast.success('Item added to cart!');
      return { success: true };
    } catch (error) {
      const errorMessage = error.response?.data?.detail || 'Failed to add item to cart';
      
      dispatch({
        type: CART_ACTIONS.ADD_TO_CART_FAILURE,
        payload: errorMessage,
      });
      
      toast.error(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Update cart item function
  const updateCartItem = async (itemId, quantity) => {
    try {
      dispatch({ type: CART_ACTIONS.UPDATE_CART_ITEM_START });
      
      const response = await cartAPI.updateCartItem(itemId, { quantity });
      
      dispatch({
        type: CART_ACTIONS.UPDATE_CART_ITEM_SUCCESS,
        payload: response.data,
      });
      
      // Refresh cart to get updated totals
      await fetchCart();
      
      toast.success('Cart updated!');
      return { success: true };
    } catch (error) {
      const errorMessage = error.response?.data?.detail || 'Failed to update cart item';
      
      dispatch({
        type: CART_ACTIONS.UPDATE_CART_ITEM_FAILURE,
        payload: errorMessage,
      });
      
      toast.error(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Remove from cart function
  const removeFromCart = async (itemId) => {
    try {
      dispatch({ type: CART_ACTIONS.REMOVE_FROM_CART_START });
      
      await cartAPI.removeFromCart(itemId);
      
      dispatch({
        type: CART_ACTIONS.REMOVE_FROM_CART_SUCCESS,
        payload: itemId,
      });
      
      // Refresh cart to get updated totals
      await fetchCart();
      
      toast.success('Item removed from cart!');
      return { success: true };
    } catch (error) {
      const errorMessage = error.response?.data?.detail || 'Failed to remove item from cart';
      
      dispatch({
        type: CART_ACTIONS.REMOVE_FROM_CART_FAILURE,
        payload: errorMessage,
      });
      
      toast.error(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Clear cart function
  const clearCart = async () => {
    try {
      dispatch({ type: CART_ACTIONS.CLEAR_CART_START });
      
      await cartAPI.clearCart();
      
      dispatch({ type: CART_ACTIONS.CLEAR_CART_SUCCESS });
      
      toast.success('Cart cleared!');
      return { success: true };
    } catch (error) {
      const errorMessage = error.response?.data?.detail || 'Failed to clear cart';
      
      dispatch({
        type: CART_ACTIONS.CLEAR_CART_FAILURE,
        payload: errorMessage,
      });
      
      toast.error(errorMessage);
      return { success: false, error: errorMessage };
    }
  };

  // Get cart item count
  const getCartItemCount = () => {
    return state.totalItems;
  };

  // Check if product is in cart
  const isInCart = (productId) => {
    return state.items.some(item => item.product_id === productId);
  };

  // Get cart item by product ID
  const getCartItem = (productId) => {
    return state.items.find(item => item.product_id === productId);
  };

  // Clear error function
  const clearError = () => {
    dispatch({ type: CART_ACTIONS.CLEAR_ERROR });
  };

  const value = {
    ...state,
    fetchCart,
    addToCart,
    updateCartItem,
    removeFromCart,
    clearCart,
    getCartItemCount,
    isInCart,
    getCartItem,
    clearError,
  };

  return (
    <CartContext.Provider value={value}>
      {children}
    </CartContext.Provider>
  );
};

// Custom hook to use cart context
export const useCart = () => {
  const context = useContext(CartContext);
  
  if (!context) {
    throw new Error('useCart must be used within a CartProvider');
  }
  
  return context;
};

export default CartContext;
