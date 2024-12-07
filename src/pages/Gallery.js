import React from 'react';

const Gallery = () => {
  const arrangements = [
    { id: 1, title: 'Wedding Bouquet', description: 'Classic white and pink roses' },
    { id: 2, title: 'Table Centerpiece', description: 'Modern mixed flower arrangement' },
    { id: 3, title: 'Event Display', description: 'Large-scale floral installation' },
    { id: 4, title: 'Bridal Package', description: 'Complete wedding flower set' },
    { id: 5, title: 'Seasonal Arrangement', description: 'Fresh spring flowers' },
    { id: 6, title: 'Custom Design', description: 'Unique floral creation' },
  ];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <h1 className="text-4xl font-serif text-center mb-12">Our Work</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {arrangements.map((arrangement) => (
          <div key={arrangement.id} className="rounded-lg overflow-hidden shadow-lg">
            <div className="h-64 bg-gray-200"></div>
            <div className="p-6">
              <h3 className="text-lg font-medium text-gray-900">{arrangement.title}</h3>
              <p className="mt-2 text-sm text-gray-500">{arrangement.description}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Gallery;