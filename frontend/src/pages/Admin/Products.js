import React, { useEffect, useState } from 'react';
import { productsAPI, categoriesAPI, getImageUrl } from '../../services/api';
import { confirmDialog } from '../../utils/dialogs';
import ProductForm from '../../components/Admin/ProductForm';
import toast from 'react-hot-toast';

const Products = () => {
  const [products, setProducts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [pRes, cRes] = await Promise.all([
        productsAPI.getProducts().catch(() => ({ data: { products: [] } })),
        categoriesAPI.getCategories().catch(() => ({ data: [] })),
      ]);

      const fetchedProducts = pRes.data && pRes.data.products ? pRes.data.products : Array.isArray(pRes.data) ? pRes.data : [];
      setProducts(fetchedProducts);
      setCategories(Array.isArray(cRes.data) ? cRes.data : []);
    } catch (err) {
      console.error('Error loading products:', err);
      toast.error('Failed to load products');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleCreate = () => {
    setEditingProduct(null);
    setShowForm(true);
  };

  const handleEdit = (product) => {
    setEditingProduct(product);
    setShowForm(true);
  };

  const handleDelete = async (product) => {
    if (!confirmDialog(`Delete product "${product.name}"? This cannot be undone.`)) return;
    try {
      await productsAPI.deleteProduct(product.id);
      toast.success('Product deleted');
      fetchData();
    } catch (err) {
      console.error('Delete error:', err);
      toast.error('Failed to delete product');
    }
  };

  const handleSubmit = async (formData, files) => {
    try {
      if (editingProduct) {
        await productsAPI.updateProduct(editingProduct.id, formData);
        if (files && files.length > 0) {
          await productsAPI.uploadProductImages(editingProduct.id, files);
        }
        toast.success('Product updated');
      } else {
        const res = await productsAPI.createProduct(formData);
        const created = res.data;
        if (files && files.length > 0) {
          await productsAPI.uploadProductImages(created.id, files);
        }
        toast.success('Product created');
      }

      setShowForm(false);
      setEditingProduct(null);
      fetchData();
    } catch (err) {
      console.error('Save error:', err);
      const detail = err.response?.data?.detail || 'Failed to save product';
      toast.error(detail);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-3xl font-bold text-gray-900">Manage Products</h1>
          <div>
            <button
              onClick={handleCreate}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
            >
              + Create Product
            </button>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          {loading ? (
            <div className="p-8 text-center">Loading products...</div>
          ) : (
            <div className="p-4">
              <table className="w-full table-auto">
                <thead>
                  <tr className="text-left text-sm text-gray-600">
                    <th className="px-4 py-2">Product</th>
                    <th className="px-4 py-2">SKU</th>
                    <th className="px-4 py-2">Category</th>
                    <th className="px-4 py-2">Price</th>
                    <th className="px-4 py-2">Qty</th>
                    <th className="px-4 py-2">Active</th>
                    <th className="px-4 py-2">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {products.map((p) => (
                    <tr key={p.id} className="border-t">
                      <td className="px-4 py-3 flex items-center gap-3">
                        <div className="w-12 h-12 bg-gray-100 rounded overflow-hidden">
                          {p.images && p.images.length > 0 ? (
                            <img src={getImageUrl(p.images[0])} alt={p.name} className="w-full h-full object-cover" />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center text-gray-400">📦</div>
                          )}
                        </div>
                        <div>
                          <div className="font-medium">{p.name}</div>
                          <div className="text-sm text-gray-500">{p.short_description}</div>
                        </div>
                      </td>
                      <td className="px-4 py-3 text-sm">{p.sku}</td>
                      <td className="px-4 py-3 text-sm">{p.category?.name || '—'}</td>
                      <td className="px-4 py-3 text-sm">${p.price?.toFixed(2)}</td>
                      <td className="px-4 py-3 text-sm">{p.quantity}</td>
                      <td className="px-4 py-3 text-sm">{p.is_active ? 'Yes' : 'No'}</td>
                      <td className="px-4 py-3 text-sm">
                        <div className="flex gap-2">
                          <button onClick={() => handleEdit(p)} className="px-3 py-1 bg-yellow-100 rounded">Edit</button>
                          <button onClick={() => handleDelete(p)} className="px-3 py-1 bg-red-100 rounded">Delete</button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        {showForm && (
          <div className="fixed inset-0 bg-black/40 flex items-start justify-center p-6">
            <div className="w-full max-w-3xl bg-white rounded-lg shadow-lg p-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-xl font-semibold">{editingProduct ? 'Edit Product' : 'Create Product'}</h2>
                <button onClick={() => { setShowForm(false); setEditingProduct(null); }} className="text-gray-600">Close</button>
              </div>
              <ProductForm
                product={editingProduct}
                categories={categories}
                onCancel={() => { setShowForm(false); setEditingProduct(null); }}
                onSubmit={handleSubmit}
              />
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default Products;
