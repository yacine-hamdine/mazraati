const { fetchProducts, createProduct, updateProduct, removeProduct } = require('../services/products.service');

// Fetching All Products
exports.getProducts = async (res) => {
    try {
      const result = await fetchProducts();
      res.status(200).json(result);
    } catch (error) {
      res.status(error.status || 500).json({ message: error.message || 'Server error' });
    }
  };

// Creating a Product
exports.setProduct = async (req, res) => {
  try {
    const user = req.user.id;
    const { name, category, image, price, stock, discounts } = req.body;
    const result = await createProduct(user, name, category, image, price, stock, discounts);
    res.status(201).json(result);
  } catch (error) {
    res.status(error.status || 500).json({ message: error.message || 'Server error' });
  }
};

// Updating a Product
exports.putProduct = async (req, res) => {
  try {
    const user = req.user.id;
    const { id } = req.params;
    const { image, price, stock, discounts } = req.body;
    const result = await updateProduct(id, user, image, price, stock, discounts);
    res.status(200).json(result);
  } catch (error) {
    res.status(error.status || 500).json({ message: error.message || 'Server error' });
  }
};

// Deleting a Product
exports.deleteProduct = async (req, res) => {
  try {
    const user = req.user.id;
    const { id } = req.params;
    const result = await removeProduct(id, user);
    res.status(200).json(result);
  } catch (error) {
    res.status(error.status || 500).json({ message: error.message || 'Server error' });
  }
};
