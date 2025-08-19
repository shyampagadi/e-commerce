import React from 'react';
import { useParams } from 'react-router-dom';

const OrderDetail = () => {
  const { id } = useParams();
  
  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Order #{id}</h1>
        <div className="bg-white rounded-lg shadow-md p-6">
          <p className="text-gray-600">Order details will be displayed here.</p>
        </div>
      </div>
    </div>
  );
};

export default OrderDetail;
