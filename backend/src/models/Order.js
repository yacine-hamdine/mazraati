const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  buyer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },

  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true,
  },

  sellerIndex: {
    type: Number,
    required: true,
  },

  quantity: {
    type: Number,
    required: true,
    min: 1,
  },

  pricePerUnit: {
    type: Number,
    required: true,
  },

  discountPercentage: {
    type: Number,
    default: 0,
  },

  totalPrice: {
    type: Number,
    required: true,
  },

  status: {
    type: String,
    enum: ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'],
    default: 'pending',
  },

//   paymentStatus: {
//     type: String,
//     enum: ['unpaid', 'paid', 'refunded'],
//     default: 'unpaid',
//   },

  deliveryInfo: {
    address: { type: String, required: true },
    expectedAt: { type: Date },
    deliveredAt: { type: Date },
  },

  createdAt: {
    type: Date,
    default: Date.now,
  }
});

module.exports = mongoose.model('Order', orderSchema);
