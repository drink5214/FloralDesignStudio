import React from 'react';

const Home = () => {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="text-center">
        <h1 className="text-4xl font-serif tracking-tight text-gray-900 sm:text-5xl md:text-6xl">
          Welcome to Floral Design Studio
        </h1>
        <p className="mt-3 max-w-md mx-auto text-base text-gray-500 sm:text-lg md:mt-5 md:text-xl md:max-w-3xl">
          Creating beautiful floral arrangements for weddings, events, and special occasions.
        </p>
      </div>
      
      <div className="mt-16 grid grid-cols-1 gap-8 md:grid-cols-2 lg:grid-cols-3">
        <div className="relative rounded-lg overflow-hidden shadow-lg">
          <div className="h-64 bg-gray-200"></div>
          <div className="p-6">
            <h3 className="text-lg font-medium text-gray-900">Wedding Bouquets</h3>
            <p className="mt-2 text-sm text-gray-500">Custom designed bouquets for your special day</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;