import React, { useEffect, useState } from 'react';
import { categoriesAPI } from '../../services/api';
import { confirmDialog } from '../../utils/dialogs';
import toast from 'react-hot-toast';
import CategoryForm from '../../components/Admin/CategoryForm';

const Categories = () => {
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [editing, setEditing] = useState(null);
  const [showForm, setShowForm] = useState(false);

  const load = async () => {
    setLoading(true);
    try {
      const res = await categoriesAPI.getCategories();
      setCategories(res.data || []);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { load(); }, []);

  const handleCreate = () => {
    setEditing(null);
    setShowForm(true);
  };

  const handleEdit = (c) => {
    setEditing(c);
    setShowForm(true);
  };

  const handleDelete = async (id) => {
    if (!confirmDialog('Delete this category?')) return;
    try {
      await categoriesAPI.deleteCategory(id);
      toast.success('Category deleted');
      load();
    } catch (err) {
      // errors handled by interceptor
    }
  };

  const handleSubmit = async (data, file) => {
    try {
      if (editing) {
        await categoriesAPI.updateCategory(editing.id, data);
        if (file) {
          await categoriesAPI.uploadCategoryImage(editing.id, file);
        }
        toast.success('Category updated');
      } else {
        const res = await categoriesAPI.createCategory(data);
        const newId = res.data?.id;
        if (file && newId) await categoriesAPI.uploadCategoryImage(newId, file);
        toast.success('Category created');
      }
      setShowForm(false);
      load();
    } catch (err) {
      // handled by interceptor
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-3xl font-bold text-gray-900">Manage Categories</h1>
          <button onClick={handleCreate} className="px-4 py-2 bg-blue-600 text-white rounded">New Category</button>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          {showForm ? (
            <div>
              <CategoryForm category={editing} onCancel={() => setShowForm(false)} onSubmit={handleSubmit} />
            </div>
          ) : (
            <div>
              {loading ? (
                <p>Loading...</p>
              ) : (
                <table className="w-full table-auto">
                  <thead>
                    <tr className="text-left">
                      <th className="px-4 py-2">ID</th>
                      <th className="px-4 py-2">Name</th>
                      <th className="px-4 py-2">Slug</th>
                      <th className="px-4 py-2">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {categories.map((c) => (
                      <tr key={c.id} className="border-t">
                        <td className="px-4 py-2">{c.id}</td>
                        <td className="px-4 py-2">{c.name}</td>
                        <td className="px-4 py-2">{c.slug || '-'}</td>
                        <td className="px-4 py-2">
                          <button onClick={() => handleEdit(c)} className="mr-2 px-3 py-1 bg-yellow-400 rounded">Edit</button>
                          <button onClick={() => handleDelete(c.id)} className="px-3 py-1 bg-red-500 text-white rounded">Delete</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Categories;
