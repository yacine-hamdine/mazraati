const Product = require('../models/Product');
const User = require('../models/User'); // <-- Add this import

exports.fetchProducts = async () => {
  const products = await Product.find({});
  return products;
};

exports.createProduct = async (user, name, category, image, price, stock, discounts) => {
  // Fetch user info for name
  const userDoc = await User.findById(user);
  const sellerName = userDoc ? `${userDoc.firstName} ${userDoc.lastName}`.trim() : '';

  let product = await Product.findOne({ name, category });

  if (product) {
    // Check if this user already listed this product
    const sellerIndex = product.sellers.findIndex(s => s._id.toString() === user);

    if (sellerIndex !== -1) {
      // User already listed it – update the existing offer
      product.sellers[sellerIndex] = { 
        _id: user, 
        name: sellerName, // <-- Add seller name here
        image, 
        price, 
        stock, 
        discounts 
      };
    } else {
      // New seller – add to sellers array
      product.sellers.push({ 
        _id: user, 
        name: sellerName, // <-- Add seller name here
        image, 
        price, 
        stock, 
        discounts 
      });
    }

    await product.save();
  } else {
    // New product entry
    product = new Product({
      name,
      category,
      sellers: [{
        _id: user,
        name: sellerName, // <-- Add seller name here
        image,
        price,
        stock,
        discounts
      }]
    });
    await product.save();
  }

  return product;
};

exports.updateProduct = async (id, user, image, price, stock, discounts) => {
  const product = await Product.findById(id);
  if (!product) throw new Error('Product not found');

  // Fetch user info for name
  const userDoc = await User.findById(user);
  const sellerName = userDoc ? `${userDoc.firstName} ${userDoc.lastName}`.trim() : '';

  const sellerIndex = product.sellers.findIndex(s => s._id.toString() === user);
  if (sellerIndex === -1) throw new Error('Seller offer not found for this product');

  // Only update the seller's offer
  product.sellers[sellerIndex] = {
    ...product.sellers[sellerIndex],
    _id: user,
    name: sellerName, // <-- Add seller name here
    image,
    price,
    stock,
    discounts
  };

  await product.save();
  return product;
};

exports.removeProduct = async (id, user) => {
  const product = await Product.findById(id);
  if (!product) throw new Error('Product not found');

  // Remove only the seller's offer
  product.sellers = product.sellers.filter(s => s._id.toString() !== user);

  if (product.sellers.length === 0) {
    // No sellers left – remove the product
    await product.deleteOne();
    return { deleted: true };
  }

  await product.save();
  return { deleted: false, product };
};
