import React, { useEffect, useState } from 'react';
import { ordersAPI } from '../../services/api';
import { confirmDialog, alertDialog, promptDialog } from '../../utils/dialogs';
import toast from 'react-hot-toast';

const Orders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const res = await ordersAPI.getAllOrders();
      setOrders(res.data || []);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const handleUpdate = async (id) => {
    const status = promptDialog('Enter new status (e.g., processing, shipped, delivered, cancelled):');
    if (!status) return;
    try {
      await ordersAPI.updateOrder(id, { status });
      toast.success('Order updated');
      load();
    } catch (err) {}
  };

  const handleCancel = async (id) => {
    if (!confirmDialog('Cancel this order?')) return;
    try {
      await ordersAPI.cancelOrder(id);
      toast.success('Order cancelled');
      load();
    } catch (err) {}
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Manage Orders</h1>
        <div className="bg-white rounded-lg shadow-md p-6">
          {loading ? (
            <p>Loading...</p>
          ) : (
            <table className="w-full table-auto">
              <thead>
                <tr className="text-left">
                  <th className="px-4 py-2">ID</th>
                  <th className="px-4 py-2">User</th>
                  <th className="px-4 py-2">Total</th>
                  <th className="px-4 py-2">Status</th>
                  <th className="px-4 py-2">Actions</th>
                </tr>
              </thead>
              <tbody>
                {orders.map(o => (
                  <tr key={o.id} className="border-t">
                    <td className="px-4 py-2">{o.id}</td>
                    <td className="px-4 py-2">{o.user?.email || o.user_email || '-'}</td>
                    <td className="px-4 py-2">{o.total || '-'}</td>
                    <td className="px-4 py-2">{o.status || '-'}</td>
                    <td className="px-4 py-2">
                      <button onClick={() => handleUpdate(o.id)} className="mr-2 px-3 py-1 bg-yellow-400 rounded">Update</button>
                      <button onClick={() => handleCancel(o.id)} className="px-3 py-1 bg-red-500 text-white rounded">Cancel</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      </div>
    </div>
  );
};

export default Orders;
