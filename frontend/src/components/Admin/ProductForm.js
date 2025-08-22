import React, { useState, useEffect } from 'react';
import { getImageUrl } from '../../services/api';

const ProductForm = ({ product, categories = [], onCancel, onSubmit }) => {
  const [form, setForm] = useState({
    name: '',
    short_description: '',
    description: '',
    price: 0,
    compare_price: null,
    cost_price: null,
    sku: '',
    quantity: 0,
    category_id: null,
    is_active: true,
    is_featured: false,
  });

  const [files, setFiles] = useState([]);
  const [previewUrls, setPreviewUrls] = useState([]);

  useEffect(() => {
    if (product) {
      setForm({
        name: product.name || '',
        short_description: product.short_description || '',
        description: product.description || '',
        price: product.price || 0,
        compare_price: product.compare_price || null,
        cost_price: product.cost_price || null,
        sku: product.sku || '',
        quantity: product.quantity || 0,
        category_id: product.category_id || null,
        is_active: product.is_active ?? true,
        is_featured: product.is_featured ?? false,
      });

      // existing images
      if (product.images && product.images.length > 0) {
        setPreviewUrls(product.images.map(img => getImageUrl(img)));
      }
    } else {
      setForm(prev => ({ ...prev, name: '', sku: '', quantity: 0, price: 0 }));
      setPreviewUrls([]);
      setFiles([]);
    }
  }, [product]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm(prev => ({ ...prev, [name]: type === 'checkbox' ? checked : value }));
  };

  const handleFiles = (e) => {
    const selected = Array.from(e.target.files || []);
    setFiles(selected);
    const urls = selected.map(file => URL.createObjectURL(file));
    setPreviewUrls(prev => [...prev, ...urls]);
  };

  const submit = (e) => {
    e.preventDefault();
    // build payload
    const payload = {
      name: form.name,
      short_description: form.short_description,
      description: form.description,
      price: parseFloat(form.price) || 0,
      compare_price: form.compare_price ? parseFloat(form.compare_price) : null,
      cost_price: form.cost_price ? parseFloat(form.cost_price) : null,
      sku: form.sku,
      quantity: parseInt(form.quantity, 10) || 0,
      category_id: form.category_id || null,
      is_active: !!form.is_active,
      is_featured: !!form.is_featured,
    };

    onSubmit(payload, files);
  };

  return (
    <form onSubmit={submit} className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Name</label>
          <input name="name" value={form.name} onChange={handleChange} required className="mt-1 block w-full border px-3 py-2 rounded" />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">SKU</label>
          <input name="sku" value={form.sku} onChange={handleChange} required className="mt-1 block w-full border px-3 py-2 rounded" />
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Short Description</label>
        <input name="short_description" value={form.short_description} onChange={handleChange} className="mt-1 block w-full border px-3 py-2 rounded" />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Description</label>
        <textarea name="description" value={form.description} onChange={handleChange} rows={5} className="mt-1 block w-full border px-3 py-2 rounded" />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Price</label>
          <input name="price" value={form.price} onChange={handleChange} type="number" step="0.01" className="mt-1 block w-full border px-3 py-2 rounded" />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Compare Price</label>
          <input name="compare_price" value={form.compare_price || ''} onChange={handleChange} type="number" step="0.01" className="mt-1 block w-full border px-3 py-2 rounded" />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Cost Price</label>
          <input name="cost_price" value={form.cost_price || ''} onChange={handleChange} type="number" step="0.01" className="mt-1 block w-full border px-3 py-2 rounded" />
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">Quantity</label>
          <input name="quantity" value={form.quantity} onChange={handleChange} type="number" className="mt-1 block w-full border px-3 py-2 rounded" />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Category</label>
          <select name="category_id" value={form.category_id || ''} onChange={handleChange} className="mt-1 block w-full border px-3 py-2 rounded">
            <option value="">-- Select --</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </select>
        </div>
        <div className="flex items-center gap-4">
          <label className="flex items-center gap-2">
            <input type="checkbox" name="is_active" checked={form.is_active} onChange={handleChange} />
            <span className="text-sm">Active</span>
          </label>
          <label className="flex items-center gap-2">
            <input type="checkbox" name="is_featured" checked={form.is_featured} onChange={handleChange} />
            <span className="text-sm">Featured</span>
          </label>
        </div>
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700">Product Images</label>
        <input type="file" accept="image/*" multiple onChange={handleFiles} className="mt-1" />
        <div className="mt-2 flex gap-2 flex-wrap">
          {previewUrls.map((u, idx) => (
            <img key={idx} src={u} alt={`preview-${idx}`} className="w-24 h-24 object-cover rounded" />
          ))}
        </div>
      </div>

      <div className="flex justify-end gap-3">
        <button type="button" onClick={onCancel} className="px-4 py-2 border rounded">Cancel</button>
        <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded">Save Product</button>
      </div>
    </form>
  );
};

export default ProductForm;
