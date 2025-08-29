import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { ordersAPI, getImageUrl } from '../services/api';
import LoadingSpinner from '../components/UI/LoadingSpinner';
import toast from 'react-hot-toast';

const OrderDetail = () => {
  const { id } = useParams();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchOrder = async () => {
      try {
        setLoading(true);
        const res = await ordersAPI.getOrder(id);
        setOrder(res.data);
      } catch (err) {
        console.error('Error fetching order:', err);
        toast.error('Failed to load order details');
      } finally {
        setLoading(false);
      }
    };

    fetchOrder();
  }, [id]);

  if (loading) return (
    <div className="min-h-screen flex items-center justify-center">
      <LoadingSpinner size="lg" text="Loading order..." />
    </div>
  );

  if (!order) return (
    <div className="min-h-screen flex items-center justify-center">
      <p className="text-gray-500">Order not found.</p>
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-4">Order #{order.order_number || order.id}</h1>
        <p className="text-sm text-gray-600 mb-6">Placed on {new Date(order.created_at).toLocaleString()}</p>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2 bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">Items</h2>
            <div className="space-y-4">
              {order.order_items && order.order_items.length > 0 ? (
                order.order_items.map((item) => (
                  <div key={item.id} className="flex items-center justify-between border-b pb-4">
                    <div className="flex items-center gap-4">
                      <div className="w-16 h-16 bg-gray-100 rounded overflow-hidden">
                        {item.product_image ? (
                          <img 
                            src={getImageUrl(item.product_image)} 
                            alt={item.product_name} 
                            className="w-full h-full object-cover" 
                          />
                        ) : (
                          <div className="w-full h-full flex items-center justify-center text-gray-400">
                            📦
                          </div>
                        )}
                      </div>
                      <div>
                        <div className="font-medium text-gray-900">{item.product_name}</div>
                        <div className="text-sm text-gray-600">SKU: {item.product_sku}</div>
                        <div className="text-sm text-gray-600">Qty: {item.quantity}</div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="font-semibold text-gray-900">${item.total_price.toFixed(2)}</div>
                      <div className="text-sm text-gray-500">${item.unit_price.toFixed(2)} each</div>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-gray-500">
                  No items found in this order.
                </div>
              )}
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold mb-4">Order Summary</h2>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-600">Subtotal</span>
                <span className="font-medium">${order.subtotal ? order.subtotal.toFixed(2) : '0.00'}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Shipping</span>
                <span className="font-medium">${order.shipping_amount ? order.shipping_amount.toFixed(2) : '0.00'}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Tax</span>
                <span className="font-medium">${order.tax_amount ? order.tax_amount.toFixed(2) : '0.00'}</span>
              </div>
              {order.discount_amount > 0 && (
                <div className="flex justify-between text-green-600">
                  <span>Discount</span>
                  <span>-${order.discount_amount.toFixed(2)}</span>
                </div>
              )}
              <div className="flex justify-between border-t pt-3 font-semibold text-lg">
                <span>Total</span>
                <span>${order.total_amount ? order.total_amount.toFixed(2) : '0.00'}</span>
              </div>
            </div>

            <div className="mt-6 space-y-4">
              <div>
                <h3 className="text-sm font-medium text-gray-700 mb-1">Status</h3>
                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                  order.status === 'delivered' ? 'bg-green-100 text-green-800' :
                  order.status === 'shipped' ? 'bg-blue-100 text-blue-800' :
                  order.status === 'processing' ? 'bg-yellow-100 text-yellow-800' :
                  order.status === 'cancelled' ? 'bg-red-100 text-red-800' :
                  'bg-gray-100 text-gray-800'
                }`}>
                  {order.status ? order.status.charAt(0).toUpperCase() + order.status.slice(1) : 'Pending'}
                </span>
              </div>

              <div>
                <h3 className="text-sm font-medium text-gray-700 mb-1">Payment Status</h3>
                <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                  order.payment_status === 'paid' ? 'bg-green-100 text-green-800' :
                  order.payment_status === 'failed' ? 'bg-red-100 text-red-800' :
                  'bg-yellow-100 text-yellow-800'
                }`}>
                  {order.payment_status ? order.payment_status.charAt(0).toUpperCase() + order.payment_status.slice(1) : 'Pending'}
                </span>
              </div>

              {order.tracking_number && (
                <div>
                  <h3 className="text-sm font-medium text-gray-700 mb-1">Tracking Number</h3>
                  <p className="text-sm text-gray-900 font-mono">{order.tracking_number}</p>
                </div>
              )}

              <div>
                <h3 className="text-sm font-medium text-gray-700 mb-1">Shipping Address</h3>
                <div className="text-sm text-gray-600">
                  <p>{order.shipping_first_name} {order.shipping_last_name}</p>
                  <p>{order.shipping_address}</p>
                  <p>{order.shipping_city}, {order.shipping_state} {order.shipping_zip_code}</p>
                  <p>{order.shipping_country}</p>
                </div>
              </div>

              <div>
                <h3 className="text-sm font-medium text-gray-700 mb-1">Contact</h3>
                <div className="text-sm text-gray-600">
                  <p>{order.customer_email}</p>
                  {order.customer_phone && <p>{order.customer_phone}</p>}
                </div>
              </div>

              {order.notes && (
                <div>
                  <h3 className="text-sm font-medium text-gray-700 mb-1">Notes</h3>
                  <p className="text-sm text-gray-600">{order.notes}</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default OrderDetail;
