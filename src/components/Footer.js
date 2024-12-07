import React from 'react';

const Footer = () => {
  return (
    <footer className="bg-gray-800 text-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div>
            <h3 className="text-lg font-medium mb-4">Floral Design Studio</h3>
            <p className="text-gray-300">
              Creating beautiful floral arrangements for all occasions.
            </p>
          </div>
          <div>
            <h3 className="text-lg font-medium mb-4">Contact</h3>
            <p className="text-gray-300">
              Email: contact@floraldesignstudio.com<br />
              Phone: (555) 123-4567
            </p>
          </div>
          <div>
            <h3 className="text-lg font-medium mb-4">Follow Us</h3>
            <div className="flex space-x-4">
              <a href="#" className="text-gray-300 hover:text-white">Instagram</a>
              <a href="#" className="text-gray-300 hover:text-white">Facebook</a>
              <a href="#" className="text-gray-300 hover:text-white">Pinterest</a>
            </div>
          </div>
        </div>
        <div className="mt-8 border-t border-gray-700 pt-8 text-center text-gray-300">
          © {new Date().getFullYear()} Floral Design Studio. All rights reserved.
        </div>
      </div>
    </footer>
  );
};

export default Footer;