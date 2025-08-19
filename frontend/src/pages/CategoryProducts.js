import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { getImageUrl } from '../services/api';

const CategoryProducts = () => {
  const { slug } = useParams();
  const [category, setCategory] = useState(null);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCategoryAndProducts = async () => {
      try {
        console.log('Fetching category and products for slug:', slug);
        setLoading(true);
        
        // Fetch category details
        const categoryResponse = await fetch(`http://localhost:8000/api/v1/categories/slug/${slug}`);
        
        if (!categoryResponse.ok) {
          throw new Error(`Category not found: ${categoryResponse.status}`);
        }
        
        const categoryData = await categoryResponse.json();
        console.log('Category data:', categoryData);
        setCategory(categoryData);
        
        // Fetch products for this category
        const productsResponse = await fetch(`http://localhost:8000/api/v1/products/?category_id=${categoryData.id}`);
        
        if (!productsResponse.ok) {
          throw new Error(`Products fetch failed: ${productsResponse.status}`);
        }
        
        const productsData = await productsResponse.json();
        console.log('Products data:', productsData);
        
        if (productsData && productsData.products) {
          setProducts(productsData.products);
          console.log('🚀 CACHE BUSTER - Products loaded at:', new Date().toISOString());
          console.log('Products loaded:', productsData.products.length);
          
          // Debug each product in detail
          productsData.products.forEach((product, index) => {
            console.log(`🔍 Product ${index + 1} DEBUG:`, {
              id: product.id,
              name: product.name,
              slug: product.slug,
              images: product.images,
              imagesType: typeof product.images,
              imagesLength: product.images ? product.images.length : 0,
              hasImages: !!(product.images && product.images.length > 0)
            });
          });
        } else {
          setProducts([]);
        }
        
        setError(null);
      } catch (error) {
        console.error('Error fetching category data:', error);
        setError(error.message);
      } finally {
        setLoading(false);
      }
    };

    if (slug) {
      fetchCategoryAndProducts();
    }
  }, [slug]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading category products...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center py-12">
            <div className="text-red-500 text-6xl mb-4">❌</div>
            <h1 className="text-2xl font-bold text-gray-900 mb-4">Error Loading Category</h1>
            <p className="text-gray-600 mb-6">Error: {error}</p>
            <Link
              to="/categories"
              className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              ← Back to Categories
            </Link>
          </div>
        </div>
      </div>
    );
  }

  if (!category) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center py-12">
            <div className="text-gray-400 text-6xl mb-4">❌</div>
            <h1 className="text-2xl font-bold text-gray-900 mb-4">Category Not Found</h1>
            <p className="text-gray-600 mb-6">The category you're looking for doesn't exist.</p>
            <Link
              to="/categories"
              className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              ← Back to Categories
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Breadcrumb */}
        <nav className="flex items-center space-x-2 text-sm text-gray-600 mb-6">
          <Link to="/" className="hover:text-blue-600">Home</Link>
          <span>/</span>
          <Link to="/categories" className="hover:text-blue-600">Categories</Link>
          <span>/</span>
          <span className="text-gray-900 font-medium">{category.name}</span>
        </nav>

        {/* Category Header */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">{category.name}</h1>
              <p className="text-gray-600 mb-4">{category.description}</p>
              <p className="text-sm text-gray-500">
                {products.length} {products.length === 1 ? 'product' : 'products'} available
              </p>
            </div>
            <Link
              to="/categories"
              className="inline-flex items-center px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors"
            >
              ← All Categories
            </Link>
          </div>
        </div>

        {/* Products Grid */}
        {products.length === 0 ? (
          <div className="text-center py-12">
            <div className="text-gray-400 text-6xl mb-4">📦</div>
            <h2 className="text-xl font-semibold text-gray-900 mb-2">No Products Found</h2>
            <p className="text-gray-600 mb-6">
              There are no products available in the {category.name} category at the moment.
            </p>
            <Link
              to="/products"
              className="inline-flex items-center px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
            >
              Browse All Products
            </Link>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {products.map((product, index) => {
              console.log(`🖼️ RENDERING Product ${index + 1}:`, product.name);
              console.log(`🖼️ Images for ${product.name}:`, product.images);
              
              const hasImages = product.images && product.images.length > 0;
              const imageUrl = hasImages ? getImageUrl(product.images[0]) : 'https://via.placeholder.com/300x200?text=No+Image';
              
              console.log(`🖼️ Image URL for ${product.name}:`, imageUrl);
              console.log(`🖼️ Has images: ${hasImages}`);
              
              return (
                <Link
                  key={product.id}
                  to={`/products/${product.slug}`}
                  className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1"
                >
                  <div className="h-48 overflow-hidden bg-gray-100">
                    <img
                      src={imageUrl}
                      alt={product.name}
                      className="w-full h-full object-cover"
                      onLoad={() => {
                        console.log(`✅ SUCCESS: Image loaded for ${product.name}`);
                        console.log(`✅ Image URL that worked: ${imageUrl}`);
                      }}
                      onError={(e) => {
                        console.error(`❌ FAILED: Image failed for ${product.name}`);
                        console.error(`❌ Failed URL: ${e.target.src}`);
                        e.target.src = 'https://via.placeholder.com/300x200?text=No+Image';
                      }}
                    />
                  </div>
                <div className="p-4">
                  <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2">
                    {product.name}
                  </h3>
                  {product.short_description && (
                    <p className="text-sm text-gray-600 mb-3 line-clamp-2">
                      {product.short_description}
                    </p>
                  )}
                  <div className="flex items-center justify-between">
                    <div className="flex flex-col">
                      <span className="text-xl font-bold text-blue-600">
                        ${product.price}
                      </span>
                      {product.compare_price && product.compare_price > product.price && (
                        <span className="text-sm text-gray-500 line-through">
                          ${product.compare_price}
                        </span>
                      )}
                    </div>
                    {product.is_featured && (
                      <span className="bg-yellow-100 text-yellow-800 text-xs font-medium px-2 py-1 rounded">
                        Featured
                      </span>
                    )}
                  </div>
                  <div className="mt-3 flex items-center justify-between text-sm text-gray-500">
                    <span>Stock: {product.quantity}</span>
                    {product.track_quantity && product.quantity < 10 && (
                      <span className="text-orange-600 font-medium">Low Stock</span>
                    )}
                  </div>
                </div>
              </Link>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default CategoryProducts;
