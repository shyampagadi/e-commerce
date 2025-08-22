import React, { useState, useEffect } from 'react';
import { getImageUrl } from '../../services/api';

const CategoryForm = ({ category, onCancel, onSubmit }) => {
  const [name, setName] = useState('');
  const [slug, setSlug] = useState('');
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState(null);

  useEffect(() => {
    if (category) {
      setName(category.name || '');
      setSlug(category.slug || '');
      if (category.image) setPreview(getImageUrl(category.image));
    } else {
      setName(''); setSlug(''); setFile(null); setPreview(null);
    }
  }, [category]);

  const handleFile = (e) => {
    const f = e.target.files?.[0] || null;
    setFile(f);
    if (f) setPreview(URL.createObjectURL(f));
  };

  const submit = (e) => {
    e.preventDefault();
    const payload = { name, slug };
    onSubmit(payload, file);
  };

  return (
    <form onSubmit={submit} className="space-y-4 bg-gray-50 p-4 rounded">
      <div>
        <label className="block text-sm font-medium text-gray-700">Name</label>
        <input value={name} onChange={(e) => setName(e.target.value)} required className="mt-1 block w-full border px-3 py-2 rounded" />
      </div>
      <div>
        <label className="block text-sm font-medium text-gray-700">Slug</label>
        <input value={slug} onChange={(e) => setSlug(e.target.value)} className="mt-1 block w-full border px-3 py-2 rounded" />
      </div>
      <div>
        <label className="block text-sm font-medium text-gray-700">Image</label>
        <input type="file" accept="image/*" onChange={handleFile} className="mt-1" />
        {preview && <img src={preview} alt="preview" className="mt-2 w-32 h-32 object-cover rounded" />}
      </div>
      <div className="flex justify-end gap-3">
        <button type="button" onClick={onCancel} className="px-4 py-2 border rounded">Cancel</button>
        <button type="submit" className="px-4 py-2 bg-blue-600 text-white rounded">Save</button>
      </div>
    </form>
  );
};

export default CategoryForm;
